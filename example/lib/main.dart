import 'package:flutter/material.dart';

import 'messaging.dart';
import 'src/app.dart';
import 'src/pages/todo/logic/create_todo_message.dart';
import 'src/pages/todo/logic/todo_local_repository.dart';
import 'src/pages/todo/logic/todo_notifier.dart';
import 'src/pages/todo/logic/todo_remote_repository.dart';

void main() async {
  _addSubscribers();
  await messaging.start();
  runApp(const MyApp());
}

void _addSubscribers() {
  messaging.subscribe(TodoLocalRepository(), to: CreateTodoMessage);
  messaging.subscribe(TodoRemoteRepository(), to: CreateTodoMessage);
  messaging.subscribe(TodoNotifier(), to: CreateTodoMessage);
}
