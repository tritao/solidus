import 'package:dart_web_test/vite_ui/router.dart' as router;

import './config.dart';

final class AppRoute {
  const AppRoute({
    required this.usersEndpoint,
    required this.showUsers,
  });

  final String usersEndpoint;
  final bool showUsers;
}

AppRoute readRoute(AppConfig config) {
  final usersMode = router.getQueryParam('users');
  final endpoint =
      usersMode == 'limited' ? config.usersLimited : config.usersAll;
  final showUsers = router.getQueryFlag('showUsers', defaultValue: true);

  return AppRoute(usersEndpoint: endpoint, showUsers: showUsers);
}

void setUsersMode(String mode) => router.setQueryParam('users', mode);

void setShowUsers(bool show) =>
    router.setQueryParam('showUsers', show ? '1' : '0');

