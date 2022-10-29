import 'package:flutter/cupertino.dart';
import 'package:messaging/messaging.dart';

import '../../../../messaging.dart';
import 'create_todo_message.dart';
import 'todo.dart';

class TodoViewModel extends ChangeNotifier implements MessagingSubscriber {
  final List<Todo> _todos;

  TodoViewModel() : _todos = <Todo>[] {
    messaging.subscribe(this, to: CreateTodoMessage);
  }

  List<Todo> get todos => _todos;

  void add(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  @override
  Future<void> onMessage(Message message) async {
    if (message is CreateTodoMessage) {
      add(message.todo);
    }
  }

  @override
  String get subscriberKey => '$TodoViewModel';
}
