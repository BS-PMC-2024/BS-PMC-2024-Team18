import 'package:flutter/material.dart';

class CountdownTimer extends StatelessWidget {
  final String time;
  final Color? color;

  const CountdownTimer({super.key, this.color, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.timer,
          color: color??Colors.white,
        ),
        const SizedBox(width: 5),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}