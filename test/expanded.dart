//Created from xml
import 'package:flutter/material.dart';
import 'dart:async';

Widget buildExpanded({
  Key key,
}) {
  return Row(key: key, children: [
    Expanded(
      flex: 1,
      child: Text('A'),
    ),
    Expanded(
      flex: 2,
      child: Text('B'),
    ),
    Text('C'),
  ]);
}
