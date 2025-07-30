// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/auth_service.dart';
import 'package:mamasave/widgets/custom_snackbar.dart';

// The LoginPage allows users to sign in to the application.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handles user login.
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      final bool loginSuccess = await authService.signIn(email, password);

      if (loginSuccess) {
        CustomSnackBar.showSuccess(context, 'Login successful!');
        String role = authService.currentUserRole ?? 'mother';
        if (role == 'mother') {
          Navigator.of(context).pushReplacementNamed('/mother_dashboard');
        } else if (role == 'chw') {
          Navigator.of(context).pushReplacementNamed('/chw_dashboard');
        } else if (role == 'midwife') {
          Navigator.of(context).pushReplacementNamed('/midwife_dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/role_selection');
        }
      } else {
        CustomSnackBar.showError(
            context, 'Login failed. Invalid credentials or role.');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        // Center the content
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Use a flexible SizedBox for top spacing to adapt to screen size
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Center(
                child: Image.asset(
                  'assets/logo.png', // Placeholder for your app logo
                  height: 120,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome Back!',
                style: AppStyles.headline1
                    .copyWith(color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue to MamaSave',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined,
                            color: Theme.of(context).iconTheme.color),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock_outline,
                            color: Theme.of(context).iconTheme.color),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          CustomSnackBar.showInfo(context,
                              'Forgot password functionality coming soon!');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .textButtonTheme
                                      .style
                                      ?.foregroundColor
                                      ?.resolve(MaterialState.values.toSet())),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).primaryColor)
                        : ElevatedButton(
                            onPressed: _login,
                            style: Theme.of(context).elevatedButtonTheme.style,
                            child: const Text('Login'),
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: AppStyles.bodyText1.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/signup');
                          },
                          child: Text(
                            'Sign Up',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .textButtonTheme
                                        .style
                                        ?.foregroundColor
                                        ?.resolve(
                                            MaterialState.values.toSet())),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/backend_demo');
                          },
                          child: const Text('Backend Demo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
