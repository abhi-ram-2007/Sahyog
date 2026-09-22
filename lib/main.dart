import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tkcixakmmaxxrpleisti.supabase.co',
    publishableKey:
        'sb_publishable_EB5WtHPUPQo2OTw-QZ_Zbw_cB40nOOM',
  );

  runApp(const SahyogApp());
}

class SahyogApp extends StatelessWidget {
  const SahyogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Sahyog',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF078B49),
        ),
      ),

      // Start with the Welcome / Landing Page
      home: const LandingPage(),
    );
  }
}