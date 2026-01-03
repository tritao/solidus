import "dart:js_interop";

import "package:dart_web_test/solid.dart";
import "package:web/web.dart" as web;

typedef SolidView = Object? Function();

Dispose render(web.Node mount, SolidView view) {
  return createRoot<Dispose>((dispose) {
    mount.textContent = "";

    final nodes = _normalizeToNodes(view());
    for (final node in nodes) {
      mount.appendChild(node);
    }

    onCleanup(() {
      for (final node in nodes) {
        _detach(node);
      }
    });

    return dispose;
  });
}

web.Text text(String Function() compute) {
  final node = web.Text("");
  createRenderEffect(() {
    node.data = compute();
  });
  return node;
}

/// Binds an attribute value; removes the attribute when `compute()` returns null.
void attr(
  web.Element element,
  String name,
  String? Function() compute,
) {
  createRenderEffect(() {
    final value = compute();
    if (value == null) {
      element.removeAttribute(name);
      return;
    }
    element.setAttribute(name, value);
  });
}

/// Binds an element property via a setter.
void prop<T>(
  void Function(T value) set,
  T Function() compute,
) {
  createRenderEffect(() {
    set(compute());
  });
}

/// Binds `element.className` to a computed string.
void className(web.Element element, String Function() compute) {
  createRenderEffect(() {
    element.className = compute();
  });
}

/// Binds class presence based on a computed map.
void classList(
  web.Element element,
  Map<String, bool> Function() compute,
) {
  createRenderEffect(() {
    final next = compute();
    for (final entry in next.entries) {
      if (entry.value) {
        element.classList.add(entry.key);
      } else {
        element.classList.remove(entry.key);
      }
    }
  });
}

/// Binds inline styles; removes the property when the value is null.
void style(
  web.HTMLElement element,
  Map<String, String?> Function() compute,
) {
  createRenderEffect(() {
    final next = compute();
    for (final entry in next.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value == null) {
        element.style.removeProperty(key);
      } else {
        element.style.setProperty(key, value);
      }
    }
  });
}

/// Adds an event listener and automatically unregisters it on cleanup.
void on(
  web.EventTarget target,
  String type,
  void Function(web.Event event) handler,
) {
  final jsHandler = ((web.Event e) => handler(e)).toJS;
  target.addEventListener(type, jsHandler);
  onCleanup(() => target.removeEventListener(type, jsHandler));
}

/// Inserts dynamic content into [parent] between comment anchors.
///
/// The [compute] callback may return:
/// - `null` (renders nothing)
/// - `String` / `num` / `bool` (renders as a text node)
/// - `web.Node`
/// - `Iterable<web.Node>`
web.DocumentFragment insert(web.Node parent, Object? Function() compute) {
  final start = web.Comment("solid:start");
  final end = web.Comment("solid:end");
  final fragment = web.DocumentFragment()
    ..appendChild(start)
    ..appendChild(end);

  final current = <web.Node>[];

  void replaceWith(List<web.Node> next) {
    for (final node in current) {
      _detach(node);
    }
    current
      ..clear()
      ..addAll(next);

    for (final node in next) {
      end.parentNode?.insertBefore(node, end);
    }
  }

  createRenderEffect(() {
    final next = _normalizeToNodes(compute());
    replaceWith(next);
  });

  onCleanup(() {
    replaceWith(const []);
    _detach(start);
    _detach(end);
  });

  return fragment;
}

web.Comment Portal({
  required SolidView children,
  web.Node? mount,
}) {
  final placeholder = web.Comment("solid:portal");
  final target = mount ?? web.document.body!;
  final container = web.HTMLDivElement()
    ..setAttribute("data-solid-portal", "1");
  target.appendChild(container);

  Dispose? disposeSubtree;
  createChildRoot<void>((dispose) {
    disposeSubtree = dispose;
    final nodes = _normalizeToNodes(children());
    for (final node in nodes) {
      container.appendChild(node);
    }
    onCleanup(() {
      for (final node in nodes) {
        _detach(node);
      }
      _detach(container);
    });
  });

  onCleanup(() => disposeSubtree?.call());
  return placeholder;
}

