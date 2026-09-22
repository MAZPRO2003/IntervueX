import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/views/auth/auth_gate_screen.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: IntervueXApp()));
}

class IntervueXApp extends ConsumerWidget {
  const IntervueXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final variant = ref.watch(themeVariantProvider);

    return MaterialApp(
      title: 'IntervueX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(variant),
      darkTheme: AppTheme.darkTheme(variant),
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ta', ''),
        Locale('hi', ''),
      ],
      home: const AuthGateScreen(),
    );
  }
}
