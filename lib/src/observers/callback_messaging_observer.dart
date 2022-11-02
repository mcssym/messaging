import '../common/message.dart';
import '../common/messaging_state.dart';
import '../guards/messaging_guard.dart';
import '../subscribers/messaging_subscriber.dart';
import 'messaging_observer.dart';

/// Messaging observer that you can use to pass callback for event rather than
/// implementing an observer
class CallbackMessagingObserver implements MessagingObserver {
  /// Action to invoke when the [onDispatchFailed] method is called
  final void Function(
    Message message,
    Object error, {
    MessagingSubscriber? subscriber,
    StackTrace? trace,
  })? dispatchFailed;

  /// Action to invoke when the [onMessagingStateChanged] method is called
  final void Function(MessagingState state)? messagingStateChanged;

  /// Action to invoke when the [onNotAllowed] method is called
  final void Function(
    Message message,
    MessagingGuard guard,
    MessagingGuardResponse response,
  )? notAllowed;

  /// Action to invoke when the [onPostDispatch] method is called
  final void Function(Message message)? postDispatch;

  /// Action to invoke when the [onPostPublish] method is called
  final void Function(Message message)? postPublish;

  /// Action to invoke when the [onPreDispatch] method is called
  final void Function(Message message)? preDispatch;

  /// Action to invoke when the [onPrePublish] method is called
  final void Function(Message message)? prePublish;

  /// Action to invoke when the [onPublishFailed] method is called
  final void Function(Message message, Object error, {StackTrace? trace})?
      publishFailed;

  /// Action to invoke when the [onSaved] method is called
  final void Function(Message message)? saved;

  /// Constructor
  CallbackMessagingObserver({
    this.dispatchFailed,
    this.messagingStateChanged,
    this.notAllowed,
    this.postDispatch,
    this.postPublish,
    this.preDispatch,
    this.prePublish,
    this.publishFailed,
    this.saved,
  });

  @override
  void onDispatchFailed(
    Message message,
    Object error, {
    MessagingSubscriber? subscriber,
    StackTrace? trace,
  }) {
    dispatchFailed?.call(
      message,
      error,
      subscriber: subscriber,
      trace: trace,
    );
  }

  @override
  void onMessagingStateChanged(MessagingState state) {
    messagingStateChanged?.call(state);
  }

  @override
  void onNotAllowed(
    Message message,
    MessagingGuard guard,
    MessagingGuardResponse response,
  ) {
    notAllowed?.call(message, guard, response);
  }

  @override
  void onPostDispatch(Message message) {
    postDispatch?.call(message);
  }

  @override
  void onPostPublish(Message message) {
    postPublish?.call(message);
  }

  @override
  void onPreDispatch(Message message) {
    preDispatch?.call(message);
  }

  @override
  void onPrePublish(Message message) {
    prePublish?.call(message);
  }

  @override
  void onPublishFailed(Message message, Object error, {StackTrace? trace}) {
    publishFailed?.call(message, error, trace: trace);
  }

  @override
  void onSaved(Message message) {
    saved?.call(message);
  }
}
