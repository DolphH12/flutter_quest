import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/learning_models.dart';

class DartRouteAssetSource {
  const DartRouteAssetSource({
    this.assetPath = 'assets/content/dart_route.json',
  });

  final String assetPath;

  Future<DartRouteContent> loadRoute() async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return DartRouteContent.fromJson(json);
  }
}
