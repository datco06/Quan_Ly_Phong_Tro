enum TrangThaiHopDong { nhap, choKy, choCoc, dangHieuLuc, daKetThuc }

class CauHinhHopDong {
  const CauHinhHopDong({
    this.phiDichVu = 300000,
    this.donGiaDien = 4000,
    this.donGiaNuoc = 30000,
    this.internet = 100000,
    this.khoanKhac = 0,
    this.ngayGhiSo = 28,
    this.thanhToanTu = 1,
    this.thanhToanDen = 5,
    this.phuThuCham = 50000,
    this.ketThucSom = 'Hai bên thỏa thuận kết thúc sớm',
    this.noiQuy = '',
  });
  final int phiDichVu, donGiaDien, donGiaNuoc, internet, khoanKhac;
  final int ngayGhiSo, thanhToanTu, thanhToanDen, phuThuCham;
  final String ketThucSom, noiQuy;
}

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
    this.cauHinh = const CauHinhHopDong(),
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
  final CauHinhHopDong cauHinh;

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
    CauHinhHopDong? cauHinh,
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
    cauHinh: cauHinh ?? this.cauHinh,
  );
}
