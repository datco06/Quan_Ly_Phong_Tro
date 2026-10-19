enum TrangThaiHoaDon {
  nhap,
  chuaThanhToan,
  daThanhToan,
  quaHan,
  thanhToanMotPhan,
}

class KhoanThuHoaDon {
  const KhoanThuHoaDon({required this.ten, required this.soTien});
  final String ten;
  final int soTien;
}

class HoaDon {
  const HoaDon({
    required this.id,
    required this.maPhong,
    required this.kyHoaDon,
    required this.ngayDenHan,
    required this.danhSachKhoanThu,
    required this.tongTien,
    required this.daThanhToan,
    required this.congNoConLai,
    required this.trangThai,
  });
  final String id;
  final String maPhong;
  final DateTime kyHoaDon;
  final DateTime ngayDenHan;
  final List<KhoanThuHoaDon> danhSachKhoanThu;
  final int tongTien;
  final int daThanhToan;
  final int congNoConLai;
  final TrangThaiHoaDon trangThai;

  HoaDon copyWith({
    String? id,
    String? maPhong,
    DateTime? kyHoaDon,
    DateTime? ngayDenHan,
    List<KhoanThuHoaDon>? danhSachKhoanThu,
    int? tongTien,
    int? daThanhToan,
    int? congNoConLai,
    TrangThaiHoaDon? trangThai,
  }) => HoaDon(
    id: id ?? this.id,
    maPhong: maPhong ?? this.maPhong,
    kyHoaDon: kyHoaDon ?? this.kyHoaDon,
    ngayDenHan: ngayDenHan ?? this.ngayDenHan,
    danhSachKhoanThu: danhSachKhoanThu ?? this.danhSachKhoanThu,
    tongTien: tongTien ?? this.tongTien,
    daThanhToan: daThanhToan ?? this.daThanhToan,
    congNoConLai: congNoConLai ?? this.congNoConLai,
    trangThai: trangThai ?? this.trangThai,
  );
}
