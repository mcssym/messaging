import 'dart:async';

import 'common/iterable_wrapper.dart';
import 'common/log.dart';
import 'common/message.dart';
import 'common/message_state.dart';
import 'common/messaging_state.dart';
import 'guards/messaging_guard.dart';
import 'observers/messaging_observer.dart';
import 'queue/message_queue.dart';
import 'queue/timer_message_queue.dart';
import 'store/messaging_memory_store.dart';
import 'store/messaging_store.dart';
import 'subscribers/messaging_subscriber.dart';

/// Result of publishing a message that failed
class FailedPublishResult extends PublishResult {
  /// The error
  final Object? error;

  /// Stacktrace
  final StackTrace? trace;

  /// Constructor
  const FailedPublishResult({
    required bool published,
    this.error,
    this.trace,
  }) : super(published: published);
}

/// Result of publishing a message after the guard step
class GuardPublishResult extends PublishResult {
  /// The guard response
  final MessagingGuardResponse? response;

  /// Constructor
  const GuardPublishResult({
    required bool published,
    required this.response,
  }) : super(published: published);
}

/// Configuration for log
class LogConfig {
  /// Level
  final LogLevel logLevel;

  /// If enable
  final bool enable;

  /// Configuration
  LogConfig({required this.logLevel, required this.enable});
}

/// Pub/Sub messaging handler that allows to publish and subscribe to message
/// from anywhere in your app.
///
/// It allows you to put guards to filter some messages and to add observers
/// for each message lifecycle.
///
/// The usage is simple.
/// ```dart
/// class RandomMessage extends Message {
///   final String randomString;
///
///   const RandomMessage(this.randomString): super();
/// }
///
/// class RandomSubscriber implements MessagingSubscriber {
///
///   @override
///   Future<void> onMessage(Message message) {
///     // Do stuff
///   }
///
///   @override
///   String get subscriberKey => '$RandomSubscriber';
/// }
///
/// final subscriber = RandomSubscriber();
/// final Messaging messaging = Messaging();
/// messaging.subscribe(subscriber, to: RandomMessage);
///
/// messaging.start();
///
/// // Do Stuff
///
/// messaging.publish(RandomMessage('RandomMessage'));
/// ```
class Messaging {
  /// Default guards of the messaging
  static final defaultGuards = <MessagingGuard>[];

  /// Default observers of the messaging
  static final defaultObservers = <MessagingObserver>[];

  final ILogger _log;
  final MessagingCacheStore _store;
  late final MessageQueue _messageQueue;
  final IterableWrapper<MessagingGuard> _guards;
  final IterableWrapper<MessagingObserver> _observers;
  final Map<Type, Set<MessagingSubscriber>> _subscribers;
  late final _QueueDispatcherHandler _queueDispatcherHandler;

  bool _stopped = true;

  /// Factory constructor to ease the construction of [Messaging.create] constructor
  factory Messaging({
    ILogger? logger,
    LogConfig? logConfig,
    MessageQueueFactory? messageQueueFactory,
    Iterable<MessagingGuard>? guards,
    Iterable<MessagingObserver>? observers,
    MessagingCacheStore? store,
  }) {
    return Messaging.create(
      logConfig: logConfig,
      logger: logger,
      messageQueueFactory: messageQueueFactory,
      store: store,
      guards: IterableWrapper<MessagingGuard>(guards ?? defaultGuards),
      observers:
          IterableWrapper<MessagingObserver>(observers ?? defaultObservers),
    );
  }

