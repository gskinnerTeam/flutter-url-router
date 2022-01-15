import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_router/url_router.dart';

UrlRouter getSinglePageRouter([String? initial, String? Function(UrlRouter router, String newUrl)? onChanging]) =>
    UrlRouter(
        url: initial ?? '/',
        builder: (_, navigator) => Container(child: navigator),
        onChanging: onChanging,
        onGeneratePages: (router) {
          return [MaterialPage(child: Center(child: Text(router.url)))];
        });

void main() {
  testWidgets('initial url', (tester) async {
    final router = getSinglePageRouter('/first');
    await tester.pumpWidget(MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router));
    await tester.pumpAndSettle();
    expect(find.text('/first'), findsOneWidget);
  });

  testWidgets('url changing', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    await tester.pumpAndSettle();
    expect(find.text('/'), findsOneWidget);
    router.url = '/second';
    await tester.pumpAndSettle();
    expect(find.text('/'), findsNothing);
    expect(find.text('/second'), findsOneWidget);
  });

  testWidgets('query params', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    router.url = '/home?search=0';
    expect(int.tryParse(router.queryParams['search']!), 0);
    expect(router.urlPath, '/home');
  });

  testWidgets('pop/push', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    router.push('1');
    router.push('1');
    router.push('1');
    expect(router.url, '/1/1/1');
    router.pop();
    expect(router.url, '/1/1');
    router.pop();
    router.pop(); // call pop an extra time, to make sure it doesn't pop past the root segment
    expect(router.url, '/1');
  });

  testWidgets('query params', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    router.queryParams = {'a': 'b'};
    expect(router.queryParams, {'a': 'b'});
    expect(router.url, '/?a=b');
    // Do a simple push, should wipe the params
    router.push('1');
    expect(router.url, '/1');
    // Push another route, then pop with params
    router.push('1');
    router.pop({'a': 'b'});
    expect(router.url, '/1?a=b');
    // Replace params
    router.queryParams = {'aa': 'bb'};
    expect(router.url, '/1?aa=bb');
    // Add to existing params
    router.queryParams = router.queryParams..addAll({'c': 'd'});
    expect(router.url, '/1?aa=bb&c=d');
    // Push a route and replace params
    router.push('1', {'e': 'f'});
    expect(router.url, '/1/1?e=f');
    // Push route and carry params forward
    router.push('1', router.queryParams);
    expect(router.url, '/1/1/1?e=f');
    // Pop and carry params back
    router.pop(router.queryParams);
    router.pop(router.queryParams);
    expect(router.url, '/1?e=f');
    // Pop again and expect it not to have changed
    router.pop();
    expect(router.url, '/1?e=f');
  });

  testWidgets('onChanging', (tester) async {
    // Create a router
    var router = getSinglePageRouter('/', (_, __) => null);
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    router.url = 'new';
    // Blocked! :'(
    expect(router.url, '/');

    router = getSinglePageRouter('/', (_, newUrl) => newUrl);
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: router),
    );
    router.url = 'new';
    // Allowed! :)
    expect(router.url, 'new');
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
    expect(router.url, '/1/1?a=b');
    // Check that pop works as expected
    nav.context.urlPop({'c': 'd'});
    expect(router.url, '/1?c=d');
    // Assign url test
    nav.context.url = '/new';
    expect(router.url, '/new');
  });
}
