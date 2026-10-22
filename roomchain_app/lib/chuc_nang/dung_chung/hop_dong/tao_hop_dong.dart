import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'thanh_phan_hop_dong.dart';

class TaoHopDong extends StatefulWidget {
  const TaoHopDong({super.key, this.kho, this.khiMoChiTiet});
  final KhoHopDongMau? kho;
  final ValueChanged<String>? khiMoChiTiet;
  @override
  State<TaoHopDong> createState() => _TaoHopDongState();
}

class _TaoHopDongState extends State<TaoHopDong> {
  final _cacForm = List.generate(3, (_) => GlobalKey<FormState>());
  final _cuon = ScrollController();
  final _nhap = <String, TextEditingController>{
    for (final e in <String, String>{
      'giaThue': '',
      'tienCoc': '',
      'phiDichVu': '300.000',
      'dien': '4.000',
      'nuoc': '30.000',
      'internet': '100.000',
      'khac': '0',
      'tuNgay': '1',
      'denNgay': '5',
      'ghiSo': '28',
      'phuThu': '50.000',
      'noiQuy': '',
    }.entries)
      e.key: TextEditingController(text: e.value),
  };
  int _buoc = 0;
  String? _phongId, _nguoiId, _loi;
  DateTime? _ngayBatDau = DateUtils.dateOnly(DateTime.now());
  DateTime? _ngayKetThuc = DateTime(
    DateTime.now().year + 1,
    DateTime.now().month,
    DateTime.now().day,
  );
  String _ketThucSom = cacDieuKhoanKetThuc[2];
  bool _daSua = false, _xacNhan = false, _choThoat = false;
  HopDong? _daTao;
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;

  @override
  void dispose() {
    for (final c in _nhap.values) {
      c.dispose();
    }
    _cuon.dispose();
    super.dispose();
  }

  int _so(String ten) =>
      int.tryParse(_nhap[ten]!.text.replaceAll('.', '')) ?? 0;
  void _sua() {
    _daSua = true;
    _xacNhan = false;
  }

  void _doiBuoc(int buoc) {
    FocusScope.of(context).unfocus();
    setState(() {
      _buoc = buoc;
      _loi = null;
    });
    if (_cuon.hasClients) _cuon.jumpTo(0);
  }

  HopDong _banNhap() => HopDong(
    id: '',
    maHopDong: '',
    phongId: _phongId ?? '',
    nguoiThueId: _nguoiId ?? '',
    ngayBatDau: _ngayBatDau ?? DateTime(1900),
    ngayKetThuc: _ngayKetThuc ?? DateTime(1900),
    giaThue: _so('giaThue'),
    tienCoc: _so('tienCoc'),
    trangThai: TrangThaiHopDong.choKy,
    cauHinh: CauHinhHopDong(
      phiDichVu: _so('phiDichVu'),
      donGiaDien: _so('dien'),
      donGiaNuoc: _so('nuoc'),
      internet: _so('internet'),
      khoanKhac: _so('khac'),
      ngayGhiSo: _so('ghiSo'),
      thanhToanTu: _so('tuNgay'),
      thanhToanDen: _so('denNgay'),
      phuThuCham: _so('phuThu'),
      ketThucSom: _ketThucSom,
      noiQuy: _nhap['noiQuy']!.text.trim(),
    ),
  );

  String? _kiemTraNgay() {
    if (_ngayBatDau == null || _ngayKetThuc == null) {
      return 'Vui lòng chọn đủ ngày bắt đầu và kết thúc.';
    }
    if (!_ngayKetThuc!.isAfter(_ngayBatDau!)) {
      return 'Ngày kết thúc phải sau ngày bắt đầu.';
    }
    if (_phongId != null &&
        _kho.trungThoiGian(_phongId!, _ngayBatDau!, _ngayKetThuc!)) {
      return 'Phòng đã có hợp đồng trùng thời gian. Vui lòng chọn ngày hoặc phòng khác.';
    }
    return null;
  }

