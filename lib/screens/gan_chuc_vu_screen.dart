import 'package:flutter/material.dart';

class GanChucVuScreen extends StatelessWidget {
  const GanChucVuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gán Chức vụ'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_ind_outlined, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Màn hình Gán Chức vụ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
