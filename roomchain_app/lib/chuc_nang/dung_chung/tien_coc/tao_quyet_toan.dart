import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/mo_hinh/quyet_toan_tien_coc.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'anh_bang_chung.dart';
import 'thanh_phan_tien_coc.dart';

class TaoQuyetToan extends StatefulWidget {
  const TaoQuyetToan({
    super.key,
    this.hopDongId,
    this.kho,
    this.dichVuAnh = const DichVuAnhBangChung(),
  });
  final String? hopDongId;
  final KhoHopDongMau? kho;
  final DichVuAnhBangChung dichVuAnh;
  @override
  State<TaoQuyetToan> createState() => _TaoQuyetToanState();
}

class _TaoQuyetToanState extends State<TaoQuyetToan> {
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;
  final _form = GlobalKey<FormState>();
  final _loiKey = GlobalKey();
  final _cuon = ScrollController();
  final _khoan = <_KhoanNhap>[];
  final _anh = <BangChungKhauTru>[];
  String? _id, _loi;
  int _thuTu = 0, _lanChon = 0;
  bool _xacNhan = false,
      _dangChonAnh = false,
      _dangGui = false,
      _daSua = false,
      _choThoat = false;
  HopDong? get _hopDong => _id == null ? null : _kho.theoId(_id!);
  QuyetToanTienCoc? get _ketQua => _hopDong?.quyetToan;
  @override
  void initState() {
    super.initState();
    _id = widget.hopDongId;
    _khoan.add(_KhoanNhap(++_thuTu));
  }

  @override
  void dispose() {
    for (final k in _khoan) {
      k.dispose();
    }
    _cuon.dispose();
    super.dispose();
  }

  void _sua() {
    _daSua = true;
    _xacNhan = false;
    _loi = null;
  }

