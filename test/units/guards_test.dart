import 'package:messaging/src/common/message.dart';
import 'package:messaging/src/guards/guards.dart';
import 'package:messaging/src/messaging.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

@GenerateNiceMocks(
  [
    MockSpec<Messaging>(),
    MockSpec<Message>(
      as: #MockOneShotMessage,
    ),
    MockSpec<Message>(
      as: #MockUniqueMessage,
    ),
    MockSpec<Message>(
      as: #MockDependencyMessage,
    ),
    MockSpec<Message>(
      as: #MockSecondDependencyMessage,
    ),
  ],
)
import 'guards_test.mocks.dart';

void main() {
  group('OneShotMessagingGuard', () {
    test('factory always returns same instance', () {
      final instance1 = OneShotMessagingGuard();
      final instance2 = OneShotMessagingGuard();

      expect(instance1, equals(instance2));
    });
    test('newInstance always returned different instance', () {
      final List<Type> types = <Type>[];
      final instance1 =
          OneShotMessagingGuard.newInstance(oneShotMessageTypes: types);
      final instance2 =
          OneShotMessagingGuard.newInstance(oneShotMessageTypes: types);

      expect(instance1, isNot(equals(instance2)));
    });
    test('newInstance and factory are different instances', () {
      final List<Type> types = <Type>[];
      final instance1 =
          OneShotMessagingGuard.newInstance(oneShotMessageTypes: types);
      final instance2 = OneShotMessagingGuard();

      expect(instance1, isNot(equals(instance2)));
    });

    test('one shot message are not allowed', () {
      OneShotMessagingGuard.setDefaultOneShotMessageTypes(
        <Type>[MockOneShotMessage],
        force: true,
      );
      final messaging = MockMessaging();

      final responseFirstTry =
          OneShotMessagingGuard().can(MockOneShotMessage(), messaging);
      final responseSecondTry =
          OneShotMessagingGuard().can(MockOneShotMessage(), messaging);

      expect(responseFirstTry, isA<AllowedMessagingGuardResponse>());
      expect(responseSecondTry, isA<NotAllowedMessagingGuardResponse>());
    });
  });
  group('UniqueDependantMessagingGuard', () {
    test('factory always returns same instance', () {
      final instance1 = UniqueDependantMessagingGuard();
      final instance2 = UniqueDependantMessagingGuard();

      expect(instance1, equals(instance2));
    });
    test('newInstance always returned different instance', () {
      final Map<Type, Iterable<Type>> types = <Type, Iterable<Type>>{};
      final instance1 = UniqueDependantMessagingGuard.newInstance(
        uniqueDependantMessageTypes: types,
      );
      final instance2 = UniqueDependantMessagingGuard.newInstance(
        uniqueDependantMessageTypes: types,
      );

      expect(instance1, isNot(equals(instance2)));
    });
    test('newInstance and factory are different instances', () {
      final Map<Type, Iterable<Type>> types = <Type, Iterable<Type>>{};
      final instance1 = UniqueDependantMessagingGuard.newInstance(
        uniqueDependantMessageTypes: types,
      );
      final instance2 = UniqueDependantMessagingGuard();

      expect(instance1, isNot(equals(instance2)));
    });

    test('unique dependant message are not allowed', () {
      UniqueDependantMessagingGuard.setDefaultUniqueDependantMessageTypes(
        {
          MockUniqueMessage: <Type>[
            MockDependencyMessage,
            MockSecondDependencyMessage,
          ],
        },
        force: true,
      );
      final messaging = MockMessaging();

      final responseFirstTry =
          UniqueDependantMessagingGuard().can(MockUniqueMessage(), messaging);
      final responseSecondTry =
          UniqueDependantMessagingGuard().can(MockUniqueMessage(), messaging);
      UniqueDependantMessagingGuard()
          .observer
          .onPostDispatch(MockDependencyMessage());
      final responseAfterDispatchDependency =
          UniqueDependantMessagingGuard().can(MockUniqueMessage(), messaging);

      expect(responseFirstTry, isA<AllowedMessagingGuardResponse>());
      expect(responseSecondTry, isA<NotAllowedMessagingGuardResponse>());
      expect(
        responseAfterDispatchDependency,
        isA<AllowedMessagingGuardResponse>(),
      );
    });
  });
}
