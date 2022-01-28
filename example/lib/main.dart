import 'package:example/stateful_tabs.dart';
import 'package:example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_router/url_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  late final router = UrlRouter(
    // Return a single MainView regardless of path
    onGeneratePages: (router) => [
      const MaterialPage(child: MainView()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: UrlRouteParser(),
      routerDelegate: router,
    );
  }
}
