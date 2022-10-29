import 'message_queue.dart';

/// A message queue that dispatch a new key directly when it is added
class SyncMessageQueue extends MessageQueue {
  /// Constructor
  SyncMessageQueue({
    required MessageQueueDispatcher dispatcher,
    bool isPaused = false,
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
