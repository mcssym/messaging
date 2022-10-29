import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// A factory that allows to create a [MessageQueue]
typedef MessageQueueFactory = MessageQueue Function(
  MessageQueueDispatcher dispatcher,
);

/// Interface to access public API of the queue of messaging
abstract class MessagingQueue {
  /// length of the queue
  int get length;

  /// Check if the queue is empty
  bool get isEmpty;

  /// Check if the queue is not empty
  bool get isNotEmpty;
}

/// A queue that store all message keys
abstract class MessageQueue implements MessagingQueue {
  /// Callback that will be called every time a message by its key
  /// should be dispatched to subscribers
  final MessageQueueDispatcher dispatcher;

  /// Queue of items
  final PriorityQueue<QueueItem<String>> _queue;

  /// Strategy to apply during resume
  final ResumeQueueStrategy resumeStrategy;

  bool _paused;

  bool _alreadyResumeOnce = false;

  /// Constructor
  MessageQueue({
    required this.resumeStrategy,
    required this.dispatcher,
    required bool isPaused,
  })  : _paused = isPaused,
        _queue = PriorityQueue((p0, p1) => p0.priority < p1.priority ? 1 : -1);

  /// Check if the queue is empty
  @override
  bool get isEmpty => _queue.isEmpty;

  /// Check if the queue is not empty
  @override
  bool get isNotEmpty => _queue.isNotEmpty;

  /// Get unordered list of items inside the queue
  Iterable<QueueItem<String>> get items => _queue.unorderedElements;

  /// Get number of items in queue
  @override
  int get length => _queue.length;

  /// Check if the queue is paused
  bool get paused => _paused;

  /// Add key of a message to queue
  @nonVirtual
  void addQueueItem(QueueItem<String> item) {
    _queue.add(item);
    onItemAddedToQueue();
  }

  /// Dispatch item using [dispatcher]
  ///
  /// It should be called every time you want to dispatch a queued item.
  @protected
  @nonVirtual
  void dispatchQueuedItem() {
    if (_paused) return;

    if (_queue.isNotEmpty) {
      final item = _queue.removeFirst();
      dispatcher.dispatch(item.item);
    }
  }

  /// Action called when item is added in the queue
  @protected
  void onItemAddedToQueue() {}

  /// Pause the dispatch of item
  @mustCallSuper
  void pause() {
    if (!_paused) {
      _paused = true;
    }
  }

  /// Reset the queue
  @mustCallSuper
  void reset() {
    _queue.clear();
    _paused = true;
    _alreadyResumeOnce = false;
  }

  /// Resume the dispatch of item
  @mustCallSuper
  void resume() {
    if (_paused) {
      _paused = false;
    }
    _applyStrategyToPendingItemsInQueue();
    _alreadyResumeOnce = true;
  }

  void _applyStrategyToPendingItemsInQueue() {
    switch (resumeStrategy) {
      case ResumeQueueStrategy.dispatchPendingMessages:
        _dispatchToPendingItemsInQueue();
        break;
      case ResumeQueueStrategy.removePendingMessages:
        _removePendingItemsInQueue();
        break;
      case ResumeQueueStrategy.removePendingMessagesButFirstResume:
        if (_alreadyResumeOnce) {
          _removePendingItemsInQueue();
        }
        break;
      default:
    }
  }

  void _dispatchToPendingItemsInQueue() {
    while (isNotEmpty && !paused) {
      dispatchQueuedItem();
    }
  }

  void _removePendingItemsInQueue() {
    _queue.clear();
  }
}

/// Dispatcher that will dispatch message key
abstract class MessageQueueDispatcher {
  /// Dispatch [item] of a [QueueItem]
  void dispatch(String item);
}

/// Item of queue
class QueueItem<S> {
  /// Item
  final S item;

  /// Priority of the item in the queue
  final int priority;

  /// Constructor
  const QueueItem({
    required this.item,
    required this.priority,
  });
}

/// Strategy to apply when the queue is resumed
enum ResumeQueueStrategy {
  /// Dispatch all messages in the queue
  dispatchPendingMessages,

  /// Remove all messages from queue at resume
  ///
  /// They won't be dispatched
  removePendingMessages,

  /// Remove all message from queue at resume but at the first resume
  ///
  /// They won't be dispatched
  removePendingMessagesButFirstResume,

  /// Do nothing
  ///
  /// It assumes you will handle it by yourself
  nothing,
}
