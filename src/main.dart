import 'package:web/web.dart' as web;

import './app/counter_component.dart';
import './app/todos_component.dart';
import './app/users_component.dart';
import './ui/component.dart';

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
    final container = web.HTMLDivElement()
      ..id = 'app-root'
      ..className = 'container';

    final header = web.HTMLDivElement()
      ..className = 'header'
      ..append(web.HTMLHeadingElement.h1()..textContent = 'Dart + Vite (DOM demo)')
      ..append(web.HTMLParagraphElement()
        ..className = 'muted'
        ..textContent =
            'Counter + Todos (localStorage) + Fetch (async) to validate the integration.');

    container
      ..append(header)
      ..append(web.HTMLDivElement()..id = 'counter-root')
      ..append(web.HTMLDivElement()..className = 'spacer')
      ..append(web.HTMLDivElement()..id = 'todos-root')
      ..append(web.HTMLDivElement()..className = 'spacer')
      ..append(web.HTMLDivElement()..id = 'users-root');

    return container;
  }
}