  /// Constructor with [messageQueueFactory] a factory method to use to create
  /// the [MessageQueue]. If none assigned then a [TimerMessageQueue] will be used
  ///
  /// The [guards] is the list of guards to use. When null, the [defaultGuards] will
  /// be used. Be sure to include the [defaultGuards] in your guards when you assign it if you
  /// want the default guards to be applied.
  ///
  /// The [observers] is the list of observers to use. When null, the [defaultObservers] will
  /// be used. Be sure to include the [defaultObservers] in your observers when you assign it if you
  /// want the default observers to be applied.
  ///
  /// The [store] is the cache store to save and read [MessageState]. When null,
  /// [MessagingMemoryStore] will be used.
  Messaging.create({
    ILogger? logger,
    LogConfig? logConfig,
    MessageQueueFactory? messageQueueFactory,
    required IterableWrapper<MessagingGuard> guards,
    required IterableWrapper<MessagingObserver> observers,
    MessagingCacheStore? store,
  })  : _subscribers = <Type, Set<MessagingSubscriber>>{},
        _guards = guards,
        _store = store ?? MessagingMemoryStore(),
        _log = logger ??
            Log(
              enable: logConfig?.enable ?? true,
              level: logConfig?.logLevel ?? LogLevel.verbose,
            ),
        _observers = observers {
    _queueDispatcherHandler = _QueueDispatcherHandler(_dispatch);

    _messageQueue = messageQueueFactory != null
        ? messageQueueFactory(_queueDispatcherHandler)
        : TimerMessageQueue(
            dispatcher: _queueDispatcherHandler,
          );
  }

  /// Wrapper of guards that allows you to add or remove some
  IterableWrapper<MessagingGuard> get guards => _guards;

  /// Log
  ToggableLog get log => _log;

  /// Wrapper of observers that allows you to add or remove some
  IterableWrapper<MessagingObserver> get observers => _observers;

  /// Queue
  MessagingQueue get queue => _messageQueue;

  /// Check the messaging is stopped
  bool get stopped => _stopped;

  /// Get current store
  MessagingStore get store => _store;

  /// Pause the messaging
  ///
  /// It will pause the queue so that new message won't be dispatch
  /// until it is resumed.
  void pause() {
    _messageQueue.pause();
    _log.info('Paused');
    _informObserversOfStateChanged(MessagingState.paused);
  }

  /// Publish [message]
  ///
  /// The `PublishResult.reason` will be the response of guard check.
  /// If all guards allowed then it will be a [AllowedMessagingGuardResponse]
  /// otherwise it will be a [NotAllowedMessagingGuardResponse].
  PublishResult publish(Message message) {
    _log.info('Publishing $message');

    final response = _checkGuards(message);

    if (!response.allowed) {
      return GuardPublishResult(
        published: response.allowed,
        response: response,
      );
    }

    unawaited(_saveAndPublish(message));
    _log.info('Publish $message ended');

    return const PublishResult(
      published: true,
    );
  }

  /// Publish [message] now allowing to wait until all subscribers
  /// received the published message.
  ///
  /// The `PublishResult.reason` could be the response of guard check.
  /// If all guards allowed then it will be a [AllowedMessagingGuardResponse] if
  /// no errors occurred during dispatch otherwise it will be
  /// a [NotAllowedMessagingGuardResponse].
  ///
  /// If an error is thrown by one subscriber during dispatch
  /// then it is stopped and the `PublishResult.reason`
  /// will be the thrown error.
  Future<PublishResult> publishNow(
    Message message, {
    PublishNowErrorHandlingStrategy strategy =
        PublishNowErrorHandlingStrategy.continueDispatch,
  }) async {
    _log.info('Publishing now $message');
    final response = _checkGuards(message);

    if (!response.allowed) {
      return GuardPublishResult(
        published: response.allowed,
        response: response,
      );
    }

    try {
      final key = await _saveToStore(
        message,
      );
      _informObserversOf(_InformType.postPublish, message);
      await _dispatchMessageByKey(
        key,
        shouldWait: true,
        strategy: strategy,
      );
    } catch (e, s) {
      _informObserversOfPublishFailed(message, e, s);
      return FailedPublishResult(
        published: false,
        error: e,
        trace: s,
      );
    }
    _log.info('Publish $message ended');

    return const PublishResult(
      published: true,
    );
  }

  /// Resume the messaging
  ///
  /// It will resume the dispatch of messages.
  void resume() {
    _messageQueue.resume();
    _log.info('Resumed');
    _informObserversOfStateChanged(MessagingState.resumed);
  }

  /// Start the publishing of messages.
  ///
  /// If there's events that was not published in the store
  /// then they will be published directly.
  ///
  /// It is recommended to call it when you know that every subscribers are
  /// subscribing
  Future<void> start() async {
    if (!_stopped) return;

    final states = await _store.getStates();
    states.forEach((key, state) {
      if (state.type != MessageStateType.dispatched) {
        _addKeyToMessageQueue(key, state.message.priority);
      }
    });
    resume();
    _stopped = false;
    _informObserversOfStateChanged(MessagingState.started);
    _log.info('Started');
  }

