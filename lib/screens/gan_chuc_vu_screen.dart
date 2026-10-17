import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_data.dart';

class GanChucVuScreen extends StatefulWidget {
  const GanChucVuScreen({super.key});

  @override
  State<GanChucVuScreen> createState() => _GanChucVuScreenState();
}

class _GanChucVuScreenState extends State<GanChucVuScreen> {
  String? _selectedEmployeeId;
  String? _selectedPositionId;
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _assignPosition() {
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn nhân viên cần gán!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final appData = context.read<AppData>();
    final nv = appData.getNhanVienById(_selectedEmployeeId);
    final cv = appData.getChucVuById(_selectedPositionId);

    appData.ganChucVu(_selectedEmployeeId!, _selectedPositionId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedPositionId != null
              ? 'Đã gán chức vụ "${cv?.tenChucVu}" cho ${nv?.hoTen}'
              : 'Đã gỡ chức vụ của ${nv?.hoTen}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final employees = appData.danhSachNhanVien;
    final positions = appData.danhSachChucVu;
    final phanCong = appData.phanCong;

    // Đảm bảo id hợp lệ nếu nhân viên/chức vụ bị xóa từ màn hình khác
    if (_selectedEmployeeId != null &&
        !employees.any((e) => e.id == _selectedEmployeeId)) {
      _selectedEmployeeId = null;
    }
    if (_selectedPositionId != null &&
        !positions.any((p) => p.id == _selectedPositionId)) {
      _selectedPositionId = null;
    }

    // Danh sách nhân viên lọc theo tìm kiếm
    final filteredEmployees = employees.where((nv) {
      final query = _searchKeyword.trim().toLowerCase();
      if (query.isEmpty) return true;
      final matchName = nv.hoTen.toLowerCase().contains(query);
      final matchId = nv.id.toLowerCase().contains(query);
      final cvId = phanCong[nv.id];
      final cv = appData.getChucVuById(cvId);
      final matchPosition = cv?.tenChucVu.toLowerCase().contains(query) ?? false;
      return matchName || matchId || matchPosition;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gán Chức Vụ'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Khu vực điều khiển gán chức vụ (Card trên cùng)
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_ind_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Phân công chức vụ cho nhân viên',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Dropdown chọn nhân viên
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Chọn nhân viên *',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedEmployeeId,
                        hint: const Text('-- Chọn nhân viên --'),
                        isExpanded: true,
                        items: employees.map((nv) {
                          final currentCvId = phanCong[nv.id];
                          final currentCv = appData.getChucVuById(currentCvId);
                          final cvText = currentCv != null ? ' (${currentCv.tenChucVu})' : ' (Chưa có)';
                          return DropdownMenuItem<String>(
                            value: nv.id,
                            child: Text(
                              '${nv.id} - ${nv.hoTen}$cvText',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedEmployeeId = val;
                            if (val != null) {
                              _selectedPositionId = phanCong[val];
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dropdown chọn chức vụ
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Chọn chức vụ cần gán',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedPositionId,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              '-- Gỡ chức vụ (Chưa có) --',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          ...positions.map((cv) {
                            return DropdownMenuItem<String?>(
                              value: cv.id,
                              child: Text('${cv.id} - ${cv.tenChucVu} (HS: ${cv.heSoLuong})'),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedPositionId = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Nút Gán
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _assignPosition,
                    icon: const Icon(Icons.how_to_reg),
                    label: const Text(
                      'Gán',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Thanh tìm kiếm trong danh sách phân công
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Lọc theo tên, mã NV hoặc chức vụ...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchKeyword.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
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
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchKeyword = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Thống kê số lượng phân công
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh sách nhân viên & Chức vụ:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Đã gán: ${phanCong.length}/${employees.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Danh sách nhân viên kèm chức vụ hiện tại (hoặc "Chưa có")
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy nhân viên nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEmployees.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    itemBuilder: (context, index) {
                      final nv = filteredEmployees[index];
                      final cvId = phanCong[nv.id];
                      final currentCv = appData.getChucVuById(cvId);
                      final isSelected = _selectedEmployeeId == nv.id;

                      return Card(
                        elevation: isSelected ? 3 : 1,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer.withAlpha(80)
                            : null,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSelected
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1.5,
                                )
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: currentCv != null
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                            child: Icon(
                              currentCv != null
                                  ? Icons.person
                                  : Icons.person_outline,
                              color: currentCv != null
                                  ? Colors.blue.shade800
                                  : Colors.grey.shade600,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nv.hoTen,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Text(
                                nv.id,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Text('Chức vụ hiện tại: '),
                                if (currentCv != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Text(
                                      currentCv.tenChucVu,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Text(
                                      'Chưa có',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Nút chọn nhanh để gán
                              IconButton(
                                icon: const Icon(Icons.edit_note, color: Colors.blue),
                                tooltip: 'Chọn để gán chức vụ',
                                onPressed: () {
                                  setState(() {
                                    _selectedEmployeeId = nv.id;
                                    _selectedPositionId = phanCong[nv.id];
                                  });
                                },
                              ),
                              // Nút gỡ gán nhanh (nếu đã có chức vụ)
                              if (currentCv != null)
                                IconButton(
                                  icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
                                  tooltip: 'Gỡ chức vụ',
                                  onPressed: () {
                                    appData.ganChucVu(nv.id, null);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Đã gỡ chức vụ của ${nv.hoTen}'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                            ],
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
