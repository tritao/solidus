import 'package:web/web.dart' as web;

import 'package:solidus/dom_ui/action_dispatch.dart';
import 'package:solidus/dom_ui/component.dart';
import 'package:solidus/dom_ui/dom.dart' as dom;
import 'package:solidus/dom_ui/router.dart' as router;

import './admin_controller.dart';
import './admin_pages.dart';

final class AdminNavigator {
  AdminNavigator(this._navigate);
  final void Function(String page) _navigate;
  void go(String page) => _navigate(page);
}

const String adminNavigatorKey = 'admin.navigator';

String _normalizeAdminPage(String? page) {
  final p = (page ?? '').trim().toLowerCase();
  if (p.isEmpty || p == '1' || p == 'true') return 'tenants';
  return switch (p) {
    'login' => 'login',
    'tenants' => 'tenants',
    'members' => 'members',
    'invites' => 'invites',
    'outbox' => 'outbox',
    _ => 'tenants',
  };
}

final class AdminAppComponent extends Component {
  static const _mountShell = 'admin-shell-mount';
  static const _mountPage = 'admin-page-mount';

  AdminController get _ctrl {
    final ref = useRef<AdminController?>('admin.ctrl', null);
    ref.value ??= AdminController(baseUrl: '/api');
    return ref.value!;
  }

  String get _currentPage => useRef<String>(
          'admin.page', _normalizeAdminPage(router.getQueryParam('admin')))
      .value;

  set _currentPage(String value) =>
      useRef<String>('admin.page', 'tenants').value = value;

  Component? get _currentChild => useRef<Component?>('admin.child', null).value;

  set _currentChild(Component? value) =>
      useRef<Component?>('admin.child', null).value = value;

  @override
  void onMount() {
    final ctrl = _ctrl;
    provide<AdminController>(adminControllerKey, ctrl);
    addCleanup(ctrl.dispose);

    final nav = AdminNavigator(_navigate);
    provide<AdminNavigator>(adminNavigatorKey, nav);

    mountChild(AdminShellComponent(), queryOrThrow('#$_mountShell'));

    _syncFromUrl();

    addCleanup(router.listenPopState((_) => _syncFromUrl()));

    // Initial load: if logged in, load tenants; otherwise route to login.
    () async {
      await ctrl.refreshSession();
      if (ctrl.isAuthenticated) {
        await ctrl.loadTenants();
        final slug = router.getQueryParam('t');
        if (slug != null && slug.trim().isNotEmpty) {
          await ctrl.selectTenant(slug: slug.trim());
        }
        if (_currentPage == 'login') {
          _navigate('tenants');
        }
      } else {
        _navigate('login');
      }
    }();
  }

  void _syncFromUrl() {
    final desired = _normalizeAdminPage(router.getQueryParam('admin'));
    _setPage(desired);
    final desiredTenant = router.getQueryParam('t');
    if (desiredTenant != null && desiredTenant.trim().isNotEmpty) {
      _ctrl.selectTenant(slug: desiredTenant.trim());
    }
  }

  void _navigate(String page) {
    final normalized = _normalizeAdminPage(page);
    router.setQueryParam('admin', normalized, replace: false);
    _setPage(normalized);
  }

  void _setPage(String page) {
    if (_currentPage == page && _currentChild != null) return;
    _currentPage = page;

    final mount = queryOrThrow('#$_mountPage');
    final existing = _currentChild;
    if (existing != null) {
      unmountChild(existing);
      _currentChild = null;
    }

    final next = switch (page) {
      'login' => AdminLoginPage(),
      'tenants' => AdminTenantsPage(),
      'members' => AdminMembersPage(),
      'invites' => AdminInvitesPage(),
      'outbox' => AdminOutboxPage(),
      _ => AdminTenantsPage(),
    };

    _currentChild = next;
    mountChild(next, mount);
  }

