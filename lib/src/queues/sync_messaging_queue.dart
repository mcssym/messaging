import 'messaging_queue.dart';

/// A message queue that dispatch a new key directly when it is added
class SyncMessagingQueue extends MessagingQueue {
  /// Constructor
  SyncMessagingQueue({
    required super.dispatcher,
    super.isPaused = true,
    super.resumeStrategy = ResumeQueueStrategy.dispatchPendingMessages,
  });

  @override
  void onItemAddedToQueue() {
    super.onItemAddedToQueue();
    dispatchQueuedItem();
  }
}
