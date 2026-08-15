import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_typography.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.kertas,
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          selectedItemColor: AppColors.daun,
          unselectedItemColor: AppColors.tanahSamar,
          selectedLabelStyle: AppTypography.label.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTypography.label,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Kelas',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: navigationShell.currentIndex == 1 
                      ? AppColors.daun 
                      : AppColors.daunSamar,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.document_scanner_outlined,
                  color: navigationShell.currentIndex == 1 
                      ? AppColors.kertas 
                      : AppColors.daun,
                ),
              ),
              label: 'Periksa',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Warung',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Saya',
            ),
          ],
        ),
      ),
    );
  }
}
