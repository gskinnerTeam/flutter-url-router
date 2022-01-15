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
    url: '/',
    onChanging: (router, newUrl) {
      if (authorized == false) return '/';
      return newUrl;
    },
    builder: (router, navigator) {
      return _OuterNavigator(
        child: Row(
          children: [
            const SideBar(),
            Expanded(child: navigator),
          ],
        ),
      );
    },
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

class _OuterNavigator extends StatelessWidget {
  const _OuterNavigator({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (_) {
      return PageRouteBuilder(
        transitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) {
          return child;
        },
      );
    });
  }
}
