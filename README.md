<a href="https://github.com/gskinnerTeam/flutter-url-router/actions"><img src="https://github.com/gskinnerTeam/flutter-url-router/workflows/core-tests/badge.svg" alt="Build Status"></a>
[![codecov](https://codecov.io/gh/gskinnerTeam/flutter-url-router/branch/master/graph/badge.svg?token=O5XM3W0094)](https://codecov.io/gh/gskinnerTeam/flutter-url-router)

An un-opinionated url-based Router implementation (Navigator 2.0).

```dart
late final router = UrlRouter(
  onGeneratePages: (router) => [
    MaterialPage(child: MainView(router.url)),
]);

@override
Widget build(BuildContext context) => MaterialApp.router(
  routeInformationParser: UrlRouteParser(),
  routerDelegate: router,
);
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
  url_router: ^0.2.0
```

## 🕹️ Usage
* Declare a `UrlRouter` and implement the `onGeneratePages` method
* Return a list of `Page` elements that represent your desired navigator stack
* Implement the optional `onChanging` and `builder` delegates

Here is an intermediate example, showing a persistent `MainView` with a `SettingsView` that can sit on top. It also implements simple authentication and shows how to wrap some outer widgets around the Navigator:
```dart
late final router = UrlRouter(
  // The Flutter `Navigator` expects a set of `Page` instances
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
  // Optional, protect or redirect urls
  onChanging: (router, newUrl) {
    if (authorized == false) return '/'; // redirect to main view
    return newUrl; // allow change
  },
  // Optional, wrap some outer UI around navigator
  builder: (router, navigator) {
    return Row(
      children: [ 
         const SideBar(), 
         Expanded(child: navigator) 
         ],
    );
  },

);
```

As seen above you can use the `onChanging` delegate to redirect or protect certain urls.

The `builder` can be used to wrap additional UI around the routers `navigator` widget, or it can be used to discard the `navigator` completely and implement a fully custom routing scheme (more on this below).

### Controlling the url
`UrlRouter` offers a small but powerful API to control the url:

| API  | Description  |
|---|---|
| `.url`  | read / update the current path  |
| `.push`  | add a segment to the current path   |
| `.pop`  | remove a segment from the current path  |
| `.onChanging`  | called before path is changed, allows for protected paths and redirects  |
| `.queryParams` | read / update the current query parameters  |


### Accessing the router
Access the `UrlRouter` anywhere in your app, using `UrlRouter.of(context)`, or use the context extensions:
* `context.url`
* `context.urlPush`
* `context.urlPop`
* `context.urlRouter`

### Outer Scaffolding
You can use the `builder` delegate to wrap persistent UI around the underlying `Navigator` widget:
```dart
final router = UrlRouter(
    builder: (router, navigator) {
      return Row(
        children: [
          SideBar(),
          Expanded(child: navigator),
        ],
      );
    },
```

### Handling full-screen modals
When using UI around the `Navigator`, like title-bars or side-bars, it is common to want to show dialogs and bottom sheets that sit above that UI.

This is most easily solved by adding a second `Navigator`, above the one that is handled by the router.
```dart
final router = UrlRouter(
    builder: (router, navigator) {
      return Navigator(
        onGenerateRoute: (_) {
          return PageRouteBuilder(
            transitionDuration: Duration.zero,
            pageBuilder: (_, __, ___){
                return AppScaffold(body: navigator);
            },
          );
        });
...
```

### Using custom Navigator(s)
To provide a fully custom navigation implementation ignore the `Widget navigator` parameter from within the `builder` delegate:
```
UrlRouter(builder: (_, navigator) => MyApp());
```
`UrlRouter` at this point would be responsible only for reading and writing url, and calling `builder` whenever it changes.

`MyApp` would be responsible for setting up a nested `Navigator`, or otherwise responding to `router.url`.

 ## 🐞 Bugs/Requests

If you encounter any problems please open an issue. If you feel the library is missing a feature, please raise a ticket on Github and we'll look into it. Pull request are welcome.

## 📃 License

MIT License
