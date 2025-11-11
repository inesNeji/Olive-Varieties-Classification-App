import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:olive_leaf_analyzer/constants/constants.dart';
import 'package:olive_leaf_analyzer/models/DashboardModel.dart'; // Import model

class DashboardController extends GetxController {
  var lastActivity = RxString('');
  var mostFrequentVariety = RxString('');
  var precisionPerVariety = RxMap<String, double>({});
  var totalAnalyses = 0.obs;
  var varietiesCount = 0.obs;
  var varietyDistribution = RxMap<String, int>({});
  var weeklyActivity = RxMap<String, int>({});

  Future<void> fetchDashboardData() async {
    final box = GetStorage();
    final email = box.read('email') ?? ''; // Get the email from GetStorage
    final response = await http.get(
      Uri.parse('$baseUrlwifi/dashboard?email=$email'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Use the model to parse the fetched data
      DashboardModel dashboard = DashboardModel.fromJson(data);

      // Format lastActivity to display only year/month/day
      DateTime lastActivityDate = DateTime.parse(dashboard.lastActivity);
      lastActivity.value =
          "${lastActivityDate.year}-${lastActivityDate.month.toString().padLeft(2, '0')}-${lastActivityDate.day.toString().padLeft(2, '0')}";

      // Populate the controller's variables using the model
      mostFrequentVariety.value = dashboard.mostFrequentVariety;
      precisionPerVariety.value = dashboard.precisionPerVariety;
      totalAnalyses.value = dashboard.totalAnalyses;
      varietiesCount.value = dashboard.varietiesCount;
      varietyDistribution.value = dashboard.varietyDistribution;
      weeklyActivity.value = dashboard.weeklyActivity;
    } else {
      // Handle error here
      print(
       Text('${'Échec du chargement des données du tableau de bord :'.tr}: ${response.statusCode}'),
      );
    }
  }
}
