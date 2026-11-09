extension NullableListExt<T> on List<T>? {
  bool get isNotEmpty => this != null && this!.isNotEmpty;
  bool get isEmpty => this == null || this!.isEmpty;
}

extension ListExt<T> on List<T> {
  /// Returns element at [index] or null if out of bounds.
  T? safeGet(int index) => (index < 0 || index >= length) ? null : this[index];

  /// Splits list into chunks of [size].
  List<List<T>> chunks(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, (i + size).clamp(0, length)));
    }
    return result;
  }

  /// Index of the first element matching [test], or null if none matches.
  int? indexOrNull(bool Function(T) test) {
    final index = indexWhere(test);
    return index == -1 ? null : index;
  }
}

extension NullableIterableExt<T> on Iterable<T?> {
  /// Drops null elements. `[1, null, 2]` → `[1, 2]`.
  List<T> whereNotNull() => where((e) => e != null).cast<T>().toList();
}

extension IterableExt<T> on Iterable<T> {
  List<T> distinctBy<K>(K Function(T) key) {
    final seen = <K>{};
    return where((e) => seen.add(key(e))).toList();
  }

  Iterable<R> mapIndexed<R>(R Function(int index, T item) f) sync* {
    var i = 0;
    for (final item in this) {
      yield f(i++, item);
    }
  }

  /// Groups elements by a key. Returns a `Map<K, List<T>>`.
  Map<K, List<T>> groupBy<K>(K Function(T) key) {
    final result = <K, List<T>>{};
    for (final item in this) {
      result.putIfAbsent(key(item), () => []).add(item);
    }
    return result;
  }

  num sumBy(num Function(T) selector) =>
      fold<num>(0, (acc, e) => acc + selector(e));

  double averageBy(num Function(T) selector) {
    if (isEmpty) return 0;
    return sumBy(selector) / length;
  }

  T? maxBy<R extends Comparable<R>>(R Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) >= 0 ? a : b);
  }

  T? minBy<R extends Comparable<R>>(R Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) <= 0 ? a : b);
  }
}

extension ListMutationExt<T> on List<T> {
  /// Adds [item] if absent, removes it if present.
  List<T> toggled(T item) {
    final copy = List<T>.from(this);
    if (copy.contains(item)) {
      copy.remove(item);
    } else {
      copy.add(item);
    }
    return copy;
  }
}
