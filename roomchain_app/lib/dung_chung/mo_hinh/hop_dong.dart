import 'dart:typed_data';

import 'tien_coc.dart';
import 'quyet_toan_tien_coc.dart';

enum TrangThaiHopDong { nhap, choKy, choCoc, dangHieuLuc, daKetThuc }

enum LoaiSuKienHopDong { tao, guiKy, ky, datCoc, nhacCoc, quyetToan }

class SuKienHopDong {
  const SuKienHopDong({
    required this.loai,
    required this.tieuDe,
    required this.thoiGian,
    this.moTa,
    this.thamChieu,
  });
  final LoaiSuKienHopDong loai;
  final String tieuDe;
  final DateTime thoiGian;
  final String? moTa, thamChieu;
}

class TaiLieuHopDong {
  TaiLieuHopDong({
    required Uint8List noiDung,
    required this.tenTep,
    required this.sha256,
    required this.ngayTao,
    this.phienBan = 1,
  }) : noiDung = Uint8List.fromList(noiDung).asUnmodifiableView();
  final Uint8List noiDung;
  final String tenTep, sha256;
  final DateTime ngayTao;
  final int phienBan;
}

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
    this.ngayTao,
    this.guiKyLuc,
    this.chuTroKyLuc,
    this.nguoiThueKyLuc,
    this.nguoiThueDongYLuc,
    this.dangKyDemo = false,
    this.loiKyDemo,
    this.viNguoiThueKy,
    this.maBamDaKy,
    this.taiLieu,
    this.coc,
    this.ghiNhanCocLuc,
    this.diaChiEscrow,
    this.maGiaoDichCoc,
    this.lichSu = const [],
    this.quyetToan,
    this.thoaThuanKetThucSom,
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
  final DateTime? ngayTao, guiKyLuc, chuTroKyLuc, nguoiThueKyLuc, ghiNhanCocLuc;
  // Chấp thuận trên giao diện demo, tách riêng với chữ ký ví.
  final DateTime? nguoiThueDongYLuc;
  final bool dangKyDemo;
  final String? loiKyDemo, viNguoiThueKy, maBamDaKy;
  bool get choKyVi => nguoiThueDongYLuc != null && nguoiThueKyLuc == null;
  final TaiLieuHopDong? taiLieu;
  final TienCoc? coc;
  final String? diaChiEscrow, maGiaoDichCoc;
  final List<SuKienHopDong> lichSu;
  final QuyetToanTienCoc? quyetToan;
  final ThoaThuanKetThucSom? thoaThuanKetThucSom;
  bool get daCoChuKy => chuTroKyLuc != null || nguoiThueKyLuc != null;

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
    DateTime? ngayTao,
    DateTime? guiKyLuc,
    DateTime? chuTroKyLuc,
    DateTime? nguoiThueKyLuc,
    DateTime? nguoiThueDongYLuc,
    bool? dangKyDemo,
    String? loiKyDemo,
    bool xoaLoiKyDemo = false,
    String? viNguoiThueKy,
    String? maBamDaKy,
    DateTime? ghiNhanCocLuc,
    TaiLieuHopDong? taiLieu,
    TienCoc? coc,
    String? diaChiEscrow,
    String? maGiaoDichCoc,
    List<SuKienHopDong>? lichSu,
    QuyetToanTienCoc? quyetToan,
    ThoaThuanKetThucSom? thoaThuanKetThucSom,
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
    ngayTao: ngayTao ?? this.ngayTao,
    guiKyLuc: guiKyLuc ?? this.guiKyLuc,
    chuTroKyLuc: chuTroKyLuc ?? this.chuTroKyLuc,
    nguoiThueKyLuc: nguoiThueKyLuc ?? this.nguoiThueKyLuc,
    nguoiThueDongYLuc: nguoiThueDongYLuc ?? this.nguoiThueDongYLuc,
    dangKyDemo: dangKyDemo ?? this.dangKyDemo,
    loiKyDemo: xoaLoiKyDemo ? null : loiKyDemo ?? this.loiKyDemo,
    viNguoiThueKy: viNguoiThueKy ?? this.viNguoiThueKy,
    maBamDaKy: maBamDaKy ?? this.maBamDaKy,
    ghiNhanCocLuc: ghiNhanCocLuc ?? this.ghiNhanCocLuc,
    taiLieu: taiLieu ?? this.taiLieu,
    coc: coc ?? this.coc,
    diaChiEscrow: diaChiEscrow ?? this.diaChiEscrow,
    maGiaoDichCoc: maGiaoDichCoc ?? this.maGiaoDichCoc,
    lichSu: lichSu == null ? this.lichSu : List.unmodifiable(lichSu),
    quyetToan: quyetToan ?? this.quyetToan,
    thoaThuanKetThucSom: thoaThuanKetThucSom ?? this.thoaThuanKetThucSom,
  );
}
