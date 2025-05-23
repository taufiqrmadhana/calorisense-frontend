// features/profile/widgets/profile_edit_field.dart
import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';

class ProfileEditField extends StatelessWidget {
  final String label;
  final String? value; // Digunakan jika field readOnly
  final TextEditingController? controller; // Digunakan jika field bisa diedit
  final bool readOnly;
  final TextInputType keyboardType;
  final String? hintText;
  final String? Function(String?)? validator;

  const ProfileEditField({
    super.key,
    required this.label,
    this.value,
    this.controller,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.validator,
  }) : assert(
         readOnly ? controller == null : value == null,
       ); // Pastikan konsisten

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppPalette.textColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller ?? TextEditingController(text: value),
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppPalette.textColor),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: AppPalette.borderColor),
              filled: true,
              fillColor: AppPalette.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
