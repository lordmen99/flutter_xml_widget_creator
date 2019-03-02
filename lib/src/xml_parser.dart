import 'dart:async';
import 'dart:io';
import 'package:xml/xml.dart' as xml;
import 'entities.dart';

Layout parseLayoutFile(String xmlFilePath) {
  final txt = File(xmlFilePath).readAsStringSync();
  return parseLayoutXml(txt);
}
Layout parseLayoutXml(String xmlText) {
  final document = xml.parse(xmlText);
  return _paseLayout(document);
}
//-------------------------------------------------
//Parse Document basic info
Layout _paseLayout(xml.XmlDocument root) {
  final layout = Layout();

  final data = root.rootElement.findElements("data").first;
  layout.imports = _parseImports(data);
  layout.streams = _parseStreams(data);
  layout.variables = _parseVariables(data);

  for (var e in root.rootElement.children) {
    if (e is xml.XmlElement && e.name.toString() != "data") {
      layout.rootWidget = _parseWidget(e);
      break;
    }
  }
  return layout;
}

List<Import> _parseImports(xml.XmlElement dataNode) {
  final imp = dataNode.findAllElements("import");
  return imp.map((node) {
    final pkg = node.getAttribute("package");
    return Import(pkg);
  }).toList();
}

List<StreamData> _parseStreams(xml.XmlElement dataNode) {
  final stream = dataNode.findAllElements("stream");
  return stream.map((node) {
    final name = node.getAttribute("name");
    final typeName = node.getAttribute("type");
    final initial = node.getAttribute("initialData");
    return StreamData(name, typeName, initial);
  }).toList();
}

List<VariableData> _parseVariables(xml.XmlElement dataNode) {
  final variables = dataNode.findAllElements("var");
  return variables.map((node) {
    final name = node.getAttribute("name");
    final typeName = node.getAttribute("type");
    return VariableData(name, typeName);
  }).toList();
}

//----------------------------
List<String> _multiChildWidgets = [
  "Row", "Column", "Stack", "IndexedStack",
  "GridView",
];

Widget _parseWidget(xml.XmlElement elem) {
  final name = elem.name.toString();
  final attrs = elem.attributes;
  var attrMap = Map<String, String>();
  bool multiChild = _multiChildWidgets.contains(name);
  for (var attr in attrs) {
    if (attr.name.toString() == "multi_child") {
      multiChild = attr.text.toLowerCase() == "true";
    } else {
      attrMap[attr.name.toString()] = attr.value;
    }
  }
  final result = _parseRequireStreamNames(attrMap);
  final widget = Widget(name, result.convertedMap, multiChild);
  widget.requireStreamNames = result.requireNames;

  for (var c in elem.children) {
    if (c is xml.XmlElement) {
      final name = c.name.toString();
      final firstChar = name.codeUnitAt(0);
      if (firstChar >= "a".codeUnitAt(0) && firstChar <= "z".codeUnitAt(0)) {
        //act as attribute
        for (var cc in c.children) {
          if (cc is xml.XmlElement) {
            final w = _parseWidget(cc);
            widget.attrWidget[name] = w;
            w.parent = widget;
          }
        }
      } else {
        final w = _parseWidget(c);
        widget.children.add(w);
        w.parent = widget;
      }
    }
  }

  return widget;
}

class _RequireStreamResult {
  final List<String> requireNames;
  final Map<String, String> convertedMap;
  _RequireStreamResult(this.requireNames, this.convertedMap);
}

_RequireStreamResult _parseRequireStreamNames(Map<String, String> attrMap) {
  var streams = List<String>();
  var convertedMap = Map<String, String>();
  final reg = RegExp(r'\$\w+');

  for (var key in attrMap.keys) {
    var value = attrMap[key];
    reg.allMatches(value).forEach((s) {
      final part = value.substring(s.start, s.end);
      final name = part.substring(1);
      if (!streams.contains(name)) {
        streams.add(name);
      }
      value = value.replaceAll(part, name + "SnapShot.data");
    });
    convertedMap[key] = value;
  }
  return _RequireStreamResult(streams, convertedMap);
}
