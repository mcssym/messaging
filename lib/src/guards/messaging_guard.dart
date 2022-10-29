import '../common/message.dart';
import '../messaging.dart';

/// A response from guard
abstract class MessagingGuardResponse {
  /// If the message is allowed by the guard
  final bool allowed;

  /// Default constructor
  const MessagingGuardResponse({required this.allowed});
}

/// Response from guard that allows the message
class AllowedMessagingGuardResponse extends MessagingGuardResponse {
  /// Constructor
  const AllowedMessagingGuardResponse() : super(allowed: true);
}

/// Response from guard that doesn't allow the message
class NotAllowedMessagingGuardResponse extends MessagingGuardResponse {
  /// Reason of why the message is not allowed
  final Object? reason;

  /// Constructor
  const NotAllowedMessagingGuardResponse({
    this.reason,
  }) : super(allowed: false);
}

/// Messaging guard that check if the message can be published
abstract class MessagingGuard {
  /// Check if [message] is allowed
  MessagingGuardResponse can(Message message, Messaging messaging);
}
