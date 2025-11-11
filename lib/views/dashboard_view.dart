import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:olive_leaf_analyzer/widgets/nav_bar.dart';
import 'package:olive_leaf_analyzer/controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    
    final DashboardController controller = Get.put(DashboardController());


    controller.fetchDashboardData();

    return Scaffold(
      
      
      appBar: AppBar(
        title:  Text('📊 Tableau de bord'.tr),
        backgroundColor: const Color.fromARGB(255, 42, 118, 53),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFEAF3EA),
      body: Obx(() {
        // The UI will reactively update based on controller data
        return Stack(
          
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Add bottom padding to avoid overlap
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(controller),
                  const SizedBox(height: 30),
                  
                   Text("🫒 Répartition des variétés".tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildPieChart(controller),
                  const SizedBox(height: 30),
                    Text("🎯 Précision par variété".tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildBarChart(controller),
                  const SizedBox(height: 15),
                ],
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: const NavBar(currentPage: NavBarPage.dashboard),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryCards(DashboardController controller) {
    return Column(
      children: [
        Row(
          children: [
            _buildCard("🏷️ Total".tr, controller.totalAnalyses.toString(), Colors.teal),
            _buildCard("🫒 Variétés".tr, controller.varietiesCount.toString(), Colors.green),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildCard("📆 Dernière activité".tr, controller.lastActivity.value, Colors.orange),
            _buildCard("📊 + fréquente".tr, controller.mostFrequentVariety.value, Colors.deepPurple),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(DashboardController controller) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: controller.varietyDistribution.entries.map((entry) {
            return PieChartSectionData(
              value: entry.value.toDouble(),
              title: entry.key,
              color: Colors.primaries[controller.varietyDistribution.keys.toList().indexOf(entry.key) % Colors.primaries.length],
              radius: 50,
              titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 6, 6, 6)),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

 


Widget _buildBarChart(DashboardController controller) {
  final labels = controller.precisionPerVariety.keys.toList();

  return SizedBox(
    height: 200,
    child: BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, _) {
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (value.toInt() < labels.length) {
                  return Text(labels[value.toInt()], style: const TextStyle(fontSize: 12));
                } else {
                  return const Text('');
                }
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final value = controller.precisionPerVariety[label] ?? 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                color: Colors.green,
                width: 20,
              ),
            ],
          );
        }).toList(),
      ),
    ),
  );
}




}
