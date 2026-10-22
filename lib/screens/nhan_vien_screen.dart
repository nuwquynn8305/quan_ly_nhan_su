import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../models/app_data.dart';
import '../models/nhan_vien.dart';

enum SortOption {
  nameAsc('Tên (A → Z)'),
  nameDesc('Tên (Z → A)'),
  birthYearAsc('Năm sinh (Lớn tuổi → Trẻ)'),
  birthYearDesc('Năm sinh (Trẻ → Lớn tuổi)'),
  salaryDesc('Lương (Cao → Thấp)'),
  salaryAsc('Lương (Thấp → Cao)');

  final String label;
  const SortOption(this.label);
}

class NhanVienScreen extends StatefulWidget {
  const NhanVienScreen({super.key});

  @override
  State<NhanVienScreen> createState() => _NhanVienScreenState();
}

class _NhanVienScreenState extends State<NhanVienScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  // Bộ lọc
  String _filterGender = 'Tất cả';
  String _filterEducation = 'Tất cả';
  String _filterPosition = 'Tất cả';

  // Sắp xếp
  SortOption _currentSort = SortOption.nameAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

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

  // Hộp thoại xác nhận xóa nhân viên
  Future<bool?> _showDeleteConfirmation(BuildContext context, NhanVien nv) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa nhân viên "${nv.hoTen}" (Mã: ${nv.id}) khỏi danh sách không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _downloadCSV(String csvContent) {
    if (kIsWeb) {
      final blob = html.Blob([csvContent], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'danh_sach_nhan_vien_${DateTime.now().millisecondsSinceEpoch}.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For mobile/desktop, use clipboard as fallback
      Clipboard.setData(ClipboardData(text: csvContent));
    }
  }

  // Mở Form Thêm hoặc Sửa Nhân Viên
  void _openEmployeeForm(BuildContext context, {NhanVien? employee}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EmployeeFormDialog(employee: employee),
    );
  }

  // Xuất file CSV
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

  // Mở BottomSheet Bộ lọc và Sắp xếp
  void _openFilterSortSheet(BuildContext context, AppData appData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ lọc & Sắp xếp',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _filterGender = 'Tất cả';
                            _filterEducation = 'Tất cả';
                            _filterPosition = 'Tất cả';
                            _currentSort = SortOption.nameAsc;
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Đặt lại'),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Sắp xếp
                  const Text('Sắp xếp danh sách theo:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: SortOption.values.map((opt) {
                      final isSelected = _currentSort == opt;
                      return ChoiceChip(
                        label: Text(opt.label),
                        selected: isSelected,
                        onSelected: (val) {
                          setSheetState(() => _currentSort = opt);
                          setState(() => _currentSort = opt);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Lọc theo Giới tính
                  const Text('Lọc theo Giới tính:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Tất cả', 'Nam', 'Nữ', 'Khác'].map((g) {
                      final isSelected = _filterGender == g;
                      return ChoiceChip(
                        label: Text(g),
                        selected: isSelected,
                        onSelected: (val) {
                          setSheetState(() => _filterGender = g);
                          setState(() => _filterGender = g);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Lọc theo Trình độ
                  const Text('Lọc theo Trình độ:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      'Tất cả',
                      'Đại học',
                      'Cao đẳng',
                      'Thạc sĩ',
                      'Tiến sĩ',
                      'Trung cấp',
                    ].map((edu) {
                      final isSelected = _filterEducation == edu;
                      return ChoiceChip(
                        label: Text(edu),
                        selected: isSelected,
                        onSelected: (val) {
                          setSheetState(() => _filterEducation = edu);
                          setState(() => _filterEducation = edu);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Lọc theo Chức vụ
                  const Text('Lọc theo Chức vụ:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      'Tất cả',
                      'Chưa có chức vụ',
                      ...appData.danhSachChucVu.map((cv) => cv.tenChucVu),
                    ].map((pos) {
                      final isSelected = _filterPosition == pos;
                      return ChoiceChip(
                        label: Text(pos),
                        selected: isSelected,
                        onSelected: (val) {
                          setSheetState(() => _filterPosition = pos);
                          setState(() => _filterPosition = pos);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Áp dụng bộ lọc', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final allEmployees = appData.danhSachNhanVien;

    // 1. Lọc theo từ khóa tìm kiếm (tên / mã)
    var list = allEmployees.where((nv) {
      final query = _searchKeyword.trim().toLowerCase();
      if (query.isEmpty) return true;
      final matchName = nv.hoTen.toLowerCase().contains(query);
      final matchId = nv.id.toLowerCase().contains(query);
      return matchName || matchId;
    }).toList();

    // 2. Lọc theo Giới tính
    if (_filterGender != 'Tất cả') {
      list = list.where((nv) => nv.gioiTinh == _filterGender).toList();
    }

    // 3. Lọc theo Trình độ
    if (_filterEducation != 'Tất cả') {
      list = list.where((nv) => nv.trinhDo == _filterEducation).toList();
    }

    // 4. Lọc theo Chức vụ
    if (_filterPosition != 'Tất cả') {
      if (_filterPosition == 'Chưa có chức vụ') {
        list = list.where((nv) => nv.maChucVu == null).toList();
      } else {
        list = list.where((nv) {
          final cv = appData.getChucVuById(nv.maChucVu);
          return cv?.tenChucVu == _filterPosition;
        }).toList();
      }
    }

    // 5. Sắp xếp danh sách
    switch (_currentSort) {
      case SortOption.nameAsc:
        list.sort((a, b) => a.hoTen.compareTo(b.hoTen));
        break;
      case SortOption.nameDesc:
        list.sort((a, b) => b.hoTen.compareTo(a.hoTen));
        break;
      case SortOption.birthYearAsc:
        list.sort((a, b) => a.ngaySinh.compareTo(b.ngaySinh));
        break;
      case SortOption.birthYearDesc:
        list.sort((a, b) => b.ngaySinh.compareTo(a.ngaySinh));
        break;
      case SortOption.salaryDesc:
        list.sort((a, b) => appData.tinhLuongNhanVien(b).compareTo(appData.tinhLuongNhanVien(a)));
        break;
      case SortOption.salaryAsc:
        list.sort((a, b) => appData.tinhLuongNhanVien(a).compareTo(appData.tinhLuongNhanVien(b)));
        break;
    }

    final hasActiveFilter = _filterGender != 'Tất cả' ||
        _filterEducation != 'Tất cả' ||
        _filterPosition != 'Tất cả' ||
        _currentSort != SortOption.nameAsc;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhân viên'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Xuất CSV',
            onPressed: () => _showExportCsvDialog(context),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilter,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Bộ lọc & Sắp xếp',
            onPressed: () => _openFilterSortSheet(context, appData),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEmployeeForm(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm NV'),
      ),
      body: Column(
        children: [
          // Ô Tìm kiếm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên hoặc mã nhân viên...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchKeyword = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(90),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
            ),
          ),

          // Thanh hiển thị các filter đang áp dụng (nếu có)
          if (hasActiveFilter)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (_currentSort != SortOption.nameAsc)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        avatar: const Icon(Icons.sort, size: 14),
                        label: Text(_currentSort.label, style: const TextStyle(fontSize: 11)),
                        onDeleted: () => setState(() => _currentSort = SortOption.nameAsc),
                      ),
                    ),
                  if (_filterGender != 'Tất cả')
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        avatar: const Icon(Icons.wc, size: 14),
                        label: Text('Giới tính: $_filterGender', style: const TextStyle(fontSize: 11)),
                        onDeleted: () => setState(() => _filterGender = 'Tất cả'),
                      ),
                    ),
                  if (_filterEducation != 'Tất cả')
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        avatar: const Icon(Icons.school, size: 14),
                        label: Text('Trình độ: $_filterEducation', style: const TextStyle(fontSize: 11)),
                        onDeleted: () => setState(() => _filterEducation = 'Tất cả'),
                      ),
                    ),
                  if (_filterPosition != 'Tất cả')
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        avatar: const Icon(Icons.work, size: 14),
                        label: Text('CV: $_filterPosition', style: const TextStyle(fontSize: 11)),
                        onDeleted: () => setState(() => _filterPosition = 'Tất cả'),
                      ),
                    ),
                ],
              ),
            ),

          // Thanh thống kê số lượng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng số nhân viên: ${allEmployees.length}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Hiển thị: ${list.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Danh sách nhân viên ListView.builder
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _searchKeyword.isNotEmpty || hasActiveFilter
                              ? 'Không tìm thấy nhân viên phù hợp bộ lọc'
                              : 'Chưa có nhân viên nào trong danh sách',
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: list.length,
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 80),
                    itemBuilder: (context, index) {
                      final nv = list[index];
                      final chucVu = appData.getChucVuById(nv.maChucVu);
                      final salary = appData.tinhLuongNhanVien(nv);

                      return Dismissible(
                        key: ValueKey(nv.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Vuốt để xóa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.delete_forever, color: Colors.white),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showDeleteConfirmation(context, nv);
                        },
                        onDismissed: (direction) {
                          appData.xoaNhanVien(nv.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã xóa nhân viên ${nv.hoTen} (${nv.id})'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Card(
                          elevation: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: nv.gioiTinh == 'Nữ'
                                  ? Colors.pink.shade100
                                  : Colors.blue.shade100,
                              child: Text(
                                nv.hoTen.trim().isNotEmpty
                                    ? nv.hoTen.trim().split(' ').last[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: nv.gioiTinh == 'Nữ'
                                      ? Colors.pink.shade800
                                      : Colors.blue.shade800,
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    nv.hoTen,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withAlpha(180),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    nv.id,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.work_outline,
                                        size: 14,
                                        color: chucVu != null ? Colors.blue.shade700 : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Chức vụ: ${chucVu?.tenChucVu ?? "Chưa gán"}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: chucVu != null ? Colors.blue.shade700 : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.school_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('Trình độ: ${nv.trinhDo}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.cake_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${_formatDate(nv.ngaySinh)} (${nv.gioiTinh})'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(nv.soDienThoai),
                                    ],
                                  ),
                                  // Hiển thị lương tính toán
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.monetization_on_outlined, size: 14, color: Colors.green),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Lương: ${_formatCurrency(salary)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  tooltip: 'Chỉnh sửa',
                                  onPressed: () => _openEmployeeForm(context, employee: nv),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Xóa nhân viên',
                                  onPressed: () async {
                                    final confirm = await _showDeleteConfirmation(context, nv);
                                    if (confirm == true && context.mounted) {
                                      appData.xoaNhanVien(nv.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Đã xóa nhân viên ${nv.hoTen} (${nv.id})'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Dialog Form Thêm / Sửa Nhân Viên
class EmployeeFormDialog extends StatefulWidget {
  final NhanVien? employee;

  const EmployeeFormDialog({super.key, this.employee});

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;

  late String _selectedGender;
  late String _selectedEducation;
  String? _selectedPositionId;
  DateTime? _selectedBirthDate;

  final List<String> _genderOptions = const ['Nam', 'Nữ', 'Khác'];
  final List<String> _educationOptions = const [
    'Đại học',
    'Cao đẳng',
    'Thạc sĩ',
    'Tiến sĩ',
    'Trung cấp',
    'Phổ thông',
  ];

  bool get isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;
    _idController = TextEditingController(text: emp?.id ?? '');
    _nameController = TextEditingController(text: emp?.hoTen ?? '');
    _phoneController = TextEditingController(text: emp?.soDienThoai ?? '');
    _emailController = TextEditingController(text: emp?.email ?? '');

    _selectedGender = emp?.gioiTinh ?? 'Nam';
    _selectedEducation = emp?.trinhDo ?? 'Đại học';
    _selectedPositionId = emp?.maChucVu;

    _selectedBirthDate = emp?.ngaySinh ?? DateTime(2000, 1, 1);
    _birthDateController = TextEditingController(
      text: _formatDate(_selectedBirthDate!),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final currentYear = DateTime.now().year;
    final maxDate = DateTime(currentYear - 18, 12, 31);
    final minDate = DateTime(1950, 1, 1);

    DateTime initialDate = _selectedBirthDate ?? maxDate;
    if (initialDate.isAfter(maxDate)) initialDate = maxDate;
    if (initialDate.isBefore(minDate)) initialDate = minDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: 'CHỌN NGÀY SINH (TỪ 18 TUỔI TRỞ LÊN)',
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = _formatDate(picked);
      });
    }
  }

  void _saveEmployee() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appData = context.read<AppData>();
    final currentYear = DateTime.now().year;
    final maxValidYear = currentYear - 18;

    if (_selectedBirthDate == null ||
        _selectedBirthDate!.year < 1950 ||
        _selectedBirthDate!.year > maxValidYear) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Năm sinh không hợp lệ! Yêu cầu từ năm 1950 đến $maxValidYear (đủ 18 tuổi).',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final id = _idController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (isEditing) {
      final updatedEmp = widget.employee!.copyWith(
        hoTen: name,
        soDienThoai: phone,
        email: email,
        gioiTinh: _selectedGender,
        trinhDo: _selectedEducation,
        ngaySinh: _selectedBirthDate!,
        maChucVu: _selectedPositionId,
      );
      appData.capNhatNhanVien(updatedEmp);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật nhân viên $name')),
      );
    } else {
      final newEmp = NhanVien(
        id: id,
        hoTen: name,
        email: email,
        soDienThoai: phone,
        gioiTinh: _selectedGender,
        ngaySinh: _selectedBirthDate!,
        trinhDo: _selectedEducation,
        maChucVu: _selectedPositionId,
      );
      final success = appData.themNhanVien(newEmp);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Mã nhân viên đã tồn tại!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm nhân viên $name')),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.read<AppData>();
    final currentYear = DateTime.now().year;
    final maxValidYear = currentYear - 18;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit : Icons.person_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Sửa thông tin nhân viên' : 'Thêm nhân viên mới',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // 1. Mã nhân viên
                TextFormField(
                  controller: _idController,
                  enabled: !isEditing,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Mã nhân viên *',
                    hintText: 'VD: NV06',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: const OutlineInputBorder(),
                    helperText: isEditing ? 'Không thể thay đổi mã khi sửa' : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã nhân viên';
                    }
                    if (!isEditing && appData.kiemTraTrungMa(value.trim())) {
                      return 'Mã nhân viên đã tồn tại trong hệ thống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 2. Họ và tên
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên *',
                    hintText: 'VD: Nguyễn Văn A',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    if (value.trim().length < 2) {
                      return 'Họ tên quá ngắn';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 3. Dropdown Giới tính & Trình độ
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Giới tính *',
                          prefixIcon: Icon(Icons.wc),
                          border: OutlineInputBorder(),
                        ),
                        items: _genderOptions
                            .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedGender = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedEducation,
                        decoration: const InputDecoration(
                          labelText: 'Trình độ *',
                          prefixIcon: Icon(Icons.school_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: _educationOptions
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedEducation = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Ngày sinh
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: () => _selectBirthDate(context),
                  decoration: InputDecoration(
                    labelText: 'Ngày sinh * (Năm 1950 - $maxValidYear)',
                    hintText: 'dd/MM/yyyy',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () => _selectBirthDate(context),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng chọn ngày sinh';
                    }
                    if (_selectedBirthDate == null) {
                      return 'Ngày sinh không hợp lệ';
                    }
                    final birthYear = _selectedBirthDate!.year;
                    if (birthYear < 1950 || birthYear > maxValidYear) {
                      return 'Năm sinh phải từ 1950 đến $maxValidYear (đủ 18 tuổi)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 5. Số điện thoại & Email
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại *',
                    hintText: 'VD: 0901234567',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    final cleanPhone = value.trim();
                    if (!RegExp(r'^[0-9]{9,11}$').hasMatch(cleanPhone)) {
                      return 'Số điện thoại phải từ 9-11 chữ số';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    hintText: 'VD: user@domain.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    final cleanEmail = value.trim();
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(cleanEmail)) {
                      return 'Email không đúng định dạng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 6. Chức vụ
                DropdownButtonFormField<String?>(
                  initialValue: _selectedPositionId,
                  decoration: const InputDecoration(
                    labelText: 'Chức vụ',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: const Text('Chưa phân công'),
                    ),
                    ...appData.danhSachChucVu.map(
                      (cv) => DropdownMenuItem<String?>(
                        value: cv.id,
                        child: Text('${cv.tenChucVu} (${cv.id})'),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedPositionId = val;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _saveEmployee,
                      icon: const Icon(Icons.save),
                      label: Text(isEditing ? 'Cập nhật' : 'Thêm mới'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
