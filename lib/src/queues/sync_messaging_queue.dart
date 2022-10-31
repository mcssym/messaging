import 'messaging_queue.dart';

/// A message queue that dispatch a new key directly when it is added
class SyncMessagingQueue extends MessagingQueue {
  /// Constructor
  SyncMessagingQueue({
    required MessagingQueueDispatcher dispatcher,
    bool isPaused = true,
    ResumeQueueStrategy resumeStrategy =
        ResumeQueueStrategy.dispatchPendingMessages,
  }) : super(
          dispatcher: dispatcher,
          isPaused: isPaused,
          resumeStrategy: resumeStrategy,
        );

  @override
  void onItemAddedToQueue() {
    super.onItemAddedToQueue();
    dispatchQueuedItem();
  }
}
