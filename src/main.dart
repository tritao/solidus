import 'package:web/web.dart' as web;

import './app/config.dart';
import './app/counter_component.dart';
import './app/route.dart' as route;
import './app/todos_component.dart';
import './app/users_component.dart';
import 'package:dart_web_test/vite_ui/component.dart';
import 'package:dart_web_test/vite_ui/action_dispatch.dart';
import 'package:dart_web_test/vite_ui/dom.dart' as dom;

abstract final class _AppActions {
  static const toggleUsersEndpoint = 'app-toggle-users-endpoint';
  static const toggleUsersVisible = 'app-toggle-users-visible';
}

void main() {
  final mount = web.document.querySelector('#app');
  if (mount == null) return;

  AppComponent(
    counter: CounterComponent(),
    todos: TodosComponent(),
    usersFactory: () => UsersComponent(),
  ).mountInto(mount);
}

final class AppComponent extends Component {
  AppComponent({
    required this.counter,
    required this.todos,
    required this.usersFactory,
  });

  final CounterComponent counter;
  final TodosComponent todos;
  final UsersComponent Function() usersFactory;

  UsersComponent? _users;
  String _usersEndpoint = UsersComponent.usersAll;
  bool _showUsers = false;

  @override
  void onMount() {
    provide<AppConfig>(
      AppConfig.contextKey,
      const AppConfig(
        usersAll: UsersComponent.usersAll,
        usersLimited: UsersComponent.usersLimited,
      ),
    );
    mountChild(counter, root.querySelector('#counter-root')!);
    mountChild(todos, root.querySelector('#todos-root')!);
    _applyRoute();
    listen(root.onClick, _onClick);
    listen(web.window.onPopState, (_) => _applyRoute());
  }

  void _applyRoute() {
    final config = useContext<AppConfig>(AppConfig.contextKey);
    final state = route.readRoute(config);
    final endpoint = state.usersEndpoint;
    final showUsers = state.showUsers;

    if (endpoint != _usersEndpoint) {
      _usersEndpoint = endpoint;
      final users = _users;
      if (users != null) users.setEndpoint(endpoint);
    }

    final usersMount = root.querySelector('#users-root')!;
    if (!showUsers) {
      _showUsers = false;
      final users = _users;
      if (users != null) {
        unmountChild(users);
        usersMount.textContent = '';
        _users = null;
      }
      invalidate();
      return;
    }
    _showUsers = true;

    final existing = _users;
    if (existing != null) {
      existing.setEndpoint(_usersEndpoint);
      invalidate();
      return;
    }

    final users = usersFactory()..setEndpoint(_usersEndpoint);
    _users = users;
    usersMount.textContent = '';
    mountChild(users, usersMount);
    invalidate();
  }

  void _onClick(web.MouseEvent event) {
    dispatchAction(event, {
      _AppActions.toggleUsersEndpoint: (_) {
        final config = useContext<AppConfig>(AppConfig.contextKey);
        final next = _usersEndpoint == config.usersAll ? 'limited' : 'all';
        route.setUsersMode(next);
        _applyRoute();
      },
      _AppActions.toggleUsersVisible: (_) {
        route.setShowUsers(!_showUsers);
        _applyRoute();
      }
    });
  }

  @override
  web.Element render() {
    return dom.div(id: 'app-root', className: 'container', children: [
      dom.div(className: 'header', children: [
        dom.h1('Dart + Vite (DOM demo)'),
        dom.p(
          'Counter + Todos (localStorage) + Fetch (async) to validate the integration.',
          className: 'muted',
        ),
        dom.row(children: [
          dom.secondaryButton(
            'Toggle users endpoint',
            action: _AppActions.toggleUsersEndpoint,
          ),
          dom.secondaryButton(
            _showUsers ? 'Hide users' : 'Show users',
            action: _AppActions.toggleUsersVisible,
          ),
        ]),
      ]),
      dom.div(id: 'counter-root'),
      dom.div(className: 'spacer'),
      dom.div(id: 'todos-root'),
      dom.div(className: 'spacer'),
      dom.div(id: 'users-root'),
    ]);
  }
}
