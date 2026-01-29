import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/core/api/api.dart';
import 'package:music_app/models/plan_model.dart';

class PlanService {
  static Future<List<PlanModel>> fetchPlans() async {
    // ✅ FIX: combine baseUrl + endpoint
    final String url = '${ApiConfig.baseUrl}${ApiConfig.getPlans}';

    debugPrint('PlanService → calling URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('PlanService → status: ${response.statusCode}');
      debugPrint('PlanService → body: ${response.body}');

      if (response.statusCode != 200) {
        debugPrint('PlanService → failed body: ${response.body}');
        return [];
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> data = json['data'] ?? [];

      debugPrint('PlanService → found ${data.length} raw items');

      return data
          .map((item) => PlanModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('PlanService → exception: $e');
      return [];
    }
  }
}
