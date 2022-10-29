import 'package:messaging/messaging.dart';

import '../../../../messaging.dart';
import 'create_todo_message.dart';
import 'todo.dart';

class TodoRemoteRepository implements MessagingSubscriber {
  static TodoRemoteRepository? _instance;

  factory TodoRemoteRepository() {
    _instance ??= TodoRemoteRepository._();

    return _instance!;
  }
  TodoRemoteRepository._() {
    messaging.subscribe(this, to: CreateTodoMessage);
  }

  @override
  String get subscriberKey => '$TodoRemoteRepository';

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
