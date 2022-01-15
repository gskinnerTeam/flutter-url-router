import 'package:example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_router/url_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  bool get authorized => true;

  late final router = UrlRouter(
    url: '/start',
    onChanging: (router, newUrl) {
      if (authorized == false) return '/';
      return newUrl;
    },
    scaffoldBuilder: (router, navigator) {
      return Row(
        children: [
          const SideBar(),
          Expanded(child: navigator),
        ],
      );
    },
    onGeneratePages: (router) => [
      const MaterialPage(child: MainView()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: UrlRouter.parser,
      routerDelegate: router,
    );
  }
}
