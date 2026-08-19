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
    if (nodeCount == 1) {
      return const [Offset(0.50, 0.40)];
    }
    if (nodeCount == 2) {
      // 2 nodes (e.g. Terong & Padi): Tersebar proporsional di teras atas dan tengah-bawah
      return const [
        Offset(0.52, 0.22), // Teras atas
        Offset(0.44, 0.58), // Teras tengah-bawah
      ];
    }
    if (nodeCount == 3) {
      return const [
        Offset(0.52, 0.18), // Teras atas
        Offset(0.32, 0.44), // Teras tengah kiri
        Offset(0.62, 0.70), // Teras bawah kanan
      ];
    }
    // 4 nodes (e.g. Cabai) & default:
    // Pola S-curve alami mengikuti terasering pulau isometrik:
    // Node 1: Teras teratas tengah (greenhouse / kebun atas)
    // Node 2: Teras tengah kiri (pondok / kebun kiri)
    // Node 3: Teras tengah kanan (ladang cabai merah / kincir air)
    // Node 4: Teras terbawah kiri (sawah bertingkat bawah)
    const defaultPositions = [
      Offset(0.52, 0.16), // Node 1 — teras teratas
      Offset(0.30, 0.36), // Node 2 — teras tengah kiri
      Offset(0.66, 0.56), // Node 3 — teras tengah kanan
      Offset(0.36, 0.76), // Node 4 — teras terbawah kiri
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
// Menampilkan satu node pada peta dengan ikon, label, dan circular progress.
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
          // Ikon utama node (lingkaran + circular progress terintegrasi)
          _buildNodeCircle(),

          const SizedBox(height: 6),

          // Label nama node
          _buildNodeLabel(),
        ],
      ),
    );
  }

  /// Membangun lingkaran ikon utama node dengan efek scale pulse & circular progress ring.
  Widget _buildNodeCircle() {
    final config = _getNodeConfig();
    final isInProgress = node.status == TerraceNodeStatus.inProgress;

    return Transform.scale(
      scale: _shouldPulse ? pulseScale : 1.0,
      child: SizedBox(
        width: 66,
        height: 66,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator untuk node yang sedang dikerjakan
            if (isInProgress)
              SizedBox(
                width: 66,
                height: 66,
                child: CircularProgressIndicator(
                  value: node.progress,
                  strokeWidth: 3.5,
                  backgroundColor: AppColors.daunSamar,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.daun),
                ),
              ),
            // Lingkaran utama
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: config.circleColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: config.borderColor,
                  width: isInProgress ? 2.5 : 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: config.borderColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: _buildNodeIcon(config),
              ),
            ),
          ],
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
        horizontal: AppSpacing.m,
        vertical: 4,
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
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
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
