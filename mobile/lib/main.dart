import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/shoppe_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShoppeProvider(),
      child: Consumer<ShoppeProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'ShoppeFake Dopamine Booster',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark, // Default to OLED Dark High-Contrast
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: provider.isAuthenticated
                ? const MainNavigationScreen()
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}
