import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UrlRouter extends RouterDelegate<String> with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  UrlRouter({String url = '/', this.onGeneratePages, this.builder, this.onPopPage, this.onChanging}) {
    _initialUrl = url;
    assert(onGeneratePages != null || builder != null,
        'UrlRouter expects you to implement `builder` or `onGeneratePages` (or both)');
  }

  /// Enable UrlRouter.of(context) lookup
  static UrlRouter of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<_InheritedRouterController>() as _InheritedRouterController).router;

  /// Should build a stack of pages, based on the current location.
  /// This is technically optional, as you could decide to implement your
  /// own custom navigator inside the `builder`
  final List<Page<dynamic>> Function(UrlRouter router)? onGeneratePages;

  /// Wrap widgets around the [MaterialApp]s [Navigator] widget.
  /// Primarily used for providing scaffolding like a `SideBar`, `TitleBar` around the page stack.
  /// Also useful for when you would like to discard the provided [Navigator], and implement your own.
  final Widget Function(UrlRouter router, Widget navigator)? builder;

  /// Optionally provide a way for the parent to implement custom `onPopPage` logic.
  final PopPageCallback? onPopPage;

  /// Optionally invoked just prior to the location being changed.
  /// Allows a parent class to protect or redirect certain routes. The callback can return the original url to allow the location change,
  /// or return a new url to redirect. If null is returned the location change will be ignored / blocked.
  String? Function(UrlRouter router, String newLocation)? onChanging;

  /// Set from inside the build method, allows us to avoid passing context into delegates
  late BuildContext context;

  Map<String, String> get queryParams {
    final Uri? uri = _getUri();
    if (uri == null) return {};
    return Map.from(uri.queryParameters);
  }

  set queryParams(Map<String, String> value) {
    url = _getUri().replace(queryParameters: value).toString();
  }

  @override
  @protected
  String? get currentConfiguration => _url;

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navKey;
  final GlobalKey<NavigatorState> _navKey = GlobalKey();

  Uri _getUri() => Uri.tryParse(_url) ?? Uri(path: _initialUrl);

  late final String _initialUrl;
  String _url = '';
  String get url => _url;
  set url(String value) {
    if (value != _url) {
      // Allow onChanging to override the target path
      String? newUrl = onChanging == null ? value : onChanging?.call(this, value);
      if (newUrl != null) {
        _url = newUrl;
        notifyListeners();
      }
    }
  }

  String get urlPath => _getUri().path;

  void push(String path, [Map<String, String>? queryParams]) => _pushOrPop(path, queryParams);

  void pop([Map<String, String>? queryParams]) => _pushOrPop(null, queryParams);

  @override
  Future<void> setInitialRoutePath(String configuration) {
    if (configuration == '/') {
      configuration = _url = _initialUrl;
    }
    url = configuration;
    super.setInitialRoutePath(url);
    return SynchronousFuture(null);
  }

  @override
  Widget build(BuildContext context) {
    final pages = onGeneratePages?.call(this) ?? [];
    //TODO: Add more use cases for this, figure out if this is really what we want to do, or should we just always return false.
    bool handlePopPage(Route<dynamic> route, dynamic settings) {
      if (pages.length > 1 && route.didPop(settings)) {
        return true;
      }
      return false;
    }

    this.context = context;
    Widget content = Navigator(
      key: _navKey,
      onPopPage: onPopPage ?? handlePopPage,
      pages: pages,
    );
    if (builder != null) {
      content = builder!.call(this, content);
    }
    return _InheritedRouterController(router: this, child: content);
  }

  @override
  SynchronousFuture<void> setNewRoutePath(configuration) {
    url = configuration;
    return SynchronousFuture(null);
  }

  void _pushOrPop([String? path, Map<String, String>? queryParams]) {
    // Create a new list, because `pathSegments` is an unmodifiable list
    final segments = List.from(_getUri().pathSegments);
    // A null path indicates a pop vs push
    bool pop = path == null;
    if (pop && segments.length <= 1) return; // Can't pop if we're down to 1 segment
    // Add or remove a segment
    pop ? segments.removeAt(segments.length - 1) : segments.add(path);
    var newUrl = '/${segments.join('/')}';
    if (queryParams != null) {
      final queryString = Uri(queryParameters: queryParams).query;
      if (queryString.isNotEmpty) {
        newUrl += '?' + queryString;
      }
    }
    url = newUrl;
  }
}

class _InheritedRouterController extends InheritedWidget {
  const _InheritedRouterController({Key? key, required Widget child, required this.router})
      : super(key: key, child: child);
  final UrlRouter router;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
