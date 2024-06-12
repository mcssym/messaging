import 'package:messaging/messaging.dart';

import 'todo.dart';

class CreateTodoMessage extends Message {
  final Todo todo;

  const CreateTodoMessage(this.todo)
      : super(
          priority: 10,
        );
}
