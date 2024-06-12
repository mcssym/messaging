import 'package:messaging/messaging.dart';

class User {
  final String email;

  User(this.email);
}

void main(List<String> args) async {
  final Messaging messaging = Messaging();

  // Instantiate your subscriber
  final UserSubscriber userSubscriber = UserSubscriber();

  // Subscribe it to UserCreateMessage
  messaging.subscribe(userSubscriber, to: UserCreateMessage);

  // Start your messaging instance
  await messaging.start();

  // Somewhere you publish
  messaging.publish(UserCreateMessage(User('email@example.com')));
}

class UserCreateMessage extends Message {
  final User user;

  const UserCreateMessage(this.user);
}

class UserSubscriber implements MessagingSubscriber {
  @override
  Future<void> onMessage(Message message) async {
    if (message is UserCreateMessage) {
      // Do stuff
    }
  }

  @override
  String get subscriberKey => '$UserSubscriber';
}
