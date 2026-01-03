import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

import '../ui/component.dart';

abstract final class _UsersActions {
  static const load = 'users-load';
  static const clear = 'users-clear';
}

final class UsersComponent extends Component {
  UsersComponent();

  bool _isLoading = false;
  String? _error;
  List<Map<String, Object?>> _users = const [];

  @override
  web.Element render() {
    final status = web.HTMLParagraphElement()..className = 'muted';
    if (_isLoading) {
      status.textContent = 'Loading users…';
    } else if (_error != null) {
      status
        ..className = 'muted error'
        ..textContent = _error!;
    } else if (_users.isEmpty) {
      status.textContent = 'Click “Load users” to fetch JSON from the network.';
    } else {
      status.textContent = 'Loaded ${_users.length} users.';
    }

    final row = web.HTMLDivElement()..className = 'row';
    row
      ..append(_button(
        _isLoading ? 'Loading…' : 'Load users',
        disabled: _isLoading,
        action: _UsersActions.load,
      ))
      ..append(_button(
        'Clear',
        kind: 'secondary',
        disabled: _isLoading && _users.isEmpty,
        action: _UsersActions.clear,
      ));

    final list = web.HTMLUListElement()..className = 'list';
    for (final user in _users) {
      final name = (user['name'] as String?) ?? '(no name)';
      final email = (user['email'] as String?) ?? '';

      final li = web.HTMLLIElement()..className = 'item';
      li.append(web.HTMLSpanElement()
        ..className = 'user'
        ..textContent = name);
      if (email.isNotEmpty) {
        li.append(web.HTMLSpanElement()
          ..className = 'muted'
          ..textContent = ' • $email');
      }
      list.append(li);
    }

    return _card(title: 'Fetch (async)', children: [
      row,
      status,
      if (_users.isNotEmpty) list,
      web.HTMLParagraphElement()
        ..className = 'muted'
        ..textContent = 'Endpoint: https://jsonplaceholder.typicode.com/users',
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
      case _UsersActions.load:
        _loadUsers();
      case _UsersActions.clear:
        setState(() {
          _error = null;
          _users = const [];
        });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users'),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) throw FormatException('Unexpected response shape');

      final users = decoded
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList(growable: false);

      setState(() => _users = users);
    } catch (e) {
      setState(() => _error = 'Failed to load users: $e');
    } finally {
      setState(() => _isLoading = false);
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

