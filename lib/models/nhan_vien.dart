class NhanVien {
  final String id;
  final String hoTen;
  final String email;
  final String soDienThoai;
  final String gioiTinh;
  final DateTime ngaySinh;
  final String trinhDo;
  String? maChucVu;

  NhanVien({
    required this.id,
    required this.hoTen,
    required this.email,
    required this.soDienThoai,
    required this.gioiTinh,
    required this.ngaySinh,
    required this.trinhDo,
    this.maChucVu,
  });

  NhanVien copyWith({
    String? id,
    String? hoTen,
    String? email,
    String? soDienThoai,
    String? gioiTinh,
    DateTime? ngaySinh,
    String? trinhDo,
    String? maChucVu,
  }) {
    return NhanVien(
      id: id ?? this.id,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      ngaySinh: ngaySinh ?? this.ngaySinh,
      trinhDo: trinhDo ?? this.trinhDo,
      maChucVu: maChucVu ?? this.maChucVu,
    );
  }
}
