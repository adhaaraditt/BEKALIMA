import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bekalima/main.dart';
import 'package:bekalima/data/sample_data.dart';
import 'package:bekalima/widgets/add_to_cart_dialog.dart';
import 'package:bekalima/widgets/catering_menu_card.dart';
import 'package:bekalima/widgets/promo_carousel_banner.dart';

void main() {
  testWidgets('Welcome, Login, and Register screen flow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const BekalimaApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('BEKALIMA'), findsOneWidget);
    expect(find.text('Healty Food Catering'), findsOneWidget);

    final arrowFinder = find.byKey(const ValueKey('welcome_arrow_button'));
    expect(arrowFinder, findsOneWidget);

    await tester.tap(arrowFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.byKey(const ValueKey('welcome_masuk_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('welcome_daftar_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('welcome_masuk_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Silahkan Masuk akun apabila sudah mempunyai akun'), findsOneWidget);
    expect(find.text('Username/Email'), findsOneWidget);
    expect(find.text('Lupa Password?'), findsOneWidget);
    expect(find.text('Continue With Google'), findsOneWidget);
    expect(find.text('Continue With Facebook'), findsOneWidget);

    await tester.tap(find.text('Daftar').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Silahkan membuat akun terlebih dahulu'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('No Telepon'), findsOneWidget);
    expect(find.text('Ulangi Password'), findsOneWidget);
    expect(
      find.text(
        'Harus ada huruf besar, angka, simbol, dan minimal 8 karakter.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('submit_register_button')));
    await tester.pump();

    expect(find.text('Harap di isi terlebih dahulu.'), findsNWidgets(5));

    await tester.enterText(find.byType(TextField).at(0), 'raditya@bekalima.com');
    await tester.enterText(find.byType(TextField).at(1), 'raditya');
    await tester.enterText(find.byType(TextField).at(2), '081234567890');
    await tester.enterText(find.byType(TextField).at(3), 'bekalima123');
    await tester.enterText(find.byType(TextField).at(4), 'bekalima123');

    await tester.tap(find.byKey(const ValueKey('submit_register_button')));
    await tester.pump();

    expect(
      find.text(
        'Password minimal 8 karakter, harus ada huruf besar, angka, dan simbol.',
      ),
      findsOneWidget,
    );
    expect(find.text('Katering Online Indonesia'), findsNothing);

    await tester.enterText(find.byType(TextField).at(3), 'Bekalima123!');
    await tester.enterText(find.byType(TextField).at(4), 'Bekalima123!');

    await tester.tap(find.byKey(const ValueKey('submit_register_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Katering Online Indonesia'), findsOneWidget);
    expect(find.text('Kategori Katering'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);

    final initialIndicator = tester.widget<AnimatedAlign>(
      find.byType(AnimatedAlign),
    );
    expect(initialIndicator.alignment, equals(const Alignment(-1.0, 0.0)));

    final menuCrossFade = tester.widget<AnimatedCrossFade>(
      find.byWidgetPredicate((widget) =>
          widget is AnimatedCrossFade &&
          widget.firstChild is Padding &&
          ((widget.firstChild as Padding).child is AnimatedDefaultTextStyle) &&
          (((widget.firstChild as Padding).child as AnimatedDefaultTextStyle).child as Text).data == 'Menu'),
    );
    expect(menuCrossFade.crossFadeState, equals(CrossFadeState.showSecond));

    await tester.tap(find.byIcon(Icons.restaurant_menu_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

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

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Berhasil Ditambahkan'), findsOneWidget);
    expect(
      find.text('Berhasil menambahkan 5 porsi Nasi Liwet Komplit ke keranjang.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('dialog_close_button')), findsOneWidget);
    expect(find.byKey(const ValueKey('dialog_view_cart_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('dialog_close_button')));
    await tester.pumpAndSettle();

    expect(find.text('Berhasil Ditambahkan'), findsNothing);
  });

  testWidgets('CateringMenuCard renders Image for menus with imageAsset',
      (WidgetTester tester) async {
    final ayamBakar = SampleData.menuItems.firstWhere((m) => m.id == 'm1');
    expect(ayamBakar.imageAsset, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CateringMenuCard(
            menu: ayamBakar,
            onTap: () {},
            onAddToCart: () {},
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Nasi Kotak Ayam Bakar Madu'), findsOneWidget);
  });

  testWidgets('PromoCarouselBanner renders headline, highlight, and Shop Now button',
      (WidgetTester tester) async {
    final ayamBakar = SampleData.menuItems.firstWhere((m) => m.id == 'm1');
    final promo = PromoItemData(
      menu: ayamBakar,
      headline: 'Promo Spesial Bulan Ini',
      highlight: 'Ayam Bakar Madu',
      subtitle: 'Ayam bumbu madu legit dengan tahu tempe & urap',
      termsText: '*Min. order 10 box.',
      ctaText: 'Shop Now',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PromoCarouselBanner(
            promoItems: [promo],
          ),
        ),
      ),
    );

    expect(find.text('PROMO SPESIAL BULAN INI'), findsOneWidget);
    expect(find.text('AYAM BAKAR MADU'), findsOneWidget);
    expect(find.text('Shop Now'), findsOneWidget);
    expect(find.byKey(const ValueKey('promo_cta_button_m1')), findsOneWidget);
  });

  testWidgets('PromoCarouselBanner shows both arrows when there are multiple promos',
      (WidgetTester tester) async {
    final ayamBakar = SampleData.menuItems.firstWhere((m) => m.id == 'm1');
    PromoItemData promo(String highlight) => PromoItemData(
          menu: ayamBakar,
          headline: 'Promo',
          highlight: highlight,
          subtitle: 'Sub',
          termsText: 'Terms',
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PromoCarouselBanner(
            promoItems: [promo('Satu'), promo('Dua')],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });
}
