

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final AppUser user;
  final double radius;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 24,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = user.profileImage != null && user.profileImage!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.2),

      // Profile Picture
      backgroundImage: hasImage ? FileImage(File(user.profileImage!)) : null,

      // Initial letter fallback
      child: hasImage
          ? null
          : Text(
              user.name.isNotEmpty
                  ? user.name[0].toUpperCase()
                  : "?",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
