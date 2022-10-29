import 'package:messaging/messaging.dart';

import '../../../../messaging.dart';
import 'create_todo_message.dart';
import 'todo.dart';

class TodoLocalRepository implements MessagingSubscriber {
  static TodoLocalRepository? _instance;

  factory TodoLocalRepository() {
    _instance ??= TodoLocalRepository._();

    return _instance!;
  }

  TodoLocalRepository._() {
    messaging.subscribe(this, to: CreateTodoMessage);
  }

  @override
  String get subscriberKey => '$TodoLocalRepository';

  Future<void> create(Todo todo) async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> onMessage(Message message) async {
    if (message is CreateTodoMessage) {
      await create(message.todo);
    }
  }
}
