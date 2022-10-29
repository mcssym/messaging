import '../common/message.dart';
import '../common/messaging_state.dart';
import '../guards/messaging_guard.dart';
import '../subscribers/messaging_subscriber.dart';

/// Observer that is notified in every lifecycle of the message
abstract class MessagingObserver {
  /// It is called before [message] is checked by the guards
  void onPrePublish(Message message) {}

  /// It is called after [message] is checked by the guards.
  ///
  /// It will be called only if [message] is allowed by the guards.
  void onPostPublish(Message message) {}

  /// It is called before [message] is dispatched to subscribers
  void onPreDispatch(Message message) {}

  /// It is called after [message] is dispatched to subscribers
  void onPostDispatch(Message message) {}

  /// It is called when [message] is saved in the store
  void onSaved(Message message) {}

  /// It is called only if [message] is not allowed by the [guard] with [response].
  void onNotAllowed(
    Message message,
    MessagingGuard guard,
    MessagingGuardResponse response,
  ) {}

  /// It is called when [subscriber] throws [error] when it processes [message]
  void onDispatchFailed(
    Message message,
    Object error, {
    MessagingSubscriber? subscriber,
    StackTrace? trace,
  }) {}

  /// It is called when [error] occurs when [message] is publishing
  void onPublishFailed(
    Message message,
    Object error, {
    StackTrace? trace,
  }) {}

  /// It is called when the messaging instance is closed
  void onMessagingStateChanged(MessagingState state) {}
}
