import 'package:flutter/material.dart';
import 'package:mini_velo/ui/screens/login/login_screen.dart';
import 'package:mini_velo/ui/screens/shell/main_shell.dart';
import 'package:mini_velo/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mini_velo/data/repositories/plan_repository.dart';
import 'package:mini_velo/ui/screens/subscription/plan_view_model.dart';
import 'ui/screens/login/login_screen.dart';
import 'ui/screens/shell/main_shell.dart';
import 'ui/theme/app_theme.dart';

import 'ui/screens/welcome/welcome_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sdeltabhnujeskzviplz.supabase.co',
    anonKey: 'sb_publishable_BM8zzatlX4Ai3tjtxRpWYA_rs-K_2E6',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlanViewModel(PlanRepository())),
      ],
      child: const VeloToulouseApp(),
    ),
  );
}

class VeloToulouseApp extends StatelessWidget {
  const VeloToulouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KONG JOUL',
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
      theme: AppTheme.light(),
      // home: const AuthGate(),
      // theme: AppTheme.light(),
      // home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;
        return session == null ? const LoginScreen() : const MainShell();
      },
    );
  }
}
