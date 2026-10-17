import 'package:flutter/material.dart';
import 'nhan_vien.dart';
import 'chuc_vu.dart';

class AppData extends ChangeNotifier {
  // Dữ liệu mẫu 3 chức vụ
  final List<ChucVu> _danhSachChucVu = [
    ChucVu(
      id: 'CV01',
      tenChucVu: 'Giám đốc',
      heSoLuong: 3.5,
      moTa: 'Quản lý toàn bộ hoạt động của công ty',
    ),
    ChucVu(
      id: 'CV02',
      tenChucVu: 'Trưởng phòng',
      heSoLuong: 2.5,
      moTa: 'Quản lý và điều phối công việc trong bộ phận',
    ),
    ChucVu(
      id: 'CV03',
      tenChucVu: 'Nhân viên',
      heSoLuong: 1.5,
      moTa: 'Thực hiện các công việc chuyên môn được giao',
    ),
  ];

  // Dữ liệu mẫu 5 nhân viên
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

  List<ChucVu> get danhSachChucVu => _danhSachChucVu;
  List<NhanVien> get danhSachNhanVien => _danhSachNhanVien;

  ChucVu? getChucVuById(String? id) {
    if (id == null) return null;
    try {
      return _danhSachChucVu.firstWhere((cv) => cv.id == id);
    } catch (_) {
      return null;
    }
  }

  // =================== QUẢN LÝ NHÂN VIÊN ===================
  bool themNhanVien(NhanVien nv) {
    if (kiemTraTrungMa(nv.id)) {
      return false;
    }
    _danhSachNhanVien.add(nv);
    notifyListeners();
    return true;
  }

  bool capNhatNhanVien(NhanVien nv) {
    final index = _danhSachNhanVien.indexWhere((item) => item.id == nv.id);
    if (index != -1) {
      _danhSachNhanVien[index] = nv;
      notifyListeners();
      return true;
    }
    return false;
  }

  void xoaNhanVien(String id) {
    _danhSachNhanVien.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  bool kiemTraTrungMa(String id, {String? excludeId}) {
    final cleanId = id.trim().toUpperCase();
    return _danhSachNhanVien.any(
      (item) => item.id.toUpperCase() == cleanId && item.id != excludeId,
    );
  }

  void ganChucVu(String maNhanVien, String? maChucVu) {
    final index = _danhSachNhanVien.indexWhere((nv) => nv.id == maNhanVien);
    if (index != -1) {
      _danhSachNhanVien[index].maChucVu = maChucVu;
      notifyListeners();
    }
  }

  // =================== QUẢN LÝ CHỨC VỤ ===================
  bool themChucVu(ChucVu cv) {
    if (kiemTraTrungMaChucVu(cv.id)) {
      return false;
    }
    _danhSachChucVu.add(cv);
    notifyListeners();
    return true;
  }

  bool capNhatChucVu(ChucVu cv) {
    final index = _danhSachChucVu.indexWhere((item) => item.id == cv.id);
    if (index != -1) {
      _danhSachChucVu[index] = cv;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Xóa chức vụ: nếu có nhân viên thì gỡ chức vụ trước khi xóa
  void xoaChucVu(String id, {bool goGanNhanVien = true}) {
    if (goGanNhanVien) {
      for (final nv in _danhSachNhanVien) {
        if (nv.maChucVu == id) {
          nv.maChucVu = null;
        }
      }
    }
    _danhSachChucVu.removeWhere((cv) => cv.id == id);
    notifyListeners();
  }

  bool kiemTraTrungMaChucVu(String id, {String? excludeId}) {
    final cleanId = id.trim().toUpperCase();
    return _danhSachChucVu.any(
      (item) => item.id.toUpperCase() == cleanId && item.id != excludeId,
    );
  }

  List<NhanVien> layDanhSachNhanVienTheoChucVu(String chucVuId) {
    return _danhSachNhanVien.where((nv) => nv.maChucVu == chucVuId).toList();
  }

  int laySoLuongNhanVienTheoChucVu(String chucVuId) {
    return _danhSachNhanVien.where((nv) => nv.maChucVu == chucVuId).length;
  }
}
