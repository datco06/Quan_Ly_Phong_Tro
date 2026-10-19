enum LoaiDongHo { dien, nuoc }

enum TrangThaiChiSo { chuaGui, choDuyet, daDuyet, tuChoi }

class ChiSoDienNuoc {
  const ChiSoDienNuoc({
    required this.id,
    required this.maPhong,
    required this.loaiDongHo,
    required this.chiSoCu,
    required this.chiSoMoi,
    required this.soTieuThu,
    required this.donVi,
    required this.ngayGhi,
    this.anhDongHo,
    required this.trangThai,
  });
  final String id;
  final String maPhong;
  final LoaiDongHo loaiDongHo;
  final num chiSoCu;
  final num chiSoMoi;
  final num soTieuThu;
  final String donVi;
  final DateTime ngayGhi;
  final String? anhDongHo;
  final TrangThaiChiSo trangThai;

  ChiSoDienNuoc copyWith({
    String? id,
    String? maPhong,
    LoaiDongHo? loaiDongHo,
    num? chiSoCu,
    num? chiSoMoi,
    num? soTieuThu,
    String? donVi,
    DateTime? ngayGhi,
    String? anhDongHo,
    TrangThaiChiSo? trangThai,
    bool xoaAnhDongHo = false,
  }) => ChiSoDienNuoc(
    id: id ?? this.id,
    maPhong: maPhong ?? this.maPhong,
    loaiDongHo: loaiDongHo ?? this.loaiDongHo,
    chiSoCu: chiSoCu ?? this.chiSoCu,
    chiSoMoi: chiSoMoi ?? this.chiSoMoi,
    soTieuThu: soTieuThu ?? this.soTieuThu,
    donVi: donVi ?? this.donVi,
    ngayGhi: ngayGhi ?? this.ngayGhi,
    anhDongHo: xoaAnhDongHo ? null : anhDongHo ?? this.anhDongHo,
    trangThai: trangThai ?? this.trangThai,
  );
}
