import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bekalima/main.dart';

void main() {
  testWidgets('Welcome, Login, and Register screen flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BekalimaApp());
    await tester.pump(const Duration(milliseconds: 100));

    // 1. Verifikasi Welcome Screen
    expect(find.text('BEKALIMA'), findsOneWidget);
    expect(find.text('Healty Food Catering'), findsOneWidget);

    final arrowFinder = find.byKey(const ValueKey('welcome_arrow_button'));
    expect(arrowFinder, findsOneWidget);

    // Buka Bottom Sheet Selamat Datang
    await tester.tap(arrowFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.byKey(const ValueKey('welcome_masuk_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('welcome_daftar_button')), findsOneWidget);

    // 2. Navigasi ke Halaman Masuk (Login)
    await tester.tap(find.byKey(const ValueKey('welcome_masuk_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verifikasi elemen halaman Masuk sesuai desain
    expect(find.text('Silahkan Masuk akun apabila sudah mempunyai akun'), findsOneWidget);
    expect(find.text('Username/Email'), findsOneWidget);
    expect(find.text('Lupa Password?'), findsOneWidget);
    expect(find.text('Continue With Google'), findsOneWidget);
    expect(find.text('Continue With Facebook'), findsOneWidget);

    // 3. Pindah ke Halaman Daftar dari link header atas
    await tester.tap(find.text('Daftar').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verifikasi elemen halaman Daftar sesuai desain
    expect(find.text('Silahkan membuat akun terlebih dahulu'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('No Telepon'), findsOneWidget);
    expect(find.text('Ulangi Password'), findsOneWidget);

    // 4. Submit Daftar dan masuk ke Main App
    await tester.tap(find.byKey(const ValueKey('submit_register_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verifikasi masuk ke layar utama katering
    expect(find.text('Katering Online Indonesia'), findsOneWidget);
    expect(find.text('Kategori Katering'), findsOneWidget);
  });
}
