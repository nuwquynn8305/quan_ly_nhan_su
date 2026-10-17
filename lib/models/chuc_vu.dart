class ChucVu {
  final String id;
  final String tenChucVu;
  final double heSoLuong;
  final double luongCoBan;
  final double phuCap;
  final String moTa;

  ChucVu({
    required this.id,
    required this.tenChucVu,
    this.heSoLuong = 1.0,
    this.luongCoBan = 5000000.0,
    this.phuCap = 1000000.0,
    this.moTa = '',
  });

  // Tính lương theo chức vụ: (Lương cơ bản * Hệ số) + Phụ cấp
  double get tongLuong => (luongCoBan * heSoLuong) + phuCap;

  ChucVu copyWith({
    String? id,
    String? tenChucVu,
    double? heSoLuong,
    double? luongCoBan,
    double? phuCap,
    String? moTa,
  }) {
    return ChucVu(
      id: id ?? this.id,
      tenChucVu: tenChucVu ?? this.tenChucVu,
      heSoLuong: heSoLuong ?? this.heSoLuong,
      luongCoBan: luongCoBan ?? this.luongCoBan,
      phuCap: phuCap ?? this.phuCap,
      moTa: moTa ?? this.moTa,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenChucVu': tenChucVu,
      'heSoLuong': heSoLuong,
      'luongCoBan': luongCoBan,
      'phuCap': phuCap,
      'moTa': moTa,
    };
  }

  factory ChucVu.fromJson(Map<String, dynamic> json) {
    return ChucVu(
      id: json['id'] as String,
      tenChucVu: json['tenChucVu'] as String,
      heSoLuong: (json['heSoLuong'] as num?)?.toDouble() ?? 1.0,
      luongCoBan: (json['luongCoBan'] as num?)?.toDouble() ?? 5000000.0,
      phuCap: (json['phuCap'] as num?)?.toDouble() ?? 1000000.0,
      moTa: json['moTa'] as String? ?? '',
    );
  }
}
