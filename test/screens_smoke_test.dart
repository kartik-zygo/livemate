import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:livemate/app/routes/app_pages.dart';
import 'package:livemate/app/routes/app_routes.dart';
import 'package:livemate/app/theme/app_theme.dart';
import 'package:livemate/core/services/onboarding_service.dart';
import 'package:livemate/core/widgets/city_picker_sheet.dart';
import 'package:livemate/data/models/search_filters.dart';
import 'package:livemate/modules/create_finder_post/bindings/create_finder_post_binding.dart';
import 'package:livemate/modules/create_finder_post/controllers/create_finder_post_controller.dart';
import 'package:livemate/modules/create_finder_post/views/create_finder_post_view.dart';
import 'package:livemate/modules/create_listing/bindings/create_listing_binding.dart';
import 'package:livemate/modules/create_listing/controllers/create_listing_controller.dart';
import 'package:livemate/modules/create_listing/views/create_listing_view.dart';
import 'package:livemate/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:livemate/modules/enquiries/controllers/enquiries_controller.dart';
import 'package:livemate/modules/search/controllers/listing_search_controller.dart';
import 'package:livemate/modules/dashboard/widgets/create_menu_sheet.dart';
import 'package:livemate/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:livemate/modules/onboarding/views/onboarding_view.dart';
import 'package:livemate/modules/search/widgets/filter_sheet.dart';
import 'package:livemate/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:livemate/modules/dashboard/views/dashboard_view.dart';

import 'support/fixtures.dart';
import 'support/test_graph.dart';

/// Renders the real screens against the real object graph.
///
/// GetX throws `[Get] the improper use of a GetX has been detected` at build
/// time when an `Obx` closure registers no observable of its own — the
/// analyzer cannot see it and neither can a unit test. Pumping the widget is
/// the only thing that catches it, so these tests exist to make that class of
/// bug impossible to reintroduce silently.
///
/// `DashboardView` builds all six sections at once through its `IndexedStack`,
/// so a single pump covers Home, Discover, Search, Enquiries, Shortlist and
/// Profile together.
Future<void> pumpApp(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(1080, 2280);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.light,
      home: home,
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.35,
        child: child ?? const SizedBox.shrink(),
      ),
    ),
  );

  await settle(tester);
}

