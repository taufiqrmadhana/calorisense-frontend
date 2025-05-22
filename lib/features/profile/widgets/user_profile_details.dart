import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserProfileDetails extends StatelessWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String country;
  final String goal;
  final double height;
  final double weight;
  final DateTime dateOfBirth;

  const UserProfileDetails({
    super.key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.country,
    required this.goal,
    required this.height,
    required this.weight,
    required this.dateOfBirth,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildRow(
              icon: LucideIcons.user,
              label: 'Name',
              value: '$firstName $lastName',
            ),
            _buildRow(icon: LucideIcons.mail, label: 'Email', value: email),
            _buildRow(icon: Icons.male, label: 'Gender', value: gender),
            _buildRow(
              icon: LucideIcons.globe,
              label: 'Country',
              value: country,
            ),
            _buildRow(icon: LucideIcons.flag, label: 'Goal', value: goal),
            _buildRow(
              icon: LucideIcons.ruler,
              label: 'Height',
              value: '${height.toStringAsFixed(1)} cm',
            ),
            _buildRow(
              icon: Icons.monitor_weight,
              label: 'Weight',
              value: '${weight.toStringAsFixed(1)} kg',
            ),
            _buildRow(
              icon: LucideIcons.calendar,
              label: 'Date of Birth',
              value: DateFormat('d/M/yyyy').format(dateOfBirth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppPalette.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppPalette.textColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppPalette.darkSubTextColor),
            ),
          ),
        ],
      ),
    );
  }
}