  /// Stop the messaging and stop all related processes
  void stop() {
    if (_stopped) return;

    _messageQueue.reset();

    _log.info('Stopped');
    _informObserversOfStateChanged(MessagingState.stopped);
    _stopped = true;
  }

  /// Subscribe [subscriber] to messages of type [to]
  void subscribe(
    MessagingSubscriber subscriber, {
    required Type to,
  }) {
    if (!_subscribers.containsKey(to)) {
      _subscribers[to] = <MessagingSubscriber>{};
    }
    if (_subscribers[to]?.any(
          (element) => element.subscriberKey == subscriber.subscriberKey,
        ) ==
        true) {
      return;
    }
    _subscribers[to]!.add(subscriber);
    _log.info('${subscriber.subscriberKey} subscribes to $to');
  }

  /// Subscribe [subscriber] to all message in [to]
  ///
  /// It will call [subscribe] for each item in [to].
  void subscribeAll(
    MessagingSubscriber subscriber, {
    required Iterable<Type> to,
  }) {
    for (final element in to) {
      subscribe(subscriber, to: element);
    }
  }

  /// Unsubscribe [subscriber] to messages of type [to]
  void unsubscribe(
    MessagingSubscriber subscriber, {
    required Type to,
  }) {
    if (!_subscribers.containsKey(to)) {
      return;
    }
    _subscribers[to]!.remove(subscriber);
    _log.info('${subscriber.subscriberKey} unsubscribes to $to');
  }

  /// Unsubscribe [subscriber] to all messages
  void unsubscribeAll(MessagingSubscriber subscriber) {
    _subscribers.forEach((key, value) {
      if (value.contains(subscriber)) {
        unsubscribe(subscriber, to: key);
      }
    });
    _log.info('unsubscribe $subscriber to all');
  }

  void _addKeyToMessageQueue(String key, int priority) {
    _messageQueue.addQueueItem(
      QueueItem<String>(
        item: key,
        priority: priority,
      ),
    );
  }

  MessagingGuardResponse _checkGuards(Message message) {
    _informObserversOf(_InformType.prePublish, message);
    final it = _guards.iterator;
    while (it.moveNext()) {
      final response = it.current.can(message, this);
      if (!response.allowed) {
        _informObserversOfNotAllowed(
          message,
          it.current,
          response,
        );
        return response;
      }
    }
    return const AllowedMessagingGuardResponse();
  }

  void _dispatch(String key) {
    unawaited(_dispatchMessageByKey(key));
  }

  Future<void> _dispatchMessageByKey(
    String key, {
    bool shouldWait = false,
    PublishNowErrorHandlingStrategy? strategy,
  }) async {
    final MessageState? state = await _store.read(key);
    if (state != null) {
      final message = state.message;
      _informObserversOf(_InformType.preDispatch, message);
      _updateStateOfMessage(
        key,
        const MessageStateUpdatableData(
          type: MessageStateType.dispatching,
        ),
      );
      final Iterable<MessagingSubscriber>? subscribers =
          _getSubscriberFor(message)?.where(
        (element) =>
            !state.dispatchedSubscribers.contains(element.subscriberKey),
      );
      if (subscribers != null) {
        try {
          if (shouldWait) {
            final List<String> dispatched = <String>[];
            await Future.forEach<MessagingSubscriber>(
              subscribers,
              (subscriber) async {
                try {
                  await _dispatchTo(subscriber, message);
                  dispatched.add(subscriber.subscriberKey);
                  _log.info('$message dispatched to $subscriber');
                  _updateStateOfMessage(
                    key,
                    MessageStateUpdatableData(
                      dispatchedSubscribers: dispatched,
                    ),
                  );
                } catch (e) {
                  if (strategy ==
                      PublishNowErrorHandlingStrategy.breakDispatch) {
                    rethrow;
                  }
                }
              },
            );
          } else {
            for (final element in subscribers) {
              unawaited(_dispatchTo(element, message).catchError((_) {}));
            }
          }
          _informObserversOf(_InformType.postDispatch, message);
          _updateStateOfMessage(
            key,
            MessageStateUpdatableData(
              type: MessageStateType.dispatched,
              dispatchedSubscribers: List<String>.generate(
                subscribers.length,
                (index) => subscribers.elementAt(index).subscriberKey,
              ),
            ),
          );
        } catch (e, s) {
          _log.error('Error during dispatch', error: e, stackTrace: s);
          _informObserversOfDispatchFailed(message, e, trace: s);
          if (shouldWait) {
            rethrow;
          }
        }
      }
    }
  }

