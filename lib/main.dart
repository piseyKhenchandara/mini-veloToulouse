import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ui/screens/shell/main_shell.dart';
import 'ui/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://sdeltabhnujeskzviplz.supabase.co',
    anonKey: 'sb_publishable_BM8zzatlX4Ai3tjtxRpWYA_rs-K_2E6',
  );
  runApp(const VeloToulouseApp());
}

class VeloToulouseApp extends StatelessWidget {
  const VeloToulouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KONG JOUL ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}
