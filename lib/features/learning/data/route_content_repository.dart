import 'dart:async';

import '../models/learning_models.dart';
import 'dart_route_asset_source.dart';

class RouteContentRepository {
  RouteContentRepository(this._assetSource);

  final DartRouteAssetSource _assetSource;
  DartRouteContent? _cachedDartRoute;

  Future<DartRouteContent> loadDartRoute({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDartRoute != null) {
      return _cachedDartRoute!;
    }
    final route = await _assetSource.loadRoute();
    _cachedDartRoute = route;
    return route;
  }
}
