
import 'dart:io';

import 'package:recase/recase.dart';
import 'code_writer.dart';
import 'xml_parser.dart';

void convertFile(String path) async {
  final file = File(path);
  final dir = Directory(path);

  final fExists = await file.exists();
  final dExists = await dir.exists();

  if (!fExists && !dExists) {
    print("File or Directory doesn't exist:" + path);
    return;
  }
  if (dExists) {
    _createRecursive(dir);
  } else {
    _create(path);
  }
}
void _createRecursive(Directory dir) async {
  var dirList = await dir.list().toList();
  for (final f in dirList) {
    if (f is File) {
      if (f.path.endsWith(".xml")) {
        _create(f.path);
      }
    } else if (f is Directory) {
      _createRecursive(f);
    }
  }
}

String getWidgetClassNameFromPath(String path) {
  final file = File(path);
  var xmlFileName = file.uri.pathSegments.last;
  var fileName = xmlFileName;
  final dot = fileName.indexOf(".");
  if (dot >= 0) {
    fileName = fileName.substring(0, dot);
  }
  return ReCase(fileName).pascalCase;
}
void _create(String path) {
  final file = File(path);
  final className =getWidgetClassNameFromPath(path);

  final layout = parseLayoutFile(path);
  final code = convertToCode(className, layout);

  final outPath = path.replaceAll(".xml", ".dart");
  File(outPath).writeAsStringSync(code);
  print("Created:" + outPath);

  Process.run("flutter", ["format", outPath], runInShell: true).then((s) {
    print(s.stdout);
    print(s.stderr);
  });
}
String convertXml(String className, String xmlText) {
  final layout = parseLayoutXml(xmlText);
  return convertToCode(className, layout);
}