import 'package:flame/components.dart';

/// Generic object pool for Flame components to eliminate allocations during gameplay.
class GameObjectPool<T extends Component> {
  final T Function() factory;
  final int initialCapacity;
  final List<T> _available = [];
  final Set<T> _inUse = {};

  GameObjectPool({
    required this.factory,
    this.initialCapacity = 0,
  }) {
    for (int i = 0; i < initialCapacity; i++) {
      _available.add(factory());
    }
  }

  int get availableCount => _available.length;
  int get inUseCount => _inUse.length;
  int get totalCount => _available.length + _inUse.length;

  /// Acquires an instance from the pool, or creates a new one if exhausted.
  T acquire() {
    final T item;
    if (_available.isNotEmpty) {
      item = _available.removeLast();
    } else {
      item = factory();
    }
    _inUse.add(item);
    return item;
  }

  /// Releases an instance back into the pool.
  void release(T item) {
    if (_inUse.remove(item)) {
      if (item.isMounted) {
        item.removeFromParent();
      }
      _available.add(item);
    }
  }

  /// Releases all currently in-use instances back into the pool.
  void releaseAll() {
    for (final item in _inUse) {
      if (item.isMounted) {
        item.removeFromParent();
      }
      _available.add(item);
    }
    _inUse.clear();
  }

  /// Clears both available and in-use pools.
  void clear() {
    for (final item in _inUse) {
      if (item.isMounted) {
        item.removeFromParent();
      }
    }
    _inUse.clear();
    _available.clear();
  }
}
