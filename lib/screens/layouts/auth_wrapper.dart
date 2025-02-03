import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_canteen/models/login_response.dart';
import 'package:school_canteen/providers/profile_provider.dart';
import 'package:school_canteen/screens/layouts/admin_stand_layout.dart';
import 'package:school_canteen/services/stand_admin/stand_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  final String _lastVisitKey = 'last_visit_timestamp';
  final Duration _cacheValidity = const Duration(hours: 1);
  bool _isFirstLoad = true;
  bool _isHaveProfile = true;

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _loadingController.forward();
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
      await _checkAuth();
      await prefs.setInt(_lastVisitKey, now);
    } else {
      await _checkAuth();
    }
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    if (authProvider.isAuthenticated) {
      if (!mounted) return;
      if (authProvider.role == Role.STUDENT) {
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);
        await profileProvider.loadProfile();

        final studentProfile = profileProvider.studentProfile;

        if (studentProfile?.data == null) _isHaveProfile = false;
      } else {
        final standProfile = await context.read<StandService>().getProfile();

        if (standProfile.data == null) _isHaveProfile = false;
      }
    }

    if (_isFirstLoad) {
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

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
                    primaryColor.withValues(alpha: .05),
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
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: .1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color:
                                          primaryColor.withValues(alpha: .05),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/icons/icon-large_foreground.png',
                                    width: 120,
                                    height: 120,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          'School Canteen',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _loadingController,
                          curve: Curves.easeOut,
                        )),
                        child: Text(
                          'Order Your Food Easily',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                    letterSpacing: 0.5,
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
          return auth.role == Role.STUDENT
              ? StudentLayout(
                  isHaveProfile: _isHaveProfile,
                )
              : AdminStandLayout(
                  isHaveProfile: _isHaveProfile,
                );
        }
        return const LoginScreen();
      },
    );
  }
}
