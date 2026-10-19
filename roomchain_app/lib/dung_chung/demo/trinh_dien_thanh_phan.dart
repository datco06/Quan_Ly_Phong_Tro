import 'package:flutter/material.dart';

import '../roomchain_ui.dart';

class TrinhDienThanhPhan extends StatefulWidget {
  const TrinhDienThanhPhan({super.key});
  @override
  State<TrinhDienThanhPhan> createState() => _TrinhDienThanhPhanState();
}

class _TrinhDienThanhPhanState extends State<TrinhDienThanhPhan> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false, _selected = false, _favorite = false;
  int _tab = 0, _tenant = 0, _landlord = 0;
  String? _vehicle = 'Xe máy';
  DateTime? _date;
  String _search = '';
  final List<String> _images = [];
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: KieuChu.tieuDeMuc),
        const SizedBox(height: 12),
        for (final child in children)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: child),
      ],
    ),
  );
  void _feedback(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => KhungTrang(
    tieuDe: 'RoomChain · Core UI',
    coQuayLai: false,
    noiDung: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ThongBaoNoiDung(
          noiDung: 'Bản trình diễn · Dữ liệu mẫu, không có giao dịch thực tế.',
        ),
        const SizedBox(height: 24),
        _section('01 · Màu sắc', [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in [
                ('Teal', BangMau.chinh),
                ('Thành công', BangMau.thanhCong),
                ('Cảnh báo', BangMau.canhBao),
                ('Lỗi', BangMau.loi),
                ('Thông tin', BangMau.thongTin),
              ])
                SizedBox(
                  width: 92,
                  child: Column(
                    children: [
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: c.$2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Text(c.$1),
                    ],
                  ),
                ),
            ],
          ),
        ]),
        _section('02 · Typography', [
          for (final style in [
            KieuChu.tieuDeLon,
            KieuChu.tieuDeTrang,
            KieuChu.tieuDeMuc,
            KieuChu.tieuDeThe,
            KieuChu.noiDung,
            KieuChu.noiDungDam,
            KieuChu.nhan,
            KieuChu.chuPhu,
            KieuChu.chuNho,
            KieuChu.soTienLon,
            KieuChu.soTienVua,
          ])
            Text('RoomChain · Tìm trọ dễ dàng', style: style),
        ]),
        _section('03 · Button', [
          for (final type in KieuNut.values)
            NutBam(
              nhan: 'Xác nhận · ${type.name}',
              kieu: type,
              bieuTuong: Icons.check,
              khiNhan: () => _feedback('Đã bấm ${type.name}'),
            ),
          NutBam(nhan: 'Không khả dụng', voHieuHoa: true, khiNhan: () {}),
          SwitchListTile(
            title: const Text('Bật trạng thái loading'),
            value: _loading,
            onChanged: (value) => setState(() => _loading = value),
          ),
          NutBam(nhan: 'Gửi yêu cầu mẫu', dangTai: _loading, khiNhan: () {}),
          NutBieuTuong(
            bieuTuong: Icons.camera_alt_outlined,
            goiY: 'Camera mẫu',
            khiNhan: () => _feedback('Callback camera'),
          ),
        ]),
        _section('04 · Form input', [
          Form(
            key: _form,
            child: Column(
              children: [
                ONhapLieu(
                  nhan: 'Email',
                  controller: _email,
                  batBuoc: true,
                  kieuBanPhim: TextInputType.emailAddress,
                  kiemTra: KiemTraDuLieu.email,
                ),
                const SizedBox(height: 12),
                NutBam(
                  nhan: 'Kiểm tra form',
                  khiNhan: () {
                    if (_form.currentState!.validate()) {
                      _feedback('Email hợp lệ');
                    }
                  },
                ),
              ],
            ),
          ),
          OChon<String>(
            nhan: 'Phương tiện',
            giaTri: _vehicle,
            luaChon: const [
              LuaChon(giaTri: 'Xe máy', nhan: 'Xe máy'),
              LuaChon(giaTri: 'Xe buýt', nhan: 'Xe buýt'),
            ],
            khiThayDoi: (v) => setState(() => _vehicle = v),
          ),
          ChonNgay(
            nhan: 'Ngày dự kiến',
            giaTri: _date,
            khiThayDoi: (v) => setState(() => _date = v),
          ),
        ]),
        _section('05 · Search bar', [
          OTimKiem(khiTimKiem: (v) => setState(() => _search = v)),
          Text('Từ khóa: $_search'),
        ]),
        _section('06 · Chip & tab', [
          Wrap(
            children: [
              ChipLoc(
                nhan: 'Hà Đông',
                daChon: _selected,
                khiChon: (v) => setState(() => _selected = v),
              ),
            ],
          ),
          ThanhChuyenTab(
            danhSach: const [
              CauHinhTab('Điện', bieuTuong: Icons.bolt),
              CauHinhTab('Nước', bieuTuong: Icons.water_drop_outlined),
            ],
            chiSoChon: _tab,
            khiChon: (v) => setState(() => _tab = v),
          ),
        ]),
        _section('07 · Status badge', [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in TrangThaiHienThi.values)
                NhanTrangThai(trangThai: s),
            ],
          ),
        ]),
        _section('08 · Room card', [
          ThePhongTro(
            phong: DuLieuGia.phongTro.first,
            yeuThich: _favorite,
            khiYeuThich: () => setState(() => _favorite = !_favorite),
            khiNhan: () => _feedback('Xem phòng mẫu'),
          ),
          ThePhongTro(phong: DuLieuGia.phongTro.last, kieu: KieuThePhong.doc),
          TheKhuTro(khuTro: DuLieuGia.khuTro),
        ]),
        _section('09 · Invoice card', [
          TheHoaDon(
            hoaDon: DuLieuGia.hoaDon,
            tenNguoiThue: DuLieuGia.nguoiThue.hoTen,
            khiNhan: () => _feedback('Xem hóa đơn mẫu'),
          ),
          for (final k in DuLieuGia.hoaDon.danhSachKhoanThu)
            DongTien(tenKhoanThu: k.ten, soTien: k.soTien),
        ]),
        _section('10 · Meter reading card', [
          for (final c in DuLieuGia.chiSo) TheChiSo(chiSo: c),
        ]),
        _section('11 · Statistics card', [
          const TheThongKe(
            tieuDe: 'Tổng số phòng',
            giaTri: '24',
            bieuTuong: Icons.home_outlined,
          ),
          const TheThongKe(
            tieuDe: 'Doanh thu mẫu',
            giaTri: '92.268.000đ',
            bieuTuong: Icons.bar_chart,
            phanTram: 12,
          ),
        ]),
        _section('12 · Dialog', [
          NutBam(
            nhan: 'Mở hộp thoại',
            khiNhan: () async {
              final result = await HopThoaiXacNhan.hienThi(
                context,
                tieuDe: 'Xác nhận mẫu',
                noiDung: 'Bạn muốn xác nhận thao tác demo?',
              );
              if (mounted) _feedback(result == true ? 'Đã xác nhận' : 'Đã hủy');
            },
          ),
        ]),
        _section('13 · Empty state', [
          TrangThaiRong(
            tieuDe: 'Chưa có kết quả',
            moTa: 'Thử thay đổi bộ lọc tìm kiếm.',
            nhanHanhDong: 'Thử lại',
            khiNhan: () => _feedback('Đã bấm thử lại'),
          ),
        ]),
        _section('14 · Loading state', [
          const HienThiDangTai(thongDiep: 'Đang tải dữ liệu mẫu'),
          const HienThiDangTai(kieu: KieuDangTai.skeleton),
        ]),
        _section('15 · Timeline', [
          DongThoiGian(
            cacBuoc: [
              BuocThoiGian(
                tieuDe: 'Đã gửi mẫu',
                ngayGio: DateTime(2026, 11, 1, 9, 20),
                trangThai: TrangThaiBuoc.hoanThanh,
              ),
              const BuocThoiGian(
                tieuDe: 'Đang xử lý',
                moTa: 'Chờ xác nhận',
                trangThai: TrangThaiBuoc.hienTai,
              ),
              const BuocThoiGian(tieuDe: 'Hoàn tất'),
            ],
          ),
        ]),
        _section('16 · Bottom navigation', [
          const Text('Người thuê'),
          ThanhDieuHuongVaiTro(
            cacMuc: BoCucNguoiThue.cacMuc,
            chiSoChon: _tenant,
            khiChon: (v) => setState(() => _tenant = v),
          ),
          const Text('Chủ trọ'),
          ThanhDieuHuongVaiTro(
            cacMuc: BoCucChuTro.cacMuc,
            chiSoChon: _landlord,
            khiChon: (v) => setState(() => _landlord = v),
          ),
          Text('Tenant: $_tenant · Landlord: $_landlord'),
        ]),
        _section('17 · Contract & transaction', [
          TheHopDong(
            hopDong: DuLieuGia.hopDong,
            maPhong: 'P502B',
            tenNguoiThue: DuLieuGia.nguoiThue.hoTen,
          ),
          TheGiaoDich(
            tenGiaoDich: 'Cọc mẫu · Đang khóa trong Smart Contract',
            soTien: DuLieuGia.tienCoc.soToken,
            ngayGio: DateTime(2026, 10, 1),
            trangThai: TrangThaiHienThi.dangXuLy,
            donVi: DonViTien.mockVNDC,
          ),
        ]),
        _section('18 · Image selection', [
          ChonAnh(
            soAnh: _images.length,
            khiChon: () => setState(() {
              if (_images.length < 5) _images.add('demo-image-placeholder');
            }),
          ),
          LuoiHinhAnh(
            danhSachAnh: _images,
            khiThem: () =>
                setState(() => _images.add('demo-image-placeholder')),
            khiXoa: (i) => setState(() => _images.removeAt(i)),
          ),
        ]),
        _section('19 · Bottom action', [
          NutDuoiManHinh(
            nutChinh: NutBam(
              nhan: 'Lưu mẫu',
              khiNhan: () => _feedback('Lưu mẫu'),
            ),
            nutPhu: NutBam(
              nhan: 'Hủy',
              kieu: KieuNut.phu,
              khiNhan: () => _feedback('Hủy mẫu'),
            ),
          ),
        ]),
      ],
    ),
  );
}
