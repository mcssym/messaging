/// Wrapper class that allows to have access to specific method of an [Iterable]
class IterableWrapper<T> {
  /// The iterable
  final List<T> _iterable;

  /// Constructor
  IterableWrapper(Iterable<T> items) : _iterable = List<T>.from(items);

  /// Get iterator of iterable
  Iterator<T> get iterator => _iterable.iterator;

  /// Add [item] to the iterable
  void add(T item) {
    _iterable.add(item);
  }

  /// Prepend [item] in the iterable
  ///
  /// If [before] is not null then [item] will be insert before it.
  void prepend(T item, {T? before}) {
    if (before == null) {
      _iterable.insert(0, item);
    } else {
      final index = _iterable.indexOf(before);
      _iterable.insert(index != -1 ? index : 0, item);
    }
  }

  /// Append [item] in the iterable
  ///
  /// If [after] is not null then [item] will be insert after it.
  void append(T item, {T? after}) {
    if (after != null) {
      final index = _iterable.indexOf(after);
      final newIndex = index + 1;
      if (index != -1 && newIndex < _iterable.length) {
        _iterable.insert(newIndex, item);
        return;
      }
    }
    _iterable.add(item);
  }

  /// Get the number of items in the iterable
  int get length => _iterable.length;

  /// Check if the iterable is not empty
  bool get isNotEmpty => _iterable.isNotEmpty;

  /// Check if the iterable is empty
  bool get isEmpty => _iterable.isEmpty;

  /// Remove [item] from the iterable
  void remove(T item) {
    _iterable.remove(item);
  }

  /// Clear the iterable
  void clear() {
    _iterable.clear();
  }

  /// Invokes [action] on each item of the iterable
  void forEach(void Function(T observer) action) {
    _iterable.forEach(action);
  }

  /// Get element at [index]
  ///
  /// It same as doing `Iterable<T>.elementAt(index)`
  T elementAt(int index) {
    return _iterable.elementAt(index);
  }
}
