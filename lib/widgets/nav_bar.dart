import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NavBarPage { home, profile, historique, dashboard, other }

class NavBar extends StatelessWidget {
  final NavBarPage currentPage;

  const NavBar({
    super.key,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    void addItem(NavBarPage page, IconData icon, String route, {bool isCenter = false}) {
      if (page == currentPage && currentPage != NavBarPage.other) return;
      items.add(
        IconButton(
          onPressed: () => Get.offAllNamed(route),
          icon: Icon(icon, size: isCenter ? 32 : 28, color: Colors.black),
        ),
      );
    }

    // Add items based on the current page
    if (currentPage == NavBarPage.home) {
      addItem(NavBarPage.profile, Icons.person_outline, '/profile');
      addItem(NavBarPage.dashboard, Icons.dashboard_customize_rounded, '/dashboard', isCenter: true);
      addItem(NavBarPage.historique, Icons.access_time, '/historique');
    } else if (currentPage == NavBarPage.profile) {
      addItem(NavBarPage.historique, Icons.access_time, '/historique');
      addItem(NavBarPage.home, Icons.home, '/', isCenter: true);
      addItem(NavBarPage.dashboard, Icons.dashboard_customize_rounded, '/dashboard');
    } else if (currentPage == NavBarPage.historique) {
      addItem(NavBarPage.profile, Icons.person_outline, '/profile');
      addItem(NavBarPage.home, Icons.home, '/', isCenter: true);
      addItem(NavBarPage.dashboard, Icons.dashboard_customize_rounded, '/dashboard');
    } else if (currentPage == NavBarPage.dashboard) {
      addItem(NavBarPage.profile, Icons.person_outline, '/profile');
      addItem(NavBarPage.home, Icons.home, '/', isCenter: true);
      addItem(NavBarPage.historique, Icons.access_time, '/historique');
    } else {
      // Show all icons when the currentPage is "other"
      addItem(NavBarPage.profile, Icons.person_outline, '/profile');
      addItem(NavBarPage.home, Icons.home, '/', isCenter: true);
      addItem(NavBarPage.historique, Icons.access_time, '/historique');
      addItem(NavBarPage.dashboard, Icons.dashboard_customize_rounded, '/dashboard');
    }

    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((255 * 0.9).toInt()),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).toInt()), // 25.5 ≈ 25
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items,
          ),
        ),
      ),
    );
  }
}
