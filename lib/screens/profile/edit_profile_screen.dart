import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  UserProfile? _profile;
  final List<String> _universities = ['AUCA', 'ULK', 'MOK', 'Other'];
  final List<String> _interestOptions = [
    'Academic Performance',
    'Schedule Optimization',
    'Professional Development',
    'Anxiety Management',
    'Mood Regulation',
    'Stress Reduction',
    'Sleep Hygiene',
    'Interpersonal Relationships'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final userProvider = context.read<UserProvider>();
    if (userProvider.profile != null) {
      setState(() {
        _profile = UserProfile(
          userId: userProvider.profile!.userId,
          displayName: userProvider.profile!.displayName,
          avatarUrl: userProvider.profile!.avatarUrl,
          university: userProvider.profile!.university,
          interests: List<String>.from(userProvider.profile!.interests),
        );
      });
    } else {
      setState(() {
        _profile = UserProfile(
          userId: 'default_user',
          displayName: 'Student',
          university: 'AUCA',
          interests: [],
        );
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null && _profile != null) {
        setState(() => _profile!.avatarUrl = image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image selection error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          title: const Text('Profile Configuration'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Profile Configuration'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header with avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF81C784),
                      backgroundImage: _profile!.avatarUrl != null
                          ? FileImage(File(_profile!.avatarUrl!))
                          : null,
                      child: _profile!.avatarUrl == null
                          ? const Icon(Icons.person_add_alt_1, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile Configuration',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your personal information',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Display Name
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          initialValue: _profile!.displayName,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          validator: (value) =>
                          value?.isEmpty ?? true ? 'Required field' : null,
                          onSaved: (value) => _profile!.displayName = value!,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // University Dropdown
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButtonFormField<String>(
                          value: _profile!.university,
                          items: _universities
                              .map((uni) => DropdownMenuItem(
                            value: uni,
                            child: Text(uni),
                          ))
                              .toList(),
                          onChanged: (value) => setState(() => _profile!.university = value!),
                          decoration: const InputDecoration(
                            labelText: 'Educational Institution',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Interests Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Areas of Focus',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: _interestOptions.map((interest) {
                            return FilterChip(
                              label: Text(interest),
                              labelStyle: TextStyle(
                                color: _profile!.interests.contains(interest)
                                    ? Colors.white
                                    : const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                              ),
                              selected: _profile!.interests.contains(interest),
                              selectedColor: const Color(0xFF388E3C),
                              backgroundColor: const Color(0xFFE8F5E9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _profile!.interests.add(interest);
                                  } else {
                                    _profile!.interests.remove(interest);
                                  }
                                });
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text('Update Profile',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate() && _profile != null) {
      try {
        _formKey.currentState!.save();
        context.read<UserProvider>().updateProfile(_profile!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    }
  }
}