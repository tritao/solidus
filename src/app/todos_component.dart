import 'dart:convert';

import 'package:web/web.dart' as web;

import '../ui/component.dart';
import '../ui/dom.dart' as dom;

final class _Todo {
  _Todo({
    required this.id,
    required this.text,
    this.done = false,
  });

  final int id;
  final String text;
  final bool done;

  _Todo copyWith({String? text, bool? done}) =>
      _Todo(id: id, text: text ?? this.text, done: done ?? this.done);

  Map<String, Object?> toJson() => {"id": id, "text": text, "done": done};

  static _Todo fromJson(Map<String, Object?> json) => _Todo(
        id: (json["id"] as num).toInt(),
        text: (json["text"] as String?) ?? "",
        done: (json["done"] as bool?) ?? false,
      );
}

abstract final class _TodosActions {
  static const add = 'todos-add';
  static const clearDone = 'todos-clear-done';
  static const toggle = 'todos-toggle';
  static const remove = 'todos-remove';
}

final class TodosComponent extends Component {
  TodosComponent();

  static const _storageKey = 'todos_v1';

  int _nextId = 1;
  final List<_Todo> _todos = [];

  web.HTMLInputElement? _input;

  @override
  web.Element render() {
    final input = dom.inputText(
      id: 'todos-input',
      className: 'input',
      placeholder: 'New todo…',
    );

    final list = dom.ul(className: 'list');
    if (_todos.isEmpty) {
      list.append(dom.li(className: 'muted', text: 'No todos yet.'));
    } else {
      for (final todo in _todos) {
        list.append(_todoItem(todo));
      }
    }

    final remaining = _todos.where((t) => !t.done).length;

    final row = dom.div(className: 'row');
    row
      ..append(input)
      ..append(dom.button('Add', action: _TodosActions.add))
      ..append(dom.button(
        'Clear done',
        kind: 'secondary',
        disabled: _todos.every((t) => !t.done),
        action: _TodosActions.clearDone,
      ));

    return dom.card(title: 'Todos', children: [
      row,
      dom.p(
        '${_todos.length} total • $remaining remaining • persists to localStorage',
        className: 'muted',
      ),
      list,
    ]);
  }

  @override
  void onMount() {
    _loadTodos();
    root.onClick.listen(_onClick);
    root.onChange.listen(_onChange);
    root.onKeyDown.listen(_onKeyDown);
    _cacheRefs();
    invalidate();
  }

  @override
  void onAfterPatch() => _cacheRefs();

  void _cacheRefs() {
    try {
      _input = root.querySelector('#todos-input') as web.HTMLInputElement?;
    } catch (_) {
      _input = null;
    }
  }

  void _onClick(web.MouseEvent event) {
    final actionEl = _actionElement(event.target);
    if (actionEl == null) return;

    final action = actionEl.getAttribute('data-action');
    if (action == null) return;

    switch (action) {
      case _TodosActions.add:
        _addFromInput();
      case _TodosActions.clearDone:
        setState(() {
          _todos.removeWhere((t) => t.done);
          _saveTodos();
        });
      case _TodosActions.remove:
        final id = int.tryParse(actionEl.getAttribute('data-id') ?? '');
        if (id == null) return;
        setState(() {
          _todos.removeWhere((t) => t.id == id);
          _saveTodos();
        });
    }
  }

  void _onChange(web.Event event) {
    final target = event.target;
    if (target == null) return;

    web.Element? targetEl;
    try {
      targetEl = target as web.Element;
    } catch (_) {
      return;
    }

    final actionEl = targetEl.closest('[data-action="${_TodosActions.toggle}"]');
    if (actionEl == null) return;

    final id = int.tryParse(actionEl.getAttribute('data-id') ?? '');
    if (id == null) return;

    try {
      final checkbox = actionEl as web.HTMLInputElement;
      final checked = checkbox.checked == true;
      setState(() {
        final index = _todos.indexWhere((t) => t.id == id);
        if (index == -1) return;
        _todos[index] = _todos[index].copyWith(done: checked);
        _saveTodos();
      });
    } catch (_) {
      return;
    }
  }

  void _onKeyDown(web.KeyboardEvent event) {
    if (event.key != 'Enter') return;
    final target = event.target;
    if (target == null) return;

    web.Element? targetEl;
    try {
      targetEl = target as web.Element;
    } catch (_) {
      return;
    }

    if (targetEl.getAttribute('id') == 'todos-input') {
      _addFromInput();
    }
  }

  web.Element? _actionElement(web.EventTarget? target) {
    if (target == null) return null;
    try {
      final targetEl = target as web.Element;
      return targetEl.closest('[data-action]');
    } catch (_) {
      return null;
    }
  }

  void _addFromInput() {
    final input = _input;
    if (input == null) return;

    final text = input.value.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.insert(0, _Todo(id: _nextId++, text: text));
      _saveTodos();
    });

    input.value = '';
  }

  void _loadTodos() {
    final storage = web.window.localStorage;
    if (storage == null) return;

    final raw = storage.getItem(_storageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      _todos
        ..clear()
        ..addAll(decoded.whereType<Map>().map((e) {
          final map = e.map((k, v) => MapEntry(k.toString(), v));
          return _Todo.fromJson(map);
        }));
      final maxId =
          _todos.isEmpty ? 0 : _todos.map((t) => t.id).reduce((a, b) => a > b ? a : b);
      _nextId = maxId + 1;
    } catch (_) {
      _todos.clear();
      _nextId = 1;
    }
  }

  void _saveTodos() {
    final storage = web.window.localStorage;
    if (storage == null) return;
    storage.setItem(_storageKey, jsonEncode(_todos.map((t) => t.toJson()).toList()));
  }

  web.HTMLLIElement _todoItem(_Todo todo) {
    final item = dom.li(
      className: 'item',
      attrs: {'data-key': 'todos-${todo.id}'},
    );

    final checkbox = dom.checkbox(
      checked: todo.done,
      className: 'checkbox',
      attrs: {
        'data-action': _TodosActions.toggle,
        'data-id': '${todo.id}',
      },
    );

    final label =
        dom.span(todo.text, className: todo.done ? 'todoText done' : 'todoText');

    final remove = dom.button(
      'Delete',
      kind: 'danger',
      action: _TodosActions.remove,
      dataId: todo.id,
    );

    item..append(checkbox)..append(label)..append(remove);
    return item;
  }
}
