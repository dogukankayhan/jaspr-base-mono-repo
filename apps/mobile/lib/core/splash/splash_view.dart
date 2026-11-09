import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitSpinningLines(
        color: Theme.of(context).colorScheme.primary,
        size: 60,
      ),
    );
  }
}
