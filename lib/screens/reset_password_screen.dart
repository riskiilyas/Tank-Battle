import 'package:flutter/material.dart';
import 'package:tank_battle/screens/auth_screen.dart';
import 'package:tank_battle/screens/sign_in_screen.dart';
import 'package:tank_battle/widgets/game_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _resetComplete = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implement actual password reset

    if (mounted) {
      setState(() {
        _isLoading = false;
        _resetComplete = true;
      });

      // Navigate back to sign in after showing success message
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseAuthScreen(
      title: 'RESET PASSWORD',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_resetComplete) ...[
            // Reset password form
            const SizedBox(height: 30),

            // Key icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.key,
                  color: Colors.amber,
                  size: 50,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Instruction text
            Text(
              'Create a new password for',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade200,
                fontSize: 16,
              ),
            ),

            Text(
              widget.email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // Password fields
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // New Password field
                  GameTextField(
                    label: 'NEW PASSWORD',
                    hintText: '••••••••',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password field
                  GameTextField(
                    label: 'CONFIRM PASSWORD',
                    hintText: '••••••••',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Password requirements
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade700),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Password must:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPasswordRequirement(
                    'Be at least 8 characters',
                    _passwordController.text.length >= 8,
                  ),
                  _buildPasswordRequirement(
                    'Include at least one number',
                    RegExp(r'[0-9]').hasMatch(_passwordController.text),
                  ),
                  _buildPasswordRequirement(
                    'Include at least one special character',
                    RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Reset button
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.blue.shade200,
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
                'RESET PASSWORD',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ] else ...[
            // Success message
            const SizedBox(height: 60),

            // Success animation
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.5),
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade400,
                  size: 80,
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              'Password Reset Successful!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green.shade400,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Your password has been updated.\nYou can now sign in with your new password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade200,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // Loading indicator for redirect
            const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 3,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Redirecting to sign in...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String requirement, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              color: isMet ? Colors.white : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}