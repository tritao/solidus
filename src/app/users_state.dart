import './user.dart';

sealed class UsersAction {
  const UsersAction();
}

final class UsersStartLoad extends UsersAction {
  const UsersStartLoad();
}

final class UsersLoaded extends UsersAction {
  const UsersLoaded(this.users);
  final List<User> users;
}

final class UsersFailed extends UsersAction {
  const UsersFailed(this.message);
  final String message;
}

final class UsersClear extends UsersAction {
  const UsersClear();
}

final class UsersSetEndpoint extends UsersAction {
  const UsersSetEndpoint(this.endpoint);
  final String endpoint;
}

final class UsersState {
  const UsersState({
    required this.endpoint,
    required this.isLoading,
    required this.error,
    required this.users,
  });

  final String endpoint;
  final bool isLoading;
  final String? error;
  final List<User> users;

  static const usersAll = 'https://jsonplaceholder.typicode.com/users';
  static const usersLimited =
      'https://jsonplaceholder.typicode.com/users?_limit=5';

  factory UsersState.initial() => const UsersState(
        endpoint: usersAll,
        isLoading: false,
        error: null,
        users: [],
      );
}

UsersState usersReducer(UsersState state, UsersAction action) {
  switch (action) {
    case UsersSetEndpoint(:final endpoint):
      return UsersState(
        endpoint: endpoint,
        isLoading: false,
        error: null,
        users: const [],
      );
    case UsersStartLoad():
      return UsersState(
        endpoint: state.endpoint,
        isLoading: true,
        error: null,
        users: state.users,
      );
    case UsersLoaded(:final users):
      return UsersState(
        endpoint: state.endpoint,
        isLoading: false,
        error: null,
        users: users,
      );
    case UsersFailed(:final message):
      return UsersState(
        endpoint: state.endpoint,
        isLoading: false,
        error: message,
        users: const [],
      );
    case UsersClear():
      return UsersState(
        endpoint: state.endpoint,
        isLoading: false,
        error: null,
        users: const [],
      );
  }
}

