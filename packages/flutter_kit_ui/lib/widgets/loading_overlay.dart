import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Color(0x99000000),
      child: Center(
        child: SpinKitSpinningLines(
          color: Theme.of(context).colorScheme.error,
          size: 60,
        ),
      ),
    );
  }
}
