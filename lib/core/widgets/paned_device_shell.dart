import 'package:flutter/material.dart';

/// Transparent pass-through — device frame removed.
class PanedDeviceShell extends StatelessWidget {
  const PanedDeviceShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
