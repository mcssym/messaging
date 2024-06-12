import 'package:meta/meta.dart';

/// The base class extended by every kind of message
@immutable
abstract class Message {
  /// Maximum priority allowed
  static const int maxPriority = 999999999;

  /// Minimum priority allowed
  static const int minPriority = 0;

  /// Priority of this event
  ///
  /// An event with higher priority will be executed sooner. This priority should
  /// be between [minPriority] and [maxPriority]
  final int priority;

  /// Default constructor that set [priority] to [minPriority].
  const Message({this.priority = minPriority});
}
