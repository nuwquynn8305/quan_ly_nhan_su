import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();

    // Lấy số liệu trực tiếp từ .length của các Map theo đúng yêu cầu
    final totalEmployees = appData.mapNhanVien.length;
    final totalPositions = appData.mapChucVu.length;
    final totalAssigned = appData.phanCong.length;
    final totalUnassigned = totalEmployees >= totalAssigned ? totalEmployees - totalAssigned : 0;
    final assignRate = totalEmployees > 0 ? (totalAssigned / totalEmployees) : 0.0;

    final statByPosition = appData.mapThongKeChucVu;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng Quan Nhân Sự (Dashboard)'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề chào mừng
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  radius: 24,
                  child: Icon(
                    Icons.dashboard_customize_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hệ Thống Quản Lý',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Thống kê số liệu nhân sự thời gian thực',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4 Thẻ thống kê lấy từ .length của các Map
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                // Thẻ 1: Tổng Nhân Viên
                _buildStatCard(
                  context,
                  title: 'Tổng Nhân Viên',
                  value: '$totalEmployees',
                  subtitle: 'nhân sự trong cty',
                  icon: Icons.people_alt,
                  color: Colors.blue,
                ),
                // Thẻ 2: Tổng Chức Vụ
                _buildStatCard(
                  context,
                  title: 'Tổng Chức Vụ',
                  value: '$totalPositions',
                  subtitle: 'vị trí công tác',
                  icon: Icons.badge,
                  color: Colors.purple,
                ),
                // Thẻ 3: Đã Phân Công
                _buildStatCard(
                  context,
                  title: 'Đã Phân Công',
                  value: '$totalAssigned',
                  subtitle: 'nhân viên có chức vụ',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                // Thẻ 4: Chưa Phân Công
                _buildStatCard(
                  context,
                  title: 'Chưa Phân Công',
                  value: '$totalUnassigned',
                  subtitle: 'cần gán chức vụ',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card Tiến độ phân công
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
                        const Text(
                          'Tỷ lệ nhân sự đã có chức vụ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${(assignRate * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: assignRate,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          assignRate >= 0.8
                              ? Colors.green
                              : (assignRate >= 0.5 ? Colors.blue : Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalAssigned trên tổng số $totalEmployees nhân viên đã được phân công nhiệm vụ.',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Phân bổ nhân sự theo từng chức vụ
            Row(
              children: [
                Icon(Icons.pie_chart_outline, size: 20, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Phân bổ nhân sự theo chức vụ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (appData.danhSachChucVu.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Chưa có chức vụ nào được tạo.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appData.danhSachChucVu.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cv = appData.danhSachChucVu[index];
                    final count = statByPosition[cv.id] ?? 0;
                    final ratio = totalEmployees > 0 ? (count / totalEmployees) : 0.0;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(
                          cv.id,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ),
                      title: Text(
                        cv.tenChucVu,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Hệ số lương: ${cv.heSoLuong} | Tỷ lệ: ${(ratio * 100).toStringAsFixed(0)}%'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: count > 0 ? Colors.blue.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: count > 0 ? Colors.blue.shade300 : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          '$count NV',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: count > 0 ? Colors.blue.shade800 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
