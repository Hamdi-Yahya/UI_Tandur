import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';
import 'package:tandur/features/kelas/presentation/widgets/gamification_widgets.dart';
import 'package:tandur/features/kelas/presentation/widgets/kelas_widgets.dart';
import 'package:tandur/features/kelas/presentation/widgets/terrace_map.dart';

class KelasMapScreen extends StatefulWidget {
  const KelasMapScreen({super.key});

  @override
  State<KelasMapScreen> createState() => _KelasMapScreenState();
}

class _KelasMapScreenState extends State<KelasMapScreen> {
  String _selectedCommodity = 'Cabai';

  @override
  Widget build(BuildContext context) {
    List<TerraceNode> currentNodes;
    switch (_selectedCommodity) {
      case 'Terong':
        currentNodes = KelasMockData.terongNodes;
        break;
      case 'Padi':
        currentNodes = KelasMockData.padiNodes;
        break;
      case 'Cabai':
      default:
        currentNodes = KelasMockData.cabaiNodes;
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Gamifikasi
            const GamificationHeader(
              streak: KelasMockData.currentStreak,
              xp: KelasMockData.currentXp,
              lives: KelasMockData.currentLives,
            ),
            
            // 2. Tab Komoditas
            CommodityTabs(
              selectedCommodity: _selectedCommodity,
              onSelected: (commodity) {
                setState(() {
                  _selectedCommodity = commodity;
                });
              },
            ),

            // 3. Peta Terasering (Flexible to take remaining space)
            Expanded(
              child: TerraceMap(
                nodes: currentNodes,
                onNodeTap: (node) {
                  if (node.status == TerraceNodeStatus.locked) {
                    // Tampilkan snackbar atau bottom sheet syarat
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${node.title} masih terkunci. Selesaikan petak sebelumnya.'),
                        backgroundColor: AppColors.tanah,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    // Navigasi ke detail petak
                    context.push('/kelas/petak/${node.id}');
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // Dummy bottom nav placeholders can be added here or in a shell route later.
      // For now, the user request says: "Jangan membuat bottom navigation final" 
      // but they provided a simple structure in DESAIN.md. We will just focus on the screen content.
    );
  }
}
