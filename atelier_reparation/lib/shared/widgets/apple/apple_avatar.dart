import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Avatar circulaire à initiales, coloré de façon déterministe à partir du nom.
class AppleAvatar extends StatelessWidget {
  const AppleAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  static const _palette = [
    Color(0xFF007AFF),
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFFFF3B30),
    Color(0xFF5856D6),
    Color(0xFFAF52DE),
    Color(0xFF30B0C7),
  ];

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Color get _color => _palette[name.hashCode.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
      child: Text(
        _initials,
        style: AppleTypography.subheadline.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
