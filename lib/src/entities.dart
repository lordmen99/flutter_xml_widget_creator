//root element
class Layout {
  List<Import> imports = [];
  List<StreamData> streams = [];
  List<VariableData> variables = [];
  Widget rootWidget = null;

  Layout();
}

//---------------------------------
class Widget {
  //class name
  final String name;
  //attributes, converted constructor parameter
  final Map<String, String> attrMap;
  //which attr to write child elements, child or children.
  final bool isMultiChild;
  //attributes described as Widget, such as Scaffold.appBar
  //key=attribute name, value=widget
  final Map<String, Widget> attrWidget = Map<String, Widget>();

  //using stream-name-list in this widget
  List<String> requireStreamNames = [];
  //child-list. also used when single-child
  List<Widget> children = [];
  //
  Widget parent;

  //constructor
  Widget(this.name, this.attrMap, this.isMultiChild);
}

class StreamData {
  final String name;
  final String typeName;
  final String initialData;
  StreamData(this.name, this.typeName, this.initialData);
}
class VariableData {
  final String name;
  final String typeName;
  VariableData(this.name, this.typeName);
}
class Import {
  final String pkgName;
  Import(this.pkgName);
}
