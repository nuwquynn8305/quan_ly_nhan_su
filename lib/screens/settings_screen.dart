import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, dynamic>> _themeColors = [
    {'name': 'Indigo', 'color': Colors.indigo},
    {'name': 'Xanh dương', 'color': Colors.blue},
    {'name': 'Xanh mòng két', 'color': Colors.teal},
    {'name': 'Xanh lá', 'color': Colors.green},
    {'name': 'Cam', 'color': Colors.orange},
    {'name': 'Tím', 'color': Colors.deepPurple},
    {'name': 'Hồng', 'color': Colors.pink},
    {'name': 'Đỏ', 'color': Colors.red},
    {'name': 'Hổ phách', 'color': Colors.amber},
  ];

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final isDark = appData.isDarkMode;
    final currentColor = appData.primaryColor;
    final currentScale = appData.fontSizeScale;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt Giao diện'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Chế độ Tối (Dark Mode Switch)
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SwitchListTile(
                secondary: CircleAvatar(
                  backgroundColor: isDark ? Colors.amber.shade100 : Colors.indigo.shade100,
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.amber.shade900 : Colors.indigo.shade800,
                  ),
                ),
                title: const Text(
                  'Chế độ nền tối (Dark Mode)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isDark ? 'Đang kích hoạt giao diện tối' : 'Đang sử dụng giao diện sáng',
                  style: const TextStyle(fontSize: 13),
                ),
                value: isDark,
                onChanged: (bool value) {
                  appData.setDarkMode(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Chọn Màu Chủ Đạo (Hàng CircleAvatar)
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: currentColor.withAlpha(40),
                        child: Icon(Icons.palette_outlined, color: currentColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Màu sắc chủ đạo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Chọn tông màu yêu thích cho ứng dụng',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hàng CircleAvatar chọn màu sắc
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _themeColors.map((item) {
                        final Color color = item['color'];
                        final String name = item['name'];
                        final bool isSelected = currentColor == color;

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () => appData.setPrimaryColor(color),
                            borderRadius: BorderRadius.circular(28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: isSelected ? 24 : 20,
                                      backgroundColor: color,
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Slider Cỡ Chữ (Font Size Scale)
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blue.withAlpha(30),
                            child: const Icon(Icons.format_size, color: Colors.blue, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kích thước chữ',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Điều chỉnh tỷ lệ hiển thị phông chữ',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(currentScale * 100).round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Slider điều chỉnh cỡ chữ
                  Row(
                    children: [
                      const Text(
                        'A',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Slider(
                          value: currentScale,
                          min: 0.8,
                          max: 1.3,
                          divisions: 10,
                          label: '${(currentScale * 100).round()}%',
                          onChanged: (value) {
                            appData.setFontSizeScale(value);
                          },
                        ),
                      ),
                      const Text(
                        'A',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // Khung Xem trước văn bản mẫu
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant.withAlpha(100),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Xem trước hiển thị:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hệ Thống Quản Lý Nhân Sự & Chức Vụ Công Ty',
                          style: TextStyle(
                            fontSize: 16 * currentScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đây là văn bản xem trước khi áp dụng kích thước chữ ${(currentScale * 100).round()}%. Toàn bộ ứng dụng sẽ tự động điều chỉnh theo tỷ lệ này.',
                          style: TextStyle(
                            fontSize: 14 * currentScale,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nút Đặt lại về mặc định
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                appData.resetSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã khôi phục cài đặt giao diện về mặc định'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Khôi phục cài đặt mặc định'),
            ),
          ),
        ],
      ),
    );
  }
}