  void _baoLoi(String chu) {
    setState(() => _loi = chu);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _loiKey.currentContext != null) {
        Scrollable.ensureVisible(
          _loiKey.currentContext!,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  bool get _soHopLe => _khoan.every((k) => k.soTien != null);
  int get _tong => _khoan.fold(0, (t, k) => t + (k.soTien ?? 0));

  Future<void> _doiHopDong(String? id) async {
    if (id == null || id == _id) return;
    if (_daSua) {
      final ok = await HopThoaiXacNhan.hienThi(
        context,
        tieuDe: 'Đổi hợp đồng?',
        noiDung: 'Các khoản khấu trừ và ảnh trong bản nháp hiện tại sẽ được xóa để tránh áp dụng nhầm hợp đồng.',
      );
      if (!mounted) return;
      if (ok != true) {
        setState(() => _lanChon++);
        return;
      }
    }
    setState(() {
      _id = id;
      _lanChon++;
      _anh.clear();
      for (final k in _khoan) {
        k.dispose();
      }
      _khoan
        ..clear()
        ..add(_KhoanNhap(++_thuTu));
      _daSua = false;
      _xacNhan = false;
      _loi = null;
    });
  }

  Future<void> _themAnh() async {
    if (_dangChonAnh || _anh.length >= 5 || _dangGui) return;
    setState(() => _dangChonAnh = true);
    try {
      final moi = await widget.dichVuAnh.chon();
      if (!mounted) return;
      final cacId = _anh.map((a) => a.id).toSet();
      final boSung = moi.where((a) => cacId.add(a.id)).toList();
      if (_anh.length + boSung.length > 5) {
        _baoLoi('Tối đa 5 ảnh. Vui lòng chọn ít ảnh hơn.');
        return;
      }
      setState(() {
        if (boSung.isNotEmpty) {
          _sua();
          _anh.addAll(boSung);
        }
      });
    } catch (e) {
      if (mounted) {
        _baoLoi(
          e is FormatException
              ? e.message
              : 'Không thể chọn ảnh trên thiết bị này. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _dangChonAnh = false);
    }
  }

  Future<void> _gui() async {
    if (_dangGui || _dangChonAnh || _ketQua != null) return;
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final h = _hopDong;
    if (h == null) {
      _baoLoi('Vui lòng chọn hợp đồng hợp lệ.');
      return;
    }
    final cacKhoan = [
      for (final k in _khoan)
        KhoanKhauTru(
          id: 'K${k.id}',
          soTien: k.soTien!,
          lyDo: k.lyDo.text.trim(),
        ),
    ];
    final loi = _kho.kiemTraQuyetToan(h.id, cacKhoan, _anh);
    if (loi != null) {
      _baoLoi(loi);
      return;
    }
    if (!_xacNhan) {
      _baoLoi(
        'Vui lòng xác nhận các khoản khấu trừ và bằng chứng trước khi gửi.',
      );
      return;
    }
    setState(() => _dangGui = true);
    final ok = await HopThoaiXacNhan.hienThi(
      context,
      tieuDe: 'Gửi người thuê xác nhận?',
      noiDung:
          'Hợp đồng ${h.maHopDong}\nKhấu trừ: ${dinhDangVND(_tong)}\nHoàn dự kiến: ${dinhDangVND(h.tienCoc - _tong)}\n\nChỉ tạo bản quyết toán demo chờ người thuê. Token vẫn được giữ trong escrow, chưa hoàn tiền hoặc phân chia.',
    );
    if (!mounted) return;
    if (ok == true) {
      try {
        _kho.guiQuyetToan(
          hopDongId: h.id,
          cacKhoan: cacKhoan,
          bangChung: _anh,
          chuTroDaXacNhan: _xacNhan,
        );
        if (mounted) {
          setState(() {
            _daSua = false;
            _loi = null;
          });
          if (_cuon.hasClients) _cuon.jumpTo(0);
        }
      } on StateError catch (e) {
        if (mounted) _baoLoi(e.message.toString());
      }
    }
    if (mounted) setState(() => _dangGui = false);
  }

  Future<void> _quayLai() async {
    if (_dangGui || _dangChonAnh) return;
    if (_daSua && _ketQua == null) {
      final ok = await HopThoaiXacNhan.hienThi(
        context,
        tieuDe: 'Hủy bản nháp quyết toán?',
        noiDung: 'Các khoản khấu trừ và ảnh chưa gửi sẽ không được lưu.',
      );
      if (!mounted || ok != true) return;
    }
    setState(() => _choThoat = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, _ketQua);
      } else {
        Navigator.pushReplacementNamed(
          context,
          DieuHuong.quanLyTienCoc,
          arguments: _kho,
        );
      }
    });
  }

  Widget _tieuDe(String chu) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 12),
    child: Text(chu, style: KieuChu.noiDungDam.copyWith(fontSize: 16)),
  );
  Widget _motKhoan(_KhoanNhap k, int i) => Column(
    key: ValueKey('khoan_${k.id}'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_khoan.length > 1)
        Row(
          children: [
            Expanded(child: Text('Khoản ${i + 1}', style: KieuChu.nhan)),
            NutBieuTuong(
              bieuTuong: Icons.delete_outline,
              goiY: 'Xóa khoản ${i + 1}',
              khiNhan: _dangGui
                  ? null
                  : () => setState(() {
                      _khoan.remove(k);
                      k.dispose();
                      _sua();
                    }),
            ),
          ],
        ),
      ONhapLieu(
        key: ValueKey('soTien_${k.id}'),
        nhan: 'Số tiền khấu trừ',
        batBuoc: true,
        controller: k.tien,
        choPhep: !_dangGui,
        kieuBanPhim: TextInputType.number,
        bieuTuongCuoi: const Padding(
          padding: EdgeInsets.all(14),
          child: Text('VND', style: KieuChu.chuNho),
        ),
        kiemTra: (_) => k.soTien == null
            ? 'Nhập số nguyên không âm, tối đa 15 chữ số.'
            : null,
        khiThayDoi: (v) => setState(() {
          _sua();
          if (RegExp(r'^[0-9.]+$').hasMatch(v) &&
              v.replaceAll('.', '').length <= 15) {
            final so = int.tryParse(v.replaceAll('.', ''));
            if (so != null) {
              final dep = soTienKhongDonVi(so);
              k.tien.value = TextEditingValue(
                text: dep,
                selection: TextSelection.collapsed(offset: dep.length),
              );
            }
          }
        }),
      ),
      const SizedBox(height: 16),
      ONhapLieu(
        key: ValueKey('lyDo_${k.id}'),
        nhan: 'Lý do khấu trừ',
        batBuoc: (k.soTien ?? 0) > 0,
        controller: k.lyDo,
        choPhep: !_dangGui,
        soDong: 2,
        kiemTra: (v) => (v?.length ?? 0) > 500
            ? 'Tối đa 500 ký tự.'
            : ((k.soTien ?? 0) > 0 && (v?.trim().isEmpty ?? true)
                  ? 'Vui lòng nhập lý do khấu trừ.'
                  : null),
        khiThayDoi: (_) => setState(_sua),
      ),
      const SizedBox(height: 12),
    ],
  );

  Widget _bangChung({bool chiXem = false, List<BangChungKhauTru>? anhDaGui}) {
    final ds = anhDaGui ?? _anh;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ds.isEmpty)
          const Text(
            'Chưa có ảnh. Có khấu trừ cần ít nhất một ảnh bằng chứng; hoàn đủ cọc có thể không cần ảnh.',
            style: KieuChu.chuPhu,
          ),
        if (ds.isNotEmpty)
          LayoutBuilder(
            builder: (context, c) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: (c.maxWidth / 100).floor().clamp(1, 5),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                for (final a in ds)
                  AnhBangChung(
                    key: ValueKey(a.id),
                    anh: a,
                    khiXoa: chiXem || _dangGui
                        ? null
                        : () => setState(() {
                            _anh.remove(a);
                            _sua();
                          }),
                  ),
              ],
            ),
          ),
        if (!chiXem && ds.length < 5)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: NutBam(
              nhan: 'Thêm ảnh (${ds.length}/5)',
              bieuTuong: Icons.add_photo_alternate_outlined,
              kieu: KieuNut.phu,
              khiNhan: _themAnh,
              dangTai: _dangChonAnh,
              voHieuHoa: _dangGui,
            ),
          ),
        const SizedBox(height: 6),
        const Text(
          'JPEG, PNG, WebP · Tối đa 5 ảnh, 5 MB/ảnh · Chỉ lưu trong phiên demo.',
          style: KieuChu.chuNho,
        ),
      ],
    );
  }

  Widget _tongKet(int coc, int khauTru, {bool hopLe = true}) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _tieuDe('Tổng kết'),
      DongThongTin(nhan: 'Tiền cọc ban đầu (VND)', giaTri: dinhDangVND(coc)),
      _dongTien(
        'Tổng khấu trừ',
        hopLe ? dinhDangVND(khauTru) : 'Chưa hợp lệ',
        BangMau.loi,
      ),
      const Divider(),
      _dongTien(
        'Số tiền dự kiến hoàn trả cho người thuê',
        hopLe ? dinhDangVND(coc - khauTru) : 'Chưa tính',
        coc >= khauTru ? BangMau.chinh : BangMau.loi,
      ),
      const SizedBox(height: 10),
      const Text(
        'Biên bản tính bằng VND. Token sẽ được phân chia theo quy ước demo sau khi người thuê xác nhận và đủ điều kiện; chưa có giao dịch Blockchain.',
        style: KieuChu.chuNho,
      ),
    ],
  );
  Widget _dongTien(String nhan, String tien, Color mau) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: Text(nhan, style: KieuChu.chuPhu)),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            tien,
            textAlign: TextAlign.right,
            style: KieuChu.noiDungDam.copyWith(color: mau),
          ),
        ),
      ],
    ),
  );

  Widget _formNhap() {
    final h = _hopDong;
    final luaChon = _kho.danhSach
        .where(
          (p) => _kho.lyDoChuaDuDieuKienQuyetToan(p.id) == null || p.id == _id,
        )
        .toList();
    final loiDieuKien = _id == null
        ? null
        : _kho.lyDoChuaDuDieuKienQuyetToan(_id!);
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tieuDe('Thông tin hợp đồng'),
          OChon<String>(
            key: ValueKey('chonHopDong_$_lanChon'),
            nhan: 'Hợp đồng *',
            giaTri: h == null ? null : _id,
            luaChon: [
              for (final p in luaChon)
                LuaChon(
                  giaTri: p.id,
                  nhan:
                      '${p.maHopDong} – ${_kho.nguoi(p.nguoiThueId).hoTen} (${_kho.phong(p.phongId).maPhong})',
                ),
            ],
            khiThayDoi: _dangGui || widget.hopDongId != null
                ? null
                : _doiHopDong,
            kiemTra: (v) =>
                v == null ? 'Vui lòng chọn hợp đồng đủ điều kiện.' : null,
          ),
          if (luaChon.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: ThongBaoNoiDung(
                noiDung: 'Chưa có hợp đồng đủ điều kiện quyết toán.',
              ),
            ),
          if (h != null) ...[
            DongThongTin(
              nhan: 'Người thuê',
              giaTri: _kho.nguoi(h.nguoiThueId).hoTen,
            ),
            DongThongTin(nhan: 'Hết hạn', giaTri: dinhDangNgay(h.ngayKetThuc)),
            if (h.coc != null)
              Align(
                alignment: Alignment.centerLeft,
                child: NhanTienCoc(trangThai: h.coc!.trangThai),
              ),
            if (h.thoaThuanKetThucSom != null &&
                h.ngayKetThuc.isAfter(DateTime.now())) ...[
              const SizedBox(height: 12),
              ThongBaoNoiDung(
                noiDung:
                    'Kết thúc sớm theo thỏa thuận hai bên: ${h.thoaThuanKetThucSom!.noiDung}\nKhấu trừ đã thống nhất: ${dinhDangVND(h.thoaThuanKetThucSom!.khauTruDaThongNhat)}.',
              ),
            ],
          ],
          if (loiDieuKien != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ThongBaoNoiDung(
                noiDung: loiDieuKien,
                loai: LoaiThongBao.canhBao,
              ),
            ),
          _tieuDe('Các khoản khấu trừ'),
          for (var i = 0; i < _khoan.length; i++) _motKhoan(_khoan[i], i),
          if (_khoan.length < 10)
            TextButton.icon(
              onPressed: _dangGui
                  ? null
                  : () => setState(() {
                      _khoan.add(_KhoanNhap(++_thuTu));
                      _sua();
                    }),
              icon: const Icon(Icons.add),
              label: const Text('Thêm khoản khấu trừ'),
            ),
          _tieuDe('Bằng chứng (hình ảnh)'),
          _bangChung(),
          _tongKet(h?.tienCoc ?? 0, _tong, hopLe: _soHopLe),
          CheckboxListTile(
            key: const ValueKey('xacNhanQuyetToan'),
            value: _xacNhan,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Tôi xác nhận thông tin, các khoản khấu trừ và bằng chứng là đúng để gửi người thuê kiểm tra.',
            ),
            onChanged: _dangGui
                ? null
                : (v) => setState(() {
                    _xacNhan = v ?? false;
                    _daSua = true;
                    _loi = null;
                  }),
          ),
          if (_loi != null)
            Padding(
              key: _loiKey,
              padding: const EdgeInsets.only(top: 12),
              child: Semantics(
                liveRegion: true,
                child: ThongBaoNoiDung(noiDung: _loi!, loai: LoaiThongBao.loi),
              ),
            ),
        ],
      ),
    );
  }

  Widget _daGui(QuyetToanTienCoc q) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _tieuDe(switch (q.trangThai) {
        TrangThaiQuyetToan.choNguoiThueXacNhan => 'Chờ người thuê xác nhận',
        TrangThaiQuyetToan.daXacNhan => 'Đã xác nhận, chờ giải ngân',
        TrangThaiQuyetToan.daGiaiNgan =>
          q.daHoanTat ? 'Đã giải ngân (dữ liệu demo)' : 'Chờ dữ liệu giao dịch',
      }),
      ThongBaoNoiDung(
        noiDung: switch (q.trangThai) {
          TrangThaiQuyetToan.choNguoiThueXacNhan => 'Đã lưu bản quyết toán trong phiên demo. Chưa chuyển token, hoàn tiền hoặc ghi nhận doanh thu. Màn hình T18 để người thuê xác nhận chưa được triển khai.',
          TrangThaiQuyetToan.daXacNhan => 'Bản ghi demo đã được xác nhận, chưa giải ngân. Thao tác xem không chuyển token.',
          TrangThaiQuyetToan.daGiaiNgan =>
            q.daHoanTat
                ? 'Đây là bản ghi giải ngân mẫu đã có trong dữ liệu demo, không phải giao dịch vừa thực hiện.'
                : 'Chưa đủ biên nhận thành công để kết luận đã giải ngân.',
        },
      ),
      const SizedBox(height: 12),
      NutBam(
        nhan: 'Xem kết quả quyết toán',
        kieu: KieuNut.phu,
        khiNhan: () => Navigator.pushNamed(
          context,
          DieuHuong.ketQuaQuyetToan,
          arguments: ThamSoQuyetToan(quyetToanId: q.id, kho: _kho),
        ),
      ),
      DongThongTin(nhan: 'Mã quyết toán', giaTri: q.maQuyetToan),
      DongThongTin(nhan: 'Hợp đồng', giaTri: _hopDong!.maHopDong),
      DongThongTin(
        nhan: 'Chủ trọ xác nhận',
        giaTri: q.chuTroXacNhanLuc == null
            ? 'Chưa xác nhận'
            : dinhDangNgayGio(q.chuTroXacNhanLuc!),
      ),
      DongThongTin(
        nhan: 'Người thuê',
        giaTri: q.nguoiThueXacNhanLuc == null
            ? 'Chưa xác nhận'
            : dinhDangNgayGio(q.nguoiThueXacNhanLuc!),
      ),
      _tieuDe('Các khoản đã gửi'),
      for (final k in q.cacKhoan)
        DongThongTin(
          nhan: k.lyDo.isEmpty ? 'Hoàn đủ cọc' : k.lyDo,
          giaTri: dinhDangVND(k.soTien),
        ),
      _tongKet(q.tienCocBanDau, q.tongKhauTru),
      _tieuDe('Bằng chứng đã gửi'),
      _bangChung(chiXem: true, anhDaGui: q.bangChung),
    ],
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _choThoat,
    onPopInvokedWithResult: (daPop, _) {
      if (!daPop) _quayLai();
    },
    child: ListenableBuilder(
      listenable: _kho,
      builder: (context, _) {
        final q = _ketQua;
        return Scaffold(
          backgroundColor: BangMau.nenThe,
          appBar: AppBar(
            title: Text(
              'Tạo quyết toán',
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
                Expanded(
                  child: SingleChildScrollView(
                    controller: _cuon,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: q == null
                        ? AbsorbPointer(
                            absorbing: _dangChonAnh || _dangGui,
                            child: _formNhap(),
                          )
                        : _daGui(q),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: q == null
                      ? NutBam(
                          nhan: 'Gửi người thuê xác nhận',
                          bieuTuong: Icons.send_outlined,
                          khiNhan: _gui,
                          voHieuHoa: _dangGui || _dangChonAnh,
                        )
                      : NutBam(
                          nhan: 'Về quản lý tiền cọc',
                          khiNhan: () {
                            setState(() => _choThoat = true);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  DieuHuong.quanLyTienCoc,
                                  arguments: _kho,
                                );
                              }
                            });
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _KhoanNhap {
  _KhoanNhap(this.id);
  final int id;
  final tien = TextEditingController(text: '0');
  final lyDo = TextEditingController();
  int? get soTien {
    final chu = tien.text;
    if (!RegExp(r'^\d{1,3}(\.\d{3})*$').hasMatch(chu)) return null;
    final n = int.tryParse(chu.replaceAll('.', ''));
    return n != null && n >= 0 && n <= 999999999999999 ? n : null;
  }

  void dispose() {
    tien.dispose();
    lyDo.dispose();
  }
}
