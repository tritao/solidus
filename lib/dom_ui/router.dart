import 'package:web/web.dart' as web;

typedef RouterDispose = void Function();

String? getQueryParam(String key) => Uri.base.queryParameters[key];

bool getQueryFlag(String key, {bool defaultValue = false}) {
  final value = getQueryParam(key);
  if (value == null) return defaultValue;
  return value == '1' || value.toLowerCase() == 'true';
}

RouterDispose listenPopState(void Function(Uri uri) handler) {
  final sub = web.window.onPopState.listen((_) => handler(Uri.base));
  return () {
    // Best-effort: callers generally don't need to await cancellation.
    // ignore: discarded_futures
    sub.cancel();
  };
}

void setQueryParam(
  String key,
  String? value, {
  bool replace = true,
}) {
  final current = Uri.base;
  final params = Map<String, String>.from(current.queryParameters);
  if (value == null) {
    params.remove(key);
  } else {
    params[key] = value;
  }

  final next = current.replace(queryParameters: params.isEmpty ? null : params);
  final url = next.toString();

  if (replace) {
    web.window.history.replaceState(null, '', url);
  } else {
    web.window.history.pushState(null, '', url);
  }
}

/// Returns a normalized `?docs=...` slug for use by the docs router.
///
/// Historically the docs home used `?docs=1`; treat null/empty/"1" as "index".
String normalizeDocsSlug(String? slug) {
  if (slug == null || slug.isEmpty || slug == '1') return 'index';
  return slug;
}
