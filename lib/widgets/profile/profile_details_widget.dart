// widgets/profile/profile_details_widget.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class ProfileDetailsWidget extends StatelessWidget {
  final UserProfile? userProfile;

  const ProfileDetailsWidget({super.key, required this.userProfile});

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  style: TextStyle(
                    fontSize: 16,
                    color: value.isNotEmpty ? Colors.black87 : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            _buildDetailRow(
              Icons.person_outline,
              'Name',
              userProfile?.name ?? '',
            ),
            _buildDetailRow(
              Icons.email_outlined,
              'Email',
              userProfile?.email ?? '',
            ),
            _buildDetailRow(
              Icons.phone_outlined,
              'Phone',
              userProfile?.phone ?? '',
            ),
            _buildDetailRow(
              Icons.location_on_outlined,
              'Address',
              userProfile?.address ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
