import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_router/src/url_router.dart';

UrlRouter getSinglePageRouter([String? initial]) => UrlRouter(
    url: initial ?? '/',
    onGeneratePages: (router) {
      return [MaterialPage(child: Center(child: Text(router.url)))];
    });

void main() {
  testWidgets('initial url', (tester) async {
    final router = getSinglePageRouter('/first');
    await tester.pumpWidget(MaterialApp.router(routeInformationParser: UrlRouter.parser, routerDelegate: router));
    await tester.pumpAndSettle();
    expect(find.text('/first'), findsOneWidget);
  });

  testWidgets('url changing', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouter.parser, routerDelegate: router),
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
      MaterialApp.router(routeInformationParser: UrlRouter.parser, routerDelegate: router),
    );
    await tester.pumpAndSettle();
    router.url = '/home?search=0';
    await tester.pumpAndSettle();
    expect(int.tryParse(router.queryParams['search']!), 0);
  });

  testWidgets('pop/push', (tester) async {
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouter.parser, routerDelegate: router),
    );
    await tester.pumpAndSettle();
    router.push('1');
    router.push('1');
    router.push('1');
    await tester.pumpAndSettle();
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
      MaterialApp.router(routeInformationParser: UrlRouter.parser, routerDelegate: router),
    );
    await tester.pumpAndSettle();

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
    final router = getSinglePageRouter();
    await tester.pumpWidget(
      MaterialApp.router(routeInformationParser: UrlRouter.parser, routerDelegate: router),
    );
  });
}