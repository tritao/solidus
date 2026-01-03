part of "solid.dart";

final class Context<T> {
  Context(this._id, this.defaultValue);
  final Object _id;
  final T defaultValue;
}

final class _ContextFrame {
  _ContextFrame(this.parent);
  final _ContextFrame? parent;
  final Map<Object, Object?> values = <Object, Object?>{};
}

_ContextFrame? _currentContextFrame;

Context<T> createContext<T>(T defaultValue) =>
    Context<T>(Object(), defaultValue);

T useContext<T>(Context<T> context) {
  _ContextFrame? frame = _currentContextFrame;
  while (frame != null) {
    if (frame.values.containsKey(context._id)) {
      return frame.values[context._id] as T;
    }
    frame = frame.parent;
  }
  return context.defaultValue;
}

R provideContext<T, R>(Context<T> context, T value, R Function() fn) {
  final previous = _currentContextFrame;
  final frame = _ContextFrame(previous);
  frame.values[context._id] = value;
  _currentContextFrame = frame;

  try {
    return fn();
  } finally {
    _currentContextFrame = previous;
  }
}
