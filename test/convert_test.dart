import 'dart:io';
import 'dart:async';
import "package:test/test.dart";
import 'package:xml_widget_creator/xml_widget_creator.dart';

const _tempDartFile = "test/temp.dart";

void main() {
  group("WidgetNameTest", () {
    test("name", () {
      expect(
          getWidgetClassNameFromPath("./hoge/counter.xml"), equals("Counter"));
    });
    test("name_number", () {
      expect(getWidgetClassNameFromPath("./hoge/counter2.xml"),
          equals("Counter2"));
    });
    test("name_pascal_case", () {
      expect(getWidgetClassNameFromPath("./dir_path/counter_widget.xml"),
          equals("CounterWidget"));
    });
    test("name_pascal_case_2", () {
      expect(getWidgetClassNameFromPath("./dir/counter_item_widget.xml"),
          equals("CounterItemWidget"));
    });
  });
  group("ConvertTest", () {
    tearDownAll(() {
      File(_tempDartFile).delete();
    });
    testConvert("Counter1", "counter1");
    testConvert("Counter2", "counter2");
    testConvert("Padding", "padding");
    testConvert("Expanded", "expanded");
  });
}

void testConvert(String testName, String baseFileName) {
  test(testName, () {
    final xmlFile = "./test/" + baseFileName + ".xml";
    final dartFile = "./test/" + baseFileName + ".dart";
    expect(_convert(xmlFile), completion(equals(_readFile(dartFile))));
  });
}

String _readFile(String path) {
  return File(path).readAsStringSync();
}

Future<String> _convert(String xmlPath) async {
  final file = File(xmlPath);
  final className = getWidgetClassNameFromPath(xmlPath);
  final xmlText = file.readAsStringSync();
  final converted = convertXml(className, xmlText);
  //to format code, write code to temp file
  final outPath = _tempDartFile;
  final outFile = File(outPath);
  outFile.writeAsStringSync(converted);

  await Process.run("flutter", ["format", outPath], runInShell: true);

  return outFile.readAsStringSync();
}
