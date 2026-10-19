enum TrangThaiHopDong { nhap, choKy, dangHieuLuc, daKetThuc }

class HopDong {
  const HopDong({
    required this.id,
    required this.maHopDong,
    required this.phongId,
    required this.nguoiThueId,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    required this.giaThue,
    required this.tienCoc,
    required this.trangThai,
  });
  final String id;
  final String maHopDong;
  final String phongId;
  final String nguoiThueId;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final int giaThue;
  final int tienCoc;
  final TrangThaiHopDong trangThai;

  HopDong copyWith({
    String? id,
    String? maHopDong,
    String? phongId,
    String? nguoiThueId,
    DateTime? ngayBatDau,
    DateTime? ngayKetThuc,
    int? giaThue,
    int? tienCoc,
    TrangThaiHopDong? trangThai,
  }) => HopDong(
    id: id ?? this.id,
    maHopDong: maHopDong ?? this.maHopDong,
    phongId: phongId ?? this.phongId,
    nguoiThueId: nguoiThueId ?? this.nguoiThueId,
    ngayBatDau: ngayBatDau ?? this.ngayBatDau,
    ngayKetThuc: ngayKetThuc ?? this.ngayKetThuc,
    giaThue: giaThue ?? this.giaThue,
    tienCoc: tienCoc ?? this.tienCoc,
    trangThai: trangThai ?? this.trangThai,
  );
}
