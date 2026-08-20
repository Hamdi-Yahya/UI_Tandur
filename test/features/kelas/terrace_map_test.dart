import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tandur/features/kelas/data/kelas_mock_data.dart';
import 'package:tandur/features/kelas/presentation/widgets/terrace_map.dart';

List<TerraceNode> _nodes(int jumlah) {
  return List<TerraceNode>.generate(
    jumlah,
    (i) => TerraceNode(
      id: 'level-$i',
      title: 'Petak ${i + 1}',
      code: 'C${i + 1}',
      status: i == 0 ? TerraceNodeStatus.available : TerraceNodeStatus.locked,
    ),
  );
}

Future<void> _pump(WidgetTester tester, List<TerraceNode> nodes) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TerraceMap(nodes: nodes, onNodeTap: (_) {}),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('TerraceMap', () {
    testWidgets('satu petak (Terong/Padi) dirender', (tester) async {
      await _pump(tester, _nodes(1));
      expect(find.text('Petak 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empat petak dirender semuanya', (tester) async {
      await _pump(tester, _nodes(4));
      for (var i = 1; i <= 4; i++) {
        expect(find.text('Petak $i'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('lebih dari empat petak tidak melempar RangeError', (
      tester,
    ) async {
      // Kurikulum masih bertambah. Daftar posisi tetap hanya berisi empat
      // entri, jadi jumlah petak kelima ke atas dulu memicu RangeError.
      await _pump(tester, _nodes(7));

      expect(tester.takeException(), isNull);
      for (var i = 1; i <= 7; i++) {
        expect(find.text('Petak $i'), findsOneWidget);
      }
    });

    testWidgets('peta tanpa petak tidak melempar', (tester) async {
      await _pump(tester, const []);
      expect(tester.takeException(), isNull);
    });
  });
}
