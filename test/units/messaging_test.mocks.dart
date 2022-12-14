// Mocks generated by Mockito 5.3.2 from annotations
// in messaging/test/units/messaging_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:messaging/src/common/log.dart' as _i8;
import 'package:messaging/src/common/message.dart' as _i7;
import 'package:messaging/src/common/message_state.dart' as _i6;
import 'package:messaging/src/common/messaging_state.dart' as _i12;
import 'package:messaging/src/guards/messaging_guard.dart' as _i3;
import 'package:messaging/src/messaging.dart' as _i9;
import 'package:messaging/src/observers/messaging_observer.dart' as _i10;
import 'package:messaging/src/queues/messaging_queue.dart' as _i2;
import 'package:messaging/src/stores/messaging_store.dart' as _i4;
import 'package:messaging/src/subscribers/messaging_subscriber.dart' as _i11;
import 'package:mockito/mockito.dart' as _i1;

import 'messaging_test.dart' as _i13;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeMessagingQueueDispatcher_0 extends _i1.SmartFake
    implements _i2.MessagingQueueDispatcher {
  _FakeMessagingQueueDispatcher_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMessagingGuardResponse_1 extends _i1.SmartFake
    implements _i3.MessagingGuardResponse {
  _FakeMessagingGuardResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [MessagingStore].
///
/// See the documentation for Mockito's code generation for more information.
class MockMessagingStore extends _i1.Mock implements _i4.MessagingStore {
  @override
  _i5.Future<String> insert(_i6.MessageState? messageState) =>
      (super.noSuchMethod(
        Invocation.method(
          #insert,
          [messageState],
        ),
        returnValue: _i5.Future<String>.value(''),
        returnValueForMissingStub: _i5.Future<String>.value(''),
      ) as _i5.Future<String>);
  @override
  _i5.Future<_i6.MessageState?> read(String? key) => (super.noSuchMethod(
        Invocation.method(
          #read,
          [key],
        ),
        returnValue: _i5.Future<_i6.MessageState?>.value(),
        returnValueForMissingStub: _i5.Future<_i6.MessageState?>.value(),
      ) as _i5.Future<_i6.MessageState?>);
  @override
  _i5.Future<void> update(
    String? key,
    _i6.MessageStateUpdatableData? data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #update,
          [
            key,
            data,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<bool> delete(String? key) => (super.noSuchMethod(
        Invocation.method(
          #delete,
          [key],
        ),
        returnValue: _i5.Future<bool>.value(false),
        returnValueForMissingStub: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);
  @override
  _i5.Future<int> count() => (super.noSuchMethod(
        Invocation.method(
          #count,
          [],
        ),
        returnValue: _i5.Future<int>.value(0),
        returnValueForMissingStub: _i5.Future<int>.value(0),
      ) as _i5.Future<int>);
  @override
  _i5.Future<Map<String, _i6.MessageState>> getStates() => (super.noSuchMethod(
        Invocation.method(
          #getStates,
          [],
        ),
        returnValue: _i5.Future<Map<String, _i6.MessageState>>.value(
            <String, _i6.MessageState>{}),
        returnValueForMissingStub:
            _i5.Future<Map<String, _i6.MessageState>>.value(
                <String, _i6.MessageState>{}),
      ) as _i5.Future<Map<String, _i6.MessageState>>);
  @override
  _i5.Future<Iterable<_i7.Message>> getMessages() => (super.noSuchMethod(
        Invocation.method(
          #getMessages,
          [],
        ),
        returnValue: _i5.Future<Iterable<_i7.Message>>.value(<_i7.Message>[]),
        returnValueForMissingStub:
            _i5.Future<Iterable<_i7.Message>>.value(<_i7.Message>[]),
      ) as _i5.Future<Iterable<_i7.Message>>);
}

/// A class which mocks [ILogger].
///
/// See the documentation for Mockito's code generation for more information.
class MockILogger extends _i1.Mock implements _i8.ILogger {
  @override
  void verbose(dynamic message) => super.noSuchMethod(
        Invocation.method(
          #verbose,
          [message],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void debug(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #debug,
          [message],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );
  @override
  void info(dynamic message) => super.noSuchMethod(
        Invocation.method(
          #info,
          [message],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void warning(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #warning,
          [message],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );
  @override
  void error(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #error,
          [message],
          {
            #error: error,
            #stackTrace: stackTrace,
          },
        ),
        returnValueForMissingStub: null,
      );
  @override
  void enable() => super.noSuchMethod(
        Invocation.method(
          #enable,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void disable() => super.noSuchMethod(
        Invocation.method(
          #disable,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [MessagingQueueDispatcher].
///
/// See the documentation for Mockito's code generation for more information.
class MockMessagingQueueDispatcher extends _i1.Mock
    implements _i2.MessagingQueueDispatcher {
  @override
  void dispatch(String? item) => super.noSuchMethod(
        Invocation.method(
          #dispatch,
          [item],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [MessagingQueue].
///
/// See the documentation for Mockito's code generation for more information.
class MockMessagingQueue extends _i1.Mock implements _i2.MessagingQueue {
  @override
  _i2.MessagingQueueDispatcher get dispatcher => (super.noSuchMethod(
        Invocation.getter(#dispatcher),
        returnValue: _FakeMessagingQueueDispatcher_0(
          this,
          Invocation.getter(#dispatcher),
        ),
        returnValueForMissingStub: _FakeMessagingQueueDispatcher_0(
          this,
          Invocation.getter(#dispatcher),
        ),
      ) as _i2.MessagingQueueDispatcher);
  @override
  _i2.ResumeQueueStrategy get resumeStrategy => (super.noSuchMethod(
        Invocation.getter(#resumeStrategy),
        returnValue: _i2.ResumeQueueStrategy.dispatchPendingMessages,
        returnValueForMissingStub:
            _i2.ResumeQueueStrategy.dispatchPendingMessages,
      ) as _i2.ResumeQueueStrategy);
  @override
  bool get isEmpty => (super.noSuchMethod(
        Invocation.getter(#isEmpty),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  bool get isNotEmpty => (super.noSuchMethod(
        Invocation.getter(#isNotEmpty),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  Iterable<_i2.QueueItem<String>> get items => (super.noSuchMethod(
        Invocation.getter(#items),
        returnValue: <_i2.QueueItem<String>>[],
        returnValueForMissingStub: <_i2.QueueItem<String>>[],
      ) as Iterable<_i2.QueueItem<String>>);
  @override
  int get length => (super.noSuchMethod(
        Invocation.getter(#length),
        returnValue: 0,
        returnValueForMissingStub: 0,
      ) as int);
  @override
  bool get paused => (super.noSuchMethod(
        Invocation.getter(#paused),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);
  @override
  void addQueueItem(_i2.QueueItem<String>? item) => super.noSuchMethod(
        Invocation.method(
          #addQueueItem,
          [item],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void dispatchQueuedItem() => super.noSuchMethod(
        Invocation.method(
          #dispatchQueuedItem,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void onItemAddedToQueue() => super.noSuchMethod(
        Invocation.method(
          #onItemAddedToQueue,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void pause() => super.noSuchMethod(
        Invocation.method(
          #pause,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void reset() => super.noSuchMethod(
        Invocation.method(
          #reset,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void resume() => super.noSuchMethod(
        Invocation.method(
          #resume,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [MessagingGuard].
///
/// See the documentation for Mockito's code generation for more information.
class MockMessagingGuard extends _i1.Mock implements _i3.MessagingGuard {
  @override
  _i3.MessagingGuardResponse can(
    _i7.Message? message,
    _i9.Messaging? messaging,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #can,
          [
            message,
            messaging,
          ],
        ),
        returnValue: _FakeMessagingGuardResponse_1(
          this,
          Invocation.method(
            #can,
            [
              message,
              messaging,
            ],
          ),
        ),
        returnValueForMissingStub: _FakeMessagingGuardResponse_1(
          this,
          Invocation.method(
            #can,
            [
              message,
              messaging,
            ],
          ),
        ),
      ) as _i3.MessagingGuardResponse);
}

/// A class which mocks [MessagingObserver].
///
/// See the documentation for Mockito's code generation for more information.
class MockMessagingObserver extends _i1.Mock implements _i10.MessagingObserver {
  @override
  void onPrePublish(_i7.Message? message) => super.noSuchMethod(
        Invocation.method(
          #onPrePublish,
          [message],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void onPostPublish(_i7.Message? message) => super.noSuchMethod(
        Invocation.method(
          #onPostPublish,
          [message],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void onPreDispatch(_i7.Message? message) => super.noSuchMethod(
        Invocation.method(
          #onPreDispatch,
          [message],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void onPostDispatch(_i7.Message? message) => super.noSuchMethod(
        Invocation.method(
          #onPostDispatch,
          [message],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void onSaved(_i7.Message? message) => super.noSuchMethod(
        Invocation.method(
          #onSaved,
          [message],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void onNotAllowed(
    _i7.Message? message,
    _i3.MessagingGuard? guard,
    _i3.MessagingGuardResponse? response,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #onNotAllowed,
          [
            message,
            guard,
            response,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void onDispatchFailed(
    _i7.Message? message,
    Object? error, {
    _i11.MessagingSubscriber? subscriber,
    StackTrace? trace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #onDispatchFailed,
          [
            message,
            error,
          ],
          {
            #subscriber: subscriber,
            #trace: trace,
          },
        ),
        returnValueForMissingStub: null,
      );
  @override
  void onPublishFailed(
    _i7.Message? message,
    Object? error, {
    StackTrace? trace,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #onPublishFailed,
          [
            message,
            error,
          ],
          {#trace: trace},
        ),
        returnValueForMissingStub: null,
      );
  @override
  void onMessagingStateChanged(_i12.MessagingState? state) =>
      super.noSuchMethod(
        Invocation.method(
          #onMessagingStateChanged,
          [state],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [MessagingSubscriber].
///
/// See the documentation for Mockito's code generation for more information.
class MockMessagingSubscriber extends _i1.Mock
    implements _i11.MessagingSubscriber {
  @override
  String get subscriberKey => (super.noSuchMethod(
        Invocation.getter(#subscriberKey),
        returnValue: _i13.uniqueKeyGenerator(),
        returnValueForMissingStub: _i13.uniqueKeyGenerator(),
      ) as String);
  @override
  _i5.Future<void> onMessage(_i7.Message? message) => (super.noSuchMethod(
        Invocation.method(
          #onMessage,
          [message],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [MessagingSubscriber].
///
/// See the documentation for Mockito's code generation for more information.
class MockMessagingSubscriberTwo extends _i1.Mock
    implements _i11.MessagingSubscriber {
  @override
  String get subscriberKey => (super.noSuchMethod(
        Invocation.getter(#subscriberKey),
        returnValue: _i13.uniqueKeyGeneratorTwo(),
        returnValueForMissingStub: _i13.uniqueKeyGeneratorTwo(),
      ) as String);
  @override
  _i5.Future<void> onMessage(_i7.Message? message) => (super.noSuchMethod(
        Invocation.method(
          #onMessage,
          [message],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [Message].
///
/// See the documentation for Mockito's code generation for more information.
class MockMessage extends _i1.Mock implements _i7.Message {
  @override
  int get priority => (super.noSuchMethod(
        Invocation.getter(#priority),
        returnValue: 0,
        returnValueForMissingStub: 0,
      ) as int);
}
