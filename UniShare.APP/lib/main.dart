import 'package:flutter/material.dart';
import 'config/app_config.dart';

void main() {
  final config = AppConfig.fromDartDefine();
  runApp(UniShareApp(config: config));
}

class UniShareApp extends StatelessWidget {
  final AppConfig config;

  const UniShareApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A), // primary.green
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), // neutral.50
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('UniShare'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'UniShare',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Chia sẻ đồ dùng sinh viên',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Text(
                'Env: ${config.environment}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                config.apiBaseUrl,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
