import 'package:flutter/material.dart';

// HoverableText Widget
class HoverableText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const HoverableText({super.key, required this.text, required this.onTap});

  @override
  _HoverableTextState createState() => _HoverableTextState();
}

class _HoverableTextState extends State<HoverableText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Change cursor to clickable
      onEnter: (_) => setState(() => _isHovered = true), // Hover starts
      onExit: (_) => setState(() => _isHovered = false), // Hover ends
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.lightBlue[50]
                : Colors.transparent, // Light blue background on hover
            border: Border.all(
              color: _isHovered
                  ? Colors.blue
                  : Colors.transparent, // Blue border on hover
              width: 1, // Border width
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Blue text color
            ),
          ),
        ),
      ),
    );
  }
}
