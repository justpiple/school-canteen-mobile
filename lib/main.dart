import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:school_canteen/models/login_response.dart';
import 'package:school_canteen/providers/cart_provider.dart';
import 'package:school_canteen/providers/profile_provider.dart';
import 'package:school_canteen/screens/layouts/auth_wrapper.dart';
import 'package:school_canteen/services/dio_instance.dart';
import 'package:school_canteen/services/discount_service.dart';
import 'package:school_canteen/services/menu_service.dart';
import 'package:school_canteen/services/order_service.dart';
import 'package:school_canteen/services/stand_service.dart';
import 'package:school_canteen/utils/navigation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/student_service.dart';
// ignore: library_prefixes
import 'services/stand_admin/stand_service.dart' as StandServiceAdmin;
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
  final standServiceAdmin = StandServiceAdmin.StandService(dio);
  final menuService = MenuService(dio);
  final discountService = DiscountService(dio);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider?>(
            create: (_) => null,
            update: (_, authProvider, __) {
              if (authProvider.role == Role.STUDENT) {
                return CartProvider(prefs);
              }
              return null;
            }),
        ChangeNotifierProvider(create: (_) => ProfileProvider(studentService)),
        Provider<OrderService>(create: (_) => orderService),
        ProxyProvider<AuthProvider, StandService?>(
          update: (_, authProvider, __) {
            if (authProvider.role == Role.STUDENT) {
              return standService;
            }
            return null;
          },
        ),
        ProxyProvider<AuthProvider, StandServiceAdmin.StandService?>(
          update: (_, authProvider, __) {
            if (authProvider.role == Role.ADMIN_STAND) {
              return standServiceAdmin;
            }
            return null;
          },
        ),
        ProxyProvider<AuthProvider, StudentService?>(
          update: (_, authProvider, __) {
            if (authProvider.role == Role.STUDENT) {
              return studentService;
            }
            return null;
          },
        ),
        ProxyProvider<AuthProvider, MenuService?>(
          update: (_, authProvider, __) {
            if (authProvider.role == Role.ADMIN_STAND) {
              return menuService;
            }
            return null;
          },
        ),
        ProxyProvider<AuthProvider, DiscountService?>(
          update: (_, authProvider, __) {
            if (authProvider.role == Role.ADMIN_STAND) {
              return discountService;
            }
            return null;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    SystemChannels.navigation.setMethodCallHandler((MethodCall call) async {
      if (call.method == "popRoute") {
        final navigator = NavigationService.navigatorKey.currentState;

        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          final bool shouldPop = await _onWillPop();
          if (shouldPop) {
            SystemNavigator.pop();
          }
        }
      }
      return null;
    });
  }

  Future<bool> _onWillPop() async {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) {
      return false;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                LucideIcons.alertTriangle,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Exit Application',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to exit the application?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        final navigator = NavigationService.navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
          return;
        }

        final bool shouldPop = await _onWillPop();
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        title: 'School Canteen',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green[500],
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.green[600]!,
            secondary: Colors.green[400]!,
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
      ),
    );
  }
}
