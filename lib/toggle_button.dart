import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final VoidCallback onToggled;

  const ToggleButton({super.key, required this.onToggled});

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _isToggled = false;

  void _toggleValue() {
    setState(() {
      _isToggled = !_isToggled;
    });
    widget.onToggled(); // Call the callback function when toggled
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleValue,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isToggled ? Colors.grey : Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
