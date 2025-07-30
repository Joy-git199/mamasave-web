// lib/pages/signup_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart'; // Ensure this import is correct
import 'package:mamasave/utils/app_styles.dart'; // Ensure this import is correct
import 'package:mamasave/services/auth_service.dart';
import 'package:mamasave/widgets/custom_snackbar.dart';

// The SignupPage allows new users to register for the application.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handles user registration and immediate login.
  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      // Ensure _selectedRole is not null before proceeding
      if (_selectedRole == null) {
        CustomSnackBar.showError(context, 'Please select a role.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // First, attempt to register the user.
      final Map<String, dynamic> signupResult =
          await authService.signUp(name, email, password, _selectedRole!);

      if (signupResult['success']) {
        // If registration is successful, automatically attempt to log the user in.
        final bool loginSuccess = await authService.signIn(email, password);
        if (loginSuccess) {
          CustomSnackBar.showSuccess(
              context, 'Registration successful! Welcome!');
          // Redirect based on the logged-in user's role.
          String role = authService.currentUserRole ??
              'mother'; // Default to mother if role is null
          if (role == 'mother') {
            Navigator.of(context).pushReplacementNamed('/mother_dashboard');
          } else if (role == 'chw') {
            Navigator.of(context).pushReplacementNamed('/chw_dashboard');
          } else if (role == 'midwife') {
            Navigator.of(context).pushReplacementNamed('/midwife_dashboard');
          } else {
            // Fallback if role is unexpected, perhaps to a role selection page or login
            Navigator.of(context).pushReplacementNamed('/role_selection');
          }
        } else {
          // This case should ideally not happen if signup was successful,
          // but handles potential login failures immediately after signup.
          CustomSnackBar.showWarning(context,
              'Registration successful, but automatic login failed. Please try logging in manually.');
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        CustomSnackBar.showError(
            context, signupResult['error'] ?? 'Registration failed. Please try again.');
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Center(
                child: Image.asset(
                  'assets/logo.png', // Placeholder for your app logo
                  height: 100,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Create Your Account',
                style: AppStyles.headline1
                    .copyWith(color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Join MamaSave to track your health journey',
                style: AppStyles.bodyText1.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person_outline,
                            color: Theme.of(context).iconTheme.color),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icon(Icons.lock_outline,
                            color: Theme.of(context).iconTheme.color),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Register as',
                        hintText: 'Select your role',
                        prefixIcon: Icon(Icons.person_add_alt_1,
                            color: Theme.of(context).iconTheme.color),
                      ),
                      value: _selectedRole,
                      hint: Text('Choose a role',
                          style:
                              Theme.of(context).inputDecorationTheme.hintStyle),
                      items: const [
                        DropdownMenuItem(
                            value: 'mother', child: Text('Mother')),
                        DropdownMenuItem(
                            value: 'chw',
                            child: Text('Community Health Worker')),
                        DropdownMenuItem(
                            value: 'midwife', child: Text('Midwife')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).primaryColor)
                        : ElevatedButton(
                            onPressed: _signup,
                            style: Theme.of(context).elevatedButtonTheme.style,
                            child: const Text('Sign Up'),
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: AppStyles.bodyText1.copyWith(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          },
                          child: Text(
                            'Login',
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