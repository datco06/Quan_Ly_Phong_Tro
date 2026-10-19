class KhuTro {
  const KhuTro({
    required this.id,
    required this.tenKhuTro,
    required this.diaChi,
    this.anhDaiDien,
    required this.tongSoPhong,
    required this.soPhongDangThue,
    required this.soPhongTrong,
    required this.dangHoatDong,
  });
  final String id;
  final String tenKhuTro;
  final String diaChi;
  final String? anhDaiDien;
  final int tongSoPhong;
  final int soPhongDangThue;
  final int soPhongTrong;
  final bool dangHoatDong;

  KhuTro copyWith({
    String? id,
    String? tenKhuTro,
    String? diaChi,
    String? anhDaiDien,
    int? tongSoPhong,
    int? soPhongDangThue,
    int? soPhongTrong,
    bool? dangHoatDong,
    bool xoaAnhDaiDien = false,
  }) => KhuTro(
    id: id ?? this.id,
    tenKhuTro: tenKhuTro ?? this.tenKhuTro,
    diaChi: diaChi ?? this.diaChi,
    anhDaiDien: xoaAnhDaiDien ? null : anhDaiDien ?? this.anhDaiDien,
    tongSoPhong: tongSoPhong ?? this.tongSoPhong,
    soPhongDangThue: soPhongDangThue ?? this.soPhongDangThue,
    soPhongTrong: soPhongTrong ?? this.soPhongTrong,
    dangHoatDong: dangHoatDong ?? this.dangHoatDong,
  );
}
