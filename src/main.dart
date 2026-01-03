import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

void main() {
  final mount = web.document.querySelector('#app');
  if (mount == null) return;

  final app = _App(mount: mount);
  app.init();
}

enum _Tab { counter, todos, fetch }

class _Todo {
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

class _App {
  _App({required this.mount});

  final web.Element mount;

  _Tab tab = _Tab.counter;
  int counter = 0;

  int _nextTodoId = 1;
  final List<_Todo> _todos = [];

  bool _isLoadingUsers = false;
  String? _usersError;
  List<Map<String, Object?>> _users = const [];

  void init() {
    _loadTodos();
    _render();
  }

  void _setState(void Function() fn) {
    fn();
    _render();
  }

  void _render() {
    mount.textContent = '';
    mount.append(_buildShell());
  }

  web.Element _buildShell() {
    final container = web.HTMLDivElement()..className = "container";

    final header = web.HTMLDivElement()
      ..className = "header"
      ..append(web.HTMLHeadingElement.h1()
        ..textContent = "Dart + Vite (DOM demo)")
      ..append(web.HTMLParagraphElement()
        ..className = "muted"
        ..textContent =
            "Counter + Todos (localStorage) + Fetch (async) to validate the integration.");

    container..append(header)..append(_buildTabs())..append(_buildView());
    return container;
  }

  web.Element _buildTabs() {
    final tabs = web.HTMLDivElement()..className = "tabs";
    tabs.append(_tabButton(_Tab.counter, "Counter"));
    tabs.append(_tabButton(_Tab.todos, "Todos"));
    tabs.append(_tabButton(_Tab.fetch, "Fetch"));
    return tabs;
  }

  web.HTMLButtonElement _tabButton(_Tab value, String label) {
    final button = web.HTMLButtonElement()
      ..type = "button"
      ..textContent = label
      ..className = tab == value ? "tab active" : "tab";
    button.onClick.listen((_) => _setState(() => tab = value));
    return button;
  }

  web.Element _buildView() {
    switch (tab) {
      case _Tab.counter:
        return _buildCounterView();
      case _Tab.todos:
        return _buildTodosView();
      case _Tab.fetch:
        return _buildFetchView();
    }
  }

  web.Element _buildCard({
    required String title,
    required List<web.Element> children,
  }) {
    final card = web.HTMLDivElement()..className = "card";
    card.append(web.HTMLHeadingElement.h2()..textContent = title);
    for (final child in children) {
      card.append(child);
    }
    return card;
  }

  web.Element _buildCounterView() {
    final row = web.HTMLDivElement()..className = "row";
    row
      ..append(_button("−1", onClick: () => _setState(() => counter--)))
      ..append(_button("+1", onClick: () => _setState(() => counter++)))
      ..append(_button("Reset",
          kind: "secondary", onClick: () => _setState(() => counter = 0)));

    return _buildCard(title: "Counter", children: [
      web.HTMLParagraphElement()
        ..className = "big"
        ..textContent = "$counter",
      row,
      web.HTMLParagraphElement()
        ..className = "muted"
        ..textContent = "Exercises DOM updates and event handlers.",
    ]);
  }

  web.Element _buildTodosView() {
    final input = web.HTMLInputElement()
      ..type = "text"
      ..placeholder = "New todo…"
      ..className = "input";

    void addTodo() {
      final text = input.value?.trim() ?? "";
      if (text.isEmpty) return;
      _setState(() {
        _todos.insert(0, _Todo(id: _nextTodoId++, text: text));
        _saveTodos();
        input.value = "";
      });
    }

    input.onKeyDown.listen((e) {
      if (e.key == "Enter") addTodo();
    });

    final list = web.HTMLUListElement()..className = "list";
    if (_todos.isEmpty) {
      list.append(web.HTMLLIElement()
        ..className = "muted"
        ..textContent = "No todos yet.");
    } else {
      for (final todo in _todos) {
        list.append(_buildTodoItem(todo));
      }
    }

    final remaining = _todos.where((t) => !t.done).length;

    final row = web.HTMLDivElement()..className = "row";
    row
      ..append(input)
      ..append(_button("Add", onClick: addTodo))
      ..append(_button(
        "Clear done",
        kind: "secondary",
        disabled: _todos.every((t) => !t.done),
        onClick: () => _setState(() {
          _todos.removeWhere((t) => t.done);
          _saveTodos();
        }),
      ));

    return _buildCard(title: "Todos", children: [
      row,
      web.HTMLParagraphElement()
        ..className = "muted"
        ..textContent =
            "${_todos.length} total • $remaining remaining • persists to localStorage",
      list,
    ]);
  }

