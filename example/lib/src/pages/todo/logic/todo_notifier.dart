import 'package:messaging/messaging.dart';

import '../../../../messaging.dart';
import 'create_todo_message.dart';
import 'todo.dart';

class TodoNotifier implements MessagingSubscriber {
  static TodoNotifier? _instance;

  factory TodoNotifier() {
    _instance ??= TodoNotifier._();

    return _instance!;
  }
  TodoNotifier._() {
    messaging.subscribe(this, to: CreateTodoMessage);
  }
  @override
  String get subscriberKey => '$TodoNotifier';

  Future<void> notifyCreate(Todo todo) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> onMessage(Message message) async {
    if (message is CreateTodoMessage) {
      await toastCreate(message.todo);
      await notifyCreate(message.todo);
    }
  }

  Future<void> toastCreate(Todo todo) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
