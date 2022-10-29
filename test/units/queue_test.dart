import 'dart:async';

import 'package:messaging/src/queue/message_queue.dart';
import 'package:messaging/src/queue/sync_message_queue.dart';
import 'package:messaging/src/queue/timer_message_queue.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateMocks(
  [
    MessageQueueDispatcher,
  ],
)
import 'queue_test.mocks.dart';

class CallbackDispatcher implements MessageQueueDispatcher {
  final void Function(String key) onDispatch;

  CallbackDispatcher({required this.onDispatch});
  @override
  void dispatch(String key) {
    onDispatch(key);
  }
}

void main() {
  group('MessageQueue', () {
    test(
      'dispatches all pending items during resume',
      () async {
        final dispatcher = MockMessageQueueDispatcher();
        final messageQueue = SyncMessageQueue(
          dispatcher: dispatcher,
          isPaused: true,
        );
        for (var i = 0; i < 4; i++) {
          messageQueue.addQueueItem(QueueItem(item: 'item_$i', priority: i));
        }

        when(dispatcher.dispatch(any)).thenAnswer((_) {});
        messageQueue.resume();

        verify(dispatcher.dispatch(any)).called(4);
      },
    );
    test(
      'removes all pending items during resume',
      () async {
        final dispatcher = MockMessageQueueDispatcher();
        final messageQueue = SyncMessageQueue(
          resumeStrategy: ResumeQueueStrategy.removePendingMessages,
          dispatcher: dispatcher,
          isPaused: true,
        );
        for (var i = 0; i < 4; i++) {
          messageQueue.addQueueItem(QueueItem(item: 'item_$i', priority: i));
        }

        when(dispatcher.dispatch(any)).thenAnswer((_) {});
        final lengthBeforeResume = messageQueue.length;
        messageQueue.resume();

        expect(lengthBeforeResume, equals(4));
        expect(messageQueue.length, equals(0));
        verifyNever(dispatcher.dispatch(any));
      },
    );
    test(
      'removes all pending items during all resume except the first one',
      () async {
        final dispatcher = MockMessageQueueDispatcher();
        final messageQueue = SyncMessageQueue(
          resumeStrategy:
              ResumeQueueStrategy.removePendingMessagesButFirstResume,
          dispatcher: dispatcher,
          isPaused: true,
        );
        for (var i = 0; i < 4; i++) {
          messageQueue.addQueueItem(QueueItem(item: 'item_$i', priority: i));
        }

        when(dispatcher.dispatch(any)).thenAnswer((_) {});
        final lengthBeforeResume = messageQueue.length;
        messageQueue.resume();
        final lengthAfterFirstResume = messageQueue.length;
        messageQueue.resume();

        expect(lengthBeforeResume, equals(4));
        expect(lengthAfterFirstResume, equals(4));
        expect(messageQueue.length, equals(0));
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
        final messageQueue = SyncMessageQueue(
          dispatcher: dispatcher,
          isPaused: true,
        );
        messageQueue.addQueueItem(const QueueItem(item: 'item_0', priority: 0));
        messageQueue.addQueueItem(const QueueItem(item: 'item_3', priority: 3));
        messageQueue
            .addQueueItem(const QueueItem(item: 'item_2', priority: 10));
        messageQueue.addQueueItem(const QueueItem(item: 'item_1', priority: 1));

        messageQueue.resume();
        await completer.future;

        expect(firstDispatchedKey, equals('item_2'));
      },
    );
  });
  group('SyncMessageQueue', () {
    late SyncMessageQueue messageQueue;
    setUp(() {
      messageQueue = SyncMessageQueue(dispatcher: MockMessageQueueDispatcher());
    });

    test(
      'has length equals to 1 when paused and one message is added',
      () async {
        messageQueue.pause();
        messageQueue.addQueueItem(
          const QueueItem(
            item: 'item',
            priority: 1,
          ),
        );
        expect(messageQueue.length, equals(1));
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
        messageQueue.addQueueItem(
          const QueueItem(
            item: 'item',
            priority: 1,
          ),
        );

        expect(messageQueue.length, equals(0));
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
        final SyncMessageQueue messageQueue = SyncMessageQueue(
          dispatcher: CallbackDispatcher(
            onDispatch: (key) {
              dispatchedKey = key;
            },
          ),
        );
        const String addedKey = 'key_dispatched';
        messageQueue.addQueueItem(
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
        final SyncMessageQueue messageQueue = SyncMessageQueue(
          dispatcher: CallbackDispatcher(
            onDispatch: (key) {
              dispatchedKeyCount++;
            },
          ),
        );
        messageQueue.pause();
        const int maxToAdd = 4;
        for (int i = 0; i < maxToAdd; i++) {
          messageQueue.addQueueItem(
            QueueItem(
              item: 'item_$i',
              priority: 1,
            ),
          );
        }
        expect(dispatchedKeyCount, equals(0));

        messageQueue.resume();

        expect(dispatchedKeyCount, equals(maxToAdd));
      },
      timeout: const Timeout(
        Duration(
          seconds: 2,
        ),
      ),
    );
  });

  group('TimerMessageQueue', () {
    late TimerMessageQueue timerMessageQueue;
    setUp(() {
      timerMessageQueue =
          TimerMessageQueue(dispatcher: MockMessageQueueDispatcher());
    });

    test(
      'has length equals to 1 when not resumed and one message is added',
      () async {
        timerMessageQueue.addQueueItem(
          const QueueItem(
            item: 'item',
            priority: 1,
          ),
        );
        expect(timerMessageQueue.length, equals(1));
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
        timerMessageQueue.resume();
        timerMessageQueue.addQueueItem(
          const QueueItem(
            item: 'item',
            priority: 1,
          ),
        );

        await Future<void>.delayed(const Duration(seconds: 1));

        expect(timerMessageQueue.length, equals(0));
      },
      timeout: const Timeout(
        Duration(
          seconds: 2,
        ),
      ),
    );

    tearDown(() {
      timerMessageQueue.reset();
    });
  });
}
