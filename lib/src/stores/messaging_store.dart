import '../common/message.dart';
import '../common/message_state.dart';

/// An interface to access public APIs of the store of messages
abstract class MessageStore {
  /// Count all saved messages
  Future<int> count();

  /// Get all saved message states
  Future<Map<String, MessageState>> getStates();

  /// Get all saved messages
  Future<Iterable<Message>> getMessages();
}

/// A store to save the messages temporarily or forever
abstract class MessagingStore extends MessageStore {
  /// Insert [messageState] in the store
  ///
  /// It should return the key to use to retrieve [messageState]
  Future<String> insert(MessageState messageState);

  /// Retrieve a [MessageState] by its [key].
  ///
  /// It should return `null` if the message can't be retrieved
  Future<MessageState?> read(String key);

  /// Update the data of a [MessageState] referenced by [key]
  Future<void> update(String key, MessageStateUpdatableData data);

  /// Delete a [MessageState] referenced by [key]
  Future<bool> delete(String key);
}
