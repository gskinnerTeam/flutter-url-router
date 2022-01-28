import 'package:example/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routed_widget_switcher/routed_widget_switcher.dart';
import 'package:url_router/url_router.dart';

class StatefulTabsExample extends StatelessWidget {
  final UrlRouter _router = UrlRouter(
    url: '/',
    onGeneratePages: (router) => [
      MaterialPage(child: _TabView()),
    ],
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routeInformationParser: UrlRouteParser(), routerDelegate: _router);
  }
}

class _TabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void handleTabPressed(String value) => context.url = value;
    Widget buildTabBtn(String url, {required String label}) {
      return Expanded(child: CupertinoButton(onPressed: () => handleTabPressed(url), child: Text(label)));
    }

    // Show selected tab + bottom menu
    return Column(
      children: [
        Expanded(
          child: RoutedSwitcher(
            builders: (_) => [
              Routed('/', HomeView.new),
              Routed('/settings', SettingsView.new),
            ],
          ),
        ),
        Row(children: [
          buildTabBtn('/', label: "Home"),
          buildTabBtn('/settings', label: "Settings"),
        ]),
      ],
    );
  }
}