  Future<void> _dispatchTo(
    MessagingSubscriber subscriber,
    Message message,
  ) async {
    try {
      await subscriber.onMessage(message);
      _log.info(
        '$message dispatched to ${subscriber.runtimeType}:${subscriber.subscriberKey}',
      );
    } catch (e, s) {
      _log.error('Error during dispatch', error: e, stackTrace: s);
      _informObserversOfDispatchFailed(
        message,
        e,
        trace: s,
        subscriber: subscriber,
      );
      rethrow;
    }
  }

  Set<MessagingSubscriber>? _getSubscriberFor(Message message) {
    return _subscribers[message.runtimeType];
  }

  void _informObserversOf(_InformType type, Message message) {
    switch (type) {
      case _InformType.prePublish:
        _observers.forEach((observer) => observer.onPrePublish(message));
        break;
      case _InformType.postPublish:
        _observers.forEach((observer) => observer.onPostPublish(message));
        break;
      case _InformType.preDispatch:
        _observers.forEach((observer) => observer.onPreDispatch(message));
        break;
      case _InformType.postDispatch:
        _observers.forEach((observer) => observer.onPostDispatch(message));
        break;
      case _InformType.saved:
        _observers.forEach((observer) => observer.onSaved(message));
        break;
    }
  }

  void _informObserversOfDispatchFailed(
    Message message,
    Object error, {
    MessagingSubscriber? subscriber,
    StackTrace? trace,
  }) {
    _observers.forEach(
      (observer) => observer.onDispatchFailed(
        message,
        error,
        subscriber: subscriber,
        trace: trace,
      ),
    );
  }

  void _informObserversOfNotAllowed(
    Message message,
    MessagingGuard guard,
    MessagingGuardResponse response,
  ) {
    _observers.forEach(
      (observer) => observer.onNotAllowed(
        message,
        guard,
        response,
      ),
    );
  }

  void _informObserversOfPublishFailed(
    Message message,
    Object error,
    StackTrace? trace,
  ) {
    _observers.forEach(
      (observer) => observer.onPublishFailed(
        message,
        error,
        trace: trace,
      ),
    );
  }

  void _informObserversOfStateChanged(
    MessagingState state,
  ) {
    _observers.forEach((observer) => observer.onMessagingStateChanged(state));
  }

  Future<void> _saveAndPublish(Message message) async {
    try {
      final key = await _saveToStore(
        message,
      );
      _addKeyToMessageQueue(key, message.priority);
      _informObserversOf(_InformType.postPublish, message);
    } catch (e, s) {
      _informObserversOfPublishFailed(message, e, s);
    }
  }

  Future<String> _saveToStore(Message message) async {
    final key = await _store.insert(
      MessageState(
        type: MessageStateType.published,
        message: message,
        dispatchedSubscribers: <String>[],
      ),
    );

    _informObserversOf(_InformType.saved, message);
    return key;
  }

  void _updateStateOfMessage(String key, MessageStateUpdatableData data) {
    _store.update(key, data);
  }
}

/// Strategy to apply when error occurred during publish/dispatch now
enum PublishNowErrorHandlingStrategy {
  /// Rethrow the error.
  ///
  /// This will stop the dispatch to others subscribers
  breakDispatch,

  /// Do not rethrow the error.
  ///
  /// Continue to dispatch to others subscribers
  continueDispatch
}

/// Result of publishing a message
class PublishResult {
  /// If the message is published
  final bool published;

  /// Constructor
  const PublishResult({
    required this.published,
  });
}

enum _InformType {
  prePublish,
  postPublish,
  preDispatch,
  postDispatch,
  saved,
}

class _QueueDispatcherHandler implements MessageQueueDispatcher {
  final void Function(String key) onDispatch;

  _QueueDispatcherHandler(this.onDispatch);
  @override
  void dispatch(String item) {
    onDispatch(item);
  }
}
