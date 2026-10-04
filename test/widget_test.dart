
import 'package:flutter_test/flutter_test.dart';
import 'package:museum_learn/main.dart';

void main() {
  testWidgets('Nusantara Museum login page test', (WidgetTester tester) async {
    await tester.pumpWidget(const NusantaraMuseumApp());

    expect(find.text('Nusantara Museum'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Silakan masuk ke akun Anda'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}