import 'package:flutter/material.dart';

class chatstyle extends StatelessWidget {
  final String Message;
  final String time;
  final String? image;
  final BorderRadiusGeometry? border;
  final Color color;
  const chatstyle(
      {super.key,
      this.border,
      required this.Message,
      required this.time,
      required this.color,
      this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: border,
        color: color,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            Message,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
