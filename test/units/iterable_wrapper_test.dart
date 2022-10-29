import 'package:messaging/messaging.dart';
import 'package:test/test.dart';

void main() {
  test('add the item', () {
    const item = 'random item';
    final iterable = IterableWrapper<String>([]);

    iterable.add(item);

    expect(iterable.length, equals(1));
  });

  test('removes the item', () {
    const item = 'random item';
    final iterable = IterableWrapper<String>([item]);

    final lengthBeforeRemoving = iterable.length;

    iterable.remove(item);

    expect(lengthBeforeRemoving, equals(1));
    expect(iterable.length, equals(0));
  });

  test('removes uniquely the item', () {
    const item1 = 'random item';
    const item2 = 'random item';
    final iterable = IterableWrapper<String>([item1, item2]);

    final lengthBeforeRemoving = iterable.length;

    iterable.remove(item1);

    expect(lengthBeforeRemoving, equals(2));
    expect(iterable.length, equals(1));
  });

  test('add item at the first index', () {
    const item1 = 'random item 1';
    const item2 = 'random item 2';
    final iterable = IterableWrapper<String>([item1, item2]);

    const item3 = 'random item 3';

    iterable.prepend(item3);

    expect(iterable.elementAt(0), equals(item3));
  });

  test('add item before another item', () {
    const item1 = 'random item 1';
    const item2 = 'random item 2';
    final iterable = IterableWrapper<String>([item1, item2]);

    const item3 = 'random item 3';

    iterable.prepend(item3, before: item2);

    expect(iterable.elementAt(1), equals(item3));
  });

  test('add item at the end', () {
    const item1 = 'random item 1';
    const item2 = 'random item 2';
    final iterable = IterableWrapper<String>([item1, item2]);

    const item3 = 'random item 3';

    iterable.append(item3);

    expect(iterable.elementAt(2), equals(item3));
  });

  test('add item after another item', () {
    const item1 = 'random item 1';
    const item2 = 'random item 2';
    final iterable = IterableWrapper<String>([item1, item2]);

    const item3 = 'random item 3';

    iterable.append(item3, after: item1);

    expect(iterable.elementAt(1), equals(item3));
  });
}
