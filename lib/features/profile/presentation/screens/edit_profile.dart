import 'package:chat_app/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final String uid;

  const EditProfilePage({super.key, required this.uid});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _aboutController;

  bool _initialized = false;
  bool _isSaving = false;
  bool _checkingUsername = false;

  String _originalUsername = '';

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _aboutController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _initializeFields(user) {
    if (_initialized) return;

    _nameController.text = user.name;
    _usernameController.text = user.username;
    _aboutController.text = user.about;

    _originalUsername = user.username;

    _initialized = true;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    final about = _aboutController.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      if (username != _originalUsername.toLowerCase()) {
        setState(() {
          _checkingUsername = true;
        });

        final available = await ref
            .read(profileControllerProvider.notifier)
            .isUsernameAvailable(username);

        if (!available) {
          if (mounted) {
            setState(() {
              _isSaving = false;
              _checkingUsername = false;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username is already taken')),
          );

          return;
        }

        setState(() {
          _checkingUsername = false;
        });
      }

      await ref
          .read(profileControllerProvider.notifier)
          .updateProfile(widget.uid, username, name, about);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _checkingUsername = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(getProfileData(widget.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Unable to load profile: $error')),
        data: (user) {
          _initializeFields(user);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'Enter your display name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Display name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }

                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _aboutController,
                  maxLines: 4,
                  maxLength: 150,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'About',
                    hintText: 'Tell people something about you',
                    prefixIcon: Icon(Icons.info_outline),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _isSaving || _checkingUsername
                        ? null
                        : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            _checkingUsername
                                ? 'Checking username...'
                                : 'Save Changes',
                          ),
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
