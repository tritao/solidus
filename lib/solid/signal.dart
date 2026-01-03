part of "solid.dart";

final class Signal<T> implements Dependency {
  Signal(this._value);

  T _value;
  final Set<Computation> _subscribers = <Computation>{};

  T get value {
    final computation = _currentComputation;
    if (computation != null) computation._track(this);
    return _value;
  }

  set value(T next) {
    if (_value == next) return;
    _value = next;
    _notify();
  }

  void update(T Function(T current) fn) => value = fn(value);

  void _notify() {
    if (_subscribers.isEmpty) return;
    for (final sub in _subscribers.toList(growable: false)) {
      sub._markStale();
    }
  }

  @override
  void _subscribe(Computation computation) => _subscribers.add(computation);

  @override
  void _unsubscribe(Computation computation) =>
      _subscribers.remove(computation);
}

Signal<T> createSignal<T>(T initial) => Signal<T>(initial);

final class Memo<T> implements Dependency {
  Memo(this._compute, this._owner) {
    _computation = Computation._(() {
      final next = _compute();
      final changed = !_hasValue || next != _cached;
      _cached = next;
      _hasValue = true;
      if (changed) _notify();
    }, _owner, isMemo: true);
  }

  final T Function() _compute;
  final Owner _owner;
  late final Computation _computation;

  T? _cached;
  bool _hasValue = false;

  final Set<Computation> _subscribers = <Computation>{};

  T get value {
    final computation = _currentComputation;
    if (computation != null) computation._track(this);
    if (!_hasValue) _computation._run();
    return _cached as T;
  }

  void _notify() {
    if (_subscribers.isEmpty) return;
    for (final sub in _subscribers.toList(growable: false)) {
      sub._markStale();
    }
  }

  @override
  void _subscribe(Computation computation) => _subscribers.add(computation);

  @override
  void _unsubscribe(Computation computation) =>
      _subscribers.remove(computation);
}

Memo<T> createMemo<T>(T Function() compute) {
  final owner = _currentOwner;
  if (owner == null)
    throw StateError("createMemo() called with no active owner");
  return Memo<T>(compute, owner);
}

final class Effect implements Disposable {
  Effect._(this._computation);

  final Computation _computation;

  void update(void Function() fn, {bool runNow = false}) =>
      _computation._setFn(fn, runNow: runNow);

  @override
  void dispose() => _computation.dispose();
}

Effect createEffect(void Function() fn) {
  final owner = _currentOwner;
  if (owner == null)
    throw StateError("createEffect() called with no active owner");
  return Effect._(Computation._(fn, owner, isMemo: false));
}
