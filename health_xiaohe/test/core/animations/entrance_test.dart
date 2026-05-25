import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_xiaohe/core/animations/entrance.dart';

void main() {
  testWidgets('Entrance 从透明渐入到不透明', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Entrance(child: Text('hi')),
    ));

    final opacityStart = tester.widget<Opacity>(
      find
          .ancestor(of: find.text('hi'), matching: find.byType(Opacity))
          .first,
    );
    expect(opacityStart.opacity, lessThan(0.2));

    await tester.pumpAndSettle();
    final opacityEnd = tester.widget<Opacity>(
      find
          .ancestor(of: find.text('hi'), matching: find.byType(Opacity))
          .first,
    );
    expect(opacityEnd.opacity, 1.0);
  });
}
