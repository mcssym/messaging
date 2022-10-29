/// The state of the messaging instance
enum MessagingState {
  /// The messaging just started
  started,

  /// The messaging just be resumed
  resumed,

  /// The messaging is stopped
  stopped,

  /// The messaging is paused
  paused,
}
