import 'entities.dart';

String convertToCode(String className, Layout layout) {
  _raiseStreamListener(layout);

  var out = "//Created from xml\n";
  out += _convertImport(layout);
  out += "\n";

  //class & var declaration
  out += "Widget build" + className + "({\n";
  out += "  Key key,\n";
  for (final s in layout.streams) {
    out += "  @required Stream<" + s.typeName + "> " + s.name + ",\n";
  }
  for (final v in layout.variables) {
    out += "  @required " + v.typeName + " " + v.name + ",\n";
  }
  out += "}) {\n";
  //build
  final widgetCode = _convertWidget(layout, layout.rootWidget, "  ", [], true);
  out += "  return " + widgetCode.substring(2); //remove first indent
  out += ";\n";
  out += "}\n";
  return out;
}

void _raiseStreamListener(Layout layout) {
  Widget w = layout.rootWidget;
  for (final s in layout.streams) {
    final listeners = _findStreamListener(w, s.name);
    final common = _findCommonAncestor(w, listeners);
    _removeRequiredStreamRecursive(w, s.name);
    common.requireStreamNames.add(s.name);
  }
}

List<Widget> _findStreamListener(Widget widget, String streamName) {
  var ret = List<Widget>();
  if (widget.requireStreamNames.contains(streamName)) {
    ret.add(widget);
  }
  for (final c in widget.children) {
    final r = _findStreamListener(c, streamName);
    ret.addAll(r);
  }
  for (final c in widget.children) {
    final r = _findStreamListener(c, streamName);
    ret.addAll(r);
  }
  for (final c in widget.attrWidget.values) {
    final r = _findStreamListener(c, streamName);
    ret.addAll(r);
  }
  return ret;
}

Widget _findCommonAncestor(Widget widget, List<Widget> widgets) {
  for (final c in widget.children) {
    final w = _findCommonAncestor(c, widgets);
    if (w != null) {
      return w;
    }
  }
  for (final c in widget.attrWidget.values) {
    final w = _findCommonAncestor(c, widgets);
    if (w != null) {
      return w;
    }
  }

  for (var w in widgets) {
    while (true) {
      if (w == widget) {
        break;
      }
      if (w == null) {
        return null;
      }
      w = w.parent;
    }
  }
  return widget;
}

void _removeRequiredStreamRecursive(Widget w, String streamName) {
  w.requireStreamNames.remove(streamName);
  for (final c in w.children) {
    _removeRequiredStreamRecursive(c, streamName);
  }
  for (final c in w.attrWidget.values) {
    _removeRequiredStreamRecursive(c, streamName);
  }
}

String _convertImport(Layout layout) {
  var out = "";
  List<Import> imports = layout.imports;
  //add material as default
  if (imports.length == 0) {
    imports.add(Import("package:flutter/material.dart"));
  }

  bool hasAsync = false;
  for (var i in layout.imports) {
    out += "import '" + i.pkgName + "';\n";
    if (i.pkgName == "dart:async") {
      hasAsync = true;
    }
  }
  if (!hasAsync && layout.streams.length > 0) {
    out += "import 'dart:async';\n";
  }
  return out;
}

String _convertWidget(Layout layout, Widget widget, String indent,
    List<String> declaredStreams, bool isTopWidget) {
  var buildStreams = List<String>();
  for (final s in widget.requireStreamNames) {
    if (!declaredStreams.contains(s)) {
      buildStreams.add(s);
    }
  }
  //wrap special-widget
  if (buildStreams.length > 0) {
    return _wrapStream(
        layout, widget, indent, declaredStreams, isTopWidget, buildStreams);
  }
  if (widget.attrMap["padding"] != null) {
    return _wrapPadding(layout, widget, indent, declaredStreams, isTopWidget);
  }
  if (widget.attrMap["flex"] != null) {
    return _wrapExpand(layout, widget, indent, declaredStreams, isTopWidget);
  }

  //write down this widget
  var out = "";
  if (widget.attrMap.length == 0 &&
      widget.children.length == 0 &&
      widget.attrWidget.length == 0) {
    out += indent + widget.name + "()\n";
    return out;
  }
  out += indent + widget.name + "(\n";
  if (isTopWidget) {
    out += indent + "  key: key,\n";
  }

  final keys = widget.attrMap.keys.toList();
  for (var i = 0; i < keys.length; i += 1) {
    final key = keys[i];
    final value = widget.attrMap[key];
    if (key.startsWith("_")) {
      out += indent + "  " + value;
    } else {
      out += indent + "  " + key + ": " + value;
    }
    if (i < keys.length - 1) {
      out += ",\n";
    }
  }
  if (widget.children.length == 0 && widget.attrWidget.length == 0) {
    out += ")";
    return out;
  }
  if (widget.attrMap.length > 0) {
    out += ",\n";
  }
  //attr-widget
  if (widget.attrWidget.length > 0) {
    final count = widget.attrWidget.length;
    final keys = widget.attrWidget.keys.toList();
    for (var i = 0; i < count; i += 1) {
      final key = keys[i];
      final value = widget.attrWidget[key];
      final childCode =
          _convertWidget(layout, value, indent + "  ", declaredStreams, false);
      out += indent + "  " + key + ": " + childCode + ",\n";
    }
  }
  if (widget.children.length == 0) {
    out += ")";
    return out;
  }

  //child
  if (!widget.isMultiChild) {
    var childCode = _convertWidget(
        layout, widget.children[0], indent + "  ", declaredStreams, false);
    childCode = childCode.substring(indent.length + 2);
    out += indent + "  child: " + childCode;
    out += indent + ")";
  } else {
    out += indent + "  children: [\n";
    for (final c in widget.children) {
      final childCode =
          _convertWidget(layout, c, indent + "  ", declaredStreams, false);
      out += childCode + ",\n";
    }
    out += indent + "  ])";
  }

  return out;
}

