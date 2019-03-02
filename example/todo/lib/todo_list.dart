//Created from xml
import 'package:flutter/material.dart';
import 'package:todo/entities.dart';
import 'dart:async';

Widget buildTodoList({
  Key key,
  @required Stream<List<Todo>> list,
  @required Sink<String> addTodoSink,
  @required Widget Function(List<Todo>, int) itemBuilder,
  @required TextEditingController textController,
}) {
  return Scaffold(
    key: key,
    appBar: AppBar(
      title: Text("Todo"),
    ),
    body: Padding(
      padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: Column(children: [
        Row(children: [
          Expanded(
            flex: 1,
            child: TextField(controller: textController),
          ),
          RaisedButton(
              onPressed: () {
                addTodoSink.add(textController.text);
                textController.text = '';
              },
              child: Text("Add")),
        ]),
        StreamBuilder<List<Todo>>(
            stream: list,
            initialData: List<Todo>(),
            builder: (ctx, listSnapShot) {
              return Expanded(
                flex: 1,
                child: ListView.builder(itemBuilder: (ctx, idx) {
                  return itemBuilder(listSnapShot.data, idx);
                }),
              );
            }),
      ]),
    ),
  );
}
