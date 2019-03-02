import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:todo/entities.dart';

class TodoBloc implements Bloc {
  final _listStream = StreamController<List<Todo>>();
  final _addStream = StreamController<String>();
  final _toggleStream = StreamController<int>();
  final _removeStream = StreamController<int>();

  Stream<List<Todo>> get todoList => _listStream.stream;

  Sink<String> get addTodo => _addStream.sink;
  Sink<int> get toggleTodo => _toggleStream.sink;
  Sink<int> get removeTodo => _removeStream.sink;

  //
  var _todoList = List<Todo>();
  var _subscriptions = List<StreamSubscription>();
  //
  TodoBloc() {
    _subscriptions.addAll([
      _addStream.stream.map((s) {
        _todoList.add(Todo(s));
        return _todoList;
      }).listen((list) {
        _listStream.sink.add(list);
      }),
      //
      _toggleStream.stream.map((id) {
        _todoList =
            _todoList.map((t) => t.id == id ? t.toggledCopy() : t).toList();
        return _todoList;
      }).listen(_listStream.sink.add),
      //
      _removeStream.stream.map((id) {
        _todoList = _todoList.where((t) => t.id != id).toList();
        return _todoList;
      }).listen(_listStream.sink.add)
    ]);
  }

  @override
  void dispose() async {
    await _listStream.close();
    await _addStream.close();
    await _toggleStream.close();
    await _removeStream.close();
    _subscriptions.forEach((s) {
      s.cancel();
    });
    _subscriptions.clear();
  }
}
