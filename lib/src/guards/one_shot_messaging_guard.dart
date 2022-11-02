import '../common/message.dart';
import '../messaging.dart';
import '../observers/callback_messaging_observer.dart';
import '../observers/messaging_observer.dart';
import 'guards.dart';

/// A guard that will not allowed message that was already published.
///
/// The observer of this guard should be added to the list of observers of the
/// messaging instance.
///
/// If the publication failed or is not allowed by another guard then
/// the message will not be counted.
///
/// Usage
/// ```dart
/// OneShotMessagingGuard.setDefaultOneShotMessageTypes(<Type>[AppLaunchMessage]);
///
/// final Messaging messaging = Messaging(
///                               guards: [OneShotMessagingGuard()],
///                               observers: [OneShotMessagingGuard().observer],
///                             );
class OneShotMessagingGuard extends MessagingGuard {
  final List<Type> _alreadyShotMessageTypes = <Type>[];

  static List<Type>? _defaultOneShotMessageTypes;
  static OneShotMessagingGuard? _instance;

  /// Get the default one shot message types
  static List<Type>? get defaultOneShotMessageTypes =>
      _defaultOneShotMessageTypes;

  /// Set the value of the default one shot message types
  ///
  /// If this value is already not null and [force] is false then no change is applied
  static void setDefaultOneShotMessageTypes(
    List<Type> oneShotMessageTypes, {
    bool force = false,
  }) {
    if (_defaultOneShotMessageTypes == null || force) {
      _defaultOneShotMessageTypes = oneShotMessageTypes;
    }
  }

  /// Factory constructor
  ///
  /// This will return the same instance each time. If you need a new instance
  /// each time prefer [OneShotMessagingGuard.newInstance] constructor.
  factory OneShotMessagingGuard() {
    _instance ??= OneShotMessagingGuard.newInstance(
      oneShotMessageTypes: defaultOneShotMessageTypes ?? [],
    );

    return _instance!;
  }

  /// List of message type that should be published only one time
  /// in application lifetime
  final List<Type> oneShotMessageTypes;

  /// Observer of this guard
  ///
  /// It should be added to the observers of the messaging instance.
  late final MessagingObserver observer;

  /// New instance constructor
  OneShotMessagingGuard.newInstance({
    required this.oneShotMessageTypes,
  }) {
    observer = CallbackMessagingObserver(
      publishFailed: (message, error, {trace}) => _removedTypeOf(message),
      notAllowed: (message, guard, response) => _removedTypeOf(message),
    );
  }

  @override
  MessagingGuardResponse can(Message message, Messaging messaging) {
    final type = message.runtimeType;
    if (oneShotMessageTypes.contains(type)) {
      if (_alreadyShotMessageTypes.contains(type)) {
        return const NotAllowedMessagingGuardResponse();
      } else {
        _alreadyShotMessageTypes.add(type);
      }
    }

    return const AllowedMessagingGuardResponse();
  }

  void _removedTypeOf(Message message) {
    final type = message.runtimeType;
    if (oneShotMessageTypes.contains(type)) {
      _alreadyShotMessageTypes.remove(type);
    }
  }
}
