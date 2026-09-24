import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SouigatBusFleetApp());
}

class SouigatBusFleetApp extends StatelessWidget {
  const SouigatBusFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مؤسسة سويقات أبو طالب - إدارة الأسطول والسائقين',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryDarkBlue,
          primary: AppColors.primaryDarkBlue,
          secondary: AppColors.accentOrange,
          surface: AppColors.cardWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cardWhite,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
        ),
      ),
      builder: (context, child) {
        // Enforce Right-To-Left (RTL) Layout for Arabic
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const MainNavigationScreen(),
    );
  }
}
