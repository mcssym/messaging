import 'message.dart';

/// Type of state of a message during its lifecycle
enum MessageStateType {
  /// Message is published
  published,

  /// Message is dispatching to subscribers
  dispatching,

  /// Message is dispatched
  dispatched,
}

/// Data of [MessageState] that can be updated
class MessageStateUpdatableData {
  /// Type of the state
  final MessageStateType? type;

  /// Key of subscribers that already received the message
  final List<String>? dispatchedSubscribers;

  /// Constructor
  const MessageStateUpdatableData({
    this.dispatchedSubscribers,
    this.type,
  });
}

/// State of a message
class MessageState {
  /// Type of the state
  final MessageStateType type;

  /// Message
  final Message message;

  /// Key of subscribers that already received the message
  final List<String> dispatchedSubscribers;

  /// Constructor
  const MessageState({
    required this.dispatchedSubscribers,
    required this.message,
    required this.type,
  });

  /// Copy this state with the new values
  MessageState copyWith(MessageStateUpdatableData data) {
    return MessageState(
      dispatchedSubscribers:
          data.dispatchedSubscribers ?? dispatchedSubscribers,
      message: message,
      type: data.type ?? type,
    );
  }
}
