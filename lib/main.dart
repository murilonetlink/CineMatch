import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'constants.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/swipe_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Constants.supabaseUrl.isNotEmpty) {
    await Supabase.initialize(
      url: Constants.supabaseUrl,
      anonKey: Constants.supabaseAnonKey,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const CinematchApp(),
    ),
  );
}

class CinematchApp extends StatelessWidget {
  const CinematchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinematch',
      theme: AppTheme.darkTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const SwipeScreen() : const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
