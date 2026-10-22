import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../models/app_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatCurrency(double amount) {
    final intAmount = amount.round();
    final str = intAmount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${buffer.toString()} đ';
  }

  void _downloadCSV(String csvContent) {
    if (kIsWeb) {
      final blob = html.Blob([csvContent], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'bao_cao_nhan_su_${DateTime.now().millisecondsSinceEpoch}.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile/desktop, use clipboard as fallback
      Clipboard.setData(ClipboardData(text: csvContent));
    }
  }

  void _showExportCsvDialog(BuildContext context) {
    final appData = context.read<AppData>();
    final csvContent = appData.xuatDanhSachCSV();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.table_chart_outlined, color: Colors.teal),
            SizedBox(width: 8),
            Text('Xuất Danh Sách CSV'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dữ liệu bảng tính chuẩn UTF-8 (hỗ trợ hiển thị tiếng Việt trên Excel):',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csvContent,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.copy),
            label: const Text('Sao chép CSV'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: csvContent));
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép nội dung CSV vào bộ nhớ tạm (Clipboard)!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.download),
            label: const Text('Tải xuống'),
            onPressed: () {
              _downloadCSV(csvContent);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đang tải xuống file CSV...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();

    final totalEmployees = appData.mapNhanVien.length;
    final totalPositions = appData.mapChucVu.length;
    final totalAssigned = appData.phanCong.length;
    final totalUnassigned = totalEmployees >= totalAssigned ? totalEmployees - totalAssigned : 0;
    final assignRate = totalEmployees > 0 ? (totalAssigned / totalEmployees) : 0.0;
    final totalPayroll = appData.tinhTongQuyLuong();

    final statByPosition = appData.mapThongKeChucVu;
    final statByGender = appData.mapThongKeGioiTinh;

    final maleCount = statByGender['Nam'] ?? 0;
    final femaleCount = statByGender['Nữ'] ?? 0;
    final otherCount = statByGender['Khác'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng Quan Nhân Sự (Dashboard)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Xuất báo cáo CSV',
            onPressed: () => _showExportCsvDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề & Quỹ lương
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withAlpha(90),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 26,
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng Quỹ Lương Dự Tính (Tháng)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(totalPayroll),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4 Thẻ thống kê lấy từ .length của các Map
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _buildStatCard(
                  context,
                  title: 'Tổng Nhân Viên',
                  value: '$totalEmployees',
                  subtitle: 'nhân sự trong cty',
                  icon: Icons.people_alt,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  title: 'Tổng Chức Vụ',
                  value: '$totalPositions',
                  subtitle: 'vị trí công tác',
                  icon: Icons.badge,
                  color: Colors.purple,
                ),
                _buildStatCard(
                  context,
                  title: 'Đã Phân Công',
                  value: '$totalAssigned',
                  subtitle: 'nhân viên có chức vụ',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
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

            // Tiến độ phân công
            Card(
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

            // BIỂU ĐỒ 1: Biểu đồ phân bổ Giới Tính
            Row(
              children: [
                Icon(Icons.pie_chart, size: 20, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Biểu đồ phân bổ theo Giới tính',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thanh tỷ lệ ngang (Stacked bar)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 20,
                        child: totalEmployees == 0
                            ? Container(color: Colors.grey.shade300)
                            : Row(
                                children: [
                                  if (maleCount > 0)
                                    Expanded(
                                      flex: maleCount,
                                      child: Container(color: Colors.blue.shade600),
                                    ),
                                  if (femaleCount > 0)
                                    Expanded(
                                      flex: femaleCount,
                                      child: Container(color: Colors.pink.shade400),
                                    ),
                                  if (otherCount > 0)
                                    Expanded(
                                      flex: otherCount,
                                      child: Container(color: Colors.teal.shade400),
                                    ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Chú giải số liệu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildGenderLegend(
                          label: 'Nam',
                          count: maleCount,
                          total: totalEmployees,
                          color: Colors.blue.shade600,
                        ),
                        _buildGenderLegend(
                          label: 'Nữ',
                          count: femaleCount,
                          total: totalEmployees,
                          color: Colors.pink.shade400,
                        ),
                        _buildGenderLegend(
                          label: 'Khác',
                          count: otherCount,
                          total: totalEmployees,
                          color: Colors.teal.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BIỂU ĐỒ 2: Biểu đồ cột Nhân Viên theo Chức Vụ
            Row(
              children: [
                Icon(Icons.bar_chart, size: 20, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Biểu đồ số NV theo Chức vụ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: appData.danhSachChucVu.map((cv) {
                    final count = statByPosition[cv.id] ?? 0;
                    final maxEmp = totalEmployees > 0 ? totalEmployees : 1;
                    final ratio = count / maxEmp;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cv.tenChucVu,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '$count NV (${(ratio * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderLegend({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          '$label: $count ($pct%)',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
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