web.DocumentFragment Show({
  required bool Function() when,
  required SolidView children,
  SolidView? fallback,
}) {
  final start = web.Comment("solid:show-start");
  final end = web.Comment("solid:show-end");
  final fragment = web.DocumentFragment()
    ..appendChild(start)
    ..appendChild(end);

  Dispose? disposeSubtree;
  final current = <web.Node>[];

  void clear() {
    for (final node in current) {
      _detach(node);
    }
    current.clear();
    disposeSubtree?.call();
    disposeSubtree = null;
  }

  void mount(SolidView builder) {
    clear();
    createChildRoot<void>((dispose) {
      disposeSubtree = dispose;
      final nodes = _normalizeToNodes(builder());
      current.addAll(nodes);
      for (final node in nodes) {
        end.parentNode?.insertBefore(node, end);
      }
    });
  }

  createRenderEffect(() {
    if (when()) {
      if (disposeSubtree == null) mount(children);
      return;
    }
    if (fallback != null) {
      if (disposeSubtree == null) mount(fallback);
      return;
    }
    clear();
  });

  onCleanup(() {
    clear();
    _detach(start);
    _detach(end);
  });

  return fragment;
}

web.DocumentFragment For<T, K>({
  required Iterable<T> Function() each,
  required K Function(T value) key,
  required web.Node Function(T Function() value) children,
}) {
  final start = web.Comment("solid:for-start");
  final end = web.Comment("solid:for-end");
  final fragment = web.DocumentFragment()
    ..appendChild(start)
    ..appendChild(end);

  final Map<K, _ForItem<T, K>> byKey = <K, _ForItem<T, K>>{};

  void disposeRemoved(Set<K> keep) {
    final remove = <K>[];
    for (final k in byKey.keys) {
      if (!keep.contains(k)) remove.add(k);
    }
    for (final k in remove) {
      final item = byKey.remove(k);
      if (item == null) continue;
      item.dispose();
      for (final node in item.nodes) {
        _detach(node);
      }
    }
  }

  createRenderEffect(() {
    final values = each().toList(growable: false);
    final keep = <K>{};
    final nextItems = <_ForItem<T, K>>[];

    for (final v in values) {
      final k = key(v);
      keep.add(k);
      final existing = byKey[k];
      if (existing != null) {
        existing.signal.value = v;
        nextItems.add(existing);
        continue;
      }

      late _ForItem<T, K> created;
      createChildRoot<void>((dispose) {
        final sig = createSignal<T>(v);
        final nodes = _normalizeToNodes(children(() => sig.value));
        created = _ForItem<T, K>(k, sig, nodes, dispose);
      });
      byKey[k] = created;
      nextItems.add(created);
    }

    disposeRemoved(keep);

    // Ensure DOM order matches [nextItems] by moving existing nodes.
    for (final item in nextItems) {
      for (final node in item.nodes) {
        end.parentNode?.insertBefore(node, end);
      }
    }
  });

  onCleanup(() {
    for (final item in byKey.values) {
      item.dispose();
      for (final node in item.nodes) {
        _detach(node);
      }
    }
    byKey.clear();
    _detach(start);
    _detach(end);
  });

  return fragment;
}

List<web.Node> _normalizeToNodes(Object? value) {
  if (value == null) return const <web.Node>[];
  if (value is web.Node) return <web.Node>[value];
  if (value is Iterable<web.Node>) return value.toList(growable: false);
  if (value is String || value is num || value is bool) {
    return <web.Node>[web.Text(value.toString())];
  }
  throw ArgumentError.value(
    value,
    "value",
    "Expected null, String/num/bool, Node, or Iterable<Node>",
  );
}

void _detach(web.Node node) {
  final parent = node.parentNode;
  if (parent == null) return;
  parent.removeChild(node);
}

final class _ForItem<T, K> {
  _ForItem(this.key, this.signal, this.nodes, this.dispose);

  final K key;
  final Signal<T> signal;
  final List<web.Node> nodes;
  final Dispose dispose;
}
