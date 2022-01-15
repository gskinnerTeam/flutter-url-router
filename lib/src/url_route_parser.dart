import 'package:flutter/widgets.dart';

class UrlRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) async => routeInformation.location ?? '/';

  @override
  RouteInformation? restoreRouteInformation(String configuration) => RouteInformation(location: configuration);
}
