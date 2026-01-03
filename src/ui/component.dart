import 'dart:async';

import 'package:web/web.dart' as web;

import '../morph_patch.dart';

final class RenderScheduler {
  RenderScheduler._();

  static final RenderScheduler instance = RenderScheduler._();

  final Set<Component> _dirty = <Component>{};
  bool _scheduled = false;

  void invalidate(Component component) {
    _dirty.add(component);
    if (_scheduled) return;
    _scheduled = true;
    scheduleMicrotask(_flush);
  }

  void _flush() {
    _scheduled = false;
    if (_dirty.isEmpty) return;

    final toRender = List<Component>.from(_dirty);
    _dirty.clear();

    for (final component in toRender) {
      component._performRender();
    }
  }
}

abstract class Component {
  Component();

  late final web.Element _root;
  bool _mounted = false;
  final List<void Function()> _cleanups = <void Function()>[];

  web.Element render();

  void onMount() {}

  void onAfterPatch() {}

  void onDispose() {}

  web.Element get root => _root;

  bool get isMounted => _mounted;

  void addCleanup(void Function() cleanup) {
    if (!_mounted) return;
    _cleanups.add(cleanup);
  }

  StreamSubscription<T> listen<T>(
    Stream<T> stream,
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final sub = stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    addCleanup(() => sub.cancel());
    return sub;
  }

  void mountInto(web.Element mount) {
    if (_mounted) return;
    _root = render();
    mount.append(_root);
    _mounted = true;
    onMount();
  }

  void setState(void Function() fn) {
    fn();
    if (!_mounted) return;
    RenderScheduler.instance.invalidate(this);
  }

  void invalidate() {
    if (!_mounted) return;
    RenderScheduler.instance.invalidate(this);
  }

  void _performRender() {
    if (!_mounted) return;
    final next = render();
    morphPatch(_root, next);
    onAfterPatch();
  }

  void dispose() {
    if (!_mounted) return;
    try {
      onDispose();
    } catch (_) {}
    for (final cleanup in _cleanups.reversed) {
      try {
        cleanup();
      } catch (_) {}
    }
    _cleanups.clear();
    _mounted = false;
  }
}
