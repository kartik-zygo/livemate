import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_theme.dart';
import '../config/env.dart';
import 'ambient_background.dart';
import 'empty_state.dart';

/// Shown instead of the app when Supabase credentials are missing.
///
/// Auth is entirely Supabase's; without a key there is no token, so every API
/// call would 401. A blank login screen would hide that, so this says exactly
/// what to set and how.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MyFlat Homes — setup needed',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: ConfigErrorView(reason: reason),
  );
}

class ConfigErrorView extends StatelessWidget {
  const ConfigErrorView({super.key, required this.reason});

  final String reason;

  static const String _command = 'cp .env.example .env';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            children: [
              const EmptyState(
                illustration: AppIllustration.error,
                compact: true,
                title: 'One setting away from running',
                message:
                    'MyFlat Homes signs in through Supabase, so it needs the '
                    'project publishable (anon) key before it can start.',
              ),
              const SizedBox(height: 8),
              _Card(
                title: 'What is missing',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reason, style: AppTextStyles.body),
                    if (Env.missingKeys.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      for (final key in Env.missingKeys)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.remove_circle_outline_rounded,
                                size: 15,
                                color: AppColors.rose600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                key,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12.5,
                                  color: AppColors.rose600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Card(
                title: 'How to fix it',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'If .env does not exist yet in the project root, '
                      'create it:',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 10),
                    _CodeBlock(code: _command),
                    const SizedBox(height: 14),
                    Text(
                      'Then open .env and paste your key after '
                      'SUPABASE_ANON_KEY=, and restart the app.',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The key is the public client key from the same Supabase '
                      'project the web app uses — copy it from that app\'s .env '
                      'file, or from Project Settings → API in the Supabase '
                      'dashboard. .env is git-ignored, so it stays out of '
                      'version control.',
                      style: AppTextStyles.caption.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Card(
                title: 'Current configuration',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(label: 'Supabase URL', value: Env.supabaseUrl),
                    _Row(label: 'API base', value: Env.apiBaseUrl),
                    _Row(
                      label: 'Anon key',
                      value: Env.supabaseAnonKey.isEmpty
                          ? 'not set'
                          : 'set (${Env.supabaseAnonKey.length} chars)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.86),
      borderRadius: AppTheme.cardRadius,
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: SelectableText(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.brand700,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: code)),
          icon: const Icon(Icons.copy_rounded, size: 18),
          tooltip: 'Copy command',
          color: AppColors.inkTertiary,
        ),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 104, child: Text(label, style: AppTextStyles.caption)),
        Expanded(
          child: Text(value, style: AppTextStyles.body.copyWith(fontSize: 13)),
        ),
      ],
    ),
  );
}
