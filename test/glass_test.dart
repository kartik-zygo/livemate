import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livemate/app/theme/app_theme.dart';
import 'package:livemate/core/widgets/glass.dart';
import 'package:livemate/modules/dashboard/controllers/dashboard_controller.dart';

/// Pumps [child] inside a MaterialApp with a coloured backdrop, so the
/// BackdropFilter in every glass surface has something real to sample.
Future<void> pumpGlass(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFFEA580C)),
            child: SizedBox.expand(),
          ),
          Center(child: child),
        ],
      ),
    ),
  ),
);

void main() {
  group('GlassSurface', () {
    testWidgets('sizes to its child under loose constraints', (tester) async {
      await pumpGlass(
        tester,
        const GlassSurface(child: SizedBox(width: 180, height: 90)),
      );

      expect(tester.getSize(find.byType(GlassSurface)), const Size(180, 90));
    });

    testWidgets('fills tight constraints without overflowing', (tester) async {
      await pumpGlass(
        tester,
        const SizedBox(
          width: 200,
          height: 60,
          child: GlassSurface(child: SizedBox.expand()),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(GlassSurface)), const Size(200, 60));
    });

    testWidgets('padding is added to the child, not the pane', (tester) async {
      await pumpGlass(
        tester,
        const GlassSurface(
          padding: EdgeInsets.all(10),
          child: SizedBox(width: 100, height: 40),
        ),
      );

      expect(tester.getSize(find.byType(GlassSurface)), const Size(120, 60));
    });

    testWidgets('lays out inside an unbounded horizontal list', (tester) async {
      // A horizontal ListView gives unbounded width — the case that catches a
      // Stack configured with the wrong fit.
      await pumpGlass(
        tester,
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              GlassSurface(child: SizedBox(width: 120, height: 80)),
              GlassSurface(child: SizedBox(width: 120, height: 80)),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(GlassSurface), findsNWidgets(2));
    });
  });

  group('GlassPill', () {
    testWidgets('reports its semantics and fires onTap', (tester) async {
      var taps = 0;
      await pumpGlass(
        tester,
        GlassPill(
          semanticLabel: 'Filters',
          selected: true,
          onTap: () => taps++,
          child: const Text('Filters'),
        ),
      );

      await tester.tap(find.text('Filters'));
      expect(taps, 1);

      final semantics = tester.getSemantics(find.text('Filters'));
      expect(semantics.label, contains('Filters'));
    });

    testWidgets('is inert without an onTap', (tester) async {
      await pumpGlass(tester, const GlassPill(child: Text('Static')));

      expect(find.byType(GlassTapTarget), findsNothing);
    });
  });

  group('GlassIconButton', () {
    testWidgets('keeps a 44px tap target when the disc is smaller', (
      tester,
    ) async {
      await pumpGlass(
        tester,
        GlassIconButton(
          icon: Icons.menu_rounded,
          semanticLabel: 'Open menu',
          size: 32,
          onTap: () {},
        ),
      );

      final size = tester.getSize(find.byType(GlassIconButton));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
    });

    testWidgets('shows a badge only when the count is positive', (
      tester,
    ) async {
      await pumpGlass(
        tester,
        const GlassIconButton(
          icon: Icons.forum_rounded,
          semanticLabel: 'Enquiries',
          badge: 0,
        ),
      );
      expect(find.byType(GlassBadge), findsNothing);

      await pumpGlass(
        tester,
        const GlassIconButton(
          icon: Icons.forum_rounded,
          semanticLabel: 'Enquiries',
          badge: 3,
        ),
      );
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('GlassBadge', () {
    testWidgets('caps at 99+ and disappears at zero', (tester) async {
      await pumpGlass(tester, const GlassBadge(count: 1200));
      expect(find.text('99+'), findsOneWidget);

      await pumpGlass(tester, const GlassBadge(count: 0));
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.textContaining('0'), findsNothing);
    });
  });

  group('DashboardSection', () {
    // DashboardView builds an IndexedStack indexed by `section.index`, so the
    // enum order IS the child order. Reordering the enum without reordering
    // those children would silently show the wrong section.
    test('order matches the IndexedStack children in DashboardView', () {
      expect(DashboardSection.values, [
        DashboardSection.home,
        DashboardSection.discover,
        DashboardSection.search,
        DashboardSection.enquiries,
        DashboardSection.saved,
        DashboardSection.profile,
      ]);
    });

    test('every section carries a label, a blurb and both icons', () {
      for (final section in DashboardSection.values) {
        expect(section.label, isNotEmpty, reason: '${section.name} label');
        expect(section.blurb, isNotEmpty, reason: '${section.name} blurb');
        expect(
          section.icon,
          isNot(section.iconOutline),
          reason: '${section.name} needs a distinct selected icon',
        );
      }
    });
  });

  group('AppTheme', () {
    // dialogTheme is transparent so the app's own confirm dialog can paint a
    // glass pane. Anything Flutter renders in a Dialog it built itself has to
    // carry its own opaque surface, or it lands on nothing.
    test('date and time pickers keep an opaque surface', () {
      final theme = AppTheme.light;

      expect(theme.dialogTheme.backgroundColor, Colors.transparent);
      expect(theme.datePickerTheme.backgroundColor, isNotNull);
      expect(theme.datePickerTheme.backgroundColor!.a, 1.0);
      expect(theme.timePickerTheme.backgroundColor, isNotNull);
      expect(theme.timePickerTheme.backgroundColor!.a, 1.0);
    });

    testWidgets('a date picker renders on a visible surface', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDate: DateTime(2025, 6, 1),
                ),
                child: const Text('pick'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('pick'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
      final dialog = tester.widget<Dialog>(
        find.descendant(
          of: find.byType(DatePickerDialog),
          matching: find.byType(Dialog),
        ),
      );
      expect(dialog.backgroundColor, isNot(Colors.transparent));
    });
  });
}
