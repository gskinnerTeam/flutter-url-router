import 'package:flutter/widgets.dart';
import 'package:url_router/url_router.dart';

extension UrlRouterExtensions on BuildContext {
  UrlRouter get urlRouter => UrlRouter.of(this);

  String get url => UrlRouter.of(this).url;

  set url(String value) => UrlRouter.of(this).url = value;

  void urlPush(String value) => UrlRouter.of(this).push(value);

  void urlPop() => UrlRouter.of(this).pop();
}
