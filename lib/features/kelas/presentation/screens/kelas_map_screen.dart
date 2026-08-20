import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/network/app_enums.dart';
import 'package:tandur/core/presentation/widgets/shared_widgets.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';
import 'package:tandur/features/kelas/presentation/widgets/gamification_widgets.dart';
import 'package:tandur/features/kelas/presentation/widgets/kelas_widgets.dart';
import 'package:tandur/features/kelas/presentation/widgets/terrace_map.dart';

class KelasMapScreen extends ConsumerStatefulWidget {
  const KelasMapScreen({super.key});

  @override
  ConsumerState<KelasMapScreen> createState() => _KelasMapScreenState();
}

class _KelasMapScreenState extends ConsumerState<KelasMapScreen> {
  String _selectedCommodity = 'Cabai';
  LearningMap? _map;
  String? _errorMessage;

  /// Nilai API komoditas yang sedang dipilih (CABAI/TERONG/PADI).
  String get _selectedCommodityApiValue {
    switch (_selectedCommodity) {
      case 'Terong':
        return Commodity.terong.apiValue;
      case 'Padi':
        return Commodity.padi.apiValue;
      default:
        return Commodity.cabai.apiValue;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMap();
  }

  Future<void> _loadMap() async {
    setState(() {
      _map = null;
      _errorMessage = null;
    });
    try {
      final map = await ref
          .read(learningRepositoryProvider)
          .getMap(commodity: _selectedCommodityApiValue);
      if (!mounted) return;
      setState(() {
        _map = map;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  /// Konversi status dari API ke status visual node peta.
  TerraceNodeStatus _toTerraceStatus(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked:
        return TerraceNodeStatus.locked;
      case NodeStatus.available:
        return TerraceNodeStatus.available;
      case NodeStatus.inProgress:
        return TerraceNodeStatus.inProgress;
      case NodeStatus.completed:
        return TerraceNodeStatus.completed;
      case NodeStatus.perfect:
        return TerraceNodeStatus.perfect;
      case NodeStatus.unknown:
        return TerraceNodeStatus.locked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Gamifikasi
            GamificationHeader(
              streak: _map?.streakDays ?? 0,
              xp: _map?.totalXp ?? 0,
              lives: _map?.lives ?? 0,
            ),

            // 2. Tab Komoditas
            CommodityTabs(
              selectedCommodity: _selectedCommodity,
              onSelected: (commodity) {
                if (commodity == _selectedCommodity) return;
                setState(() {
                  _selectedCommodity = commodity;
                });
                _loadMap();
              },
            ),

            // 3. Peta Terasering (Flexible to take remaining space)
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return KeadaanGalat(message: _errorMessage!, onRetry: _loadMap);
    }

    final map = _map;
    if (map == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.daun),
      );
    }

    // Alasan terkunci per petak, dipakai saat node terkunci disentuh.
    final lockReasons = {
      for (final node in map.nodes) node.levelId: node.lockReason,
    };

    return TerraceMap(
      nodes: map.nodes.map((node) {
        return TerraceNode(
          id: node.levelId,
          title: node.title,
          code: node.code,
          status: _toTerraceStatus(node.status),
          progress: node.progressPercent / 100,
        );
      }).toList(),
      onNodeTap: (node) {
        if (node.status == TerraceNodeStatus.locked) {
          final reason = lockReasons[node.id];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                reason != null && reason.isNotEmpty
                    ? reason
                    : '${node.title} masih terkunci. Selesaikan petak sebelumnya.',
              ),
              backgroundColor: AppColors.tanah,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Navigasi ke detail petak
          context.push('/kelas/petak/${node.id}');
        }
      },
    );
  }
}
