import 'package:flutter/material.dart';

class JailbreakBlockApp extends StatelessWidget {
  const JailbreakBlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: PopScope(
          canPop: false,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security_outlined,
                    size: 80,
                    color: Color(0xFFe74c3c),
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Cihaz Güvenliği Uyarısı',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bu uygulama güvenlik nedeniyle jailbreak veya root\'lanmış cihazlarda çalıştırılamaz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFbdbdbd),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