  void _tiepTheo() {
    if (_buoc < 3) {
      final hopLe = _cacForm[_buoc].currentState!.validate();
      final loi = _buoc == 0 ? _kiemTraNgay() : null;
      setState(() => _loi = loi);
      if (!hopLe || loi != null) return;
      _doiBuoc(_buoc + 1);
      return;
    }
    // Kiểm tra lại toàn bộ trước khi thêm vào kho mock.
    if (!_xacNhan) {
      setState(
        () => _loi = 'Vui lòng xác nhận đã kiểm tra thông tin hợp đồng.',
      );
      return;
    }
    final h = _banNhap();
    final loi = _kho.kiemTra(h);
    if (loi != null) {
      setState(() => _loi = loi);
      return;
    }
    try {
      final moi = _kho.them(h);
      setState(() {
        _daTao = moi;
        _buoc = 4;
        _loi = null;
      });
      if (_cuon.hasClients) _cuon.jumpTo(0);
    } on StateError catch (e) {
      setState(() => _loi = e.message.toString());
    }
  }

  Future<void> _thoat({bool luonHoi = false}) async {
    if (_daTao != null) {
      _veDanhSach();
      return;
    }
    if (_daSua || luonHoi) {
      final dongY = await HopThoaiXacNhan.hienThi(
        context,
        tieuDe: 'Hủy tạo hợp đồng?',
        noiDung: 'Thông tin bản nháp sẽ không được lưu.',
      );
      if (!mounted || dongY != true) return;
    }
    _veDanhSach();
  }