  web.HTMLLIElement _buildTodoItem(_Todo todo) {
    final item = web.HTMLLIElement()..className = "item";

    final checkbox = web.HTMLInputElement()
      ..type = "checkbox"
      ..checked = todo.done
      ..className = "checkbox";
    checkbox.onChange.listen((_) {
      _setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index == -1) return;
        _todos[index] = _todos[index].copyWith(done: checkbox.checked == true);
        _saveTodos();
      });
    });

    final label = web.HTMLSpanElement()
      ..textContent = todo.text
      ..className = todo.done ? "todoText done" : "todoText";

    final remove = _button("Delete", kind: "danger", onClick: () {
      _setState(() {
        _todos.removeWhere((t) => t.id == todo.id);
        _saveTodos();
      });
    });

    item..append(checkbox)..append(label)..append(remove);
    return item;
  }

  web.Element _buildFetchView() {
    final status = web.HTMLParagraphElement()..className = "muted";
    if (_isLoadingUsers) {
      status.textContent = "Loading users…";
    } else if (_usersError != null) {
      status
        ..className = "muted error"
        ..textContent = _usersError!;
    } else if (_users.isEmpty) {
      status.textContent = "Click “Load users” to fetch JSON from the network.";
    } else {
      status.textContent = "Loaded ${_users.length} users.";
    }

    final list = web.HTMLUListElement()..className = "list";
    for (final user in _users) {
      final name = (user["name"] as String?) ?? "(no name)";
      final email = (user["email"] as String?) ?? "";
      final li = web.HTMLLIElement()..className = "item";
      li.append(web.HTMLSpanElement()
        ..className = "user"
        ..textContent = name);
      if (email.isNotEmpty) {
        li.append(web.HTMLSpanElement()
          ..className = "muted"
          ..textContent = " • $email");
      }
      list.append(li);
    }

    final row = web.HTMLDivElement()..className = "row";
    row
      ..append(_button(
        _isLoadingUsers ? "Loading…" : "Load users",
        disabled: _isLoadingUsers,
        onClick: _loadUsers,
      ))
      ..append(_button(
        "Clear",
        kind: "secondary",
        disabled: _isLoadingUsers && _users.isEmpty,
        onClick: () => _setState(() {
          _usersError = null;
          _users = const [];
        }),
      ));

    return _buildCard(title: "Fetch (async)", children: [
      row,
      status,
      if (_users.isNotEmpty) list,
      web.HTMLParagraphElement()
        ..className = "muted"
        ..textContent = "Endpoint: https://jsonplaceholder.typicode.com/users",
    ]);
  }

  web.HTMLButtonElement _button(
    String label, {
    required void Function() onClick,
    String kind = "primary",
    bool disabled = false,
  }) {
    final button = web.HTMLButtonElement()
      ..type = "button"
      ..textContent = label
      ..disabled = disabled
      ..className = "btn $kind";
    button.onClick.listen((_) {
      if (!button.disabled) onClick();
    });
    return button;
  }

  void _loadTodos() {
    final storage = web.window.localStorage;
    if (storage == null) return;

    final raw = storage.getItem("todos_v1");
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
      _nextTodoId = maxId + 1;
    } catch (_) {
      // Ignore corrupted localStorage.
      _todos.clear();
      _nextTodoId = 1;
    }
  }

  void _saveTodos() {
    final storage = web.window.localStorage;
    if (storage == null) return;

    final encoded = jsonEncode(_todos.map((t) => t.toJson()).toList());
    storage.setItem("todos_v1", encoded);
  }

  Future<void> _loadUsers() async {
    _setState(() {
      _isLoadingUsers = true;
      _usersError = null;
    });

    try {
      final response = await http.get(
        Uri.parse("https://jsonplaceholder.typicode.com/users"),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception("HTTP ${response.statusCode}");
      }

      final raw = response.body;
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw FormatException("Unexpected response shape");
      }
      final users = decoded
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList(growable: false);
      _setState(() {
        _users = users;
      });
    } catch (e) {
      _setState(() {
        _usersError = "Failed to load users: $e";
      });
    } finally {
      _setState(() {
        _isLoadingUsers = false;
      });
    }
  }
}
