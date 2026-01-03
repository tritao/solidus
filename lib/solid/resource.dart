part of "solid.dart";

final class Resource<T> implements Dependency, Disposable {
  Resource._(this._owner, {T? initialValue})
      : _value = initialValue,
        _loading = true;

  final Owner _owner;
  final Set<Computation> _subscribers = <Computation>{};

  T? _value;
  Object? _error;
  bool _loading;
  bool _disposed = false;
  int _version = 0;

  T? get value {
    final computation = _currentComputation;
    if (computation != null) computation._track(this);
    return _value;
  }

  bool get loading {
    final computation = _currentComputation;
    if (computation != null) computation._track(this);
    return _loading;
  }

  Object? get error {
    final computation = _currentComputation;
    if (computation != null) computation._track(this);
    return _error;
  }

  void refetch(void Function(int version) runFetch) {
    if (_disposed) return;
    _version++;
    _setLoading(true);
    runFetch(_version);
  }

  void _setLoading(bool next) {
    if (_loading == next) return;
    _loading = next;
    _notify();
  }

  void _resolve(int version, T next) {
    if (_disposed) return;
    if (version != _version) return;
    _error = null;
    _value = next;
    _loading = false;
    _notify();
  }

  void _reject(int version, Object err) {
    if (_disposed) return;
    if (version != _version) return;
    _error = err;
    _loading = false;
    _notify();
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

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _version++;
    _subscribers.clear();
  }
}

/// Flushes any scheduled computations immediately.
///
/// Intended for tests and rare integration points; prefer relying on the
/// microtask scheduler during normal runtime.
void flushSync() => _flushSync();

Resource<T> createResource<T>(
  Future<T> Function() fetcher, {
  T? initialValue,
}) {
  final owner = _currentOwner;
  if (owner == null) {
    throw StateError("createResource() called with no active owner");
  }

  final resource = Resource<T>._(owner, initialValue: initialValue);
  owner._own(resource);

  void run(int version) {
    fetcher()
        .then<void>((value) => resource._resolve(version, value))
        .catchError((Object e, StackTrace _) => resource._reject(version, e));
  }

  resource.refetch(run);
  return resource;
}

Resource<T> createResourceWithSource<S, T>(
  S Function() source,
  Future<T> Function(S source) fetcher, {
  T? initialValue,
}) {
  final owner = _currentOwner;
  if (owner == null) {
    throw StateError("createResourceWithSource() called with no active owner");
  }

  final resource = Resource<T>._(owner, initialValue: initialValue);
  owner._own(resource);

  void runFetch(int version, S s) {
    fetcher(s)
        .then<void>((value) => resource._resolve(version, value))
        .catchError((Object e, StackTrace _) => resource._reject(version, e));
  }

  createEffect(() {
    final s = source();
    resource.refetch((version) => runFetch(version, s));
  });

  return resource;
}
