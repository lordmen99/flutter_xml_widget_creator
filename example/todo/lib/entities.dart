class Todo {
  static int _totalId = 1;
  final int id;
  final String text;
  final bool done;
  Todo._(this.id, this.text, this.done);

  factory Todo(String text) {
    _totalId += 1;
    return Todo._(_totalId, text, false);
  }
  Todo toggledCopy() {
    return Todo._(this.id, this.text, !this.done);
  }
}
