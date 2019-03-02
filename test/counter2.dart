//Created from xml
import 'package:flutter/material.dart';
import 'dart:async';

Widget buildCounter2({
  Key key,
  @required Stream<int> count,
  @required Sink<int> sink,
  @required ValueCallback<int> callback,
}) {
  return Scaffold(
    key: key,
    appBar: AppBar(
      title: Text('Counter'),
    ),
    body: Center(
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
                        child: Text('Use Sink(+1)')),
                    RaisedButton(
                        onPressed: () {
                          callback(countSnapShot.data);
                        },
                        child: Text("Use Callback(*2)")),
                  ]);
            })),
  );
}
