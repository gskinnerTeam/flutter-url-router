import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_router/url_router.dart';

extension on WidgetTester {
  Future<void> settleAndExpectText(String s) async {
    await pumpAndSettle();
    expect(find.text(s), findsOneWidget);
  }
}

typedef OnChangingCallback = String? Function(UrlRouter router, String newUrl);
UrlRouter getSinglePageRouter([String? initial, OnChangingCallback? onChanging]) => UrlRouter(
    url: initial ?? '/',
    builder: (_, navigator) => Container(child: navigator),
    onChanging: onChanging,
    onGeneratePages: (router) {
      return [
        /// Create a single page that renders the current url
        MaterialPage(
          child: Center(child: Text(router.url)),
        ),
      ];
    });

void main() {
  testWidgets('initial url', (tester) async {
    // Create router with an initial route and verify it is being set correctly
    final router = getSinglePageRouter('/first');
    await tester.pumpWidget(MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router));
    await tester.settleAndExpectText('/first');
  });

  testWidgets('url changing', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    // Test default intitial url
    await tester.settleAndExpectText('/');
    // Verify that basic url changing works
    router.url = '/second';
    await tester.pumpAndSettle();
    await tester.settleAndExpectText('/second');
  });

  testWidgets('pop/push', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    router.push('1');
    router.push('1');
    router.push('1');
    await tester.settleAndExpectText('/1/1/1');
    router.pop();
    await tester.settleAndExpectText('/1/1');
    router.pop();
    await tester.settleAndExpectText('/1');
    router.pop(); // call pop an extra time, to make sure it doesn't pop past the root segment
    await tester.settleAndExpectText('/1');
  });

  testWidgets('query params', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    // Basics
    router.url = '/home?search=0';
    expect(router.urlPath, '/home');
    expect(int.tryParse(router.queryParams['search']!), 0);
    // Set query params
    router.url = '/';
    router.queryParams = {'a': 'b'};
    expect(router.queryParams, {'a': 'b'});
    await tester.settleAndExpectText('/?a=b');
    // Do a simple push, should wipe the params
    router.push('1');
    await tester.settleAndExpectText('/1');
    // Push another route, then pop with params
    router.push('1');
    router.pop({'a': 'b'});
    await tester.settleAndExpectText('/1?a=b');
    // Replace params
    router.queryParams = {'aa': 'bb'};
    await tester.settleAndExpectText('/1?aa=bb');
    // Add to existing params
    router.queryParams = router.queryParams..addAll({'c': 'd'});
    await tester.settleAndExpectText('/1?aa=bb&c=d');
    // Push a route and replace params
    router.push('1', {'e': 'f'});
    await tester.settleAndExpectText('/1/1?e=f');
    // Push route and carry params forward
    router.push('1', router.queryParams);
    await tester.settleAndExpectText('/1/1/1?e=f');
    // Pop and carry params back
    router.pop(router.queryParams);
    router.pop(router.queryParams);
    await tester.settleAndExpectText('/1?e=f');
    // Pop again and expect it not to have changed
    router.pop();
    await tester.settleAndExpectText('/1?e=f');
  });

  testWidgets('onChanging', (tester) async {
    // use an initial onChanging delegate that always returns null, blocking any changes to url
    var router = getSinglePageRouter('/', (_, url) => null);
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    // Try change url, expect it to be blocked.
    router.url = 'new';
    await tester.settleAndExpectText('/');

    // Swap onChanging delegate, and allow all changes
    router.onChanging = (_, url) => url;
    // Change it and expect it to work
    router.url = 'new';
    await tester.settleAndExpectText('new');
  });

  testWidgets('extensions', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router));
    await tester.pumpAndSettle();
    NavigatorState nav = tester.state(find.byType(Navigator));
    // Verify basic lookups are working
    expect(nav.context.urlRouter, router);
    expect(nav.context.url, router.url);
    // Check that push works as expected
    nav.context.urlPush('1');
    nav.context.urlPush('1', {'a': 'b'});
    await tester.settleAndExpectText('/1/1?a=b');
    // Check that pop works as expected
    nav.context.urlPop({'c': 'd'});
    await tester.settleAndExpectText('/1?c=d');
    // Assign url test
    nav.context.url = '/new';
    await tester.settleAndExpectText('/new');
  });
}
