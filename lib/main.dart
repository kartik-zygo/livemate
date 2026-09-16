import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'core/config/env.dart';
import 'core/widgets/config_error_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // The dashboard has no bottom bar to butt against the system nav, so the
  // ambient field runs the full height of the screen and the nav bar floats
  // over it.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: SystemUiOverlay.values,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Everything configurable lives in .env; load it before anything reads Env.
  await Env.load();

  // Auth is Supabase's job; the API only verifies the JWT it issues. Without
  // credentials there is no session to get, so fail loudly and legibly rather
  // than shipping a login screen that can never succeed.
  if (!Env.hasSupabaseCredentials) {
    runApp(
      const ConfigErrorApp(
        reason: 'SUPABASE_ANON_KEY is empty in your .env file.',
      ),
    );
    return;
  }

  try {
    // `publishableKey` is the current name for what the dashboard still calls
    // the anon key; both formats are accepted here.
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  } catch (e) {
    runApp(ConfigErrorApp(reason: 'Supabase failed to initialise: $e'));
    return;
  }

  await InitialBinding.register();

  runApp(const LivemateApp());
}

class LivemateApp extends StatelessWidget {
  const LivemateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Livemate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // The palette is designed for a warm light surface; a dark variant would
      // need its own colour roles rather than an inverted one.
      themeMode: ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        // Keeps the dense card layouts legible at large system font sizes
        // without letting them break outright.
        maxScaleFactor: 1.35,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