  @override
  web.Element render() {
    return dom.div(
      id: 'admin-root',
      className: 'container containerWide',
      children: [
        dom.header(
          title: 'Admin',
          subtitle: 'Solidus admin console for `solidus_backend`.',
          actions: [
            dom.linkButton('Home', href: './'),
            dom.linkButton('Playground', href: '?backend=1'),
            dom.linkButton('Docs', href: 'docs.html#/backend'),
          ],
        ),
        dom.spacer(),
        dom.mountPoint(_mountShell),
        dom.spacer(),
        dom.mountPoint(_mountPage),
      ],
    );
  }
}

final class AdminShellComponent extends Component {
  AdminController get _ctrl => useContext<AdminController>(adminControllerKey);
  AdminNavigator get _nav => useContext<AdminNavigator>(adminNavigatorKey);

  @override
  void onMount() {
    listen(_ctrl.events, (e) {
      if (e.topic == AdminTopic.session ||
          e.topic == AdminTopic.tenants ||
          e.topic == AdminTopic.output) {
        invalidate();
      }
    });
    listen(root.onClick, _onClick);
    listen(root.onChange, _onChange);
  }

  @override
  web.Element render() {
    final me = _ctrl.me;
    final page = _normalizeAdminPage(router.getQueryParam('admin'));
    final tenants = _ctrl.tenants;

    web.Element tenantSelect() {
      final select = web.HTMLSelectElement()..className = 'input';
      select.id = 'admin-tenant-select';

      final placeholder = web.HTMLOptionElement()
        ..value = ''
        ..textContent = 'Select tenant…';
      select.appendChild(placeholder);

      for (final t in tenants) {
        final opt = web.HTMLOptionElement()
          ..value = t.slug
          ..textContent = '${t.name} (${t.slug}) • ${t.role}';
        if (t.slug == _ctrl.activeTenantSlug) opt.selected = true;
        select.appendChild(opt);
      }
      return select;
    }

    web.Element tab(String label, String p) {
      final active = page == p;
      return dom.button(
        label,
        kind: active ? 'primary' : 'secondary',
        disabled: !(_ctrl.isAuthenticated),
        action: 'admin-nav-$p',
      );
    }

    return dom.section(
      title: 'Navigation',
      subtitle: me == null ? 'Not logged in.' : 'Logged in as ${me.email}',
      children: [
        dom.spacer(),
        dom.row(children: [
          tab('Tenants', 'tenants'),
          tab('Members', 'members'),
          tab('Invites', 'invites'),
          tab('Outbox', 'outbox'),
          dom.secondaryButton(
            'Refresh /me',
            action: AdminActions.refreshMe,
            disabled: _ctrl.isDisabledFor(AdminActions.refreshMe),
          ),
          dom.secondaryButton(
            'Logout',
            action: AdminActions.logout,
            disabled: _ctrl.isDisabledFor(AdminActions.logout),
          ),
        ]),
        dom.spacer(),
        dom.row(children: [
          tenantSelect(),
          dom.secondaryButton(
            'Reload tenants',
            action: AdminActions.listTenants,
            disabled: _ctrl.isDisabledFor(AdminActions.listTenants),
          ),
        ]),
        dom.spacer(),
        dom.statusText(
          text: _ctrl.status,
          isError: _ctrl.status.toLowerCase().contains('error'),
        ),
      ],
    );
  }

  void _onClick(web.MouseEvent event) {
    dispatchAction(event, {
      'admin-nav-login': (_) => _nav.go('login'),
      'admin-nav-tenants': (_) => _nav.go('tenants'),
      'admin-nav-members': (_) => _nav.go('members'),
      'admin-nav-invites': (_) => _nav.go('invites'),
      'admin-nav-outbox': (_) => _nav.go('outbox'),
      AdminActions.refreshMe: (_) => _ctrl.refreshSession(),
      AdminActions.logout: (_) {
        _ctrl.logout();
        _nav.go('login');
      },
      AdminActions.listTenants: (_) => _ctrl.loadTenants(),
    });
  }

  void _onChange(web.Event event) {
    final el = event.target;
    if (el is! web.HTMLElement) return;
    if (el.id != 'admin-tenant-select') return;
    final select = el as web.HTMLSelectElement;
    final slug = select.value.trim();
    if (slug.isEmpty) return;
    router.setQueryParam('t', slug, replace: false);
    _ctrl.selectTenant(slug: slug);
  }
}
