import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/learning_models.dart';
import 'route_content_validator.dart';

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

  Future<DartRouteContent> loadRoute(
    String assetPath, {
    required String languageCode,
  }) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final localizedJson = _resolveLocalizedJson(
        json,
        languageCode: languageCode,
      );
      final route = DartRouteContent.fromJson(localizedJson);
      RouteContentValidator.validate(route);
      return route;
    } on FormatException catch (error) {
      throw FormatException(
        'Invalid route JSON in $assetPath: ${error.message}',
      );
    }
  }

  Map<String, dynamic> _resolveLocalizedJson(
    Map<String, dynamic> json, {
    required String languageCode,
  }) {
    dynamic walk(dynamic value, {String? key}) {
      if (value is Map<String, dynamic>) {
        if (_isLocalizedLeaf(value, key)) {
          return _pickLocalizedValue(value, languageCode: languageCode);
        }
        return {
          for (final entry in value.entries)
            entry.key: walk(entry.value, key: entry.key),
        };
      }
      if (value is List) {
        return value.map((item) => walk(item, key: key)).toList();
      }
      return value;
    }

    return walk(json, key: null) as Map<String, dynamic>;
  }

  bool _isLocalizedLeaf(Map<String, dynamic> value, String? key) {
    if (key == null) return false;
    const localizedKeys = {
      'title',
      'description',
      'shortDescription',
      'body',
      'example',
      'question',
      'correctAnswer',
      'correctExplanation',
      'incorrectExplanation',
      'prompt',
      'initialCode',
      'expectedAnswer',
      'hint',
      'codeSnippet',
      'instructions',
      'starterCode',
      'options',
      'blocks',
      'correctOrder',
      'codeLines',
      'expectedFragments',
      'left',
      'right',
    };
    if (!localizedKeys.contains(key)) return false;
    return value.containsKey('es') || value.containsKey('en');
  }

  dynamic _pickLocalizedValue(
    Map<String, dynamic> value, {
    required String languageCode,
  }) {
    final normalized = languageCode.toLowerCase();
    if (value.containsKey(normalized)) {
      return value[normalized];
    }
    if (value.containsKey('es')) return value['es'];
    if (value.containsKey('en')) return value['en'];
    return value.values.isEmpty ? null : value.values.first;
  }
}
