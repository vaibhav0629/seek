
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/app/router/app_routes.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';
import 'package:seek/features/meets/data/meet_providers.dart';
import 'package:seek/features/meets/domain/entities/meet.dart';

class CreateMeetScreen extends ConsumerStatefulWidget {
  const CreateMeetScreen({super.key});

  @override
  ConsumerState<CreateMeetScreen> createState() => _CreateMeetScreenState();
}

class _CreateMeetScreenState extends ConsumerState<CreateMeetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _capacityController = TextEditingController(text: '10');
  final _feeController = TextEditingController(text: '0');

  String? _clubId;
  DateTime _startsAt = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 19, minute: 0);
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startsAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _time.hour,
          _time.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (picked != null) {
      setState(() {
        _time = picked;
        _startsAt = DateTime(
          _startsAt.year,
          _startsAt.month,
          _startsAt.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _createMeet(
    List<Club> adminClubs,
    String selectedClubId,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    final selectedClub = adminClubs.firstWhere(
      (club) => club.id == selectedClubId,
    );

    final startDateTime = DateTime(
      _startsAt.year,
      _startsAt.month,
      _startsAt.day,
      _time.hour,
      _time.minute,
    );

    if (startDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future date and time.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final meet = Meet(
        id: '',
        clubId: selectedClub.id,
        title: _titleController.text.trim(),
        sport: selectedClub.sport,
        description: _descriptionController.text.trim(),
        startsAt: startDateTime,
        venueName: _venueController.text.trim(),
        maxPlayers: int.parse(_capacityController.text),
        fee: int.parse(_feeController.text),
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      final meetId = await ref
          .read(meetRepositoryProvider)
          .createMeet(meet);

      if (!mounted) return;

      context.go(AppRoutes.meet(meetId));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create Meet: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final clubsAsync = ref.watch(myClubsProvider);

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Meet')),
        body: const Center(child: Text('Please log in first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Meet')),
      body: clubsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Failed to load clubs: $error'),
        ),
        data: (clubs) {
          final adminClubs = <Club>[];
          var isLoadingMembers = false;
          String? membersError;

          for (final club in clubs) {
            final membersAsync = ref.watch(
              clubMembersProvider(club.id),
            );

            if (membersAsync.isLoading) {
              isLoadingMembers = true;
              continue;
            }

            if (membersAsync.hasError) {
              membersError = membersAsync.error.toString();
              continue;
            }

            final members = membersAsync.value ?? [];

            final isAdmin = members.any(
              (member) =>
                  member.userId == userId &&
                  member.role == ClubRole.admin,
            );

            if (isAdmin) {
              adminClubs.add(club);
            }
          }

          if (isLoadingMembers) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (membersError != null) {
            return Center(
              child: Text('Failed to load club members: $membersError'),
            );
          }

          if (adminClubs.isEmpty) {
            return const Center(
              child: Text(
                'You must be a club admin to create a meet.',
              ),
            );
          }

          final selectedClubId =
              adminClubs.any((club) => club.id == _clubId)
                  ? _clubId!
                  : adminClubs.first.id;

          final selectedClub = adminClubs.firstWhere(
            (club) => club.id == selectedClubId,
          );

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Meet Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  initialValue: selectedClubId,
                  decoration: const InputDecoration(
                    labelText: 'Club',
                    border: OutlineInputBorder(),
                  ),
                  items: adminClubs.map((club) {
                    return DropdownMenuItem<String>(
                      value: club.id,
                      child: Text(club.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _clubId = value);
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Meet Title',
                    hintText: 'e.g. Sunday Padel Session',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Please enter a meet title'
                          : null,
                ),
                const SizedBox(height: 16),

                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Sport',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(selectedClub.sport),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _venueController,
                  decoration: const InputDecoration(
                    labelText: 'Venue',
                    hintText: 'Enter location or venue name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Please enter a venue'
                          : null,
                ),
                const SizedBox(height: 16),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(_startsAt),
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _pickDate,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Time'),
                  subtitle: Text(_time.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _pickTime,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Maximum Players',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    if (number == null || number < 1) {
                      return 'Enter a valid capacity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fee (IDR)',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    if (number == null || number < 0) {
                      return 'Enter a valid fee';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading
                        ? null
                        : () => _createMeet(
                              adminClubs,
                              selectedClubId,
                            ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Create Meet'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
