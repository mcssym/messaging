import 'package:flutter/material.dart';
import '../../../messaging.dart';
import 'logic/create_todo_message.dart';

import 'logic/todo.dart';
import 'logic/todo_viewmodel.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final notifier = TodoViewModel();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _add();
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: notifier,
        builder: (context, child) => _TodoBody(
          todos: notifier.todos,
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: _AddButton(),
        ),
      ),
    );
  }

  void _add() {
    final todo = Todo.dummy();
    // We don't have to call every services like
    // TodoRemoteRepository().create(todo);
    // TodoLocalRepository().create(todo);
    // TodoNotifier().toastCreate(todo);
    // TodoNotifier().notifyCreate(todo);
    // notifier.add(todo);
    // just publish the message
    messaging.publish(CreateTodoMessage(todo));
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingNotifier = ValueNotifier(false);
    return ValueListenableBuilder(
      valueListenable: loadingNotifier,
      builder: (context, value, child) {
        return ElevatedButton(
          onPressed: () {
            if (value) return;
            loadingNotifier.value = true;
            _add().whenComplete(() {
              loadingNotifier.value = false;
            });
          },
          child: Text(value ? 'Chargement...' : 'Ajouter'),
        );
      },
    );
  }

  Future<void> _add() async {
    final todo = Todo.dummy();
    await messaging.publishNow(CreateTodoMessage(todo));
  }
}

class _TodoBody extends StatelessWidget {
  const _TodoBody({
    Key? key,
    required this.todos,
  }) : super(key: key);

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(
        height: 1,
      ),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          title: Text(todo.title),
          subtitle: Text(todo.content),
        );
      },
      itemCount: todos.length,
    );
  }
}
