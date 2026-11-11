
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const LyraApp());
}

class LyraApp extends StatelessWidget {
  const LyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LYRA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const Scaffold(
        body: Center(
          child: Text(
            'LYRA',
            style: TextStyle(
              fontFamily: 'BlackOpsOne',
              fontSize: 40,
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ),
    );
  }
}
