import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authNotifier = ref.read(authStateProvider.notifier);
    
    final success = await authNotifier.login(
      _emailController.text.trim(), 
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/home');
    } else {
      final errorMsg = ref.read(authStateProvider).error.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg.isEmpty ? 'Login Failed' : errorMsg)),
      );
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final authNotifier = ref.read(authStateProvider.notifier);
    
    final success = await authNotifier.loginWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/home');
    } else {
      final errorMsg = ref.read(authStateProvider).error.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg.isEmpty ? 'Google Sign-In Failed' : errorMsg)),
      );
    }
  }

  void _handleGuestLogin() async {
    setState(() => _isLoading = true);
    final authNotifier = ref.read(authStateProvider.notifier);
    
    final success = await authNotifier.loginAsGuest();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/home');
    } else {
      final errorMsg = ref.read(authStateProvider).error.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg.isEmpty ? 'Guest Login Failed' : errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Glowing Background Orbs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
             .fadeIn(),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(duration: 5.seconds, begin: const Offset(1.2, 1.2), end: const Offset(1, 1)),
          ),
          
          // Glassmorphism Blur Filter
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),

          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.auto_awesome, size: 80, color: Theme.of(context).colorScheme.secondary)
                    .animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  
                  Text(
                    'StudySphere AI',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Your personal, AI-powered learning ecosystem',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 48),

                  // Glassmorphism Form Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                            ).animate().fadeIn(delay: 500.ms).slideX(),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                            ).animate().fadeIn(delay: 600.ms).slideX(),
                            const SizedBox(height: 24),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                    .animate().fadeIn()
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _handleLogin,
                                        child: const Text('Login'),
                                      ).animate().fadeIn(delay: 700.ms).scale(),
                                      const SizedBox(height: 12),
                                      OutlinedButton.icon(
                                        onPressed: _handleGoogleLogin,
                                        icon: const Icon(Icons.g_mobiledata, size: 28),
                                        label: const Text('Sign in with Google'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: BorderSide(color: Colors.white.withOpacity(0.5)),
                                        ),
                                      ).animate().fadeIn(delay: 750.ms).scale(),
                                      const SizedBox(height: 12),
                                      TextButton.icon(
                                        onPressed: _handleGuestLogin,
                                        icon: const Icon(Icons.person_outline),
                                        label: const Text('Continue as Guest'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white70,
                                        ),
                                      ).animate().fadeIn(delay: 800.ms).scale(),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text("Don't have an account? Register"),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
