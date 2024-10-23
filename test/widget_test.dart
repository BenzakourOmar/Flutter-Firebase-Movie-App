import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tp_avis_film/main.dart';

void main() {
  testWidgets('Test de la page de recherche de films', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Vérifie que la page de recherche s'affiche avec le bon titre.
    expect(find.text('Recherche de Films'), findsOneWidget);

    // Trouver le champ de texte (TextField) pour saisir la recherche.
    expect(find.byType(TextField), findsOneWidget);

    // Saisir un texte dans le TextField.
    await tester.enterText(find.byType(TextField), 'Blade Runner');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump(); // Attendre que le widget se mette à jour après la recherche.

    // Vérifie que les résultats de recherche sont affichés.
    expect(find.text('Blade Runner'), findsWidgets); // Vérifie que les films contenant "Blade Runner" sont affichés.
  });
}