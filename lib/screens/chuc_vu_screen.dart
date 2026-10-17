import 'package:flutter/material.dart';

class ChucVuScreen extends StatelessWidget {
  const ChucVuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Chức vụ'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_outlined, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Màn hình Quản lý Chức vụ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
