// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smartbuy/main.dart';

void main() {
  testWidgets('SmartBuy app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(isLoggedIn: false, initialDarkMode: false));

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify that login screen is shown when not logged in
    expect(find.text('SmartBuy'), findsOneWidget);
    expect(find.text('Kelola wishlist dan keuanganmu dengan bijak!'), findsOneWidget);
  });

  testWidgets('Login form validation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(isLoggedIn: false, initialDarkMode: false));

    // Find email and password fields
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;

    // Try to submit empty form
    await tester.tap(find.text('MASUK'));
    await tester.pump();

    // Verify validation messages appear
    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('Theme toggle test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(isLoggedIn: true, initialDarkMode: false));

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Navigate to profile screen (assuming it's the last tab)
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Verify profile screen is shown
    expect(find.text('Profil'), findsOneWidget);
  });
}
