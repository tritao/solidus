import 'package:web/web.dart' as web;

import '../ui/component.dart';

abstract final class _CounterActions {
  static const dec = 'counter-dec';
  static const inc = 'counter-inc';
  static const reset = 'counter-reset';
}

final class CounterComponent extends Component {
  CounterComponent();

  int counter = 0;

  @override
  web.Element render() {
    final row = web.HTMLDivElement()..className = 'row';
    row
      ..append(_button('−1', action: _CounterActions.dec))
      ..append(_button('+1', action: _CounterActions.inc))
      ..append(_button('Reset', kind: 'secondary', action: _CounterActions.reset));

    return _card(title: 'Counter', children: [
      web.HTMLParagraphElement()
        ..className = 'big'
        ..textContent = '$counter',
      row,
      web.HTMLParagraphElement()
        ..className = 'muted'
        ..textContent = 'Exercises state updates and re-rendering.',
    ]);
  }

  @override
  void onMount() {
    root.onClick.listen(_onClick);
  }

  void _onClick(web.MouseEvent event) {
    final target = event.target;
    if (target == null) return;

    web.Element? targetEl;
    try {
      targetEl = target as web.Element;
    } catch (_) {
      return;
    }

    final actionEl = targetEl.closest('[data-action]');
    if (actionEl == null) return;

    final action = actionEl.getAttribute('data-action');
    if (action == null) return;

    switch (action) {
      case _CounterActions.dec:
        setState(() => counter--);
      case _CounterActions.inc:
        setState(() => counter++);
      case _CounterActions.reset:
        setState(() => counter = 0);
    }
  }

  web.Element _card({required String title, required List<web.Element> children}) {
    final card = web.HTMLDivElement()..className = 'card';
    card.append(web.HTMLHeadingElement.h2()..textContent = title);
    for (final child in children) {
      card.append(child);
    }
    return card;
  }

  web.HTMLButtonElement _button(
    String label, {
    String kind = 'primary',
    bool disabled = false,
    required String action,
  }) {
    final button = web.HTMLButtonElement()
      ..type = 'button'
      ..textContent = label
      ..disabled = disabled
      ..className = 'btn $kind';
    button.setAttribute('data-action', action);
    return button;
  }
}

