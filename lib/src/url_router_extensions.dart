import 'package:flutter/widgets.dart';
import 'package:url_router/url_router.dart';

extension UrlRouterExtensions on BuildContext {
  UrlRouter get urlRouter => UrlRouter.of(this);

  String get url => UrlRouter.of(this).url;

  set url(String value) => UrlRouter.of(this).url = value;

  void urlPush(String value, [Map<String, String>? queryParams]) => UrlRouter.of(this).push(value, queryParams);

  void urlPop([Map<String, String>? queryParams]) => UrlRouter.of(this).pop(queryParams);
}