  void _veDanhSach() {
    setState(() => _choThoat = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, _daTao);
      } else {
        Navigator.pushReplacementNamed(
          context,
          DieuHuong.danhSachHopDong,
          arguments: _kho,
        );
      }
    });
  }

  void _quayLai() {
    if (_daTao != null) {
      _veDanhSach();
    } else if (_buoc > 0) {
      _doiBuoc(_buoc - 1);
    } else {
      _thoat();
    }
  }

  // Phần nhập tiền: giữ số nguyên VND và định dạng hàng nghìn.
  Widget _tien(
    String ten,
    String nhan, {
    bool batBuoc = false,
    bool lonHonKhong = false,
    String donVi = 'VND',
  }) => ONhapLieu(
    key: ValueKey(ten),
    nhan: nhan,
    batBuoc: batBuoc,
    controller: _nhap[ten],
    kieuBanPhim: TextInputType.number,
    bieuTuongCuoi: Padding(
      padding: const EdgeInsets.all(12),
      child: Text(donVi, style: KieuChu.chuNho),
    ),
    kiemTra: (v) {
      final chu = v?.trim() ?? '';
      if (chu.isEmpty) return batBuoc ? 'Vui lòng nhập $nhan.' : null;
      if (!RegExp(r'^\d{1,3}(\.\d{3})*$').hasMatch(chu)) {
        return 'Chỉ nhập số tiền nguyên không âm.';
      }
      final so = int.tryParse(chu.replaceAll('.', ''));
      if (so == null || so > 999999999999999) return 'Số tiền quá lớn.';
      if (lonHonKhong && so <= 0) return 'Giá thuê phải lớn hơn 0.';
      return null;
    },
    khiThayDoi: (v) {
      _sua();
      if (!RegExp(r'^[0-9.]*$').hasMatch(v)) return;
      final chu = v.replaceAll('.', '');
      if (chu.isEmpty || chu.length > 15) return;
      final so = int.tryParse(chu);
      if (so == null) return;
      final dep = dinhDangVND(so).replaceAll('đ', '');
      _nhap[ten]!.value = TextEditingValue(
        text: dep,
        selection: TextSelection.collapsed(offset: dep.length),
      );
    },
  );

  Widget _ngayTrongThang(String ten, String nhan) => ONhapLieu(
    key: ValueKey(ten),
    nhan: nhan,
    controller: _nhap[ten],
    kieuBanPhim: TextInputType.number,
    khiThayDoi: (_) {
      _sua();
    },
    kiemTra: (v) {
      final n = int.tryParse(v ?? '');
      if (n == null || n < 1 || n > 28) return 'Nhập ngày từ 1 đến 28.';
      if (ten == 'denNgay' && n < _so('tuNgay')) {
        return 'Phải từ ngày bắt đầu trở đi.';
      }
      return null;
    },
  );

  Widget _cap(Widget trai, Widget phai) => LayoutBuilder(
    builder: (context, c) {
      if (c.maxWidth < 320 || MediaQuery.textScalerOf(context).scale(14) > 18) {
        return Column(children: [trai, const SizedBox(height: 16), phai]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: trai),
          const SizedBox(width: 12),
          Expanded(child: phai),
        ],
      );
    },
  );

  Widget _tieuDe(String chu) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 16),
    child: Text(chu, style: KieuChu.noiDungDam.copyWith(fontSize: 16)),
  );

  // Bước 1: thông tin cơ bản và chi phí của phòng.
  Widget _thongTin() => Form(
    key: _cacForm[0],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tieuDe('Thông tin cơ bản'),
        _OChonMinhHoa(
          nhan: 'Phòng cho thuê *',
          giaTri: _phongId,
          bieuTuong: Icons.meeting_room_outlined,
          luaChon: [
            for (final p in _kho.phongTro.where(
              (p) => p.trangThai == TrangThaiPhong.conTrong,
            ))
              _DoiTuong(
                p.id,
                p.maPhong,
                '${p.dienTich.toStringAsFixed(0)}m² · Còn trống · ${p.tenKhuTro}',
              ),
          ],
          khiChon: (id) => setState(() {
            _phongId = id;
            final p = _kho.phong(id);
            _nhap['giaThue']!.text = dinhDangVND(p.giaThue).replaceAll('đ', '');
            _nhap['tienCoc']!.text = dinhDangVND(p.tienCoc).replaceAll('đ', '');
            _sua();
            _loi = null;
          }),
        ),
        const SizedBox(height: 18),
        _OChonMinhHoa(
          nhan: 'Người thuê *',
          giaTri: _nguoiId,
          bieuTuong: Icons.person_outline,
          luaChon: [
            for (final n in _kho.nguoiThue)
              _DoiTuong(n.id, n.hoTen, n.soDienThoai),
          ],
          khiChon: (id) => setState(() {
            _nguoiId = id;
            _sua();
          }),
        ),
        _tieuDe('Thời hạn hợp đồng'),
        _cap(
          ChonNgay(
            key: const ValueKey('ngayBatDau'),
            nhan: 'Ngày bắt đầu *',
            giaTri: _ngayBatDau,
            khiThayDoi: (ngay) => setState(() {
              _ngayBatDau = ngay;
              _sua();
              _loi = null;
            }),
          ),
          ChonNgay(
            key: const ValueKey('ngayKetThuc'),
            nhan: 'Ngày kết thúc *',
            giaTri: _ngayKetThuc,
            khiThayDoi: (ngay) => setState(() {
              _ngayKetThuc = ngay;
              _sua();
              _loi = null;
            }),
          ),
        ),
        _tieuDe('Thông tin chi phí'),
        _cap(
          _tien(
            'giaThue',
            'Giá thuê hàng tháng',
            batBuoc: true,
            lonHonKhong: true,
          ),
          _tien('tienCoc', 'Tiền cọc', batBuoc: true),
        ),
        const SizedBox(height: 18),
        _tien('phiDichVu', 'Phí dịch vụ (nếu có)'),
        const SizedBox(height: 6),
        const Text(
          'Phí dịch vụ cố định. Điện, nước và Internet được cấu hình riêng, không tính trùng.',
          style: KieuChu.chuNho,
        ),
      ],
    ),
  );

  // Bước 2: điều khoản được hai bên thỏa thuận.
  Widget _dieuKhoan() => Form(
    key: _cacForm[1],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tieuDe('Điều khoản hợp đồng'),
        _cap(
          _ngayTrongThang('tuNgay', 'Thanh toán từ ngày'),
          _ngayTrongThang('denNgay', 'Đến hết ngày'),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder(
          valueListenable: _nhap['tuNgay']!,
          builder: (context, _, _) => ValueListenableBuilder(
            valueListenable: _nhap['denNgay']!,
            builder: (context, _, _) => Text(
              'Thời hạn thanh toán từ ngày ${_nhap['tuNgay']!.text.padLeft(2, '0')} đến hết ngày ${_nhap['denNgay']!.text.padLeft(2, '0')} hàng tháng.',
              style: KieuChu.chuPhu,
            ),
          ),
        ),
        const SizedBox(height: 18),
        _tien('phuThu', 'Phụ thu trả chậm dự kiến', donVi: 'VND/ngày'),
        const SizedBox(height: 8),
        const Text(luuYPhuThu, style: KieuChu.chuPhu),
        _tieuDe('Kết thúc hợp đồng trước hạn'),
        OChon<String>(
          nhan: 'Chính sách đã thỏa thuận',
          giaTri: _ketThucSom,
          luaChon: [
            for (final c in cacDieuKhoanKetThuc) LuaChon(giaTri: c, nhan: c),
          ],
          khiThayDoi: (v) {
            if (v != null) {
              setState(() {
                _ketThucSom = v;
                _sua();
              });
            }
          },
        ),
        const SizedBox(height: 8),
        Text(_ketThucSom, style: KieuChu.chuPhu),
        _tieuDe('Điều khoản hoàn cọc'),
        const Text(dieuKhoanHoanCoc, style: KieuChu.chuPhu),
        _tieuDe('Quy định chung'),
        ONhapLieu(
          key: const ValueKey('noiQuy'),
          nhan: 'Nội quy bổ sung',
          controller: _nhap['noiQuy'],
          soDong: 4,
          khiThayDoi: (_) {
            _sua();
          },
        ),
      ],
    ),
  );

  // Bước 3: các khoản thu hàng tháng, không tạo hóa đơn tại đây.
  Widget _chiPhi() => Form(
    key: _cacForm[2],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tieuDe('Chi phí hàng tháng'),
        _tien(
          'giaThue',
          'Tiền phòng hàng tháng',
          batBuoc: true,
          lonHonKhong: true,
        ),
        const SizedBox(height: 18),
        _cap(
          _tien('dien', 'Đơn giá điện', donVi: 'VND/kWh'),
          _tien('nuoc', 'Đơn giá nước', donVi: 'VND/m³'),
        ),
        const SizedBox(height: 18),
        _tien('internet', 'Internet hàng tháng'),
        const SizedBox(height: 18),
        _tien('phiDichVu', 'Phí dịch vụ cố định'),
        const SizedBox(height: 18),
        _tien('khac', 'Các khoản khác'),
        const SizedBox(height: 18),
        _ngayTrongThang('ghiSo', 'Ngày ghi số điện nước'),
        const SizedBox(height: 12),
        Text(
          'Thanh toán từ ngày ${_so('tuNgay')} đến hết ngày ${_so('denNgay')} hàng tháng.',
          style: KieuChu.chuPhu,
        ),
        const SizedBox(height: 8),
        const Text(
          'Điện, nước tính theo lượng sử dụng thực tế; phí dịch vụ và Internet là khoản riêng.',
          style: KieuChu.chuPhu,
        ),
      ],
    ),
  );

  Widget _nhomXemLai(String tieuDe, int buoc, List<Widget> noiDung) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            Text(tieuDe, style: KieuChu.noiDungDam),
            TextButton(
              onPressed: () {
                _xacNhan = false;
                _doiBuoc(buoc);
              },
              child: const Text('Chỉnh sửa'),
            ),
          ],
        ),
        ...noiDung,
        const Divider(),
      ],
    ),
  );

  // Bước 4: xem lại toàn bộ bản nháp.
  Widget _xemLai() {
    final h = _banNhap();
    final c = h.cauHinh;
    final p = _kho.phong(h.phongId);
    final n = _kho.nguoi(h.nguoiThueId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tieuDe('Kiểm tra hợp đồng'),
        _nhomXemLai('Phòng và người thuê', 0, [
          DongThongTin(nhan: 'Khu trọ', giaTri: p.tenKhuTro),
          DongThongTin(
            nhan: 'Phòng / Diện tích',
            giaTri: '${p.maPhong} / ${p.dienTich.toStringAsFixed(0)}m²',
          ),
          DongThongTin(nhan: 'Người thuê', giaTri: n.hoTen),
          DongThongTin(nhan: 'Điện thoại', giaTri: n.soDienThoai),
          DongThongTin(nhan: 'Bắt đầu', giaTri: dinhDangNgay(h.ngayBatDau)),
          DongThongTin(nhan: 'Kết thúc', giaTri: dinhDangNgay(h.ngayKetThuc)),
          DongThongTin(nhan: 'Tiền cọc (VND)', giaTri: dinhDangVND(h.tienCoc)),
        ]),
        _nhomXemLai('Thông tin tài chính', 2, [
          DongThongTin(
            nhan: 'Tiền phòng / tháng',
            giaTri: dinhDangVND(h.giaThue),
          ),
          DongThongTin(
            nhan: 'Dịch vụ cố định',
            giaTri: dinhDangVND(c.phiDichVu),
          ),
          DongThongTin(nhan: 'Điện / kWh', giaTri: dinhDangVND(c.donGiaDien)),
          DongThongTin(nhan: 'Nước / m³', giaTri: dinhDangVND(c.donGiaNuoc)),
          DongThongTin(
            nhan: 'Internet / tháng',
            giaTri: dinhDangVND(c.internet),
          ),
          DongThongTin(
            nhan: 'Khoản khác / tháng',
            giaTri: dinhDangVND(c.khoanKhac),
          ),
          DongThongTin(
            nhan: 'Ngày ghi số',
            giaTri: 'Ngày ${c.ngayGhiSo} hàng tháng',
          ),
        ]),
        _nhomXemLai('Điều khoản', 1, [
          DongThongTin(
            nhan: 'Hạn thanh toán',
            giaTri: 'Ngày ${c.thanhToanTu}–${c.thanhToanDen} hàng tháng',
          ),
          DongThongTin(
            nhan: 'Phụ thu dự kiến',
            giaTri: '${dinhDangVND(c.phuThuCham)}/ngày',
          ),
          const Text(luuYPhuThu, style: KieuChu.chuPhu),
          const SizedBox(height: 12),
          Text(c.ketThucSom),
          const SizedBox(height: 12),
          const Text(dieuKhoanHoanCoc, style: KieuChu.chuPhu),
          const SizedBox(height: 12),
          Text('Nội quy: ${c.noiQuy.isEmpty ? 'Không bổ sung' : c.noiQuy}'),
        ]),
        CheckboxListTile(
          key: const ValueKey('xacNhan'),
          value: _xacNhan,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'Tôi xác nhận các thông tin hợp đồng đã được kiểm tra.',
          ),
          onChanged: (v) => setState(() {
            _xacNhan = v ?? false;
            _loi = null;
          }),
        ),
      ],
    );
  }

  // Bước 5: kết quả chỉ được lưu trong phiên demo Frontend.
  Widget _hoanTat() {
    final h = _daTao!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle_outline, size: 72, color: BangMau.chinh),
        const SizedBox(height: 16),
        const Text(
          'Tạo hợp đồng thành công',
          textAlign: TextAlign.center,
          style: KieuChu.tieuDeTrang,
        ),
        const SizedBox(height: 12),
        const Text(
          'Hợp đồng đã được tạo ở trạng thái chờ ký.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Dữ liệu demo được lưu trong bộ nhớ của phiên chạy.',
          textAlign: TextAlign.center,
          style: KieuChu.chuPhu,
        ),
        const SizedBox(height: 24),
        DongThongTin(nhan: 'Mã hợp đồng', giaTri: h.maHopDong),
        DongThongTin(nhan: 'Phòng', giaTri: _kho.phong(h.phongId).maPhong),
        DongThongTin(
          nhan: 'Người thuê',
          giaTri: _kho.nguoi(h.nguoiThueId).hoTen,
        ),
        DongThongTin(nhan: 'Bắt đầu', giaTri: dinhDangNgay(h.ngayBatDau)),
        DongThongTin(nhan: 'Kết thúc', giaTri: dinhDangNgay(h.ngayKetThuc)),
        Align(
          alignment: Alignment.centerRight,
          child: NhanHopDong(trangThai: h.trangThai),
        ),
        const SizedBox(height: 24),
        NutBam(
          nhan: 'Xem hợp đồng',
          kieu: KieuNut.phu,
          khiNhan: () {
            if (widget.khiMoChiTiet != null) {
              widget.khiMoChiTiet!(h.id);
            } else {
              Navigator.pushNamed(
                context,
                DieuHuong.xemTruocHopDong,
                arguments: ThamSoHopDong(hopDongId: h.id, kho: _kho),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _cacNut() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
    child: _buoc == 4
        ? NutBam(nhan: 'Về danh sách hợp đồng', khiNhan: _veDanhSach)
        : Row(
            children: [
              Expanded(
                child: NutBam(
                  nhan: _buoc == 0 ? 'Hủy' : 'Quay lại',
                  kieu: KieuNut.phu,
                  khiNhan: _buoc == 0 ? () => _thoat(luonHoi: true) : _quayLai,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: NutBam(
                  nhan: _buoc == 3 ? 'Tạo hợp đồng' : 'Tiếp theo',
                  bieuTuong: _buoc == 3 ? null : Icons.arrow_forward,
                  khiNhan: _tiepTheo,
                ),
              ),
            ],
          ),
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _choThoat,
    onPopInvokedWithResult: (daPop, _) {
      if (!daPop) _quayLai();
    },
    child: Scaffold(
      backgroundColor: BangMau.nenThe,
      appBar: AppBar(
        title: Text(
          'Tạo hợp đồng',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: NutBieuTuong(
          bieuTuong: Icons.arrow_back_ios_new,
          goiY: 'Quay lại',
          khiNhan: _quayLai,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ThanhTienTrinhHopDong(buoc: _buoc),
            Expanded(
              child: SingleChildScrollView(
                controller: _cuon,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    switch (_buoc) {
                      0 => _thongTin(),
                      1 => _dieuKhoan(),
                      2 => _chiPhi(),
                      3 => _xemLai(),
                      _ => _hoanTat(),
                    },
                    if (_loi != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _loi!,
                            style: KieuChu.chuPhu.copyWith(color: BangMau.loi),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _cacNut(),
          ],
        ),
      ),
    ),
  );
}

class _ThanhTienTrinhHopDong extends StatelessWidget {
  const _ThanhTienTrinhHopDong({required this.buoc});
  final int buoc;
  static const _nhan = [
    'Thông tin',
    'Điều khoản',
    'Chi phí',
    'Xem lại',
    'Hoàn tất',
  ];
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    child: Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0)
                Expanded(
                  child: Divider(
                    color: i <= buoc ? BangMau.chinh : BangMau.vien,
                    thickness: 2,
                  ),
                ),
              Semantics(
                label: 'Bước ${i + 1}: ${_nhan[i]}',
                selected: i == buoc,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: i <= buoc ? BangMau.chinh : BangMau.nen,
                  child: i < buoc
                      ? const Icon(Icons.check, size: 18, color: BangMau.nenThe)
                      : Text(
                          '${i + 1}',
                          style: KieuChu.nhan.copyWith(
                            color: i == buoc ? BangMau.nenThe : BangMau.chuPhu,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final nhan in _nhan)
              Expanded(
                child: Text(
                  nhan,
                  textAlign: TextAlign.center,
                  style: KieuChu.chuNho,
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

class _DoiTuong {
  const _DoiTuong(this.id, this.ten, this.moTa);
  final String id, ten, moTa;
}

class _OChonMinhHoa extends StatelessWidget {
  const _OChonMinhHoa({
    required this.nhan,
    required this.giaTri,
    required this.bieuTuong,
    required this.luaChon,
    required this.khiChon,
  });
  final String nhan;
  final String? giaTri;
  final IconData bieuTuong;
  final List<_DoiTuong> luaChon;
  final ValueChanged<String> khiChon;
  @override
  Widget build(BuildContext context) {
    final chon = luaChon.where((p) => p.id == giaTri).firstOrNull;
    return FormField<String>(
      key: ValueKey('$nhan$giaTri'),
      initialValue: giaTri,
      validator: (v) => v == null
          ? 'Vui lòng chọn ${nhan.replaceAll(' *', '').toLowerCase()}.'
          : null,
      builder: (field) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final id = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            builder: (context) => SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .7,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        nhan.replaceAll(' *', ''),
                        style: KieuChu.tieuDeMuc,
                      ),
                    ),
                    for (final p in luaChon)
                      ListTile(
                        leading: Icon(bieuTuong, color: BangMau.chinh),
                        title: Text(p.ten),
                        subtitle: Text(p.moTa),
                        trailing: p.id == giaTri
                            ? const Icon(Icons.check, color: BangMau.chinh)
                            : null,
                        onTap: () => Navigator.pop(context, p.id),
                      ),
                    if (luaChon.isEmpty)
                      const ListTile(title: Text('Không có lựa chọn phù hợp')),
                  ],
                ),
              ),
            ),
          );
          if (id != null && context.mounted) {
            field.didChange(id);
            khiChon(id);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: nhan,
            errorText: field.errorText,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BangMau.chinhNhat,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(bieuTuong, color: BangMau.chinh),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chon?.ten ??
                          'Chọn ${nhan.replaceAll(' *', '').toLowerCase()}',
                      style: KieuChu.noiDungDam,
                    ),
                    if (chon != null) Text(chon.moTa, style: KieuChu.chuNho),
                  ],
                ),
              ),
              const Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
    );
  }
}
