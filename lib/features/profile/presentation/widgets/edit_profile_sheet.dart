import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/core/config/app_options.dart';
import 'package:seek/core/widgets/app_dropdown_field.dart';
import 'package:seek/core/widgets/custom_text_field.dart';
import 'package:seek/core/widgets/primary_button.dart';
import 'package:seek/features/profile/data/profile_providers.dart';
import 'package:seek/features/profile/domain/entities/app_user.dart';

/// Opens the edit form as a bottom sheet.
Future<void> showEditProfileSheet(BuildContext context, AppUser user) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => EditProfileSheet(user: user),
  );
}

String? _validateName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Name is required';
  if (value.trim().length < 2) return 'Name is too short';
  return null;
}

/// Indonesian numbers: 08123456789, 628123456789 or +628123456789.
String? _validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return 'Phone number is required';
  final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
  if (!RegExp(r'^(\+62|62|0)[0-9]{8,12}$').hasMatch(cleaned)) {
    return 'Enter a valid phone number';
  }
  return null;
}

class EditProfileSheet extends ConsumerStatefulWidget {
  final AppUser user;

  const EditProfileSheet({super.key, required this.user});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String? _city;
  String? _skillLevel;
  late final Set<String> _sports;

  String? _cityError;
  String? _skillError;
  String? _sportsError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user.displayName);
    _phoneController = TextEditingController(text: user.phone);
    // A dropdown crashes if its value is not in the list, so check first.
    _city = AppOptions.cities.contains(user.city) ? user.city : null;
    _skillLevel =
        AppOptions.skillLevels.contains(user.skillLevel) ? user.skillLevel : null;
    _sports = user.sports.where(AppOptions.sports.contains).toSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _errorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12),
      child: Text(
        error,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState!.validate();
    setState(() {
      _cityError = _city == null ? 'Please choose your city' : null;
      _skillError = _skillLevel == null ? 'Please choose your skill level' : null;
      _sportsError = _sports.isEmpty ? 'Choose at least one sport' : null;
    });
    if (!formValid ||
        _cityError != null ||
        _skillError != null ||
        _sportsError != null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSaving = true);
    try {
      await ref.read(userRepositoryProvider).saveUser(
            widget.user.copyWith(
              displayName: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              city: _city,
              sports: AppOptions.sports.where(_sports.contains).toList(),
              skillLevel: _skillLevel,
            ),
          );
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save your profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit profile', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Full name',
                icon: Icons.person_outline,
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),
              AppDropdownField(
                label: 'City',
                icon: Icons.location_city_outlined,
                items: AppOptions.cities,
                value: _city,
                onChanged: (v) => setState(() {
                  _city = v;
                  _cityError = null;
                }),
              ),
              _errorText(_cityError),
              const SizedBox(height: 16),
              AppDropdownField(
                label: 'Skill level',
                icon: Icons.bar_chart,
                items: AppOptions.skillLevels,
                value: _skillLevel,
                onChanged: (v) => setState(() {
                  _skillLevel = v;
                  _skillError = null;
                }),
              ),
              _errorText(_skillError),
              const SizedBox(height: 16),
              Text('Sports', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: AppOptions.sports
                    .map(
                      (sport) => FilterChip(
                        label: Text(sport),
                        selected: _sports.contains(sport),
                        onSelected: (selected) => setState(() {
                          selected ? _sports.add(sport) : _sports.remove(sport);
                          _sportsError = null;
                        }),
                      ),
                    )
                    .toList(),
              ),
              _errorText(_sportsError),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Save',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}