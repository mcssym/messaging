import 'dart:async';

import 'package:messaging/messaging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks(
  [
    MockSpec<MessagingStore>(),
    MockSpec<ILogger>(),
    MockSpec<MessagingQueueDispatcher>(),
    MockSpec<MessagingQueue>(),
    MockSpec<MessagingGuard>(),
    MockSpec<MessagingObserver>(),
    MockSpec<MessagingSubscriber>(
      fallbackGenerators: {#subscriberKey: uniqueKeyGenerator},
    ),
    MockSpec<MessagingSubscriber>(
      fallbackGenerators: {#subscriberKey: uniqueKeyGeneratorTwo},
      as: #MockMessagingSubscriberTwo,
    ),
    MockSpec<Message>(),
  ],
)
import 'messaging_test.mocks.dart';

String uniqueKeyGenerator() {
  return 'MessagingSubscriber';
}

String uniqueKeyGeneratorTwo() {
  return 'MessagingSubscriberTwo';
}

class BlockingGuard extends MessagingGuard {
  @override
  MessagingGuardResponse can(Message message, Messaging messaging) {
    return const NotAllowedMessagingGuardResponse();
  }
}

class RandomMessage extends Message {
  RandomMessage() : super(priority: 10);
}

void main() {
  group('Publish', () {
    late Messaging messaging;
    late MockMessagingQueue messagingQueue;
    late MockILogger logger;
    late MockMessagingStore store;
    setUp(() {
      messagingQueue = MockMessagingQueue();
      logger = MockILogger();
      store = MockMessagingStore();
      messaging = Messaging(
        guards: [],
        logger: logger,
        messagingQueueFactory: (_) => messagingQueue,
        store: store,
        observers: [],
      );
    });
    test(
      'returns a PublishResult',
      () async {
        await messaging.start();

        final result = messaging.publish(MockMessage());

        expect(result, isA<PublishResult>());
      },
    );
    test(
      'returns a Future<PublishResult>',
      () async {
        await messaging.start();

        final result = messaging.publishNow(MockMessage());

        expect(result, isA<Future<PublishResult>>());
      },
    );
    test(
      'returns a PublishResult that was blocked by guard',
      () async {
        await messaging.start();
        final guard = BlockingGuard();
        messaging.guards.add(guard);

        final result = messaging.publish(MockMessage());

        expect(result.published, equals(false));
        expect(result, isA<GuardPublishResult>());
        expect(
          (result as GuardPublishResult).response,
          isA<NotAllowedMessagingGuardResponse>(),
        );
      },
      timeout: const Timeout(
        Duration(
          seconds: 5,
        ),
      ),
    );
    test(
      'returns a PublishResult that was blocked by guard during immediate publish',
      () async {
        await messaging.start();
        final guard = BlockingGuard();
        messaging.guards.add(guard);

        final result = await messaging.publishNow(MockMessage());

        expect(result.published, equals(false));
        expect(result, isA<GuardPublishResult>());
        expect(
          (result as GuardPublishResult).response,
          isA<NotAllowedMessagingGuardResponse>(),
        );
      },
    );
    test(
      'dispatch breaks with PublishNowErrorHandlingStrategy.breakDispatch strategy when a subscriber throws an error',
      () async {
        final messaging = Messaging(
          guards: [],
          logger: logger,
          messagingQueueFactory: (_) => SyncMessagingQueue(dispatcher: _),
          store: MessagingMemoryStore(),
          observers: [],
        );
        await messaging.start();
        final subscriber1 = MockMessagingSubscriber();
        final subscriber2 = MockMessagingSubscriber();
        messaging.subscribe(subscriber1, to: MockMessage);
        messaging.subscribe(subscriber2, to: MockMessage);

        when(subscriber1.onMessage(any)).thenThrow(StateError('message'));
        when(subscriber2.onMessage(any))
            .thenAnswer((realInvocation) => Future<void>.value());
        final result = await messaging.publishNow(
          MockMessage(),
          strategy: PublishNowErrorHandlingStrategy.breakDispatch,
        );
        messaging.stop();

        expect(result.published, equals(false));
        expect(result, isA<FailedPublishResult>());
        expect((result as FailedPublishResult).error, isA<StateError>());
        verify(subscriber1.onMessage(any)).called(1);
        verifyNever(subscriber2.onMessage(any));
      },
    );
    test(
      'dispatch continues with PublishNowErrorHandlingStrategy.continueDispatch strategy when a subscriber throws an error',
      () async {
        final messaging = Messaging(
          guards: [],
          logger: logger,
          messagingQueueFactory: (_) => SyncMessagingQueue(dispatcher: _),
          store: MessagingMemoryStore(),
          observers: [],
        );
        await messaging.start();
        final subscriber1 = MockMessagingSubscriber();
        final subscriber2 = MockMessagingSubscriberTwo();
        messaging.subscribe(subscriber1, to: MockMessage);
        messaging.subscribe(subscriber2, to: MockMessage);

        when(subscriber1.onMessage(any)).thenThrow(StateError('message'));
        when(subscriber2.onMessage(any))
            .thenAnswer((realInvocation) => Future<void>.value());
        final result = await messaging.publishNow(
          MockMessage(),
        );
        messaging.stop();

        expect(result.published, equals(true));
        verify(subscriber1.onMessage(any)).called(1);
        verify(subscriber2.onMessage(any)).called(1);
      },
    );
    test(
      'will dispatch not dispatched messages previously',
      () async {
        final messaging = Messaging(
          guards: [],
          logger: logger,
          messagingQueueFactory: (_) => SyncMessagingQueue(
            dispatcher: _,
          ),
          store: MessagingMemoryStore(),
          observers: [],
        );
        final subscriber = MockMessagingSubscriber();

        when(subscriber.onMessage(any))
            .thenAnswer((realInvocation) => Future<void>.value());

        await messaging.start();
        messaging.pause(); // avoid the message to be dispatch directly
        messaging.publish(MockMessage());
        await Future<void>.delayed(const Duration(milliseconds: 500));
        final lengthQueueBeforeStop = messaging.queue.length;
        messaging.stop();
        final lengthQueueAfterStop = messaging.queue.length;

        messaging.subscribe(subscriber, to: MockMessage);
        await messaging.start();

        await untilCalled(subscriber.onMessage(any));

        expect(lengthQueueBeforeStop, equals(1));
        expect(lengthQueueAfterStop, equals(0));
        verify(subscriber.onMessage(any)).called(1);
      },
      timeout: const Timeout(
        Duration(
          seconds: 5,
        ),
      ),
    );

    tearDown(() {
      messaging.stop();
    });
  });
  group('Observe', () {
    late Messaging messaging;
    late MockILogger logger;
    setUp(() {
      logger = MockILogger();
      messaging = Messaging(
        guards: [],
        logger: logger,
        messagingQueueFactory: (_) => SyncMessagingQueue(dispatcher: _),
        store: MessagingMemoryStore(),
        observers: [],
      );
    });
    test(
      'observes all lifecycle of a successfully published message',
      () async {
        await messaging.start();
        final observer = MockMessagingObserver();
        messaging.subscribe(MockMessagingSubscriber(), to: MockMessage);
        messaging.observers.add(observer);

        when(observer.onPrePublish(any)).thenAnswer((_) {});
        when(observer.onPostPublish(any)).thenAnswer((_) {});
        when(observer.onPreDispatch(any)).thenAnswer((_) {});
        when(observer.onPostDispatch(any)).thenAnswer((_) {});
        when(observer.onSaved(any)).thenAnswer((_) {});

        messaging.publish(MockMessage());
        await untilCalled(observer.onPostDispatch(any));

        verifyInOrder([
          observer.onPrePublish(any),
          observer.onSaved(any),
          observer.onPostPublish(any),
          observer.onPreDispatch(any),
          observer.onPostDispatch(any),
        ]);
      },
      timeout: const Timeout(
        Duration(
          seconds: 5,
        ),
      ),
    );
    test(
      'observes all lifecycle of a messaging',
      () async {
        await messaging.start();
        final observer = MockMessagingObserver();
        messaging.observers.add(observer);

        when(observer.onMessagingStateChanged(any)).thenAnswer((_) {});
        messaging.pause();
        messaging.resume();
        await untilCalled(observer.onMessagingStateChanged(any));

        verify(observer.onMessagingStateChanged(any)).called(2);
      },
      timeout: const Timeout(
        Duration(
          seconds: 5,
        ),
      ),
    );
    test(
      'observes all lifecycle of a not allowed message',
      () async {
        await messaging.start();
        final observer = MockMessagingObserver();
        messaging.observers.add(observer);
        final guard = BlockingGuard();
        messaging.guards.add(guard);

        when(observer.onNotAllowed(any, any, any)).thenAnswer((_) {});
        messaging.publish(MockMessage());
        await untilCalled(observer.onNotAllowed(any, any, any));

        verify(
          observer.onNotAllowed(
            argThat(isA<MockMessage>()),
            argThat(isA<BlockingGuard>()),
            argThat(isA<NotAllowedMessagingGuardResponse>()),
          ),
        ).called(1);
      },
      timeout: const Timeout(
        Duration(
          seconds: 5,
        ),
      ),
    );
    test(
      'observes all lifecycle of a not dispatched message',
      () async {
        await messaging.start();
        final observer = MockMessagingObserver();
        final subscriber = MockMessagingSubscriber();
        messaging.subscribe(subscriber, to: MockMessage);
        messaging.observers.add(observer);

        when(
          observer.onDispatchFailed(
            any,
            any,
            subscriber: anyNamed('subscriber'),
            trace: anyNamed('trace'),
          ),
        ).thenAnswer(
          (_) {},
        );
        when(subscriber.onMessage(any)).thenThrow(StateError('message'));
        messaging.publish(MockMessage());
        await untilCalled(
          observer.onDispatchFailed(
            any,
            any,
            subscriber: anyNamed('subscriber'),
            trace: anyNamed('trace'),
          ),
        );

        verify(
          observer.onDispatchFailed(
            argThat(isA<MockMessage>()),
            argThat(isA<StateError>()),
            subscriber:
                argThat(isA<MockMessagingSubscriber>(), named: 'subscriber'),
            trace: anyNamed('trace'),
          ),
        ).called(1);
      },
      timeout: const Timeout(
        Duration(
          seconds: 5,
        ),
      ),
    );

    tearDown(() {
      messaging.stop();
    });
  });
  group('Subscription', () {
    late Messaging messaging;
    late MockILogger logger;
    setUp(() {
      logger = MockILogger();
      messaging = Messaging(
        guards: [],
        logger: logger,
        messagingQueueFactory: (_) => SyncMessagingQueue(dispatcher: _),
        store: MessagingMemoryStore(),
        observers: [],
      );
    });

    test(
      'allows to be notified on each message we subscribed',
      () async {
        messaging.start();
        final subscriber = MockMessagingSubscriber();
        final message1 = RandomMessage();
        final message2 = MockMessage();
        messaging.subscribe(subscriber, to: RandomMessage);
        messaging.subscribe(subscriber, to: MockMessage);

        when(subscriber.onMessage(any)).thenAnswer(
          (realInvocation) => Future<void>.value(),
        );
        await messaging.publishNow(message1);
        await messaging.publishNow(message2);

        verify(subscriber.onMessage(argThat(isA<RandomMessage>()))).called(1);
        verify(subscriber.onMessage(argThat(isA<MockMessage>()))).called(1);
      },
    );

    test(
      'receives message by their priority',
      () async {
        await messaging.start();
        final subscriber = MockMessagingSubscriber();
        final message1 = RandomMessage(); // priority 10
        final message2 = MockMessage(); // priority 0
        messaging.subscribe(subscriber, to: RandomMessage);
        messaging.subscribe(subscriber, to: MockMessage);
        final completer = Completer<void>();
        Message? firstDispatchedMessage;

        when(subscriber.onMessage(any)).thenAnswer(
          (realInvocation) {
            final message = realInvocation.positionalArguments[0] as Message;
            firstDispatchedMessage ??= message;
            if (!completer.isCompleted) {
              completer.complete();
            }
            return Future<void>.value();
          },
        );
        messaging.pause();
        messaging.publish(message2);
        messaging.publish(message1);
        await Future<void>.delayed(const Duration(milliseconds: 500));
        messaging.resume();
        await completer.future;

        verify(subscriber.onMessage(any)).called(2);
        expect(firstDispatchedMessage, isA<RandomMessage>());
      },
    );

    test(
      'allows to be notified respecting the order of subscription using publishNow',
      () async {
        await messaging.start();
        final subscriber1 = MockMessagingSubscriber();
        final subscriber2 = MockMessagingSubscriberTwo();
        messaging.subscribe(subscriber2, to: MockMessage);
        messaging.subscribe(subscriber1, to: MockMessage);

        when(subscriber1.onMessage(any)).thenAnswer(
          (realInvocation) {
            return Future<void>.delayed(const Duration(milliseconds: 500));
          },
        );

        when(subscriber2.onMessage(any)).thenAnswer(
          (realInvocation) {
            return Future<void>.delayed(const Duration(milliseconds: 500));
          },
        );
        await messaging.publishNow(MockMessage());

        verifyInOrder([
          subscriber2.onMessage(any),
          subscriber1.onMessage(any),
        ]);
      },
    );

    test(
      'will not stop others message to be dispatched if one throws an error',
      () async {
        await messaging.start();
        final subscriber1 = MockMessagingSubscriber();
        final subscriber2 = MockMessagingSubscriberTwo();
        messaging.subscribe(subscriber2, to: MockMessage);
        messaging.subscribe(subscriber1, to: MockMessage);
        final completer = Completer<void>();
        when(subscriber1.onMessage(any)).thenAnswer(
          (realInvocation) {
            if (!completer.isCompleted) {
              completer.complete();
            }
            return Future<void>.delayed(const Duration(milliseconds: 500));
          },
        );

        when(subscriber2.onMessage(any)).thenThrow(StateError('message'));
        messaging.publish(MockMessage());
        await completer.future;
        verifyInOrder([
          subscriber2.onMessage(any),
          subscriber1.onMessage(any),
        ]);
      },
    );

    tearDown(() {
      messaging.stop();
    });
  });
}
