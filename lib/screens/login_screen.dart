import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  Role _role = Role.employee;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = AuthServiceProvider.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isSignUp) {
        await authService.signUp(email, password, _role);
      } else {
        await authService.signIn(email, password);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Feedback & Surveys')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isSignUp ? 'Create an account' : 'Sign in',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Enter your email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        (value == null || value.trim().length < 6) ? 'Password must be at least 6 characters' : null,
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Role>(
                      value: _role,
                      decoration: const InputDecoration(
                        labelText: 'Account type',
                        border: OutlineInputBorder(),
                      ),
                      items: Role.values
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role == Role.admin ? 'HR / Admin' : 'Employee'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _role = value);
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(_isSignUp
                        ? 'Already have an account? Sign in'
                        : 'Need an account? Sign up'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
