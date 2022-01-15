<a href="https://github.com/gskinnerTeam/flutter-url-router/actions"><img src="https://github.com/gskinnerTeam/flutter-url-router/workflows/core-tests/badge.svg" alt="Build Status"></a>
[![codecov](https://codecov.io/gh/gskinnerTeam/flutter-url-router/branch/master/graph/badge.svg?token=O5XM3W0094)](https://codecov.io/gh/gskinnerTeam/flutter-url-router)

An un-opinionated url-based Router implementation (Navigator 2.0).

```dart
late final router = UrlRouter(
  onGeneratePages: (router) => [
    MaterialPage(child: MainView(router.url)
]);

@override
Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: UrlRouter.parser,
      routerDelegate: router,
    );
}
```
`UrlRouter` makes no assumptions about your UI layout. How you react to `router.url` is up to you.

## Features
* Easily read and update the current url and query params
* Supports deep linking, protected urls, and redirects
* Back and forward navigation in browser
* Full control over url to page mapping, wildcards etc

## 🔨 Installation
```yaml
dependencies:
  url_router: ^0.1.0
```

## 🕹️ Usage
* Declare a `UrlRouter` and implement the `onGeneratePages` method.
* Return a list of `Page` elements that represent your desired navigator stack
* Implement the optional `onChanging` and `scaffoldBuilder` delegates
```dart
late final router = UrlRouter(
  onChanging: (router, newUrl) {
    if (authorized == false) return '/';
    return newUrl;
  },
  scaffoldBuilder: (router, navigator) {
    return Row(
      children: [ const SideBar(), Expanded(child: navigator) ],
    );
  },
  onGeneratePages: (router) {
    return [
      // Main view is always present
      MaterialPage(child: MainView()),
      // Settings can sit on top of main view (and can be popped)
      if(router.url == '/settings')... [
         MaterialPage(child: SettingsView()),
      ]
    ];
  },
);
```

### Controlling the url
`UrlRouter` offers a small but powerful API to control the url:

| API  | Description  |
|---|---|
| `.url`  | read / update the current path  |
| `.push`  | add a segment to the current path   |
| `.pop`  | remove a segment from the current path  |
| `.onChanging`  | called before path is changed, allows for protected paths and redirects  |
| `.queryParams` | access the current query parameters  |


### Accessing the router
Access the `UrlRouter` anywhere in your app, using `UrlRouter.of(context)`, or use the context extensions:
* `context.url`
* `context.urlPush`
* `context.urlPop`
* `context.urlRouter`

### Outer Scaffolding
You can use the `scaffoldBuilder` delegate to wrap persistent UI around the underlying `Navigator` widget:
```dart
final router = UrlRouter(
    scaffoldBuilder: (router, navigator) {
      return Row(
        children: [
          SideBar(),
          Expanded(child: navigator),
        ],
      );
    },
```

### Using custom Navigator(s)
From within the `scaffoldBuilder` you can ignore the `Widget navigator` parameter, and instead provide one or more Navigators or sub-routers lower in the widget tree.

`UrlRouter` at this point would be responsible only for reading and writing location, and calling scaffoldBuilder whenever it changes.

 ## 🐞 Bugs/Requests

If you encounter any problems please open an issue. If you feel the library is missing a feature, please raise a ticket on Github and we'll look into it. Pull request are welcome.

## 📃 License

MIT License
