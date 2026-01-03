import 'package:web/web.dart' as web;

import '../ui/component.dart';
import '../ui/dom.dart' as dom;
import '../ui/events.dart' as events;

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
    final row = dom.div(className: 'row');
    row
      ..append(dom.actionButton('−1', action: _CounterActions.dec))
      ..append(dom.actionButton('+1', action: _CounterActions.inc))
      ..append(
        dom.actionButton('Reset',
            kind: 'secondary', action: _CounterActions.reset),
      );

    return dom.card(title: 'Counter', children: [
      dom.p('$counter', className: 'big'),
      row,
      dom.p('Exercises state updates and re-rendering.', className: 'muted'),
    ]);
  }

  @override
  void onMount() {
    listen(root.onClick, _onClick);
  }

  void _onClick(web.MouseEvent event) {
    final action = events.actionNameFromEvent(event);
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
}
