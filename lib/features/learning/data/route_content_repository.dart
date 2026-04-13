import 'dart:async';

import '../models/learning_models.dart';
import 'route_asset_source.dart';

class RouteContentRepository {
  RouteContentRepository(this._assetSource);

  final RouteAssetSource _assetSource;
  final Map<String, DartRouteContent> _cacheById = <String, DartRouteContent>{};
  final Map<String, String> _loadErrorsByRouteId = <String, String>{};

  Map<String, String> get loadErrorsByRouteId =>
      Map<String, String>.unmodifiable(_loadErrorsByRouteId);

  Future<List<DartRouteContent>> loadRoutes({
    required List<RouteAssetManifest> manifests,
    required String languageCode,
    bool forceRefresh = false,
  }) async {
    final result = <DartRouteContent>[];
    _loadErrorsByRouteId.clear();
    for (final manifest in manifests) {
      final cacheKey = '${manifest.routeId}::$languageCode';
      if (!forceRefresh && _cacheById.containsKey(cacheKey)) {
        result.add(_cacheById[cacheKey]!);
        continue;
      }
      try {
        final route = await _assetSource.loadRoute(
          manifest.assetPath,
          languageCode: languageCode,
        );
        _cacheById[cacheKey] = route;
        result.add(route);
      } catch (error) {
        _loadErrorsByRouteId[manifest.routeId] = '$error';
      }
    }
    return result;
  }

  Future<DartRouteContent> loadRouteById({
    required List<RouteAssetManifest> manifests,
    required String routeId,
    required String languageCode,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '$routeId::$languageCode';
    if (!forceRefresh && _cacheById.containsKey(cacheKey)) {
      return _cacheById[cacheKey]!;
    }
    final manifest = manifests.firstWhere((item) => item.routeId == routeId);
    final route = await _assetSource.loadRoute(
      manifest.assetPath,
      languageCode: languageCode,
    );
    _cacheById[cacheKey] = route;
    return route;
  }
}
