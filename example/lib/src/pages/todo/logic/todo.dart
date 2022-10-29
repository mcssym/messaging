import 'package:faker/faker.dart';

class Todo {
  final String title;
  final String content;

  const Todo({
    required this.title,
    required this.content,
  });

  factory Todo.dummy() {
    final faker = Faker();
    return Todo(
      title: faker.lorem.sentence(),
      content: faker.lorem.sentences(3).join('\n'),
    );
  }
}
