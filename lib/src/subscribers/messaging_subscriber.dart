import '../common/message.dart';

/// Component or service that is notified when a message it subscribed
/// is published.
abstract class MessagingSubscriber {
  /// It is called when [message] is dispatching.
  ///
  /// Asynchronous process can be done here. Every thrown exceptions will be catch
  Future<void> onMessage(Message message);

  /// Key of this subscriber used to identify it uniquely.
  String get subscriberKey;
}

/// Extension to compare two [MessagingSubscriber] instances.
extension EqualsMessagingSubscriber on MessagingSubscriber {
  /// Check if this subscriber is equal to [other].
  bool equals(MessagingSubscriber other) =>
      subscriberKey == other.subscriberKey && runtimeType == other.runtimeType;
}
