import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Champ de recherche façon iOS : fond « fill », icône loupe, coins squircle.
class AppleSearchField extends StatelessWidget {
  const AppleSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.trailing,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  /// Actions optionnelles en fin de champ (ex. tri / filtres), séparées du
  /// texte par un fin filet.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;

    return Container(
      decoration: ShapeDecoration(
        color: colors.fill,
        shape: AppleRadii.shape(AppleRadii.md),
      ),
      padding: const EdgeInsetsDirectional.only(start: 10),
      child: Row(
        children: [
          Icon(Icons.search, size: 19, color: colors.secondaryLabel),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppleTypography.body.copyWith(color: colors.label),
              cursorColor: context.accentColor,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: hintText,
                hintStyle: AppleTypography.body
                    .copyWith(color: colors.secondaryLabel),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (trailing != null) ...[
            Container(
              width: 0.5,
              height: 24,
              margin: const EdgeInsetsDirectional.only(start: 4, end: 2),
              color: colors.separator,
            ),
            trailing!,
          ] else
            const SizedBox(width: 10),
        ],
      ),
    );
  }
}
