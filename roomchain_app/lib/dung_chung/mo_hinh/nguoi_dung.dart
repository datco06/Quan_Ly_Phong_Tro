enum VaiTro { tenant, landlord }

class NguoiDung {
  const NguoiDung({
    required this.id,
    required this.hoTen,
    required this.email,
    required this.soDienThoai,
    required this.vaiTro,
    this.anhDaiDien,
  });
  final String id;
  final String hoTen;
  final String email;
  final String soDienThoai;
  final VaiTro vaiTro;
  final String? anhDaiDien;

  NguoiDung copyWith({
    String? id,
    String? hoTen,
    String? email,
    String? soDienThoai,
    VaiTro? vaiTro,
    String? anhDaiDien,
    bool xoaAnhDaiDien = false,
  }) => NguoiDung(
    id: id ?? this.id,
    hoTen: hoTen ?? this.hoTen,
    email: email ?? this.email,
    soDienThoai: soDienThoai ?? this.soDienThoai,
    vaiTro: vaiTro ?? this.vaiTro,
    anhDaiDien: xoaAnhDaiDien ? null : anhDaiDien ?? this.anhDaiDien,
  );
}
