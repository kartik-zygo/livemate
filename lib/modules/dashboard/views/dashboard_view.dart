import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/ambient_background.dart';
import '../../discover/views/discover_view.dart';
import '../../enquiries/views/enquiries_view.dart';
import '../../profile/views/profile_view.dart';
import '../../saved/views/saved_view.dart';
import '../../search/views/search_view.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_bar.dart';
import '../widgets/dashboard_overview.dart';

/// The whole signed-in app: one page, six sections, no bottom bar.
///
/// Sections live in an [IndexedStack] so scroll position and loaded results
/// survive switching away and back. The shell owns the single ambient field
/// every glass surface in the app samples — one animated background for the
/// whole session rather than one per section.
class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back should walk you out of a section before it walks you out of the
      // app — with no bottom bar to return to, leaving would be a surprise.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!controller.popSection()) Navigator.of(context).pop();
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        backgroundColor: Colors.transparent,
        extendBody: true,
        drawer: const AppDrawer(),
        drawerScrimColor: const Color(0x591F1613),
        drawerEdgeDragWidth: 60,
        body: AmbientBackground(
          animate: true,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const DashboardBar(),
                Expanded(
                  child: Obx(
                    () => IndexedStack(
                      index: controller.index,
                      children: const [
                        DashboardOverview(),
                        DiscoverView(),
                        SearchView(),
                        EnquiriesView(),
                        SavedView(),
                        ProfileView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
