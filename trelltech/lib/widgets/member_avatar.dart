import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  final String initials;

  const MemberAvatar({super.key, required this.initials});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.blue,
      child: Text(
        initials,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
