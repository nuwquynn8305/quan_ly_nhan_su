import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chuc_vu.dart';
import 'nhan_vien.dart';

class AppData extends ChangeNotifier {
  // Dữ liệu mẫu ban đầu 3 chức vụ
  final List<ChucVu> _danhSachChucVu = [
    ChucVu(
      id: 'CV01',
      tenChucVu: 'Giám đốc',
      heSoLuong: 3.5,
      luongCoBan: 10000000,
      phuCap: 5000000,
      moTa: 'Quản lý toàn bộ hoạt động của công ty',
    ),
    ChucVu(
      id: 'CV02',
      tenChucVu: 'Trưởng phòng',
      heSoLuong: 2.5,
      luongCoBan: 8000000,
      phuCap: 3000000,
      moTa: 'Quản lý và điều phối công việc trong bộ phận',
    ),
    ChucVu(
      id: 'CV03',
      tenChucVu: 'Nhân viên',
      heSoLuong: 1.5,
      luongCoBan: 6000000,
      phuCap: 1500000,
      moTa: 'Thực hiện các công việc chuyên môn được giao',
    ),
  ];

  // Dữ liệu mẫu ban đầu 5 nhân viên
  final List<NhanVien> _danhSachNhanVien = [
    NhanVien(
      id: 'NV01',
      hoTen: 'Nguyễn Văn An',
      email: 'an.nguyen@company.com',
      soDienThoai: '0901234567',
      gioiTinh: 'Nam',
      ngaySinh: DateTime(1988, 5, 12),
      trinhDo: 'Thạc sĩ',
      maChucVu: 'CV01',
    ),
    NhanVien(
      id: 'NV02',
      hoTen: 'Trần Thị Bích',
      email: 'bich.tran@company.com',
      soDienThoai: '0912345678',
      gioiTinh: 'Nữ',
      ngaySinh: DateTime(1992, 8, 20),
      trinhDo: 'Đại học',
      maChucVu: 'CV02',
    ),
    NhanVien(
      id: 'NV03',
      hoTen: 'Lê Hoàng Cường',
      email: 'cuong.le@company.com',
      soDienThoai: '0923456789',
      gioiTinh: 'Nam',
      ngaySinh: DateTime(1995, 3, 15),
      trinhDo: 'Đại học',
      maChucVu: 'CV03',
    ),
    NhanVien(
      id: 'NV04',
      hoTen: 'Phạm Minh Dũng',
      email: 'dung.pham@company.com',
      soDienThoai: '0934567890',
      gioiTinh: 'Nam',
      ngaySinh: DateTime(1997, 11, 28),
      trinhDo: 'Cao đẳng',
      maChucVu: 'CV03',
    ),
    NhanVien(
      id: 'NV05',
      hoTen: 'Võ Thị Hồng',
      email: 'hong.vo@company.com',
      soDienThoai: '0945678901',
      gioiTinh: 'Nữ',
      ngaySinh: DateTime(1999, 7, 9),
      trinhDo: 'Đại học',
      maChucVu: 'CV03',
    ),
  ];

  // Map phân công chức vụ: key là mã nhân viên, value là mã chức vụ
  final Map<String, String> _phanCong = {
    'NV01': 'CV01',
    'NV02': 'CV02',
    'NV03': 'CV03',
    'NV04': 'CV03',
    'NV05': 'CV03',
  };

  // Cài đặt giao diện
  bool _isDarkMode = false;
  Color _primaryColor = Colors.indigo;
  double _fontSizeScale = 1.0;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AppData() {
    loadFromPrefs();
  }

  List<ChucVu> get danhSachChucVu => _danhSachChucVu;
  List<NhanVien> get danhSachNhanVien => _danhSachNhanVien;
  Map<String, String> get phanCong => Map.unmodifiable(_phanCong);

  Map<String, NhanVien> get mapNhanVien => {
        for (final nv in _danhSachNhanVien) nv.id: nv,
      };

  Map<String, ChucVu> get mapChucVu => {
        for (final cv in _danhSachChucVu) cv.id: cv,
      };

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  double get fontSizeScale => _fontSizeScale;

  // =================== LƯU TRỮ BỀN VỮNG SHARED PREFERENCES ===================
  static const _prefKeyEmployees = 'app_data_employees';
  static const _prefKeyPositions = 'app_data_positions';
  static const _prefKeyAssignments = 'app_data_assignments';
  static const _prefKeyDarkMode = 'app_data_dark_mode';
  static const _prefKeyColor = 'app_data_primary_color';
  static const _prefKeyFontSize = 'app_data_font_size';

  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final employeesJson = jsonEncode(_danhSachNhanVien.map((e) => e.toJson()).toList());
      final positionsJson = jsonEncode(_danhSachChucVu.map((e) => e.toJson()).toList());
      final assignmentsJson = jsonEncode(_phanCong);

