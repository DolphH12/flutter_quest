import 'dart:async';

import '../models/learning_models.dart';
import 'route_asset_source.dart';

class RouteContentRepository {
  RouteContentRepository(this._assetSource);

  final RouteAssetSource _assetSource;
  final Map<String, DartRouteContent> _cacheById = <String, DartRouteContent>{};

  Future<List<DartRouteContent>> loadRoutes({
    required List<RouteAssetManifest> manifests,
    bool forceRefresh = false,
  }) async {
    final result = <DartRouteContent>[];
    for (final manifest in manifests) {
      if (!forceRefresh && _cacheById.containsKey(manifest.routeId)) {
        result.add(_cacheById[manifest.routeId]!);
        continue;
      }
      final route = await _assetSource.loadRoute(manifest.assetPath);
      _cacheById[manifest.routeId] = route;
      result.add(route);
    }
    return result;
  }

  Future<DartRouteContent> loadRouteById({
    required List<RouteAssetManifest> manifests,
    required String routeId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cacheById.containsKey(routeId)) {
      return _cacheById[routeId]!;
    }
    final manifest = manifests.firstWhere((item) => item.routeId == routeId);
    final route = await _assetSource.loadRoute(manifest.assetPath);
    _cacheById[routeId] = route;
    return route;
  }
}
