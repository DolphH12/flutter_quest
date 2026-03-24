import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/learning_models.dart';

class RouteAssetManifest {
  const RouteAssetManifest({
    required this.routeId,
    required this.assetPath,
    this.requiredCompletedRouteId,
  });

  final String routeId;
  final String assetPath;
  final String? requiredCompletedRouteId;
}

class RouteAssetSource {
  const RouteAssetSource();

  Future<DartRouteContent> loadRoute(String assetPath) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return DartRouteContent.fromJson(json);
    } on FormatException catch (error) {
      throw FormatException('Invalid route JSON in $assetPath: ${error.message}');
    }
  }
}
