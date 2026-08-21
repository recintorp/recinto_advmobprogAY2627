import 'package:flutter/material.dart';
import '../services/user_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  // Controls the visibility of the password
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Checks credentials, saves user data to the phone, and goes to the Home screen.
  void _login() async {
    UserService userService = UserService();
    setState(() {
      _isLoading = true;
    });
    
    if (_formKey.currentState!.validate()) {
      try {
        final response = await userService.loginUser(
          _usernameController.text,
          _passwordController.text,
        );

        await userService.saveUserData(response);

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacementNamed(context, '/home', arguments: response);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Custom clean border style to match the sample exactly
    final luxuryBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Color(0xFF3949AB), width: 1.5),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/nubdexchange_logo.png',
                        height: 45,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      // This forces the label to sit on the border line permanently
                      floatingLabelBehavior: FloatingLabelBehavior.always, 
                      enabledBorder: luxuryBorder,
                      focusedBorder: focusedBorder,
                      errorBorder: luxuryBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
                      focusedErrorBorder: luxuryBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword, // Tied to the state variable
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: luxuryBorder,
                      focusedBorder: focusedBorder,
                      errorBorder: luxuryBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
                      focusedErrorBorder: luxuryBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      // Toggles the password visibility
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3949AB), 
                        shadowColor: const Color(0xFF3949AB).withValues(alpha: 0.4),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}