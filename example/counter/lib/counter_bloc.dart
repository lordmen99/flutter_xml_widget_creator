
import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';

class CounterBloc implements Bloc {
  final _streamController = StreamController<int>();
  Stream<int> get stream => _streamController.stream;
  Sink<int> get sink => _streamController.sink;


  @override
  void dispose() async {
    await _streamController.close();
  }

}