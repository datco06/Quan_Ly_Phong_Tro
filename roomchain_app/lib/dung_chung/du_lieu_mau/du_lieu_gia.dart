import '../mo_hinh/nguoi_dung.dart';
import '../mo_hinh/phong_tro.dart';
import '../mo_hinh/khu_tro.dart';
import '../mo_hinh/hoa_don.dart';
import '../mo_hinh/hop_dong.dart';
import '../mo_hinh/chi_so_dien_nuoc.dart';
import '../mo_hinh/tien_coc.dart';

abstract final class DuLieuGia {
  static const nguoiThue = NguoiDung(
    id: 'tenant-demo',
    hoTen: 'Trần Minh Anh',
    email: 'minhanh@gmail.com',
    soDienThoai: '0901234567',
    vaiTro: VaiTro.tenant,
  );
  static const chuTro = NguoiDung(
    id: 'landlord-demo',
    hoTen: 'Nguyễn Văn Minh',
    email: 'minh@example.com',
    soDienThoai: '0909123456',
    vaiTro: VaiTro.landlord,
  );
  static const khuTro = KhuTro(
    id: 'an-nhien',
    tenKhuTro: 'An Nhiên Residence',
    diaChi: 'Hà Đông, Hà Nội',
    tongSoPhong: 24,
    soPhongDangThue: 18,
    soPhongTrong: 6,
    dangHoatDong: true,
  );
  static final List<PhongTro> phongTro = List.unmodifiable([
    for (final p in [
      ('P201', 2500000, 20.0),
      ('P302', 2800000, 25.0),
      ('P403', 2600000, 22.0),
      ('P502B', 3800000, 28.0),
    ])
      PhongTro(
        id: p.$1,
        maPhong: p.$1,
        tenKhuTro: khuTro.tenKhuTro,
        diaChi: khuTro.diaChi,
        giaThue: p.$2,
        tienCoc: p.$2,
        dienTich: p.$3,
        danhSachAnh: const [],
        danhSachTienIch: const ['Wi-Fi', 'WC riêng', 'Điều hòa'],
        trangThai: p.$1 == 'P502B'
            ? TrangThaiPhong.dangThue
            : TrangThaiPhong.conTrong,
      ),
  ]);
  static final hoaDon = HoaDon(
    id: 'HD-demo-112026',
    maPhong: 'P502B',
    kyHoaDon: DateTime(2026, 11),
    ngayDenHan: DateTime(2026, 11, 5),
    danhSachKhoanThu: const [
      KhoanThuHoaDon(ten: 'Tiền thuê', soTien: 3800000),
      KhoanThuHoaDon(ten: 'Internet', soTien: 100000),
      KhoanThuHoaDon(ten: 'Dịch vụ', soTien: 300000),
      KhoanThuHoaDon(ten: 'Điện', soTien: 616000),
      KhoanThuHoaDon(ten: 'Nước', soTien: 210000),
      KhoanThuHoaDon(ten: 'Khoản khác', soTien: 100000),
    ],
    tongTien: 5126000,
    daThanhToan: 0,
    congNoConLai: 5126000,
    trangThai: TrangThaiHoaDon.chuaThanhToan,
  );
  static final hopDong = HopDong(
    id: 'contract-demo',
    maHopDong: 'RC20261001-P502B',
    phongId: 'P502B',
    nguoiThueId: nguoiThue.id,
    ngayBatDau: DateTime(2026, 10, 1),
    ngayKetThuc: DateTime(2027, 9, 30),
    giaThue: 3800000,
    tienCoc: 3800000,
    trangThai: TrangThaiHopDong.dangHieuLuc,
  );
  static final List<ChiSoDienNuoc> chiSo = List.unmodifiable([
    ChiSoDienNuoc(
      id: 'electric-demo',
      maPhong: 'P502B',
      loaiDongHo: LoaiDongHo.dien,
      chiSoCu: 5432,
      chiSoMoi: 5586,
      soTieuThu: 154,
      donVi: 'kWh',
      ngayGhi: DateTime(2026, 11, 1),
      trangThai: TrangThaiChiSo.daDuyet,
    ),
    ChiSoDienNuoc(
      id: 'water-demo',
      maPhong: 'P502B',
      loaiDongHo: LoaiDongHo.nuoc,
      chiSoCu: 158,
      chiSoMoi: 164,
      soTieuThu: 6,
      donVi: 'm³',
      ngayGhi: DateTime(2026, 11, 1),
      trangThai: TrangThaiChiSo.choDuyet,
    ),
  ]);
  static const tienCoc = TienCoc(
    id: 'deposit-demo',
    hopDongId: 'contract-demo',
    soToken: 3800000,
    loaiToken: 'MockVNDC',
    trangThai: TrangThaiTienCoc.dangKhoa,
  );
}
