class ChucVu {
  final String id;
  final String tenChucVu;
  final double heSoLuong;
  final String moTa;

  ChucVu({
    required this.id,
    required this.tenChucVu,
    this.heSoLuong = 1.0,
    this.moTa = '',
  });

  ChucVu copyWith({
    String? id,
    String? tenChucVu,
    double? heSoLuong,
    String? moTa,
  }) {
    return ChucVu(
      id: id ?? this.id,
      tenChucVu: tenChucVu ?? this.tenChucVu,
      heSoLuong: heSoLuong ?? this.heSoLuong,
      moTa: moTa ?? this.moTa,
    );
  }
}
