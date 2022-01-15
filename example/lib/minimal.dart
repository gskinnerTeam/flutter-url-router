import 'package:flutter/material.dart';
import 'package:url_router/url_router.dart';

class MinimalistApp extends StatelessWidget {
  MinimalistApp({Key? key}) : super(key: key);

  late final router = UrlRouter(
    onGeneratePages: (router) {
      return [
        MaterialPage(child: Center(child: Text(router.url))),
      ];
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: UrlRouter.parser,
      routerDelegate: router,
    );
  }
}
