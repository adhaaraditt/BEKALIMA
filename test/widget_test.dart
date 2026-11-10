import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bekalima/main.dart';
import 'package:bekalima/widgets/add_to_cart_dialog.dart';

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

    // 4. Submit kosong: tampilkan pesan wajib isi
    await tester.tap(find.byKey(const ValueKey('submit_register_button')));
    await tester.pump();

    expect(find.text('Harap di isi terlebih dahulu.'), findsNWidgets(5));

    // Isi semua field lalu submit
    await tester.enterText(find.byType(TextField).at(0), 'raditya@bekalima.com');
    await tester.enterText(find.byType(TextField).at(1), 'raditya');
    await tester.enterText(find.byType(TextField).at(2), '081234567890');
    await tester.enterText(find.byType(TextField).at(3), 'bekalima123');
    await tester.enterText(find.byType(TextField).at(4), 'bekalima123');

    await tester.tap(find.byKey(const ValueKey('submit_register_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verifikasi masuk ke layar utama katering
    expect(find.text('Katering Online Indonesia'), findsOneWidget);
    expect(find.text('Kategori Katering'), findsOneWidget);

    // 5. Verifikasi Bottom Navigation Bar: hanya tab aktif yang menampilkan label
    expect(find.text('Beranda'), findsOneWidget);

    // Verifikasi sliding indicator awal berada di tab pertama (-1.0)
    final initialIndicator = tester.widget<AnimatedAlign>(
      find.byType(AnimatedAlign),
    );
    expect(initialIndicator.alignment, equals(const Alignment(-1.0, 0.0)));

    // Tab lain yang belum aktif hanya menampilkan ikonnya
    final menuCrossFade = tester.widget<AnimatedCrossFade>(
      find.byWidgetPredicate((widget) =>
          widget is AnimatedCrossFade &&
          widget.firstChild is Padding &&
          ((widget.firstChild as Padding).child is AnimatedDefaultTextStyle) &&
          (((widget.firstChild as Padding).child as AnimatedDefaultTextStyle).child as Text).data == 'Menu'),
    );
    expect(menuCrossFade.crossFadeState, equals(CrossFadeState.showSecond));

    // Ketuk tab Menu
    await tester.tap(find.byIcon(Icons.restaurant_menu_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Sekarang tab Menu menampilkan labelnya dan sliding indicator bergeser ke tab Menu
    final updatedIndicator = tester.widget<AnimatedAlign>(
      find.byType(AnimatedAlign),
    );
    expect((updatedIndicator.alignment as Alignment).x, closeTo(-0.5, 0.05));

    final updatedMenuCrossFade = tester.widget<AnimatedCrossFade>(
      find.byWidgetPredicate((widget) =>
          widget is AnimatedCrossFade &&
          widget.firstChild is Padding &&
          ((widget.firstChild as Padding).child is AnimatedDefaultTextStyle) &&
          (((widget.firstChild as Padding).child as AnimatedDefaultTextStyle).child as Text).data == 'Menu'),
    );
    expect(updatedMenuCrossFade.crossFadeState, equals(CrossFadeState.showFirst));
  });

  testWidgets('AddToCartSuccessDialog displays message and closes on X tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  AddToCartSuccessDialog.show(
                    context,
                    menuName: 'Nasi Liwet Komplit',
                    quantity: 5,
                  );
                },
                child: const Text('Add'),
              ),
            ),
          ),
        ),
      ),
    );

    // Buka dialog
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verifikasi konten dialog di tengah layar
    expect(find.text('Berhasil Ditambahkan'), findsOneWidget);
    expect(
      find.text('Berhasil menambahkan 5 porsi Nasi Liwet Komplit ke keranjang.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('dialog_close_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('dialog_view_cart_button')), findsOneWidget);

    // Ketuk tombol X untuk menutup
    await tester.tap(find.byKey(const ValueKey('dialog_close_button')));
    await tester.pumpAndSettle();

    expect(find.text('Berhasil Ditambahkan'), findsNothing);
  });
}
