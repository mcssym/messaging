## 0.3.1

- Remove `logger` dependency.
- Update dart constraint to `<=4.0.0`.

## 0.3.0

- Fix un subscription by comparing subscriber key

## 0.2.0

- Fix bug in `OneShotMessagingGuard` and `UniqueDependantMessagingGuard` that cause the instance to be shared between different types.

## 0.2.0

- Create `CallbackMessagingObserver` to add observer without implementing a class.
- Create `OneShotMessagingGuard`
- Create `UniqueDependantMessagingGuard`

### Bug Fixes

- Reset OneShot and UniqueDependant messaging guard instance when default types is reset ([9d14673](https://github.com/mcssym/messaging/commit/9d146731ca6e96e31aab73411f44c7fc9e948a6f))

## 0.1.0

- Initial version.
