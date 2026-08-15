import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';

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

class _TerraceMapState extends State<TerraceMap> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Zoom slightly out initially and pan to bottom
    final matrix = Matrix4.diagonal3Values(0.75, 0.75, 1.0);
    // Pan to the bottom so the first node is visible
    matrix.setTranslationRaw(-150.0, -300.0, 0.0);
    _transformationController.value = matrix;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.8,
          maxScale: 1.6,
          constrained: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return GestureDetector(
                  onTapUp: (details) {
                    _handleTap(details.localPosition);
                  },
                  child: CustomPaint(
                    size: const Size(800, 1000), // Map size
                    painter: TerraceMapPainter(
                      nodes: widget.nodes,
                      pulseAnimation: _pulseController,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handleTap(Offset localPosition) {
    final nodePositions = TerraceMapPainter.calculateNodePositions(widget.nodes);
    
    for (int i = 0; i < widget.nodes.length; i++) {
      final node = widget.nodes[i];
      final pos = nodePositions[i];
      
      // Node dimension approx 200x92 based on DESAIN
      final rect = Rect.fromCenter(center: pos, width: 220, height: 100);
      
      if (rect.contains(localPosition)) {
        widget.onNodeTap(node);
        break;
      }
    }
  }
}

class TerraceMapPainter extends CustomPainter {
  final List<TerraceNode> nodes;
  final Animation<double> pulseAnimation;

  TerraceMapPainter({
    required this.nodes,
    required this.pulseAnimation,
  });

  // Calculate layout for nodes. Bottom to top, zig-zag.
  static List<Offset> calculateNodePositions(List<TerraceNode> nodes) {
    List<Offset> positions = [];
    double currentY = 800.0; // Start near bottom
    double centerX = 400.0; // Center of 800 width

    for (int i = 0; i < nodes.length; i++) {
      // Zig zag X
      double xOffset = (i % 2 == 0) ? -40.0 : 40.0;
      positions.add(Offset(centerX + xOffset, currentY));
      currentY -= 140.0; // Spacing between rows
    }
    return positions;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final nodePositions = calculateNodePositions(nodes);

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final center = nodePositions[i];
      
      _drawNode(canvas, node, center, i);
    }
  }

  void _drawNode(Canvas canvas, TerraceNode node, Offset center, int index) {
    // Draw polygon
    final path = Path();
    
    // Vary the shape slightly based on index
    final width = 200.0 + (index % 3) * 10; 
    final height = 92.0;
    final topOffset = (index % 2 == 0) ? 20.0 : -20.0;
    final bottomOffset = (index % 2 == 0) ? -15.0 : 15.0;

    path.moveTo(center.dx - width/2 + topOffset + 10, center.dy - height/2); // Top left
    path.lineTo(center.dx + width/2 + topOffset - 10, center.dy - height/2); // Top right
    // Top right corner curve (simplified by just letting path be sharp for now, or using arcTo if needed. 
    // To keep it simple but better proportioned:
    path.lineTo(center.dx + width/2 + bottomOffset, center.dy + height/2); // Bottom right
    path.lineTo(center.dx - width/2 + bottomOffset, center.dy + height/2); // Bottom left
    path.close();

    // Determine colors and borders based on state
    Color fillColor;
    Color borderColor;
    double borderWidth = 1.0;

    switch (node.status) {
      case TerraceNodeStatus.locked:
        fillColor = const Color(0xFFE8EAE4);
        borderColor = AppColors.garis;
        break;
      case TerraceNodeStatus.available:
        // Pulsate opacity
        fillColor = AppColors.daunSamar.withValues(alpha: 0.6 + (0.4 * pulseAnimation.value));
        borderColor = AppColors.daun;
        borderWidth = 2.0;
        break;
      case TerraceNodeStatus.inProgress:
        fillColor = AppColors.daunSamar;
        borderColor = AppColors.daun;
        borderWidth = 2.0;
        break;
      case TerraceNodeStatus.completed:
        fillColor = AppColors.air; // Simplification of gradient
        borderColor = AppColors.airDalam;
        borderWidth = 1.0;
        break;
      case TerraceNodeStatus.perfect:
        fillColor = AppColors.air;
        borderColor = AppColors.padi;
        borderWidth = 2.0;
        break;
    }

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Stroke
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(path, strokePaint);

    // Text & Icons
    _drawNodeContent(canvas, node, center);
  }

  void _drawNodeContent(Canvas canvas, TerraceNode node, Offset center) {
    // Code text (C1, T2)
    final textPainter = TextPainter(
      text: TextSpan(
        text: node.code,
        style: AppTypography.tampilanKecil.copyWith(
          color: node.status == TerraceNodeStatus.locked 
              ? AppColors.tanahSamar 
              : AppColors.tanah,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(center.dx - textPainter.width/2, center.dy - textPainter.height/2 - 10),
    );
    
    // Status Icon
    IconData? icon;
    Color? iconColor;
    if (node.status == TerraceNodeStatus.locked) {
      icon = Icons.lock;
      iconColor = AppColors.tanahSamar;
    } else if (node.status == TerraceNodeStatus.completed || node.status == TerraceNodeStatus.perfect) {
      icon = Icons.check;
      iconColor = node.status == TerraceNodeStatus.perfect ? AppColors.padi : AppColors.kertas;
    }
    
    if (icon != null) {
      final iconPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: 20,
            fontFamily: icon.fontFamily,
            color: iconColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      iconPainter.layout();
      iconPainter.paint(canvas, Offset(center.dx - iconPainter.width/2, center.dy + 5));
    }
    
    // Character / Progress for inProgress
    if (node.status == TerraceNodeStatus.inProgress) {
      // Draw progress bar
      final barWidth = 80.0;
      final barRect = Rect.fromLTWH(center.dx - barWidth/2, center.dy + 15, barWidth, 6);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(3)),
        Paint()..color = AppColors.garis,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(center.dx - barWidth/2, center.dy + 15, barWidth * node.progress, 6),
          const Radius.circular(3),
        ),
        Paint()..color = AppColors.daun,
      );
      
      // Draw character placeholder
      final charPainter = TextPainter(
        text: const TextSpan(
          text: '[ILLUSTRATION_PLACEHOLDER]',
          style: TextStyle(fontSize: 10, color: AppColors.daun),
        ),
        textDirection: TextDirection.ltr,
      );
      charPainter.layout();
      
      // Draw background for placeholder
      final bgRect = Rect.fromCenter(
        center: Offset(center.dx + 40, center.dy - 30),
        width: 100,
        height: 30,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(15)),
        Paint()..color = AppColors.kertas.withValues(alpha: 0.9),
      );
      
      charPainter.paint(
        canvas, 
        Offset(center.dx + 40 - charPainter.width/2, center.dy - 30 - charPainter.height/2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TerraceMapPainter oldDelegate) {
    return oldDelegate.pulseAnimation.value != pulseAnimation.value ||
           oldDelegate.nodes != nodes;
  }
}
