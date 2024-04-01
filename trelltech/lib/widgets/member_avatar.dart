import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  final String initials;
  final Color color;

  const MemberAvatar({super.key, required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
