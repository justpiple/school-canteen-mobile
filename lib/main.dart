import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_canteen/providers/cart_provider.dart';
import 'package:school_canteen/providers/profile_provider.dart';
import 'package:school_canteen/screens/layouts/auth_wrapper.dart';
import 'package:school_canteen/services/dio_instance.dart';
import 'package:school_canteen/services/order_service.dart';
import 'package:school_canteen/services/stand_service.dart';
import 'package:school_canteen/utils/navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/student_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final storageService = StorageService();

  final dioInstance = DioInstance(storage: storageService);
  final dio = dioInstance.dio;

  final authService = AuthService(dio, storageService);
  final studentService = StudentService(dio);
  final orderService = OrderService(dio);
  final standService = StandService(dio);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(studentService)),
        Provider<OrderService>(
          create: (_) => orderService,
        ),
        Provider<StandService>(
          create: (_) => standService,
        ),
        Provider(
          create: (_) => studentService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'School Canteen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.green[800],
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green[800]!,
          secondary: Colors.green[600]!,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[800]!, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[800]!, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green[800],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green[800],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),

        fontFamily: 'Roboto',
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
