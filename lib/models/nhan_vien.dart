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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hoTen': hoTen,
      'email': email,
      'soDienThoai': soDienThoai,
      'gioiTinh': gioiTinh,
      'ngaySinh': ngaySinh.toIso8601String(),
      'trinhDo': trinhDo,
      'maChucVu': maChucVu,
    };
  }

  factory NhanVien.fromJson(Map<String, dynamic> json) {
    return NhanVien(
      id: json['id'] as String,
      hoTen: json['hoTen'] as String,
      email: json['email'] as String,
      soDienThoai: json['soDienThoai'] as String,
      gioiTinh: json['gioiTinh'] as String,
      ngaySinh: DateTime.parse(json['ngaySinh'] as String),
      trinhDo: json['trinhDo'] as String? ?? 'Đại học',
      maChucVu: json['maChucVu'] as String?,
    );
  }
}
