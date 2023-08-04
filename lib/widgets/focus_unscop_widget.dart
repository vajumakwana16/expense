import 'package:flutter/material.dart';

class UnFocusPage extends StatelessWidget {
  final Widget child;
  const UnFocusPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
