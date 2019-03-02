//Created from xml
import 'package:flutter/material.dart';
import 'dart:async';

Widget buildPadding({
  Key key,
}) {
  return Column(key: key, children: [
    Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: Text('A'),
    ),
    Padding(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: Text('B'),
    ),
    Padding(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 30.0),
      child: Text('C'),
    ),
    Padding(
      padding: EdgeInsets.fromLTRB(40.0, 10.0, 20.0, 30.0),
      child: Text('D'),
    ),
    Padding(
      padding: EdgeInsets.fromLTRB(4.0, 1.0, 2.0, 3.0),
      child: Text('E'),
    ),
  ]);
}