/// `pumpAndSettle` would never return — the ambient field animates forever —
/// so time is advanced by hand instead. It has to cover the longest entry
/// animation (8 x 50ms stagger + 340ms) or the staggered `Future.delayed`
/// timers are still pending when the tree is torn down.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  tearDown(TestGraph.reset);

  group('DashboardView', () {
    testWidgets('renders every section with no city and no user', (
      tester,
    ) async {
      await TestGraph.register();
      DashboardBinding().dependencies();

      await pumpApp(tester, const DashboardView());

      expect(tester.takeException(), isNull);
      expect(find.byType(DashboardView), findsOneWidget);
    });

    testWidgets('renders every section with a city and a signed-in user', (
      tester,
    ) async {
      await TestGraph.register(user: fixtureUser(), city: fixtureCity());
      DashboardBinding().dependencies();

      await pumpApp(tester, const DashboardView());

      expect(tester.takeException(), isNull);
      expect(find.text('Hi Test'), findsOneWidget);
    });

    testWidgets('every section survives being switched to', (tester) async {
      await TestGraph.register(user: fixtureUser(), city: fixtureCity());
      DashboardBinding().dependencies();
      await pumpApp(tester, const DashboardView());

      final controller = Get.find<DashboardController>();

      for (final section in DashboardSection.values) {
        controller.goTo(section);
        await settle(tester);
        expect(
          tester.takeException(),
          isNull,
          reason: 'building ${section.name}',
        );
      }
    });

    testWidgets('the drawer opens and renders', (tester) async {
      await TestGraph.register(user: fixtureUser(), city: fixtureCity());
      DashboardBinding().dependencies();
      await pumpApp(tester, const DashboardView());

      Get.find<DashboardController>().openDrawer();
      await settle(tester);

      expect(tester.takeException(), isNull);
      // Both also appear on Home, so this only asserts the drawer added its
      // own copy rather than failing to build.
      expect(find.text('My listings'), findsWidgets);
      expect(find.text('Sign out'), findsWidgets);
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('badges rebuild when the pending count changes', (
      tester,
    ) async {
      await TestGraph.register(user: fixtureUser(), city: fixtureCity());
      DashboardBinding().dependencies();
      await pumpApp(tester, const DashboardView());

      final controller = Get.find<DashboardController>();
      expect(find.text('7'), findsNothing);

      // A badge that does not appear here is an Obx whose read happened in a
      // lazy builder rather than in the closure itself.
      controller.pendingEnquiries.value = 7;
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('7'), findsWidgets);
    });
  });

  /// Drives the real router so each screen gets its real binding and its real
  /// `Get.arguments`, which is what several controllers read in `onInit`.
  Future<void> pumpRoutes(
    WidgetTester tester, {
    String initialRoute = Routes.root,
  }) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        initialRoute: initialRoute,
        getPages: AppPages.pages,
        builder: (context, child) => MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.35,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
    await settle(tester);
  }

  // Collects rather than asserts, so one broken screen does not hide the
  // next one. Every failure in the run is reported together at the end.
  Future<void> visit(
    WidgetTester tester,
    List<String> failures,
    String route, {
    dynamic arguments,
  }) async {
    Get.toNamed(route, arguments: arguments);
    await settle(tester);
    final onBuild = tester.takeException();
    if (onBuild != null) failures.add('$route (build): $onBuild');

    Get.back();
    await settle(tester);
    final onLeave = tester.takeException();
    if (onLeave != null) failures.add('$route (pop): $onLeave');
  }

  group('every route', () {
    testWidgets('each screen builds without throwing', (tester) async {
      await TestGraph.register(user: fixtureUser(), city: fixtureCity());
      await pumpRoutes(tester);

      final failures = <String>[];
      final onRoot = tester.takeException();
      if (onRoot != null) failures.add('${Routes.root} (build): $onRoot');

      await visit(tester, failures, Routes.myListings);
      await visit(tester, failures, Routes.myFinderPosts);
      await visit(tester, failures, Routes.editProfile);
      await visit(tester, failures, Routes.createListing);
      await visit(tester, failures, Routes.createFinderPost);
      await visit(tester, failures, Routes.listingDetail, arguments: 'l-1');
      await visit(tester, failures, Routes.finderPostDetail, arguments: 'p-1');

      expect(failures, isEmpty, reason: failures.join('\n\n'));
    });

    testWidgets('the auth screens build', (tester) async {
      await TestGraph.register();
      await pumpRoutes(tester);

      final failures = <String>[];
      await visit(tester, failures, Routes.login);
      await visit(tester, failures, Routes.signup);

      expect(failures, isEmpty, reason: failures.join('\n\n'));
    });
  });

  group('multi-step forms', () {
    // The route test only ever renders step one. Every later step is a
    // different widget tree with its own Obx closures, so each is walked here.
    testWidgets('every listing step builds', (tester) async {
      await TestGraph.register(user: fixtureUser(), city: fixtureCity());
      CreateListingBinding().dependencies();
      await pumpApp(tester, const CreateListingView());

      final controller = Get.find<CreateListingController>();
      final failures = <String>[];

      for (final step in ListingStep.values) {
        controller.step.value = step;
        await settle(tester);
        final error = tester.takeException();
        if (error != null) failures.add('${step.name}: $error');
      }

      expect(failures, isEmpty, reason: failures.join('\n\n'));
    });

    testWidgets('every finder-post step builds', (tester) async {
      await TestGraph.register(user: fixtureUser(), city: fixtureCity());
      CreateFinderPostBinding().dependencies();
      await pumpApp(tester, const CreateFinderPostView());

      final controller = Get.find<CreateFinderPostController>();
      final failures = <String>[];

      for (final step in FinderStep.values) {
        controller.step.value = step;
        await settle(tester);
        final error = tester.takeException();
        if (error != null) failures.add('${step.name}: $error');
      }

      expect(failures, isEmpty, reason: failures.join('\n\n'));
    });
  });

  group('sheets', () {
    Future<void> openSheet(
      WidgetTester tester,
      Future<void> Function(BuildContext) open,
    ) async {
      await TestGraph.register(user: fixtureUser(), city: fixtureCity());
      DashboardBinding().dependencies();
      await pumpApp(tester, const DashboardView());

      final context = tester.element(find.byType(DashboardView));
      unawaited(open(context));
      await settle(tester);
    }

    testWidgets('the create menu builds', (tester) async {
      await openSheet(tester, CreateMenuSheet.show);
      expect(tester.takeException(), isNull);
      expect(find.text('I have a room'), findsOneWidget);
    });

    testWidgets('the city picker builds', (tester) async {
      await openSheet(tester, (c) => CityPickerSheet.show(c));
      expect(tester.takeException(), isNull);
      expect(find.text('Choose a city'), findsWidgets);
    });

    testWidgets('the filter sheets build', (tester) async {
      await openSheet(
        tester,
        (c) => ListingFilterSheet.show(c, const ListingSearchFilters()),
      );
      expect(tester.takeException(), isNull);

      await openSheet(
        tester,
        (c) => FinderFilterSheet.show(c, const FinderSearchFilters()),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('with data on screen', () {
    // Most of the app's reactive widgets only exist inside a populated list —
    // the save heart on a card, the accept/decline buttons on an enquiry, the
    // owner controls on a listing you posted. None of them are reached by the
    // empty-state runs above.
    testWidgets('every dashboard section renders populated', (tester) async {
      await TestGraph.register(
        user: fixtureUser(),
        city: fixtureCity(),
        withData: true,
      );
      DashboardBinding().dependencies();
      await pumpApp(tester, const DashboardView());

      final controller = Get.find<DashboardController>();
      final failures = <String>[];

      for (final section in DashboardSection.values) {
        controller.goTo(section);
        await settle(tester);
        final error = tester.takeException();
        if (error != null) failures.add('${section.name}: $error');
      }

      expect(failures, isEmpty, reason: failures.join('\n\n'));

      // The loop ends on Profile, so come back to a feed to prove the fixtures
      // actually reached the widgets rather than every section quietly
      // rendering its empty state.
      controller.goTo(DashboardSection.discover);
      await settle(tester);
      expect(find.text('Sunny double room in Kothrud'), findsWidgets);
    });

    testWidgets('search renders both modes', (tester) async {
      await TestGraph.register(
        user: fixtureUser(),
        city: fixtureCity(),
        withData: true,
      );
      DashboardBinding().dependencies();
      await pumpApp(tester, const DashboardView());

      Get.find<DashboardController>().goTo(DashboardSection.search);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'rooms mode');

      Get.find<ListingSearchController>().switchMode(SearchMode.people);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'people mode');
    });

    testWidgets('both enquiry tabs render their cards', (tester) async {
      await TestGraph.register(
        user: fixtureUser(),
        city: fixtureCity(),
        withData: true,
      );
      DashboardBinding().dependencies();
      await pumpApp(tester, const DashboardView());

      final dashboard = Get.find<DashboardController>();
      dashboard.goTo(DashboardSection.enquiries);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'received tab');

      Get.find<EnquiriesController>().setTab(1);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'sent tab');
    });

    testWidgets('detail and owner screens render populated', (tester) async {
      await TestGraph.register(
        user: fixtureUser(),
        city: fixtureCity(),
        withData: true,
      );
      await pumpRoutes(tester);

      final failures = <String>[];
      await visit(tester, failures, Routes.myListings);
      await visit(tester, failures, Routes.myFinderPosts);
      // Someone else's listing: the save heart and the enquiry bar.
      await visit(tester, failures, Routes.listingDetail, arguments: 'l-1');
      // Your own: the edit and delete controls instead.
      await visit(
        tester,
        failures,
        Routes.listingDetail,
        arguments: FakeTenantListingRepository.ownedId,
      );
      await visit(tester, failures, Routes.finderPostDetail, arguments: 'p-1');
      await visit(
        tester,
        failures,
        Routes.finderPostDetail,
        arguments: FakeFinderPostRepository.ownedId,
      );

      expect(failures, isEmpty, reason: failures.join('\n\n'));
    });
  });

  group('onboarding', () {
    testWidgets('all three slides build and finish lands on sign-in', (
      tester,
    ) async {
      await TestGraph.register();
      // Through the router, so `finish()` has somewhere real to land.
      await pumpRoutes(tester, initialRoute: Routes.onboarding);

      final controller = Get.find<OnboardingController>();
      expect(tester.takeException(), isNull, reason: 'first slide');
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      for (var i = 1; i < controller.slides.length; i++) {
        controller.next();
        await settle(tester);
        expect(tester.takeException(), isNull, reason: 'slide $i');
        expect(controller.index.value, i);
      }

      // The last slide swaps the label and drops Skip — there is nothing left
      // to skip to.
      expect(find.text('Get started'), findsOneWidget);
      expect(controller.isLast, isTrue);

      expect(Get.find<OnboardingService>().seen.value, isFalse);
      await controller.finish();
      await settle(tester);

      expect(Get.find<OnboardingService>().seen.value, isTrue);
      expect(Get.currentRoute, Routes.login);
      expect(find.byType(OnboardingView), findsNothing);
    });

    testWidgets('the dots jump straight to a slide', (tester) async {
      await TestGraph.register();
      await pumpRoutes(tester, initialRoute: Routes.onboarding);

      // Disposed inline rather than in a teardown: the handle check runs
      // before teardowns do.
      final semantics = tester.ensureSemantics();

      await tester.tap(find.bySemanticsLabel('Slide 3 of 3'));
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(Get.find<OnboardingController>().index.value, 2);
      semantics.dispose();
    });
  });
}
