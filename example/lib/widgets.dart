import 'package:flutter/material.dart';
import 'package:url_router/url_router.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('loc: ${context.url}'),
            TextButton(onPressed: () => context.url = "/settings", child: const Text('settings')),
            TextButton(onPressed: () => context.url = "/", child: const Text('home')),
            TextButton(onPressed: () => context.urlRouter.push('1'), child: const Text('push')),
            TextButton(onPressed: () => context.urlRouter.push('1', {'a': 'b'}), child: const Text('push w/ params')),
            TextButton(onPressed: () => context.urlRouter.pop(), child: const Text('pop')),
            TextButton(
                onPressed: () => context.urlRouter.pop(context.urlRouter.queryParams),
                child: const Text('pop w/ params')),
            TextButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (_) {
                      return Center(
                          child: TextButton(
                              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                              child: Container(width: 100, height: 100, color: Colors.red)));
                    }),
                child: const Text('dialog')),
          ],
        ),
      ),
    );
  }
}

class ComposeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: BackButton()));
  }
}

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container();
}

class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: 200,
      color: Colors.grey,
      child: const FlutterLogo(size: 100),
    );
  }
}
