# Messaging
A dart, flexible and powerful package to connect your components and services in a loosely coupled manner.

Allows you to maximize scalability and responsiveness using mainly the publisher/subscriber pattern.

## Installation

This package is a full dart package so it can be used in every platforms supported by dart. To install it, use
- dart
```
dart pub add messaging
```
- flutter
```
flutter pub add messaging
```

## Features
Messaging has many features from the basics:
- __Publish__: allowing to publish in a loosely coupled manner a `Message` to their subscribers
- __Subscribe/Unsubscribe__: allowing a subscriber to subscribe/unsubscribe to one or many messages.

To more specifics:
- __Priority queue__: allowing you to give priority to message.
- __Store__: allowing to store message state where you want (in memory or in file or in database).
- __Publish Now__: allowing to publish to all subscribers and `await` the end of the publishing.
- __Guards__: allowing to add some guard/filter to your messaging instance to filter messages by time/app state etc.
- __Observers__: allowing to observe a message state or messaging instance state.
- __Flexibility__: allowing you to customize the interfaces used the package to adapt to your business logic.

## Usage
### Messaging

The instantiation could be simple or more complex.
``` dart
// Simply
final Messaging messaging = Messaging();

// OR 

// Complex/Flexible
final ILogger myLogger = MyLogger();
final MessagingStore store = MyStore();
final Iterable<MessagingGuard> guards = <MessagingGuard>[];
final  Iterable<MessagingObserver> observers = <MessagingObserver>[];
final MessagingQueueFactory messagingQueueFactory = (dispatcher) => MyMessagingQueue(dispatcher: dispatcher, resumeStrategy:
        ResumeQueueStrategy.dispatchPendingMessages);

final Messaging messaging = Messaging(
    logger: myLogger,
    store: store,
    guards: guards,
    observers: observers,
    messagingQueueFactory: messagingQueueFactory,
);
```
It allows us to **publish**, **subscribe** to message, has its own lifecycle and must be started before any message are dispatched.
#### Lifecycle
- `started` means the messaging has been started. Before it is started, you can add subscribers (you can even add after) and publish message but they won't be dispatched to subscribers and will remain in the queue. To start the messaging use 
```dart
await messaging.start();
```
> If you use it in a flutter application we recommend to start it before the `runApp` function.
- `stopped` means the messaging has been stopped and the queue has been reset. 
```dart
messaging.stop();
```
> Only the queue is reset, guards, observers are not changed or cleared.
- `paused` means the messaging has been paused so every published message won't be dispatched and will remain in the queue.
- `resumed` means the messaging has been resumed after a pause or start. All pending messages in the queue will be dispatch following the `resumeStrategy` of `MessagingQueue`.
### Message
A message is an immutable data structure that you send/publish. It should be an object with its class extending `Message` base class.

```dart
class UserCreateMessage extends Message {
    final User user;

    const UserCreateMessage(this.user): super(priority: 10);   
}
```
A message can be published multiple times and has a priority. Higher is the priority, more quickly it will be dispatched to subscribers. 

#### Message state
A message has a state where informations about it are saved in the store. The state of a message is accessible through its `MessageState` class with states:
- `published` the message has been published aka it has passed the guards and has been added to the queue.
- `dispatching` the message is currently dispatching and the subscriber key that already received the message is saved in the `MessageState`
- `dispatched` the message has been dispatched to all current subscribers.

### Subscription
To subscribe to a message you must have a subscriber or a class that implemented `MessagingSubscriber`. This class can be service, a component, a widget etc. A subscriber can
- be implemented like
```dart
class UserCreateSubscriber implements MessagingSubscriber {
    @override
    Future<void> onMessage(Message message) {
        if (message is UserCreateMessage) {
            // Do related stuff
        }
    }

    @override
    String get subscriberKey => '$UserCreateSubscriber';
}
```
- subscribe like
```dart
final UserCreateSubscriber subscriber = UserCreateSubscriber();
messaging.subscribe(subscriber, to: UserCreateMessage);

// OR
messaging.subscribeAll(subscriber, to: <Type>[UserCreateMessage]);
```
- unsubscribe like
```dart
messaging.unsubscribe(subscriber, to: UserCreateMessage);

// OR
messaging.unsubscribeAll(subscriber); // It will unsubscribe to all subscribed messages
```
> __IMPORTANT__: A each subscriber should return a unique subscriber key through the getter `subscriberKey`. 
Prefer to add all subscribers before starting the messaging so that pending messages in the store could be dispatched to them.

### Publication
You can publish a message from anywhere in your code where you have access to the `Messaging` instance. A message can be published:
- in queue
```dart
final User user = User(name: 'John Doe');
final UserCreateMessage message = UserCreateMessage(user);
final PublishResult result = messaging.publish(message);
```
- immediately

```dart
final User user = User(name: 'John Doe');
final UserCreateMessage message = UserCreateMessage(user);
final PublishResult result = await messaging.publishNow(message);
```

#### Similarities between `in queue` and `immediately`
- They check that the message is allowed by the guards.
- They inform the observers.
- They save the message in the store.
- They return a `PublishResult`.

#### Differences between `in queue` and `immediately`
- `in queue` is synchronous and `immediately` is asynchronous.
- `in queue` added the message in queue and `immediately` directly dispatches the message to subscribers so doesn't add it in the queue.

