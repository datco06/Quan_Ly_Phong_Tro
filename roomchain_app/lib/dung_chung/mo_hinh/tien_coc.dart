enum TrangThaiTienCoc { chuaDat, dangKhoa, daHoan, daQuyetToan }

class TienCoc {
  const TienCoc({
    required this.id,
    required this.hopDongId,
    required this.soToken,
    required this.loaiToken,
    this.diaChiVi,
    required this.trangThai,
  });
  final String id;
  final String hopDongId;
  final int soToken;
  final String loaiToken;
  final String? diaChiVi;
  final TrangThaiTienCoc trangThai;

  TienCoc copyWith({
    String? id,
    String? hopDongId,
    int? soToken,
    String? loaiToken,
    String? diaChiVi,
    TrangThaiTienCoc? trangThai,
    bool xoaDiaChiVi = false,
  }) => TienCoc(
    id: id ?? this.id,
    hopDongId: hopDongId ?? this.hopDongId,
    soToken: soToken ?? this.soToken,
    loaiToken: loaiToken ?? this.loaiToken,
    diaChiVi: xoaDiaChiVi ? null : diaChiVi ?? this.diaChiVi,
    trangThai: trangThai ?? this.trangThai,
  );
}
