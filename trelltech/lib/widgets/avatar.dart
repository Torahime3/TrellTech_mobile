import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final List<Widget> avatars;

  const Avatar({super.key, required this.avatars});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: avatars
          .map((avatar) => Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: avatar,
              ))
          .toList(),
    );
  }
}
