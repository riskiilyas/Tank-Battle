import 'package:flutter/material.dart';
import 'package:tank_battle/screens/sign_up_screen.dart';

import '../widgets/game_text_field.dart';
import 'auth_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    _buttonAnimationController.forward().then((_) => _buttonAnimationController.reverse());

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implement actual sign in logic

    if (mounted) {
      setState(() => _isLoading = false);

      // Navigate to main menu or game screen on success
      // For demo, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SignUpScreen()),
    );
  }

  void _navigateToForgotPassword() {
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return BaseAuthScreen(
      title: 'SIGN IN',
      showBackButton: true,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tank icon or logo
              Center(
                child: Image.asset(
                  'assets/images/player_tank.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 40),

              // Email field
              GameTextField(
                label: 'EMAIL',
                hintText: 'your@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password field
              GameTextField(
                label: 'PASSWORD',
                hintText: '••••••••',
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),

              // Forgot password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _navigateToForgotPassword,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amber,
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign in button
              AnimatedBuilder(
                animation: _buttonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: child,
                  );
                },
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.green.shade200,
                        width: 2,
                      ),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // OR divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Google sign in button
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement Google sign in
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google Sign In - Coming Soon!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                  height: 24,
                  width: 24,
                ),
                label: const Text(
                  'CONTINUE WITH GOOGLE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New to Tank Battle?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: _navigateToSignUp,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.amber,
                    ),
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
