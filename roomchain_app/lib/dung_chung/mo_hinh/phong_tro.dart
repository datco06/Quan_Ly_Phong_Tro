enum TrangThaiPhong { conTrong, dangThue, baoTri }

class PhongTro {
  const PhongTro({
    required this.id,
    required this.maPhong,
    required this.tenKhuTro,
    required this.diaChi,
    required this.giaThue,
    required this.tienCoc,
    required this.dienTich,
    required this.danhSachAnh,
    required this.danhSachTienIch,
    required this.trangThai,
  });
  final String id;
  final String maPhong;
  final String tenKhuTro;
  final String diaChi;
  final int giaThue;
  final int tienCoc;
  final double dienTich;
  final List<String> danhSachAnh;
  final List<String> danhSachTienIch;
  final TrangThaiPhong trangThai;

  PhongTro copyWith({
    String? id,
    String? maPhong,
    String? tenKhuTro,
    String? diaChi,
    int? giaThue,
    int? tienCoc,
    double? dienTich,
    List<String>? danhSachAnh,
    List<String>? danhSachTienIch,
    TrangThaiPhong? trangThai,
  }) => PhongTro(
    id: id ?? this.id,
    maPhong: maPhong ?? this.maPhong,
    tenKhuTro: tenKhuTro ?? this.tenKhuTro,
    diaChi: diaChi ?? this.diaChi,
    giaThue: giaThue ?? this.giaThue,
    tienCoc: tienCoc ?? this.tienCoc,
    dienTich: dienTich ?? this.dienTich,
    danhSachAnh: danhSachAnh ?? this.danhSachAnh,
    danhSachTienIch: danhSachTienIch ?? this.danhSachTienIch,
    trangThai: trangThai ?? this.trangThai,
  );
}
