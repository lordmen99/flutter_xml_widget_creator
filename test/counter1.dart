//Created from xml
import 'package:flutter/material.dart';
import 'dart:async';

Widget buildCounter1({
  Key key,
  @required Stream<int> count,
  @required Sink<int> sink,
}) {
  return Center(
      key: key,
      child: StreamBuilder<int>(
          stream: count,
          initialData: 0,
          builder: (ctx, countSnapShot) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(countSnapShot.data.toString(),
                      style: TextStyle(color: Colors.red, fontSize: 16.0)),
                  RaisedButton(
                      onPressed: () {
                        sink.add(countSnapShot.data + 1);
                      },
                      child: Text('Count Up')),
                ]);
          }));
}
