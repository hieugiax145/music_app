import 'package:flutter/material.dart';

class TickerTextWidget extends StatefulWidget {
  final String text;
  final double size;
  final int speed;
  const TickerTextWidget(
      {super.key, required this.text, required this.size, required this.speed});
  @override
  _TickerTextWidgetState createState() => _TickerTextWidgetState();
}

class _TickerTextWidgetState extends State<TickerTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.speed), // Adjust duration as needed
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(-1.0, 0.0),
        ).animate(_controller),
        child: Text(
          widget.text, // Your ticker text
          style: TextStyle(fontSize: widget.size),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
