import 'package:uuid/uuid.dart';

/// Class to resolve unique key
abstract class KeyResolver {
  /// Constructor
  const KeyResolver();

  /// Resolve a unique key
  Future<String> resolve();
}

/// Default key resolver
class DefaultKeyResolver extends KeyResolver {
  Uuid get _uuid => const Uuid();

  /// Constructor
  const DefaultKeyResolver();

  @override
  Future<String> resolve() {
    return Future.value(_uuid.v4());
  }
}
