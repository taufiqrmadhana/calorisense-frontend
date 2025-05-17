import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final bool isObscureText;

  const AuthField({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    this.isObscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          style: TextStyle(color: AppPalette.textColor),
          decoration: InputDecoration(hintText: hintText),
          validator: (value) {
            if (value!.isEmpty) {
              return "$hintText is missing";
            }
            return null;
          },
          obscureText: isObscureText,
        ),
      ],
    );
  }
}
