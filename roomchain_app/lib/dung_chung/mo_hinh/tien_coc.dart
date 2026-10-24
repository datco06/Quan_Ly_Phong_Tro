import 'giao_dich_blockchain.dart';

enum TrangThaiTienCoc {
  chuaDat,
  dangKhoa,
  daHoan,
  daQuyetToan,
  choXacNhan,
  choQuyetToan,
  choNguoiThueXacNhan,
  thatBai,
}

extension HienThiTienCoc on TrangThaiTienCoc {
  String get nhan => switch (this) {
    TrangThaiTienCoc.chuaDat => 'Chưa đặt cọc',
    TrangThaiTienCoc.choXacNhan => 'Chờ xác nhận',
    TrangThaiTienCoc.dangKhoa => 'Đang khóa',
    TrangThaiTienCoc.choQuyetToan => 'Chờ quyết toán',
    TrangThaiTienCoc.choNguoiThueXacNhan => 'Chờ người thuê xác nhận',
    TrangThaiTienCoc.daHoan => 'Đã hoàn',
    TrangThaiTienCoc.daQuyetToan => 'Đã phân chia',
    TrangThaiTienCoc.thatBai => 'Giao dịch thất bại',
  };
  bool get dangGiuTrongEscrow =>
      this == TrangThaiTienCoc.dangKhoa ||
      this == TrangThaiTienCoc.choQuyetToan ||
      this == TrangThaiTienCoc.choNguoiThueXacNhan;
}

class TienCoc {
  const TienCoc({
    required this.id,
    required this.hopDongId,
    required this.soToken,
    required this.loaiToken,
    this.diaChiVi,
    required this.trangThai,
    this.giaoDich,
  });
  final String id;
  final String hopDongId;
  final int soToken;
  final String loaiToken;
  final String? diaChiVi;
  final TrangThaiTienCoc trangThai;
  final GiaoDichBlockchain? giaoDich;

  TienCoc copyWith({
    String? id,
    String? hopDongId,
    int? soToken,
    String? loaiToken,
    String? diaChiVi,
    TrangThaiTienCoc? trangThai,
    bool xoaDiaChiVi = false,
    GiaoDichBlockchain? giaoDich,
  }) => TienCoc(
    id: id ?? this.id,
    hopDongId: hopDongId ?? this.hopDongId,
    soToken: soToken ?? this.soToken,
    loaiToken: loaiToken ?? this.loaiToken,
    diaChiVi: xoaDiaChiVi ? null : diaChiVi ?? this.diaChiVi,
    trangThai: trangThai ?? this.trangThai,
    giaoDich: giaoDich ?? this.giaoDich,
  );
}
