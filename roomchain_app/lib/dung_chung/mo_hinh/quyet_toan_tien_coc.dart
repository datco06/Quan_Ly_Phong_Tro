import 'dart:typed_data';

enum TrangThaiQuyetToan { choNguoiThueXacNhan, daXacNhan, daGiaiNgan }

enum TrangThaiGiaoDichQuyetToan { chuaGui, dangXuLy, thanhCong, thatBai }

class KhoanKhauTru {
  const KhoanKhauTru({
    required this.id,
    required this.soTien,
    required this.lyDo,
  });
  final String id, lyDo;
  final int soTien;
}

class BangChungKhauTru {
  BangChungKhauTru({
    required this.id,
    required this.tenTep,
    required Uint8List noiDung,
  }) : noiDung = Uint8List.fromList(noiDung).asUnmodifiableView();
  final String id, tenTep;
  final Uint8List noiDung;
}

class ThoaThuanKetThucSom {
  const ThoaThuanKetThucSom({
    required this.noiDung,
    required this.khauTruDaThongNhat,
    required this.chuTroXacNhanLuc,
    required this.nguoiThueXacNhanLuc,
  });
  final String noiDung;
  final int khauTruDaThongNhat;
  final DateTime chuTroXacNhanLuc, nguoiThueXacNhanLuc;
}

class QuyetToanTienCoc {
  QuyetToanTienCoc({
    required this.id,
    required this.hopDongId,
    required this.tienCocBanDau,
    required List<KhoanKhauTru> cacKhoan,
    required List<BangChungKhauTru> bangChung,
    required this.chuTroXacNhanLuc,
    this.nguoiThueXacNhanLuc,
    String? maQuyetToan,
    this.ngayTao,
    this.trangThai = TrangThaiQuyetToan.choNguoiThueXacNhan,
    this.trangThaiGiaoDich = TrangThaiGiaoDichQuyetToan.chuaGui,
    this.txHash,
    this.thoiGianGiaoDich,
    this.hoanTatLuc,
    this.loiGiaoDich,
    this.soTienHoanNguoiThue,
    this.soTienChuTroNhan,
    this.doanhThuVndDaGhiNhan = 0,
  }) : cacKhoan = List.unmodifiable(cacKhoan),
       bangChung = List.unmodifiable(bangChung),
       maQuyetToan = maQuyetToan ?? id;

  final String id, maQuyetToan, hopDongId;
  final int tienCocBanDau, doanhThuVndDaGhiNhan;
  final List<KhoanKhauTru> cacKhoan;
  final List<BangChungKhauTru> bangChung;
  final DateTime? ngayTao, chuTroXacNhanLuc, nguoiThueXacNhanLuc;
  final TrangThaiQuyetToan trangThai;
  final TrangThaiGiaoDichQuyetToan trangThaiGiaoDich;
  final String? txHash, loiGiaoDich;
  final DateTime? thoiGianGiaoDich, hoanTatLuc;
  final int? soTienHoanNguoiThue, soTienChuTroNhan;
  int get tongKhauTru => cacKhoan.fold(0, (tong, k) => tong + k.soTien);
  int get soHoanDuKien => tienCocBanDau - tongKhauTru;
  int get nguoiThueNhanThamChieu => soTienHoanNguoiThue ?? soHoanDuKien;
  int get chuTroNhanThamChieu => soTienChuTroNhan ?? tongKhauTru;
  bool get daDuXacNhan =>
      chuTroXacNhanLuc != null && nguoiThueXacNhanLuc != null;
  bool get phanChiaHopLe =>
      tienCocBanDau > 0 &&
      cacKhoan.every((k) => k.soTien >= 0) &&
      tongKhauTru <= tienCocBanDau &&
      nguoiThueNhanThamChieu >= 0 &&
      chuTroNhanThamChieu >= 0 &&
      nguoiThueNhanThamChieu + chuTroNhanThamChieu == tienCocBanDau;
  String? get txHashHopLe {
    final tx = txHash?.trim();
    return tx != null && RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(tx)
        ? tx
        : null;
  }

  // Xác nhận của hai bên và enum giải ngân không thay thế biên nhận giao dịch.
  bool get daHoanTat =>
      phanChiaHopLe &&
      daDuXacNhan &&
      trangThai == TrangThaiQuyetToan.daGiaiNgan &&
      trangThaiGiaoDich == TrangThaiGiaoDichQuyetToan.thanhCong &&
      txHashHopLe != null &&
      thoiGianGiaoDich != null &&
      hoanTatLuc != null;

  QuyetToanTienCoc copyWith({
    DateTime? chuTroXacNhanLuc,
    DateTime? nguoiThueXacNhanLuc,
    TrangThaiQuyetToan? trangThai,
    TrangThaiGiaoDichQuyetToan? trangThaiGiaoDich,
    String? txHash,
    DateTime? thoiGianGiaoDich,
    DateTime? hoanTatLuc,
    String? loiGiaoDich,
    int? doanhThuVndDaGhiNhan,
  }) => QuyetToanTienCoc(
    id: id,
    maQuyetToan: maQuyetToan,
    hopDongId: hopDongId,
    ngayTao: ngayTao,
    tienCocBanDau: tienCocBanDau,
    cacKhoan: cacKhoan,
    bangChung: bangChung,
    chuTroXacNhanLuc: chuTroXacNhanLuc ?? this.chuTroXacNhanLuc,
    nguoiThueXacNhanLuc: nguoiThueXacNhanLuc ?? this.nguoiThueXacNhanLuc,
    trangThai: trangThai ?? this.trangThai,
    trangThaiGiaoDich: trangThaiGiaoDich ?? this.trangThaiGiaoDich,
    txHash: txHash ?? this.txHash,
    thoiGianGiaoDich: thoiGianGiaoDich ?? this.thoiGianGiaoDich,
    hoanTatLuc: hoanTatLuc ?? this.hoanTatLuc,
    loiGiaoDich: loiGiaoDich ?? this.loiGiaoDich,
    soTienHoanNguoiThue: soTienHoanNguoiThue,
    soTienChuTroNhan: soTienChuTroNhan,
    doanhThuVndDaGhiNhan: doanhThuVndDaGhiNhan ?? this.doanhThuVndDaGhiNhan,
  );
}
