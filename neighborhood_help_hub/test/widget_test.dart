import 'package:flutter_test/flutter_test.dart';
import 'package:neighborhood_help_hub/main.dart';

void main() {
  testWidgets('Neighborly welcome screen renders', (tester) async {
    await tester.pumpWidget(const NeighborlyApp());

    expect(find.text('Neighborly'), findsOneWidget);
    expect(find.text('Tutoring'), findsOneWidget);
  });
}
