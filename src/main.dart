import 'package:web/web.dart' as web;

import './app/counter_component.dart';
import './app/todos_component.dart';
import './app/users_component.dart';
import './ui/component.dart';
import './ui/dom.dart' as dom;

void main() {
  final mount = web.document.querySelector('#app');
  if (mount == null) return;

  AppComponent(
    counter: CounterComponent(),
    todos: TodosComponent(),
    users: UsersComponent(),
  ).mountInto(mount);
}

final class AppComponent extends Component {
  AppComponent({
    required this.counter,
    required this.todos,
    required this.users,
  });

  final CounterComponent counter;
  final TodosComponent todos;
  final UsersComponent users;

  @override
  void onMount() {
    counter.mountInto(root.querySelector('#counter-root')!);
    todos.mountInto(root.querySelector('#todos-root')!);
    users.mountInto(root.querySelector('#users-root')!);
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
      ]),
      dom.div(id: 'counter-root'),
      dom.div(className: 'spacer'),
      dom.div(id: 'todos-root'),
      dom.div(className: 'spacer'),
      dom.div(id: 'users-root'),
    ]);
  }
}