#### Result of publication
The methods `publish` and `publishNow` returns a `PublishResult` that allows to know if the publication succeed or not. If the publication was not allowed by the guards, the result will be a `GuardPublishResult` and if it failed for another reason (for example a subscriber throws an error and you pass `strategy` of `publishNow` to `PublishNowErrorHandlingStrategy.breakDispatch`), it will be a `FailedPublishResult`.

### Observation
It is possible to observe many changes in the package through an observer that will be inform for specific operations that occurred. It is possible to create an observer like
```dart
class MyObserver extends MessagingObserver {
  @override
  void onPrePublish(Message message) {
    // Informed before message is published
    super.onPrePublish(message);
  }

  @override
  void onDispatchFailed(Message message, Object error, {MessagingSubscriber? subscriber, StackTrace? trace}) {
    // Informed when an error occurred during dispatching (to an subscriber or not) 
    super.onDispatchFailed(message, error, subscriber, trace);
  }

  @override
  void onMessagingStateChanged(MessagingState state) {
    // Informed when the state of the messaging instance changed
    super.onMessagingStateChanged(state);
  }

  @override
  void onNotAllowed(Message message, MessagingGuard guard, MessagingGuardResponse response) {
    // Informed when a message is not allowed by a guard
    super.onNotAllowed(message, guard, response);
  }

  @override
  void onPostDispatch(Message message) {
    // Informed after the message is dispatched
    super.onPostDispatch(message);
  }

  @override
  void onPostPublish(Message message) {
    // Informed after the message is published
    super.onPostPublish(message);
  }

  @override
  void onPreDispatch(Message message) {
    // Informed before the message is dispatched
    super.onPreDispatch(message);
  }

  @override
  void onPublishFailed(Message message, Object error, {StackTrace? trace}) {
    // Informed when publication of a message failed for any other reason but the guard
    super.onPublishFailed(message, error, trace);
  }

  @override
  void onSaved(Message message) {
    // Informed when the message is saved in the store
    super.onSaved(message);
  }
}
```

Then you can add your observer in two ways:
- In instantiation of your `Messaging`.
- Adding to the observers property like `messaging.observers.add(MyObserver())`.

### Guard
It is also possible to add a guard to allow you to filter message that should not be publish. It could be implemented like
```dart
class OnceMessageGuard implements MessagingGuard, MessagingObserver {
  static const List<Type> messageTypePublishableOnce = [
    AppLaunchMessage,
    RefreshTokenMessage
  ];
  final List<Type> _messageTypeAlreadyPublishedOnce = [];

  @override
  MessagingGuardResponse can(Message message, Messaging messaging) {
    if (messageTypePublishableOnce.contains(message.runtimeType)) {
      if (_messageTypeAlreadyPublishedOnce.contains(message.runtimeType)) {
        return const NotAllowedMessagingGuardResponse();
      } else {
        _messageTypeAlreadyPublishedOnce.add(message.runtimeType);
      }
    }

    return const AllowedMessagingGuardResponse();
  }

  @override
  void onPublishFailed(Message message, Object error, {StackTrace? trace}) {
    _checkAndRemove(message);
  }

  @override
  void onNotAllowed(Message message, Object error, {StackTrace? trace}) {
    _checkAndRemove(message);
  }

  void _checkAndRemove(Message message) {
    if (messageTypePublishableOnce.contains(message.runtimeType)) {
      _messageTypeAlreadyPublishedOnce.remove(message.runtimeType);
    }
  }
}
```
> Yes your guard can also be an observer. Just be sure to use the same instance ^^.
Then you can add your observer in two ways:
- In instantiation of your `Messaging`.
- Adding to the observers property like `messaging.guards.add(OnceMessageGuard())`.
### Customization
#### Queue
All published messages are added to queue which is a `MessagingQueue` using their generated unique key and this one is responsable to dispatch a message to subscribers through the messaging api. The implementation (so the behavior) of the queue can be different on your needs. You can create your own implementation by extending/implementing the `MessagingQueue` class and give your implementation through the `MessagingQueueFactory` parameter of `Messaging` or use the existing ones:
- `TimerMessagingQueue` that uses an internal `Timer` to dispatch message at interval of time.
- `SyncMessagingQueue` that dispatches messages directly when they are published to the queue.

> __IMPORTANT__: If you extend `MessagingQueue` to dispatch a message you just have to call `dispatchQueuedItem()` method. The method `onItemAddedToQueue` is called every time a new item/message is added/published to the queue. 

#### Store
Before being published and after being allowed by the guards, the message is saved in the store. This store is also used to get message by their generated key before dispatching it. You can implement your own store by extending/implementing `MessagingStore` or you can use the implemented `MessagingMemoryStore` that saved messages in memory.

#### Logger
The logger is only used to log operation made. The default implementation use `logger` package internally and can be configured through the `logConfig` parameter or you can use your own implementation.
## Additional information

There's many others functionalities that'll come in the next version so i am open to contributions or simply discussion about the current implementation.

### TODOs
- Add group/channel of message and allow to subscribe to it
- Integrate
    - Idempotent messages
    - Poison messages
    - Repeated messages
    - Message expiration
    - Message scheduling
