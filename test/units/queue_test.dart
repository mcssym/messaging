import 'dart:async';

import 'package:messaging/src/queues/messaging_queue.dart';
import 'package:messaging/src/queues/sync_messaging_queue.dart';
import 'package:messaging/src/queues/timer_messaging_queue.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateMocks(
  [
    MessagingQueueDispatcher,
  ],
)
import 'queue_test.mocks.dart';

class CallbackDispatcher implements MessagingQueueDispatcher {
  final void Function(String key) onDispatch;

  CallbackDispatcher({required this.onDispatch});
  @override
  void dispatch(String key) {
    onDispatch(key);
  }
}

void main() {
  group('MessagingQueue', () {
    test(
      'dispatches all pending items during resume',
      () async {
        final dispatcher = MockMessagingQueueDispatcher();
        final messagingQueue = SyncMessagingQueue(
          dispatcher: dispatcher,
        );
        for (var i = 0; i < 4; i++) {
          messagingQueue.addQueueItem(QueueItem(item: 'item_$i', priority: i));
        }

        when(dispatcher.dispatch(any)).thenAnswer((_) {});
        messagingQueue.resume();

        verify(dispatcher.dispatch(any)).called(4);
      },
    );
    test(
      'removes all pending items during resume',
      () async {
        final dispatcher = MockMessagingQueueDispatcher();
        final messagingQueue = SyncMessagingQueue(
          resumeStrategy: ResumeQueueStrategy.removePendingMessages,
          dispatcher: dispatcher,
        );
        for (var i = 0; i < 4; i++) {
          messagingQueue.addQueueItem(QueueItem(item: 'item_$i', priority: i));
        }

        when(dispatcher.dispatch(any)).thenAnswer((_) {});
        final lengthBeforeResume = messagingQueue.length;
        messagingQueue.resume();

        expect(lengthBeforeResume, equals(4));
        expect(messagingQueue.length, equals(0));
        verifyNever(dispatcher.dispatch(any));
      },
    );
    test(
      'removes all pending items during all resume except the first one',
      () async {
        final dispatcher = MockMessagingQueueDispatcher();
        final messagingQueue = SyncMessagingQueue(
          resumeStrategy:
              ResumeQueueStrategy.removePendingMessagesButFirstResume,
          dispatcher: dispatcher,
        );
        for (var i = 0; i < 4; i++) {
          messagingQueue.addQueueItem(QueueItem(item: 'item_$i', priority: i));
        }

        when(dispatcher.dispatch(any)).thenAnswer((_) {});
        final lengthBeforeResume = messagingQueue.length;
        messagingQueue.resume();
        final lengthAfterFirstResume = messagingQueue.length;
        messagingQueue.resume();

        expect(lengthBeforeResume, equals(4));
        expect(lengthAfterFirstResume, equals(4));
        expect(messagingQueue.length, equals(0));
        verifyNever(dispatcher.dispatch(any));
      },
    );
    test(
      'checks the first dispatch has the highest priority',
      () async {
        final completer = Completer<void>();
        String? firstDispatchedKey;
        final dispatcher = CallbackDispatcher(
          onDispatch: (key) {
            firstDispatchedKey ??= key;
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
        );
        final messagingQueue = SyncMessagingQueue(
          dispatcher: dispatcher,
        );
        messagingQueue
            .addQueueItem(const QueueItem(item: 'item_0', priority: 0));
        messagingQueue
            .addQueueItem(const QueueItem(item: 'item_3', priority: 3));
        messagingQueue
            .addQueueItem(const QueueItem(item: 'item_2', priority: 10));
        messagingQueue
            .addQueueItem(const QueueItem(item: 'item_1', priority: 1));

        messagingQueue.resume();
        await completer.future;

        expect(firstDispatchedKey, equals('item_2'));
      },
    );
  });
  group('SyncMessagingQueue', () {
    late SyncMessagingQueue messagingQueue;
    setUp(() {
      messagingQueue = SyncMessagingQueue(
        dispatcher: MockMessagingQueueDispatcher(),
      );
    });

    test(
      'has length equals to 1 when paused and one message is added',
      () async {
        messagingQueue.pause();
        messagingQueue.addQueueItem(
          const QueueItem(
            item: 'item',
            priority: 1,
          ),
        );
        expect(messagingQueue.length, equals(1));
      },
      timeout: const Timeout(
        Duration(
          seconds: 2,
        ),
      ),
    );

    test(
      'has length equals to 0 when not paused and one message is added',
      () async {
        messagingQueue.resume();
        messagingQueue.addQueueItem(
          const QueueItem(
            item: 'item',
            priority: 1,
          ),
        );

        expect(messagingQueue.length, equals(0));
      },
      timeout: const Timeout(
        Duration(
          seconds: 2,
        ),
      ),
    );

    test(
      'dispatches the added message key',
      () async {
        String? dispatchedKey;
        final SyncMessagingQueue messagingQueue = SyncMessagingQueue(
          dispatcher: CallbackDispatcher(
            onDispatch: (key) {
              dispatchedKey = key;
            },
          ),
        );
        messagingQueue.resume();
        const String addedKey = 'key_dispatched';
        messagingQueue.addQueueItem(
          const QueueItem(
            item: addedKey,
            priority: 1,
          ),
        );

        expect(dispatchedKey, equals(addedKey));
      },
      timeout: const Timeout(
        Duration(
          seconds: 2,
        ),
      ),
    );

    test(
      'will dispatch all added message keys in paused state when resumed',
      () async {
        int dispatchedKeyCount = 0;
        final SyncMessagingQueue messagingQueue = SyncMessagingQueue(
          dispatcher: CallbackDispatcher(
            onDispatch: (key) {
              dispatchedKeyCount++;
            },
          ),
        );
        messagingQueue.pause();
        const int maxToAdd = 4;
        for (int i = 0; i < maxToAdd; i++) {
          messagingQueue.addQueueItem(
            QueueItem(
              item: 'item_$i',
              priority: 1,
            ),
          );
        }
        expect(dispatchedKeyCount, equals(0));

        messagingQueue.resume();

        expect(dispatchedKeyCount, equals(maxToAdd));
      },
      timeout: const Timeout(
        Duration(
          seconds: 2,
        ),
      ),
    );
  });

  group('TimerMessagingQueue', () {
    late TimerMessagingQueue messagingQueue;
    setUp(() {
      messagingQueue =
          TimerMessagingQueue(dispatcher: MockMessagingQueueDispatcher());
    });

    test(
      'has length equals to 1 when not resumed and one message is added',
      () async {
        messagingQueue.addQueueItem(
          const QueueItem(
            item: 'item',
            priority: 1,
          ),
        );
        expect(messagingQueue.length, equals(1));
      },
      timeout: const Timeout(
        Duration(
          seconds: 2,
        ),
      ),
    );

    test(
      'has length equals to 0 when resumed and one message is added',
      () async {
        messagingQueue.resume();
        messagingQueue.addQueueItem(
          const QueueItem(
            item: 'item',
            priority: 1,
          ),
        );

        await Future<void>.delayed(const Duration(seconds: 1));

        expect(messagingQueue.length, equals(0));
      },
      timeout: const Timeout(
        Duration(
          seconds: 2,
        ),
      ),
    );

    tearDown(() {
      messagingQueue.reset();
    });
  });
}
