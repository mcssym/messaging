import '../common/key_resolver.dart';
import '../common/message.dart';
import '../common/message_state.dart';
import 'messaging_store.dart';

/// Implementation of [MessagingCacheStore] that saved messages in memory
class MessagingMemoryStore extends MessagingCacheStore {
  final Map<String, MessageState> _tempStore = <String, MessageState>{};

  /// Key resolver used to resolve key for MessageState inserted
  final KeyResolver keyResolver;

  /// Constructor
  MessagingMemoryStore({
    this.keyResolver = const DefaultKeyResolver(),
  });

  @override
  Future<int> count() {
    return Future.value(_tempStore.length);
  }

  @override
  Future<String> insert(MessageState messageState) async {
    final key = await keyResolver.resolve();
    _tempStore[key] = messageState;
    return key;
  }

  @override
  Future<bool> delete(String key) {
    final removed = _tempStore.remove(key);

    return Future.value(removed != null);
  }

  @override
  Future<Iterable<Message>> getMessages() async {
    final states = await getStates();
    return states.values.map((e) => e.message);
  }

  @override
  Future<Map<String, MessageState>> getStates() {
    return Future.value(_tempStore);
  }

  @override
  Future<MessageState?> read(String key) {
    return Future.value(_tempStore[key]);
  }

  @override
  Future<void> update(String key, MessageStateUpdatableData data) async {
    final state = _tempStore[key];
    if (state != null) {
      _tempStore[key] = state.copyWith(data);
    }
  }
}
