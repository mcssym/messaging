import '../common/message.dart';
import '../messaging.dart';
import '../observers/callback_messaging_observer.dart';
import '../observers/messaging_observer.dart';
import 'guards.dart';

/// A guard that will not allowed message that was already published until
/// another one is published.
///
/// The observer of this guard should be added to the list of observers of the
/// messaging instance.
///
/// Example when in refresh token case. When it is published once you don't it to
/// be published until an message like login message is published too.
///
/// Usage
/// ```dart
/// UniqueDependantMessagingGuard.setDefaultUniqueDependantMessageTypes({
///   RefreshTokenMessage: <Type>[UserLoginMessage, UserAuthenticateMessage]
/// });
///
/// final Messaging messaging = Messaging(
///                               guards: [UniqueDependantMessagingGuard()],
///                               observers: [UniqueDependantMessagingGuard().observer],
///                             );
/// ```
class UniqueDependantMessagingGuard extends MessagingGuard {
  final List<Type> _alreadyPublishedMessageTypes = <Type>[];

  static Map<Type, Iterable<Type>>? _defaultUniqueDependantMessageTypes;
  static UniqueDependantMessagingGuard? _instance;

  /// Get the default unique dependant message types
  static Map<Type, Iterable<Type>>? get defaultUniqueDependantMessageTypes =>
      _defaultUniqueDependantMessageTypes;

  /// Set the value of the default unique dependant message types
  ///
  /// If this value is already not null and [force] is false then no change is applied
  static void setDefaultUniqueDependantMessageTypes(
    Map<Type, Iterable<Type>> uniqueDependantMessageTypes, {
    bool force = false,
  }) {
    if (_defaultUniqueDependantMessageTypes == null || force) {
      _defaultUniqueDependantMessageTypes = uniqueDependantMessageTypes;
      _instance = null;
    }
  }

  /// Factory constructor
  ///
  /// This will return the same instance each time. If you need a new instance
  /// each time prefer [UniqueDependantMessagingGuard.newInstance] constructor.
  factory UniqueDependantMessagingGuard() {
    _instance ??= UniqueDependantMessagingGuard.newInstance(
      uniqueDependantMessageTypes: defaultUniqueDependantMessageTypes ?? {},
    );

    return _instance!;
  }

  /// Map of unique message with the messages that they are dependant.
  ///
  /// The unique message can be published once then will not be published
  /// until one of its dependant is published
  final Map<Type, Iterable<Type>> uniqueDependantMessageTypes;

  late final Map<Type, List<Type>> _reverseDependencyToUniques;

  /// Observer of this guard
  ///
  /// It should be added to the observers of the messaging instance.
  late final MessagingObserver observer;

  /// New instance constructor
  UniqueDependantMessagingGuard.newInstance({
    required this.uniqueDependantMessageTypes,
  }) {
    _reverseDependencyToUniques = {};
    uniqueDependantMessageTypes.forEach((unique, dependencies) {
      for (final element in dependencies) {
        if (!_reverseDependencyToUniques.containsKey(element)) {
          _reverseDependencyToUniques[element] = [];
        }

        _reverseDependencyToUniques[element]?.add(unique);
      }
    });
    observer = CallbackMessagingObserver(
      postDispatch: (message) => _removedTypeOf(message),
    );
  }

  @override
  MessagingGuardResponse can(Message message, Messaging messaging) {
    final type = message.runtimeType;
    if (uniqueDependantMessageTypes.containsKey(type)) {
      if (_alreadyPublishedMessageTypes.contains(type)) {
        return const NotAllowedMessagingGuardResponse();
      } else {
        _alreadyPublishedMessageTypes.add(type);
      }
    }

    return const AllowedMessagingGuardResponse();
  }

  void _removedTypeOf(Message message) {
    final type = message.runtimeType;
    if (_reverseDependencyToUniques.containsKey(type)) {
      final uniques = _reverseDependencyToUniques[type]!;
      _alreadyPublishedMessageTypes
          .removeWhere((element) => uniques.contains(element));
    }
  }
}
