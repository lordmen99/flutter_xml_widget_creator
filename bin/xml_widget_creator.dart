import 'package:args/args.dart';
import 'package:xml_widget_creator/src/widget_creator.dart';

void main(List<String> args) async {
  final parser = new ArgParser();

  final argResults = parser.parse(args);
  final paths = argResults.rest;
  if (paths.length == 0) {
    print("pub run xml_widget_creator[input xml file or dir]");
    return;
  }
  final path = paths[0];
  convertFile(path);
}
