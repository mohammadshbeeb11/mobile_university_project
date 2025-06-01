// screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../services/shared_prefs_helper.dart';
import '../widgets/profile/profile_header_widget.dart';
import '../widgets/profile/profile_edit_form_widget.dart';
import '../widgets/profile/profile_details_widget.dart';
import '../widgets/profile/no_profile_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final SharedPrefsHelper _prefsHelper = SharedPrefsHelper();
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // First try to get profile from shared preferences
      var profile = await _prefsHelper.getUserProfile();

      // If not found in shared preferences, try database
      if (profile == null) {
        profile = await _databaseHelper.getUserProfile();

        // If found in database, save to shared preferences for future use
        if (profile != null) {
          await _prefsHelper.saveUserProfile(profile);
        }
      }

      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorSnackBar('Error loading profile: $e');
      }
    }
  }

  Future<void> _saveProfile(UserProfile updatedProfile) async {
    try {
      // Save only to shared preferences, not to database
      await _prefsHelper.saveUserProfile(updatedProfile);

      setState(() {
        _userProfile = updatedProfile;
        _isEditing = false;
      });

      if (mounted) {
        _showSuccessSnackBar('Profile updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error saving profile: $e');
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _createProfile() {
    setState(() {
      _isEditing = true;
      _userProfile = const UserProfile(
        id: 1,
        name: '',
        email: '',
        phone: '',
        address: '',
        profileImage: '',
        password: '',
      );
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.teal),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.cyan[800]),
            const SizedBox(width: 4),
            Text(
              "Profile",
              style: TextStyle(
                color: Colors.cyan[800],
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ],
        ),
        actions: [
          if (!_isEditing && _userProfile != null)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.cyan[800]),
              onPressed: _startEditing,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              )
              : _userProfile == null
              ? NoProfileWidget(onCreateProfile: _createProfile)
              : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          ProfileHeaderWidget(userProfile: _userProfile),
          const SizedBox(height: 32),

          // Profile Form/Details
          if (_isEditing)
            ProfileEditFormWidget(
              userProfile: _userProfile,
              onCancel: _cancelEditing,
              onSave: _saveProfile,
            )
          else
            ProfileDetailsWidget(userProfile: _userProfile),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}