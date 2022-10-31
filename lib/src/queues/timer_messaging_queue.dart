import 'dart:async';

import 'messaging_queue.dart';

/// A message queue that dispatch a new key every [timing].
///
/// It is paused by default so won't dispatch any item until you resume it.
class TimerMessagingQueue extends MessagingQueue {
  /// Duration between each timer loop
  final Duration timing;

  Timer? _timer;

  /// Constructor
  TimerMessagingQueue({
    required MessagingQueueDispatcher dispatcher,
    bool isPaused = true,
    ResumeQueueStrategy resumeStrategy = ResumeQueueStrategy.nothing,
    this.timing = const Duration(milliseconds: 500),
  }) : super(
          dispatcher: dispatcher,
          isPaused: isPaused,
          resumeStrategy: resumeStrategy,
        ) {
    _init();
  }

  /// Cancel the timer
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void reset() {
    super.reset();
    cancel();
  }

  @override
  void resume() {
    super.resume();
    if (_timer == null || _timer?.isActive != true) {
      _init();
    }
  }

  void _handleTimer(Timer timer) {
    dispatchQueuedItem();
  }

  void _init() {
    _timer = Timer.periodic(timing, _handleTimer);
  }
}
