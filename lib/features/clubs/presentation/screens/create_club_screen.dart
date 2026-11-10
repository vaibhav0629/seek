import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/features/auth/data/auth_providers.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';

const _sports = [
  'Futsal',
  'Badminton',
  'Basket',
  'Lari',
  'Voli',
  'Sepak Bola',
  'Lainnya',
];

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key});

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _sport;
  bool _isPrivate = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // 1. Validasi semua field
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(currentUserIdProvider);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (userId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Kamu harus login dulu')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      // 2. Bentuk objek Club (id dikosongin, repository yang bikin)
      final club = Club(
        id: '',
        name: _nameCtrl.text.trim(),
        sport: _sport!,
        city: _cityCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        ownerId: userId,
        isPrivate: _isPrivate,
        createdAt: DateTime.now(),
      );

      // 3. Simpan lewat repository
      final newId = await ref.read(clubRepositoryProvider).createClub(
        club,
        ownerName: 'Pengguna', // ganti dengan nama user dari auth provider
      );

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Club "${club.name}" berhasil dibuat')),
      );

      // 4. Pindah ke halaman detail club yang baru dibuat
      router.pushReplacement('/clubs/$newId'); // sesuaikan route
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal membuat club, coba lagi')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Club')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Nama club',
                  prefixIcon: Icon(Icons.groups_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return 'Nama club wajib diisi';
                  if (text.length < 3) return 'Minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _sport, // kalau merah (Flutter lama), ganti 'value'
                decoration: const InputDecoration(
                  labelText: 'Olahraga',
                  prefixIcon: Icon(Icons.sports_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _sports
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sport = v),
                validator: (v) => v == null ? 'Pilih olahraga' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityCtrl,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Kota',
                  prefixIcon: Icon(Icons.place_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Kota wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Club private'),
                subtitle: const Text(
                  'Club private tidak muncul di halaman Discover',
                ),
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Buat Club'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}