      await prefs.setString(_prefKeyEmployees, employeesJson);
      await prefs.setString(_prefKeyPositions, positionsJson);
      await prefs.setString(_prefKeyAssignments, assignmentsJson);
      await prefs.setBool(_prefKeyDarkMode, _isDarkMode);
      await prefs.setInt(_prefKeyColor, _primaryColor.toARGB32());
      await prefs.setDouble(_prefKeyFontSize, _fontSizeScale);
    } catch (_) {
      // Bỏ qua lỗi trong môi trường không hỗ trợ disk
    }
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final empStr = prefs.getString(_prefKeyEmployees);
      if (empStr != null && empStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(empStr);
        _danhSachNhanVien.clear();
        _danhSachNhanVien.addAll(decoded.map((m) => NhanVien.fromJson(m as Map<String, dynamic>)));
      }

      final posStr = prefs.getString(_prefKeyPositions);
      if (posStr != null && posStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(posStr);
        _danhSachChucVu.clear();
        _danhSachChucVu.addAll(decoded.map((m) => ChucVu.fromJson(m as Map<String, dynamic>)));
      }

      final assignStr = prefs.getString(_prefKeyAssignments);
      if (assignStr != null && assignStr.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(assignStr);
        _phanCong.clear();
        _phanCong.addAll(decoded.map((k, v) => MapEntry(k, v.toString())));
      }

      if (prefs.containsKey(_prefKeyDarkMode)) {
        _isDarkMode = prefs.getBool(_prefKeyDarkMode) ?? false;
      }
      if (prefs.containsKey(_prefKeyColor)) {
        _primaryColor = Color(prefs.getInt(_prefKeyColor) ?? Colors.indigo.toARGB32());
      }
      if (prefs.containsKey(_prefKeyFontSize)) {
        _fontSizeScale = prefs.getDouble(_prefKeyFontSize) ?? 1.0;
      }
    } catch (_) {
      // Fallback dữ liệu mặc định
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // =================== QUẢN LÝ NHÂN VIÊN ===================
  bool themNhanVien(NhanVien nv) {
    if (kiemTraTrungMa(nv.id)) {
      return false;
    }
    _danhSachNhanVien.add(nv);
    if (nv.maChucVu != null && nv.maChucVu!.isNotEmpty) {
      _phanCong[nv.id] = nv.maChucVu!;
    }
    notifyListeners();
    saveToPrefs();
    return true;
  }

  bool capNhatNhanVien(NhanVien nv) {
    final index = _danhSachNhanVien.indexWhere((item) => item.id == nv.id);
    if (index != -1) {
      _danhSachNhanVien[index] = nv;
      if (nv.maChucVu != null && nv.maChucVu!.isNotEmpty) {
        _phanCong[nv.id] = nv.maChucVu!;
      } else {
        _phanCong.remove(nv.id);
      }
      notifyListeners();
      saveToPrefs();
      return true;
    }
    return false;
  }

  void xoaNhanVien(String id) {
    _danhSachNhanVien.removeWhere((item) => item.id == id);
    _phanCong.remove(id);
    notifyListeners();
    saveToPrefs();
  }

  bool kiemTraTrungMa(String id, {String? excludeId}) {
    final cleanId = id.trim().toUpperCase();
    return _danhSachNhanVien.any(
      (item) => item.id.toUpperCase() == cleanId && item.id != excludeId,
    );
  }

  // =================== GÁN CHỨC VỤ ===================
  void ganChucVu(String maNhanVien, String? maChucVu) {
    final index = _danhSachNhanVien.indexWhere((nv) => nv.id == maNhanVien);
    if (index != -1) {
      _danhSachNhanVien[index].maChucVu = maChucVu;
      if (maChucVu != null && maChucVu.isNotEmpty) {
        _phanCong[maNhanVien] = maChucVu;
      } else {
        _phanCong.remove(maNhanVien);
      }
      notifyListeners();
      saveToPrefs();
    }
  }

  // =================== QUẢN LÝ CHỨC VỤ ===================
  bool themChucVu(ChucVu cv) {
    if (kiemTraTrungMaChucVu(cv.id)) {
      return false;
    }
    _danhSachChucVu.add(cv);
    notifyListeners();
    saveToPrefs();
    return true;
  }

  bool capNhatChucVu(ChucVu cv) {
    final index = _danhSachChucVu.indexWhere((item) => item.id == cv.id);
    if (index != -1) {
      _danhSachChucVu[index] = cv;
      notifyListeners();
      saveToPrefs();
      return true;
    }
    return false;
  }

  void xoaChucVu(String id, {bool goGanNhanVien = true}) {
    if (goGanNhanVien) {
      for (final nv in _danhSachNhanVien) {
        if (nv.maChucVu == id) {
          nv.maChucVu = null;
        }
      }
      _phanCong.removeWhere((maNv, maCv) => maCv == id);
    }
    _danhSachChucVu.removeWhere((cv) => cv.id == id);
    notifyListeners();
    saveToPrefs();
  }

  bool kiemTraTrungMaChucVu(String id, {String? excludeId}) {
    final cleanId = id.trim().toUpperCase();
    return _danhSachChucVu.any(
      (item) => item.id.toUpperCase() == cleanId && item.id != excludeId,
    );
  }

  // =================== TIỆN ÍCH & TÍNH LƯƠNG ===================
  ChucVu? getChucVuById(String? id) {
    if (id == null) return null;
    try {
      return _danhSachChucVu.firstWhere((cv) => cv.id == id);
    } catch (_) {
      return null;
    }
  }

  NhanVien? getNhanVienById(String? id) {
    if (id == null) return null;
    try {
      return _danhSachNhanVien.firstWhere((nv) => nv.id == id);
    } catch (_) {
      return null;
    }
  }

  List<NhanVien> layDanhSachNhanVienTheoChucVu(String chucVuId) {
    return _danhSachNhanVien.where((nv) => nv.maChucVu == chucVuId).toList();
  }

  int laySoLuongNhanVienTheoChucVu(String chucVuId) {
    return _phanCong.values.where((cvId) => cvId == chucVuId).length;
  }

  // Tính lương cho 1 nhân viên
  double tinhLuongNhanVien(NhanVien nv) {
    final cvId = _phanCong[nv.id] ?? nv.maChucVu;
    final cv = getChucVuById(cvId);
    if (cv != null) {
      return cv.tongLuong;
    }
    // Chưa phân công chức vụ: mức trợ cấp cơ sở
    return 4500000.0;
  }

  // Tổng quỹ lương toàn bộ công ty
  double tinhTongQuyLuong() {
    double total = 0;
    for (final nv in _danhSachNhanVien) {
      total += tinhLuongNhanVien(nv);
    }
    return total;
  }

  // Thống kê phân bổ theo giới tính
  Map<String, int> get mapThongKeGioiTinh {
    final Map<String, int> stat = {'Nam': 0, 'Nữ': 0, 'Khác': 0};
    for (final nv in _danhSachNhanVien) {
      final g = nv.gioiTinh;
      stat[g] = (stat[g] ?? 0) + 1;
    }
    return stat;
  }

  // Thống kê theo chức vụ
  Map<String, int> get mapThongKeChucVu {
    final Map<String, int> stat = {
      for (final cv in _danhSachChucVu) cv.id: 0,
    };
    for (final cvId in _phanCong.values) {
      if (stat.containsKey(cvId)) {
        stat[cvId] = (stat[cvId] ?? 0) + 1;
      }
    }
    return stat;
  }

  // Thống kê theo trình độ
  Map<String, int> get mapThongKeTrinhDo {
    final Map<String, int> stat = {};
    for (final nv in _danhSachNhanVien) {
      stat[nv.trinhDo] = (stat[nv.trinhDo] ?? 0) + 1;
    }
    return stat;
  }

  // =================== XUẤT CSV ===================
  String xuatDanhSachCSV() {
    final StringBuffer buffer = StringBuffer();
    // Thêm BOM UTF-8 (\uFEFF) để Excel hiển thị tiếng Việt chính xác
    buffer.write('\uFEFF');
    // Header
    buffer.writeln(
      'Mã NV,Họ và Tên,Giới Tính,Ngày Sinh,Trình Độ,Số Điện Thoại,Email,Chức Vụ,Hệ Số Lương,Lương Cơ Bản,Phụ Cấp,Tổng Lương',
    );

    for (final nv in _danhSachNhanVien) {
      final cvId = _phanCong[nv.id] ?? nv.maChucVu;
      final cv = getChucVuById(cvId);
      final tenCv = cv?.tenChucVu ?? 'Chưa phân công';
      final heSo = cv?.heSoLuong ?? 1.0;
      final luongCb = cv?.luongCoBan ?? 4500000;
      final phuCap = cv?.phuCap ?? 0;
      final tongLuong = tinhLuongNhanVien(nv);

      final d = nv.ngaySinh.day.toString().padLeft(2, '0');
      final m = nv.ngaySinh.month.toString().padLeft(2, '0');
      final y = nv.ngaySinh.year.toString();
      final ns = '$d/$m/$y';

      buffer.writeln(
        '"${nv.id}","${nv.hoTen}","${nv.gioiTinh}","$ns","${nv.trinhDo}","${nv.soDienThoai}","${nv.email}","$tenCv",$heSo,$luongCb,$phuCap,$tongLuong',
      );
    }

    return buffer.toString();
  }

  // =================== CÀI ĐẶT GIAO DIỆN ===================
  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    saveToPrefs();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
    saveToPrefs();
  }

  void setFontSizeScale(double scale) {
    _fontSizeScale = scale;
    notifyListeners();
    saveToPrefs();
  }

  void resetSettings() {
    _isDarkMode = false;
    _primaryColor = Colors.indigo;
    _fontSizeScale = 1.0;
    notifyListeners();
    saveToPrefs();
  }
}
