import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Champ de saisie du design system : libellé optionnel, fond « fill », coins
/// squircle, multi-lignes possible.
class AppleTextField extends StatelessWidget {
  const AppleTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.suffix,
    this.obscureText = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final String? suffix;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: AppleTypography.footnote
                  .copyWith(color: colors.secondaryLabel)),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: ShapeDecoration(
            color: colors.fill,
            shape: AppleRadii.shape(AppleRadii.md),
          ),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  onSubmitted: onSubmitted,
                  minLines: obscureText ? 1 : minLines,
                  maxLines: obscureText ? 1 : maxLines,
                  style: AppleTypography.body.copyWith(color: colors.label),
                  cursorColor: context.accentColor,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    hintText: hint,
                    hintStyle: AppleTypography.body
                        .copyWith(color: colors.tertiaryLabel),
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              if (suffix != null)
                Text(suffix!,
                    style: AppleTypography.body
                        .copyWith(color: colors.secondaryLabel)),
            ],
          ),
        ),
      ],
    );
  }
}