//--------------------------------------
//wrap Stream
String _wrapStream(Layout layout, Widget widget, String indent,
    List<String> declaredStreams, bool isTopWidget, List<String> buildStreams) {
  var out = "";
  final st = layout.streams.where((s) => s.name == buildStreams[0]).first;
  var dec = List<String>();
  for (final d in declaredStreams) {
    dec.add(d);
  }
  dec.add(st.name);

  out += indent + "StreamBuilder<" + st.typeName + ">(\n";
  if (isTopWidget) {
    out += indent + "key: key,\n";
  }
  out += indent + "  stream: " + st.name + ",\n";
  if (st.initialData != null) {
    out += indent + "  initialData: " + st.initialData + ",\n";
  }
  out += indent + "  builder: (ctx, " + st.name + "SnapShot) {\n";
  var childCode = _convertWidget(layout, widget, indent + "    ", dec, false);
  childCode = childCode.substring(indent.length + 4) + ";\n";
  out += indent + "    return " + childCode;
  out += indent + "  })";
  return out;
}

//--------------------------------------
//wrap padding
String _wrapPadding(Layout layout, Widget widget, String indent,
    List<String> declaredStreams, bool isTopWidget) {
  var out = "";
  final padding = widget.attrMap["padding"];
  final nums = padding.split(" ").map((s) => double.parse(s.trim())).toList();
  if (nums.length == 0 || nums.length >= 5) {
    throw Exception(
        "Invalid padding format:" + padding + "  in " + widget.name);
  }
  //use css order(TRBL). differ from Flutter(LTRB)
  var idxs = [0, 0, 0, 0];
  if (nums.length == 2) {
    //(vert, horz)
    idxs = [1, 0, 1, 0];
  } else if (nums.length == 3) {
    //(top, horz, bottom)
    idxs = [1, 0, 1, 2];
  } else if (nums.length == 4) {
    //top, right, bottom, left
    idxs = [3, 0, 1, 2];
  }
  var padStr = "EdgeInsets.fromLTRB(";
  for (var i = 0; i < 4; i++) {
    final p = nums[idxs[i]];
    padStr += p.toString();
    if (i < 3) {
      padStr += ", ";
    } else {
      padStr += ")";
    }
  }

  //remove padding to avoid infinite recursive call
  widget.attrMap.remove("padding");

  out += indent + "Padding(\n";
  out += indent + "  padding: " + padStr + ",\n";
  var childCode =
      _convertWidget(layout, widget, indent + "    ", declaredStreams, false);
  childCode = childCode.substring(indent.length + 4) + ",\n";
  out += indent + "  child: " + childCode;
  out += ")";
  return out;
}
//--------------------------------------
//wrap padding
String _wrapExpand(Layout layout, Widget widget, String indent,
    List<String> declaredStreams, bool isTopWidget) {
  var out = "";
  final flex = int.parse(widget.attrMap["flex"]);
  //remove padding to avoid infinite recursive call
  widget.attrMap.remove("flex");

  if (flex <= 0) { //no-need expanded
    return _convertWidget(layout, widget, indent + "    ", declaredStreams, false);
  }
  out += indent + "Expanded(\n";
  out += indent + "  flex: " + flex.toString() + ",\n";
  var childCode =
      _convertWidget(layout, widget, indent + "    ", declaredStreams, false);
  childCode = childCode.substring(indent.length + 4) + ",\n";
  out += indent + "  child: " + childCode;
  out += ")";
  return out;
}
