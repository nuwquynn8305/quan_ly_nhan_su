import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_data.dart';
import '../models/chuc_vu.dart';

class ChucVuScreen extends StatefulWidget {
  const ChucVuScreen({super.key});

  @override
  State<ChucVuScreen> createState() => _ChucVuScreenState();
}

class _ChucVuScreenState extends State<ChucVuScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  // Hộp thoại xác nhận xóa chức vụ
  Future<bool?> _showDeleteConfirmation(BuildContext context, ChucVu cv) {
    final appData = context.read<AppData>();
    final assignedEmployees = appData.layDanhSachNhanVienTheoChucVu(cv.id);
    final count = assignedEmployees.length;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              count > 0 ? Icons.warning_rounded : Icons.delete_outline,
              color: count > 0 ? Colors.amber.shade800 : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(count > 0 ? 'Cảnh báo gỡ chức vụ' : 'Xác nhận xóa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa chức vụ "${cv.tenChucVu}" (Mã: ${cv.id})?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (count > 0) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hiện có $count nhân viên đang giữ chức vụ này:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignedEmployees.take(4).map((e) => '• ${e.hoTen} (${e.id})').join('\n') +
                          (count > 4 ? '\n... và ${count - 4} nhân viên khác' : ''),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hành động này sẽ tự động gỡ chức vụ của các nhân viên trên về "Chưa phân công".',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text('Chức vụ này chưa có nhân viên nào được gán.'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: count > 0 ? Colors.amber.shade800 : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(count > 0 ? 'Gỡ gán & Xóa' : 'Xóa'),
          ),
        ],
      ),
    );
  }

  // Mở Form Thêm hoặc Sửa Chức Vụ
  void _openPositionForm(BuildContext context, {ChucVu? position}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PositionFormDialog(position: position),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final allPositions = appData.danhSachChucVu;

    final filteredPositions = allPositions.where((cv) {
      final query = _searchKeyword.trim().toLowerCase();
      if (query.isEmpty) return true;
      final matchName = cv.tenChucVu.toLowerCase().contains(query);
      final matchId = cv.id.toLowerCase().contains(query);
      return matchName || matchId;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Chức vụ'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPositionForm(context),
        icon: const Icon(Icons.add_moderator),
        label: const Text('Thêm CV'),
      ),
      body: Column(
        children: [
          // Ô Tìm kiếm
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc mã chức vụ...',
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

          // Thanh hiển thị số lượng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng số chức vụ: ${allPositions.length}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (_searchKeyword.isNotEmpty)
                  Text(
                    'Kết quả: ${filteredPositions.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Danh sách chức vụ ListView.builder
          Expanded(
            child: filteredPositions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchKeyword.isEmpty
                              ? Icons.badge_outlined
                              : Icons.search_off_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchKeyword.isEmpty
                              ? 'Chưa có chức vụ nào trong danh sách'
                              : 'Không tìm thấy chức vụ phù hợp với "$_searchKeyword"',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredPositions.length,
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 80),
                    itemBuilder: (context, index) {
                      final cv = filteredPositions[index];
                      final employeeCount = appData.laySoLuongNhanVienTheoChucVu(cv.id);

                      return Dismissible(
                        key: ValueKey(cv.id),
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
                          return await _showDeleteConfirmation(context, cv);
                        },
                        onDismissed: (direction) {
                          appData.xoaChucVu(cv.id, goGanNhanVien: true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã xóa chức vụ ${cv.tenChucVu} (${cv.id})'),
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
                              backgroundColor: Colors.teal.shade50,
                              child: Icon(
                                Icons.workspace_premium_outlined,
                                color: Colors.teal.shade700,
                                size: 28,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    cv.tenChucVu,
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
                                    cv.id,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.trending_up, size: 15, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Hệ số: ${cv.heSoLuong.toStringAsFixed(1)}',
                                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.people_outline,
                                            size: 15,
                                            color: employeeCount > 0 ? Colors.blue.shade700 : Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            employeeCount > 0 ? '$employeeCount nhân viên' : 'Chưa có NV',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: employeeCount > 0 ? Colors.blue.shade700 : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.payments_outlined, size: 15, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tổng lương: ${_formatCurrency(cv.tongLuong)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Lương CB: ${_formatCurrency(cv.luongCoBan)} | Phụ cấp: ${_formatCurrency(cv.phuCap)}',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  if (cv.moTa.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      cv.moTa,
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  tooltip: 'Chỉnh sửa',
                                  onPressed: () => _openPositionForm(context, position: cv),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  tooltip: 'Xóa chức vụ',
                                  onPressed: () async {
                                    final confirm = await _showDeleteConfirmation(context, cv);
                                    if (confirm == true && context.mounted) {
                                      appData.xoaChucVu(cv.id, goGanNhanVien: true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Đã xóa chức vụ ${cv.tenChucVu} (${cv.id})'),
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

// Dialog Form Thêm / Sửa Chức Vụ
class PositionFormDialog extends StatefulWidget {
  final ChucVu? position;

  const PositionFormDialog({super.key, this.position});

  @override
  State<PositionFormDialog> createState() => _PositionFormDialogState();
}

class _PositionFormDialogState extends State<PositionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _salaryFactorController;
  late TextEditingController _baseSalaryController;
  late TextEditingController _allowanceController;
  late TextEditingController _descriptionController;

  bool get isEditing => widget.position != null;

  @override
  void initState() {
    super.initState();
    final pos = widget.position;
    _idController = TextEditingController(text: pos?.id ?? '');
    _nameController = TextEditingController(text: pos?.tenChucVu ?? '');
    _salaryFactorController = TextEditingController(
      text: pos != null ? pos.heSoLuong.toString() : '1.0',
    );
    _baseSalaryController = TextEditingController(
      text: pos != null ? pos.luongCoBan.round().toString() : '5000000',
    );
    _allowanceController = TextEditingController(
      text: pos != null ? pos.phuCap.round().toString() : '1000000',
    );
    _descriptionController = TextEditingController(text: pos?.moTa ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _salaryFactorController.dispose();
    _baseSalaryController.dispose();
    _allowanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _savePosition() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appData = context.read<AppData>();
    final id = _idController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final factor = double.tryParse(_salaryFactorController.text.trim()) ?? 1.0;
    final baseSalary = double.tryParse(_baseSalaryController.text.trim()) ?? 5000000.0;
    final allowance = double.tryParse(_allowanceController.text.trim()) ?? 1000000.0;
    final description = _descriptionController.text.trim();

    if (isEditing) {
      final updatedPos = widget.position!.copyWith(
        tenChucVu: name,
        heSoLuong: factor,
        luongCoBan: baseSalary,
        phuCap: allowance,
        moTa: description,
      );
      appData.capNhatChucVu(updatedPos);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật chức vụ $name')),
      );
    } else {
      final newPos = ChucVu(
        id: id,
        tenChucVu: name,
        heSoLuong: factor,
        luongCoBan: baseSalary,
        phuCap: allowance,
        moTa: description,
      );
      final success = appData.themChucVu(newPos);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Mã chức vụ đã tồn tại!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm chức vụ $name')),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.read<AppData>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                      isEditing ? Icons.edit : Icons.add_moderator,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEditing ? 'Sửa thông tin chức vụ' : 'Thêm chức vụ mới',
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

                // 1. Mã chức vụ
                TextFormField(
                  controller: _idController,
                  enabled: !isEditing,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Mã chức vụ *',
                    hintText: 'VD: CV04',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: const OutlineInputBorder(),
                    helperText: isEditing ? 'Không thể thay đổi mã khi sửa' : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã chức vụ';
                    }
                    if (!isEditing && appData.kiemTraTrungMaChucVu(value.trim())) {
                      return 'Mã chức vụ đã tồn tại trong hệ thống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 2. Tên chức vụ
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tên chức vụ *',
                    hintText: 'VD: Kế toán trưởng',
                    prefixIcon: Icon(Icons.work_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên chức vụ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 3. Hệ số lương
                TextFormField(
                  controller: _salaryFactorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Hệ số lương *',
                    hintText: 'VD: 2.5',
                    prefixIcon: Icon(Icons.trending_up),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập hệ số lương';
                    }
                    final factor = double.tryParse(value.trim());
                    if (factor == null || factor <= 0) {
                      return 'Hệ số lương phải là số lớn hơn 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 4. Lương cơ bản & Phụ cấp (Row 2 cột)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _baseSalaryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Lương cơ bản (đ) *',
                          hintText: 'VD: 5000000',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nhập lương cơ bản';
                          }
                          final s = double.tryParse(value.trim());
                          if (s == null || s < 0) {
                            return 'Lương không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _allowanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Phụ cấp (đ) *',
                          hintText: 'VD: 1000000',
                          prefixIcon: Icon(Icons.card_giftcard),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nhập phụ cấp';
                          }
                          final a = double.tryParse(value.trim());
                          if (a == null || a < 0) {
                            return 'Phụ cấp không hợp lệ';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. Mô tả
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả công việc',
                    hintText: 'Nhập tóm tắt vai trò, trách nhiệm của chức vụ...',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
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
                      onPressed: _savePosition,
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
