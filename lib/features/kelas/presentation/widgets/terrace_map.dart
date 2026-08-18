import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';

/// Peta isometrik utama yang menampilkan gambar peta.png sebagai latar
/// dan menempatkan node-node pembelajaran di atasnya menggunakan Stack + Positioned.
class TerraceMap extends StatefulWidget {
  final List<TerraceNode> nodes;
  final ValueChanged<TerraceNode> onNodeTap;

  const TerraceMap({
    super.key,
    required this.nodes,
    required this.onNodeTap,
  });

  @override
  State<TerraceMap> createState() => _TerraceMapState();
}

class _TerraceMapState extends State<TerraceMap>
    with SingleTickerProviderStateMixin {
  /// Controller animasi pulse untuk node yang tersedia/sedang dikerjakan.
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Hitung posisi relatif (0.0–1.0) untuk setiap node di atas gambar peta.
  ///
  /// PENTING: gambar peta.png di-render dengan BoxFit.contain dan padding
  /// horizontal [_mapPaddingH] di kiri-kanan. Posisi X harus memperhitungkan
  /// padding ini agar node tepat di atas konten gambar, bukan bergeser keluar.
  ///
  /// Sumbu Y: 0.0 = atas, 1.0 = bawah.
  /// Sumbu X: 0.0 = kiri, 1.0 = kanan — dari lebar penuh widget (inklusif padding).
  List<Offset> _getNodeRelativePositions(int nodeCount) {
    // Posisi mengikuti teras dari paling atas (ladang atas) ke paling bawah.
    // X sedikit lebih besar dari tengah (0.50) karena gambar peta condong ke kiri-tengah.
    // Y dikunci agar tidak melebihi 0.90 supaya node terakhir tidak keluar gambar.
    const defaultPositions = [
      Offset(0.60, 0.23), // Node 1 — teras teratas, ladang atas-tengah
      Offset(0.42, 0.46), // Node 2 — teras kedua, ladang tengah kiri
      Offset(0.52, 0.67), // Node 3 — teras ketiga, sawah panen
      Offset(0.38, 0.84), // Node 4 — teras terbawah, masih di dalam gambar
    ];
    return defaultPositions.take(nodeCount).toList();
  }

  @override
  Widget build(BuildContext context) {
    final positions = _getNodeRelativePositions(widget.nodes.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tinggi konten = tinggi layar penuh (tanpa overflow agar node tidak keluar).
        final contentHeight = constraints.maxHeight;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: constraints.maxWidth,
            height: contentHeight,
            child: Stack(
              // Clip.hardEdge: pastikan tidak ada node yang keluar dari batas peta.
              clipBehavior: Clip.hardEdge,
              children: [
                // --- Layer 1: Gambar peta isometrik sebagai latar ---
                _buildMapBackground(constraints),

                // --- Layer 2: Node-node pembelajaran di atas peta ---
                ...List.generate(widget.nodes.length, (index) {
                  final node = widget.nodes[index];
                  final relPos = positions[index];

                  // Konversi posisi relatif ke piksel aktual.
                  // Posisi X memperhitungkan padding horizontal gambar sehingga
                  // node tidak bergeser ke luar area konten gambar.
                  final effectiveWidth =
                      constraints.maxWidth - (_mapPaddingH * 2);
                  final left = _mapPaddingH +
                      (relPos.dx * effectiveWidth) -
                      _nodeHalfWidth;
                  final top =
                      relPos.dy * contentHeight - _nodeHalfHeight;

                  return Positioned(
                    left: left,
                    top: top,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return _MapNode(
                          node: node,
                          pulseScale: _pulseAnimation.value,
                          onTap: () => widget.onNodeTap(node),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Lebar setengah dari node untuk centering horizontal.
  double get _nodeHalfWidth => 60.0;

  /// Tinggi setengah dari node untuk centering vertikal.
  double get _nodeHalfHeight => 45.0;

  /// Padding horizontal gambar peta — harus sinkron dengan nilai di
  /// [_buildMapBackground]. Dipakai untuk menghitung lebar area gambar
  /// yang efektif saat memposisikan node.
  double get _mapPaddingH => AppSpacing.l;

  /// Membangun latar gambar peta isometrik.
  Widget _buildMapBackground(BoxConstraints constraints) {
    return Positioned.fill(
      child: Padding(
        // Beri sedikit padding horizontal agar peta tidak terlalu mepet tepi
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        child: Image.asset(
          'assets/illustrations/peta.png',
          fit: BoxFit.contain,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: _MapNode
// Menampilkan satu node pada peta dengan ikon, label, dan progress bar.
// ---------------------------------------------------------------------------

class _MapNode extends StatelessWidget {
  final TerraceNode node;
  final double pulseScale;
  final VoidCallback onTap;

  const _MapNode({
    required this.node,
    required this.pulseScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ikon utama node (lingkaran)
          _buildNodeCircle(),

          const SizedBox(height: AppSpacing.xs),

          // Label nama node
          _buildNodeLabel(),

          // Progress bar untuk node yang sedang dikerjakan
          if (node.status == TerraceNodeStatus.inProgress)
            _buildProgressBar(),
        ],
      ),
    );
  }

  /// Membangun lingkaran ikon utama node dengan efek scale pulse.
  Widget _buildNodeCircle() {
    final config = _getNodeConfig();

    return Transform.scale(
      scale: _shouldPulse ? pulseScale : 1.0,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: config.circleColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: config.borderColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: config.borderColor.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: _buildNodeIcon(config),
        ),
      ),
    );
  }

  /// Membangun ikon di dalam lingkaran node berdasarkan status.
  Widget _buildNodeIcon(_NodeConfig config) {
    if (node.status == TerraceNodeStatus.inProgress) {
      // Tampilkan ikon karakter traktor (emoji) untuk node yang sedang dikerjakan
      return const Text('🚜', style: TextStyle(fontSize: 22));
    }

    return Icon(
      config.icon,
      color: config.iconColor,
      size: 26,
    );
  }

  /// Membangun label teks di bawah node dengan kontainer semi-transparan.
  Widget _buildNodeLabel() {
    final config = _getNodeConfig();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: config.labelBgColor,
        borderRadius: BorderRadius.circular(AppRadius.penuh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        node.title,
        style: AppTypography.label.copyWith(
          color: config.labelTextColor,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Membangun progress bar kecil di bawah label untuk node inProgress.
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
        width: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.penuh),
          child: LinearProgressIndicator(
            value: node.progress,
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.6),
            color: AppColors.daun,
          ),
        ),
      ),
    );
  }

  /// Menentukan apakah node ini harus menampilkan animasi pulse.
  bool get _shouldPulse =>
      node.status == TerraceNodeStatus.available ||
      node.status == TerraceNodeStatus.inProgress;

  /// Mengembalikan konfigurasi visual berdasarkan status node.
  _NodeConfig _getNodeConfig() {
    switch (node.status) {
      case TerraceNodeStatus.completed:
        return _NodeConfig(
          circleColor: AppColors.airDalam,
          borderColor: AppColors.air,
          icon: Icons.check_rounded,
          iconColor: Colors.white,
          labelBgColor: Colors.white,
          labelTextColor: AppColors.tanah,
        );

      case TerraceNodeStatus.perfect:
        return _NodeConfig(
          circleColor: AppColors.padi,
          borderColor: const Color(0xFFF5C842),
          icon: Icons.star_rounded,
          iconColor: Colors.white,
          labelBgColor: Colors.white,
          labelTextColor: AppColors.tanah,
        );

      case TerraceNodeStatus.inProgress:
        return _NodeConfig(
          circleColor: Colors.white.withValues(alpha: 0.85),
          borderColor: AppColors.daun,
          icon: Icons.person,
          iconColor: AppColors.daun,
          labelBgColor: AppColors.daun,
          labelTextColor: Colors.white,
        );

      case TerraceNodeStatus.available:
        return _NodeConfig(
          circleColor: Colors.white.withValues(alpha: 0.80),
          borderColor: AppColors.daunMuda,
          icon: Icons.eco_rounded,
          iconColor: AppColors.daun,
          labelBgColor: Colors.white,
          labelTextColor: AppColors.tanah,
        );

      case TerraceNodeStatus.locked:
        return _NodeConfig(
          circleColor: const Color(0xFFD8DBD3),
          borderColor: AppColors.garis,
          icon: Icons.lock_rounded,
          iconColor: AppColors.tanahSamar,
          labelBgColor: const Color(0xFFEDEFEA),
          labelTextColor: AppColors.tanahSamar,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Helper: _NodeConfig
// Data class untuk menyimpan konfigurasi visual sebuah node peta.
// ---------------------------------------------------------------------------

class _NodeConfig {
  final Color circleColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final Color labelBgColor;
  final Color labelTextColor;

  const _NodeConfig({
    required this.circleColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.labelBgColor,
    required this.labelTextColor,
  });
}
