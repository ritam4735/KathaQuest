import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'state/game_state.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: const KathaQuestApp(),
    ),
  );
}

class KathaQuestApp extends StatelessWidget {
  const KathaQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KathaQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.royalTheme,
      home: const SplashScreen(),
    );
  }
}
