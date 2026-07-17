import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/shoppe_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/catalog_screen.dart';

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
            themeMode: ThemeMode.dark,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6A11CB),
                secondary: const Color(0xFF00D2FF),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6A11CB),
                secondary: const Color(0xFF00D2FF),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF101014),
              useMaterial3: true,
            ),
            home: provider.isAuthenticated
                ? const CatalogScreen()
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}
