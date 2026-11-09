import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/app/router/app_routes.dart';
import 'package:seek/core/config/app_options.dart';
import 'package:seek/core/widgets/app_dropdown_field.dart';
import 'package:seek/core/widgets/custom_text_field.dart';
import 'package:seek/core/widgets/primary_button.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/auth/domain/auth_exception.dart';
import 'package:seek/features/auth/presentation/widgets/auth_switch_text.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedCity;
  String? _selectedSport;
  String? _selectedSkill;

  bool _isLoading = false;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _register() async {
    // Basic check only. Proper validation comes in PR 4.
    if (_selectedCity == null ||
        _selectedSport == null ||
        _selectedSkill == null) {
      _showMessage('Please choose your city, sport and skill level');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            city: _selectedCity,
            sport: _selectedSport,
            skillLevel: _selectedSkill,
          );
      // Nothing else to do: the router sees the new login and opens the app.
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.login)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create account',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Join and start playing with others',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'Full name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppDropdownField(
                label: 'City',
                icon: Icons.location_city_outlined,
                items: AppOptions.cities,
                value: _selectedCity,
                onChanged: (v) => setState(() => _selectedCity = v),
              ),
              const SizedBox(height: 16),
              AppDropdownField(
                label: 'Favorite sport',
                icon: Icons.sports_basketball_outlined,
                items: AppOptions.sports,
                value: _selectedSport,
                onChanged: (v) => setState(() => _selectedSport = v),
              ),
              const SizedBox(height: 16),
              AppDropdownField(
                label: 'Skill level',
                icon: Icons.bar_chart,
                items: AppOptions.skillLevels,
                value: _selectedSkill,
                onChanged: (v) => setState(() => _selectedSkill = v),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Register',
                isLoading: _isLoading,
                onPressed: _register,
              ),
              const SizedBox(height: 16),
              AuthSwitchText(
                question: 'Already have an account?',
                actionText: 'Log in',
                onTap: () => context.go(AppRoutes.login),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}