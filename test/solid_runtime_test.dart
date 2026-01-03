import "dart:async";

import "package:dart_web_test/solid.dart";
import "package:test/test.dart";

Future<void> pump() async {
  await Future<void>.delayed(Duration.zero);
}

void main() {
  group("solid runtime", () {
    test("effect tracks signal and reruns on change", () async {
      final runs = <int>[];
      late Signal<int> count;

      late Dispose dispose;
      createRoot<void>((d) {
        dispose = d;
        count = createSignal<int>(0);
        createEffect(() {
          runs.add(count.value);
        });
      });

      expect(runs, [0]);
      count.value = 1;
      await pump();
      expect(runs, [0, 1]);

      dispose();
      count.value = 2;
      await pump();
      expect(runs, [0, 1]);
    });

    test("dynamic dependencies switch correctly", () async {
      final hits = <String>[];

      late Signal<bool> useA;
      late Signal<int> a;
      late Signal<int> b;

      late Dispose dispose;
      createRoot<void>((d) {
        dispose = d;
        useA = createSignal<bool>(true);
        a = createSignal<int>(0);
        b = createSignal<int>(0);

        createEffect(() {
          if (useA.value) {
            hits.add("a:${a.value}");
          } else {
            hits.add("b:${b.value}");
          }
        });
      });

      expect(hits, ["a:0"]);

      a.value = 1;
      await pump();
      expect(hits.last, "a:1");

      useA.value = false;
      await pump();
      expect(hits.last, "b:0");

      a.value = 2;
      await pump();
      expect(hits.last, "b:0");

      b.value = 3;
      await pump();
      expect(hits.last, "b:3");

      dispose();
    });

    test("onCleanup runs before rerun and on dispose", () async {
      final log = <String>[];
      late Signal<int> s;
      late Dispose dispose;

      createRoot<void>((d) {
        dispose = d;
        s = createSignal<int>(0);
        createEffect(() {
          onCleanup(() => log.add("cleanup"));
          log.add("run:${s.value}");
        });
      });

      expect(log, ["run:0"]);

      s.value = 1;
      await pump();
      expect(log, ["run:0", "cleanup", "run:1"]);

      dispose();
      expect(log, ["run:0", "cleanup", "run:1", "cleanup"]);
    });

    test("batch coalesces multiple writes", () async {
      late Signal<int> s;
      final seen = <int>[];

      late Dispose dispose;
      createRoot<void>((d) {
        dispose = d;
        s = createSignal<int>(0);
        createEffect(() => seen.add(s.value));
      });

      expect(seen, [0]);

      batch(() {
        s.value = 1;
        s.value = 2;
        s.value = 3;
      });

      await pump();
      expect(seen, [0, 3]);

      dispose();
    });

    test("memo caches and only recomputes when deps change", () async {
      late Signal<int> s;
      late Memo<int> m;
      var computes = 0;

      late Dispose dispose;
      createRoot<void>((d) {
        dispose = d;
        s = createSignal<int>(1);
        m = createMemo(() {
          computes++;
          return s.value * 2;
        });
      });

      expect(computes, 1);
      expect(m.value, 2);
      expect(m.value, 2);
      expect(computes, 1);

      s.value = 2;
      await pump();
      expect(m.value, 4);
      expect(computes, 2);

      dispose();
    });

    test("untrack prevents subscription", () async {
      late Signal<int> s;
      var runs = 0;

      late Dispose dispose;
      createRoot<void>((d) {
        dispose = d;
        s = createSignal<int>(0);
        createEffect(() {
          runs++;
          untrack(() => s.value);
        });
      });

      expect(runs, 1);
      s.value = 1;
      await pump();
      expect(runs, 1);

      dispose();
    });

    test("context provides nearest value", () async {
      final ctx = createContext<String>("default");
      final values = <String>[];

      late Dispose dispose;
      createRoot<void>((d) {
        dispose = d;
        values.add(useContext(ctx));
        provideContext(ctx, "outer", () {
          values.add(useContext(ctx));
          provideContext(ctx, "inner", () {
            values.add(useContext(ctx));
          });
          values.add(useContext(ctx));
        });
        values.add(useContext(ctx));
      });

      expect(values, ["default", "outer", "inner", "outer", "default"]);
      dispose();
    });

    test("effects observe memo changes", () async {
      late Signal<int> s;
      late Memo<int> m;
      final seen = <int>[];

      late Dispose dispose;
      createRoot<void>((d) {
        dispose = d;
        s = createSignal<int>(1);
        m = createMemo(() => s.value * 10);
        createEffect(() => seen.add(m.value));
      });

      expect(seen, [10]);
      s.value = 2;
      await pump();
      expect(seen, [10, 20]);

      dispose();
    });

    test("resource: starts loading, resolves value, notifies dependents",
        () async {
      final states = <String>[];
      late Resource<int> r;
      late Dispose dispose;

      final completer = Completer<int>();
      createRoot<void>((d) {
        dispose = d;
        r = createResource(() => completer.future);
        createEffect(() {
          states.add("loading=${r.loading} value=${r.value}");
        });
      });

      expect(states, ["loading=true value=null"]);

      completer.complete(123);
      await pump();
      flushSync();
      expect(states.last, "loading=false value=123");

      dispose();
    });

    test("resource: cancellation ignores stale results", () async {
      late Signal<int> id;
      late Resource<String> r;
      late Dispose dispose;

      final c1 = Completer<String>();
      final c2 = Completer<String>();

      createRoot<void>((d) {
        dispose = d;
        id = createSignal<int>(1);
        r = createResourceWithSource<int, String>(
          () => id.value,
          (v) => v == 1 ? c1.future : c2.future,
        );
      });

      expect(r.loading, true);

      id.value = 2;
      await pump();
      flushSync();

      c2.complete("two");
      await pump();
      flushSync();
      expect(r.value, "two");
      expect(r.loading, false);

      c1.complete("one");
      await pump();
      flushSync();
      expect(r.value, "two");
      expect(r.loading, false);

      dispose();
    });

    test("resource: dispose prevents late resolution", () async {
      late Resource<int> r;
      late Dispose dispose;
      final completer = Completer<int>();

      createRoot<void>((d) {
        dispose = d;
        r = createResource(() => completer.future);
      });

      dispose();
      completer.complete(9);
      await pump();
      flushSync();
      expect(r.value, isNull);
    });

    test("resource: error is captured and loading stops", () async {
      late Resource<int> r;
      late Dispose dispose;
      final completer = Completer<int>();

      createRoot<void>((d) {
        dispose = d;
        r = createResource(() => completer.future);
      });

      completer.completeError(StateError("boom"));
      await pump();
      flushSync();
      expect(r.loading, false);
      expect(r.error, isA<StateError>());

      dispose();
    });
  });
}
