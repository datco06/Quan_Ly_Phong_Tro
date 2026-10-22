import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'ma_bam_tai_lieu.dart';
import 'tai_lieu_hop_dong.dart';
import 'thanh_phan_hop_dong.dart';

class ChiTietHopDong extends StatefulWidget {
  const ChiTietHopDong({super.key, required this.hopDongId, this.kho});
  final String hopDongId;
  final KhoHopDongMau? kho;
  @override
  State<ChiTietHopDong> createState() => _ChiTietHopDongState();
}

class _ChiTietHopDongState extends State<ChiTietHopDong> {
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;
  int _tab = 0;
  bool _dangTai = false, _dangNhac = false;
  final _cuon = ScrollController();
  static const _cacTab = [
    'Tổng quan',
    'Lịch sử giao dịch',
    'Tài liệu',
    'Thao tác',
  ];
  @override
  void dispose() {
    _cuon.dispose();
    super.dispose();
  }

  void _doiTab(int tab) {
    setState(() => _tab = tab);
    if (_cuon.hasClients) _cuon.jumpTo(0);
  }

  void _quayLai() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        DieuHuong.danhSachHopDong,
        arguments: _kho,
      );
    }
  }

  void _xemTruoc() => Navigator.pushNamed(
    context,
    DieuHuong.xemTruocHopDong,
    arguments: ThamSoHopDong(hopDongId: widget.hopDongId, kho: _kho),
  );
  Future<void> _thongTin(String tieuDe, String chu) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(tieuDe),
      content: SingleChildScrollView(child: Text(chu)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );

  Future<void> _taiPdf(TaiLieuHopDong t) async {
    if (_dangTai) return;
    setState(() => _dangTai = true);
    try {
      final ok = await const TaiLieuHopDongDemo().tai(t);
      if (mounted && !ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thao tác tải hoặc chia sẻ chưa hoàn tất.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể tải PDF trên thiết bị này. Vui lòng thử lại.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  Future<void> _nhacCoc() async {
    if (_dangNhac) return;
    setState(() => _dangNhac = true);
    final dongY = await HopThoaiXacNhan.hienThi(
      context,
      tieuDe: 'Nhắc người thuê đặt cọc?',
      noiDung: 'Ghi nhận lời nhắc trong lịch sử demo. Chưa gửi thông báo qua máy chủ.',
    );
    if (!mounted) return;
    if (dongY == true) {
      try {
        _kho.nhacDatCoc(widget.hopDongId);
      } on StateError catch (e) {
        await _thongTin('Chưa thể nhắc đặt cọc', e.message.toString());
      }
    }
    if (mounted) setState(() => _dangNhac = false);
  }

  Future<void> _quyetToan(HopDong h) async {
    if (h.quyetToan == null) {
      final loi = _kho.lyDoChuaDuDieuKienQuyetToan(h.id);
      if (loi != null) {
        await _thongTin('Chưa đủ điều kiện quyết toán', loi);
        return;
      }
    }
    if (mounted) {
      Navigator.pushNamed(
        context,
        DieuHuong.taoQuyetToan,
        arguments: ThamSoHopDong(hopDongId: h.id, kho: _kho),
      );
    }
  }

  Widget _muc(String chu) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(chu, style: KieuChu.noiDungDam),
  );
  Widget _chuKy(String ben, DateTime? luc) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person_outline, color: BangMau.chinh, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(ben, style: KieuChu.chuPhu)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    luc == null ? Icons.schedule : Icons.check_circle,
                    size: 17,
                    color: luc == null ? BangMau.canhBao : BangMau.thanhCong,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      luc == null ? 'Chưa ký' : 'Đã ký (demo)',
                      style: KieuChu.chuPhu,
                    ),
                  ),
                ],
              ),
              if (luc != null)
                Text(
                  dinhDangNgayGio(luc),
                  style: KieuChu.chuNho,
                  textAlign: TextAlign.right,
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _tienCoc(HopDong h) {
    final coc = h.coc;
    final nhan = switch (coc?.trangThai) {
      TrangThaiTienCoc.dangKhoa => 'Đã khóa cọc (dữ liệu demo)',
      TrangThaiTienCoc.choNguoiThueXacNhan =>
        'Chờ người thuê xác nhận (dữ liệu demo)',
      TrangThaiTienCoc.choQuyetToan => 'Chờ quyết toán (dữ liệu demo)',
      TrangThaiTienCoc.choXacNhan => 'Chờ xác nhận cọc (dữ liệu demo)',
      TrangThaiTienCoc.thatBai => 'Giao dịch thất bại (dữ liệu demo)',
      TrangThaiTienCoc.daHoan => 'Đã hoàn cọc (dữ liệu demo)',
      TrangThaiTienCoc.daQuyetToan => 'Đã quyết toán (dữ liệu demo)',
      _ => 'Chưa ghi nhận khóa cọc',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          nhan,
          style: KieuChu.noiDungDam.copyWith(
            color: coc == null || coc.trangThai == TrangThaiTienCoc.chuaDat
                ? BangMau.chuPhu
                : BangMau.chinh,
          ),
        ),
        DongThongTin(
          nhan: 'Cọc theo hợp đồng (VND)',
          giaTri: dinhDangVND(h.tienCoc),
        ),
        if (coc != null)
          DongThongTin(
            nhan: 'Token trong bản ghi',
            giaTri:
                '${dinhDangVND(coc.soToken).replaceAll('đ', '')} ${coc.loaiToken}',
          ),
        if (h.ghiNhanCocLuc != null)
          DongThongTin(
            nhan: 'Ghi nhận lúc',
            giaTri: dinhDangNgayGio(h.ghiNhanCocLuc!),
          ),
        if (h.diaChiEscrow != null)
          DongThongTin(nhan: 'Escrow demo', giaTri: h.diaChiEscrow!),
        if (h.maGiaoDichCoc != null)
          DongThongTin(nhan: 'Transaction hash demo', giaTri: h.maGiaoDichCoc!),
        const SizedBox(height: 8),
        const Text(
          'Bản ghi Frontend, chưa kiểm chứng trên Blockchain. VND và MockVNDC được hiển thị riêng.',
          style: KieuChu.chuNho,
        ),
      ],
    );
  }

  Widget _tongQuan(HopDong h) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ThongTinHopDong(hopDong: h, kho: _kho),
      _muc('Trạng thái ký kết'),
      _chuKy('Bên cho thuê', h.chuTroKyLuc),
      _chuKy('Bên người thuê', h.nguoiThueKyLuc),
      if (!h.daCoChuKy)
        const Text(
          'Chưa có xác nhận ký của hai bên trong dữ liệu demo.',
          style: KieuChu.chuNho,
        ),
      if (h.guiKyLuc != null)
        Text(
          'Yêu cầu ký demo: ${dinhDangNgayGio(h.guiKyLuc!)}',
          style: KieuChu.chuNho,
        ),
      _muc('Trạng thái tiền cọc'),
      _tienCoc(h),
    ],
  );

  Widget _lichSu(HopDong h) {
    if (h.lichSu.isEmpty) {
      return const TrangThaiRong(
        tieuDe: 'Chưa có lịch sử giao dịch',
        moTa: 'Các sự kiện của hợp đồng sẽ xuất hiện tại đây.',
        bieuTuong: Icons.history,
      );
    }
    final suKien = [...h.lichSu]
      ..sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ThongBaoNoiDung(
          noiDung: 'Lịch sử dữ liệu demo. Sự kiện yêu cầu ký không phải chữ ký; sự kiện token không phải thanh toán VND.',
        ),
        const SizedBox(height: 16),
        DongThoiGian(
          cacBuoc: [
            for (final s in suKien)
              BuocThoiGian(
                tieuDe: s.tieuDe,
                ngayGio: s.thoiGian,
                trangThai: TrangThaiBuoc.hoanThanh,
                moTa: [
                  if (s.moTa != null) s.moTa!,
                  'Dữ liệu demo',
                  if (s.thamChieu != null) s.thamChieu!,
                ].join('\n'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _taiLieu(HopDong h) {
    final goc = h.taiLieu;
    final t = goc != null && TaiLieuHopDongDemo.hopLe(goc) ? goc : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (goc != null && t == null)
          const ThongBaoNoiDung(
            noiDung: 'Tài liệu PDF hoặc mã băm không hợp lệ. Cần cung cấp tài liệu gốc.',
            loai: LoaiThongBao.loi,
          ),
        if (t == null) ...[
          const TrangThaiRong(
            tieuDe: 'Chưa có tài liệu PDF',
            moTa: 'Mở xem trước để tạo PDF demo từ hợp đồng. Nếu đã có xác nhận ký, cần cung cấp tài liệu gốc.',
            bieuTuong: Icons.picture_as_pdf_outlined,
          ),
        ] else ...[
          const Icon(
            Icons.picture_as_pdf_outlined,
            color: BangMau.chinh,
            size: 36,
          ),
          DongThongTin(nhan: 'Tên tài liệu', giaTri: t.tenTep),
          DongThongTin(nhan: 'Phiên bản', giaTri: '${t.phienBan}'),
          DongThongTin(nhan: 'Tạo lúc', giaTri: dinhDangNgayGio(t.ngayTao)),
          DongThongTin(
            nhan: 'Bên cho thuê',
            giaTri: h.chuTroKyLuc == null ? 'Chưa ký' : 'Đã ký (demo)',
          ),
          DongThongTin(
            nhan: 'Người thuê',
            giaTri: h.nguoiThueKyLuc == null ? 'Chưa ký' : 'Đã ký (demo)',
          ),
          const SizedBox(height: 12),
          MaBamTaiLieu(maBam: t.sha256),
          const SizedBox(height: 16),
        ],
        NutBam(
          nhan: 'Xem trước hợp đồng',
          khiNhan: _xemTruoc,
          bieuTuong: Icons.visibility_outlined,
        ),
        if (t != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: NutBam(
              nhan: 'Tải PDF',
              kieu: KieuNut.phu,
              khiNhan: () => _taiPdf(t),
              dangTai: _dangTai,
            ),
          ),
      ],
    );
  }

  Widget _thaoTac(HopDong h) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _muc('Thao tác hợp đồng'),
      switch (h.trangThai) {
        TrangThaiHopDong.nhap || TrangThaiHopDong.choKy => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NutBam(nhan: 'Xem trước hợp đồng', khiNhan: _xemTruoc),
            const SizedBox(height: 12),
            if (h.guiKyLuc == null && !h.daCoChuKy)
              NutBam(
                nhan: 'Gửi yêu cầu ký',
                kieu: KieuNut.phu,
                khiNhan: _xemTruoc,
              ),
            const SizedBox(height: 12),
            ThongBaoNoiDung(
              noiDung: h.guiKyLuc == null
                  ? 'Chờ các bên kiểm tra tài liệu và xác nhận ký.'
                  : 'Đã gửi yêu cầu ký trong bản demo. Chưa tự động xác nhận chữ ký.',
            ),
          ],
        ),
        TrangThaiHopDong.choCoc => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _tienCoc(h),
            const SizedBox(height: 16),
            NutBam(
              nhan: 'Nhắc người thuê đặt cọc',
              khiNhan: _nhacCoc,
              voHieuHoa: _dangNhac,
            ),
          ],
        ),
        TrangThaiHopDong.dangHieuLuc => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DongThongTin(
              nhan: 'Ngày kết thúc',
              giaTri: dinhDangNgay(h.ngayKetThuc),
            ),
            const Text(
              'Quyết toán cần đủ xác nhận ký, cọc đang khóa và đến hạn kết thúc. Quy trình kết thúc sớm chưa triển khai.',
              style: KieuChu.chuPhu,
            ),
            const SizedBox(height: 12),
            NutBam(
              nhan: 'Xem thông tin thời hạn',
              kieu: KieuNut.phu,
              khiNhan: () => _doiTab(0),
            ),
          ],
        ),
        TrangThaiHopDong.daKetThuc => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NutBam(
              nhan: h.quyetToan == null ? 'Tạo quyết toán' : 'Xem quyết toán',
              khiNhan: () => _quyetToan(h),
            ),
            const SizedBox(height: 12),
            NutBam(
              nhan: 'Xem lịch sử hoàn cọc',
              kieu: KieuNut.phu,
              khiNhan: () => _doiTab(1),
            ),
            const SizedBox(height: 12),
            NutBam(
              nhan: 'Xem tài liệu',
              kieu: KieuNut.phu,
              khiNhan: () => _doiTab(2),
            ),
          ],
        ),
      },
    ],
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _kho,
    builder: (context, _) {
      final h = _kho.theoId(widget.hopDongId);
      final hopLe =
          h != null &&
          _kho.phongTro.any((p) => p.id == h.phongId) &&
          _kho.nguoiThue.any((n) => n.id == h.nguoiThueId);
      return Scaffold(
        backgroundColor: BangMau.nenThe,
        appBar: AppBar(
          title: Text(
            'Chi tiết hợp đồng',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: NutBieuTuong(
            bieuTuong: Icons.arrow_back_ios_new,
            goiY: 'Quay lại',
            khiNhan: _quayLai,
          ),
          actions: [
            if (hopLe)
              PopupMenuButton<String>(
                tooltip: 'Menu chi tiết',
                onSelected: (v) {
                  if (v == 'xem') {
                    _xemTruoc();
                  } else {
                    _doiTab(2);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'xem', child: Text('Xem trước PDF')),
                  PopupMenuItem(value: 'tai_lieu', child: Text('Xem tài liệu')),
                ],
              ),
          ],
        ),
        body: SafeArea(
          child: !hopLe
              ? const TrangThaiRong(
                  tieuDe: 'Không tìm thấy hợp đồng',
                  moTa: 'Vui lòng quay lại danh sách và chọn hợp đồng hợp lệ.',
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: BangMau.chinh,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h.maHopDong, style: KieuChu.noiDungDam),
                                Text(
                                  h.ngayTao == null
                                      ? 'Chưa ghi nhận ngày tạo'
                                      : 'Tạo ngày ${dinhDangNgay(h.ngayTao!)}',
                                  style: KieuChu.chuNho,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          NhanHopDong(trangThai: h.trangThai),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          for (var i = 0; i < _cacTab.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                key: ValueKey('chi_tiet_tab_$i'),
                                label: Text(_cacTab[i]),
                                selected: _tab == i,
                                showCheckmark: false,
                                selectedColor: BangMau.chinh,
                                backgroundColor: BangMau.nen,
                                labelStyle: KieuChu.chuPhu.copyWith(
                                  color: _tab == i
                                      ? BangMau.nenThe
                                      : BangMau.chuPhu,
                                ),
                                side: BorderSide.none,
                                shape: const StadiumBorder(),
                                onSelected: (_) => _doiTab(i),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _cuon,
                        padding: const EdgeInsets.all(16),
                        child: switch (_tab) {
                          0 => _tongQuan(h),
                          1 => _lichSu(h),
                          2 => _taiLieu(h),
                          _ => _thaoTac(h),
                        },
                      ),
                    ),
                    if (h.trangThai == TrangThaiHopDong.dangHieuLuc)
                      HangNutHopDong(
                        chinh: NutBam(
                          nhan: h.quyetToan == null
                              ? 'Tạo quyết toán'
                              : 'Xem quyết toán',
                          khiNhan: () => _quyetToan(h),
                        ),
                        phu: NutBam(
                          nhan: 'Gia hạn hợp đồng',
                          kieu: KieuNut.phu,
                          khiNhan: () => _thongTin(
                            'Gia hạn hợp đồng',
                            'Màn hình gia hạn chưa được triển khai. Thời hạn hợp đồng hiện tại được giữ nguyên.',
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      );
    },
  );
}
