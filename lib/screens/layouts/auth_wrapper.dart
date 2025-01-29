import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:school_canteen/screens/layouts/student_layout.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _loadingController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final String _lastVisitKey = 'last_visit_timestamp';
  final Duration _cacheValidity = const Duration(hours: 1);
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();
    _checkAuthWithCache();
  }

  Future<void> _checkAuthWithCache() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVisit = prefs.getInt(_lastVisitKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastVisit != null) {
      final timeDifference = now - lastVisit;
      _isFirstLoad = timeDifference > _cacheValidity.inMilliseconds;
    }

    if (_isFirstLoad) {
      _loadingController.forward();
      await _checkAuth();
      await prefs.setInt(_lastVisitKey, now);
    } else {
      await _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (_isFirstLoad) {
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (_isLoading) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    Colors.white,
                  ],
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 140,
                            height: 140,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'School Canteen',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Order Your Food Easily',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 48),
                      if (_isFirstLoad)
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Lottie.asset(
                            'assets/animations/loading.json',
                            controller: _loadingController,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (auth.isAuthenticated) {
          return const StudentLayout();
        }
        return const LoginScreen();
      },
    );
  }
}
