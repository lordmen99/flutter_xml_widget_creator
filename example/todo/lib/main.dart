import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:todo/todo_bloc.dart';
import 'package:todo/todo_item.dart';
import 'package:todo/todo_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocProvider<TodoBloc>(
          creator: (context, bag) => TodoBloc(),
          child: TodoListPage(),
        ));
  }
}

//to change textfield value, use statefulwidget (for textcontroller).
class TodoListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends State<TodoListPage> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<TodoBloc>(context);

    return buildTodoList(
      list: bloc.todoList,
      addTodoSink: bloc.addTodo,
      textController: _textController,
      itemBuilder: (list, index) {
        if (index >= list.length) {
          return null;
        }
        final item = list[index];
        return buildTodoItem(
          key: Key(item.id.toString()),
          item: item,
          delSink: bloc.removeTodo,
          toggleSink: bloc.toggleTodo,
        );
      },
    );
  }
}
