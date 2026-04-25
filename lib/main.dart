import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/ambulance/screens/ambulance_user_home_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const DoctorListApp(),
    ),
  );
}

class DoctorListApp extends StatelessWidget {
  const DoctorListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool _showRegister = false;
  bool? _loggedIn;
  bool _showSplash = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    Future.wait([
      context.read<AuthProvider>().isLoggedIn(),
      Future.delayed(const Duration(seconds: 2)),
    ]).then((results) {
      setState(() {
        _loggedIn = results[0] as bool;
        _showSplash = false;
        if (!_loggedIn!) _showOnboarding = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();
    final auth = context.watch<AuthProvider>();
    // Detect logout: user was logged in but now user is null
    if (_loggedIn == true && auth.user == null && !auth.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() { _loggedIn = false; _showRegister = false; });
      });
    }
    if (_loggedIn == true) {
      final role = context.watch<AuthProvider>().user?.role;
      if (role == 'ambulance_user') return const AmbulanceUserHomeScreen();
      return const HomeScreen();
    }
    if (_showOnboarding) {
      return OnboardingScreen(
        onGetStarted: () => setState(() => _showOnboarding = false),
      );
    }
    if (_showRegister) {
      return RegisterScreen(
        onRegister: () => setState(() => _loggedIn = true),
        onLogin: () => setState(() => _showRegister = false),
      );
    }
    return LoginScreen(
      onLogin: () => setState(() => _loggedIn = true),
      onRegister: () => setState(() => _showRegister = true),
    );
  }
}
