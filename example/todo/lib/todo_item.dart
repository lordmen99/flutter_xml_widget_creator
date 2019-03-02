//Created from xml
import 'package:flutter/material.dart';
import 'package:todo/entities.dart';
import 'dart:async';

Widget buildTodoItem({
  Key key,
  @required Todo item,
  @required Sink<int> toggleSink,
  @required Sink<int> delSink,
}) {
  return Row(key: key, children: [
    Checkbox(
        value: item.done,
        onChanged: (v) {
          toggleSink.add(item.id);
        }),
    Expanded(
      flex: 1,
      child: Text(item.text),
    ),
    FlatButton(
        onPressed: () {
          delSink.add(item.id);
        },
        child: Text('DEL')),
  ]);
}
