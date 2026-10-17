class NhanVien {
  final String id;
  final String hoTen;
  final String email;
  final String soDienThoai;
  final String gioiTinh;
  final DateTime ngaySinh;
  String? maChucVu;

  NhanVien({
    required this.id,
    required this.hoTen,
    required this.email,
    required this.soDienThoai,
    required this.gioiTinh,
    required this.ngaySinh,
    this.maChucVu,
  });
}
