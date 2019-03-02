import 'package:bloc_provider/bloc_provider.dart';
import 'package:counter/counter_bloc.dart';
import 'package:counter/counter_widget.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'XML Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocProvider<CounterBloc>(
          creator: (context, bag) => CounterBloc(),
          child: MainWidget(),
        ));
  }
}

class MainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
        appBar: AppBar(title: Text("Counter"),),
        body: buildCounterWidget(count: bloc.stream, sink: bloc.sink));
  }
}
