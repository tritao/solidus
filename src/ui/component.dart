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

  web.Element render();

  void onMount() {}

  void onAfterPatch() {}

  web.Element get root => _root;

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
}

