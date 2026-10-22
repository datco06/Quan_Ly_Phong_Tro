import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'ma_bam_tai_lieu.dart';
import 'tai_lieu_hop_dong.dart';
import 'thanh_phan_hop_dong.dart';

class XemTruocHopDong extends StatefulWidget {
  const XemTruocHopDong({
    super.key,
    required this.hopDongId,
    this.kho,
    this.dichVu = const TaiLieuHopDongDemo(),
  });
  final String hopDongId;
  final KhoHopDongMau? kho;
  final TaiLieuHopDongDemo dichVu;
  @override
  State<XemTruocHopDong> createState() => _XemTruocHopDongState();
}

class _XemTruocHopDongState extends State<XemTruocHopDong> {
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;
  final _cuon = ScrollController();
  TaiLieuHopDong? _taiLieu;
  String? _loi;
  bool _dangMo = true, _dangTai = false, _dangGui = false;
  @override
  void initState() {
    super.initState();
    _moTaiLieu();
  }

  @override
  void dispose() {
    _cuon.dispose();
    super.dispose();
  }

  Future<void> _moTaiLieu() async {
    try {
      final t = await widget.dichVu.lay(_kho, widget.hopDongId);
      if (mounted) {
        setState(() {
          _taiLieu = t;
          _dangMo = false;
          _loi = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dangMo = false;
          _loi = e is StateError
              ? e.message.toString()
              : 'Không mở được tài liệu PDF. Vui lòng thử lại.';
        });
      }
    }
  }

  void _bao(String chu) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(chu)));
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

  Future<void> _taiPdf() async {
    if (_dangTai) return;
    final t = _taiLieu;
    if (t == null) {
      _bao('Chưa có tài liệu PDF hợp lệ để tải.');
      return;
    }
    setState(() => _dangTai = true);
    try {
      final ok = await widget.dichVu.tai(t);
      if (mounted && !ok) _bao('Thao tác tải hoặc chia sẻ chưa hoàn tất.');
    } catch (_) {
      if (mounted) {
        _bao('Không thể tải PDF trên thiết bị này. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  Future<void> _guiKy() async {
    if (_dangGui) return;
    final loi = _kho.kiemTraGuiKy(widget.hopDongId);
    if (loi != null) {
      _bao(loi);
      return;
    }
    setState(() => _dangGui = true);
    final dongY = await HopThoaiXacNhan.hienThi(
      context,
      tieuDe: 'Gửi cho người thuê ký?',
      noiDung: 'Tạo yêu cầu ký trong bộ nhớ demo. Thao tác này chưa gửi tới người thuê qua máy chủ và không tạo chữ ký hoặc giao dịch Blockchain.',
    );
    if (!mounted) return;
    if (dongY == true) {
      try {
        _kho.guiYeuCauKy(widget.hopDongId);
        _bao('Đã gửi yêu cầu ký trong bản demo.');
      } on StateError catch (e) {
        _bao(e.message.toString());
      }
    }
    if (mounted) setState(() => _dangGui = false);
  }

  Widget _pdf() {
    if (_dangMo) {
      return const SizedBox(
        height: 320,
        child: HienThiDangTai(
          kieu: KieuDangTai.toanTrang,
          thongDiep: 'Đang mở PDF...',
        ),
      );
    }
    if (_loi != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ThongBaoNoiDung(noiDung: _loi!, loai: LoaiThongBao.loi),
            TextButton(
              onPressed: () {
                setState(() => _dangMo = true);
                _moTaiLieu();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    final t = _taiLieu!;
    return Container(
      height: 360,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: BangMau.vien),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            color: BangMau.chuChinh,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 18,
                  color: BangMau.nenThe,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.tenTep,
                    style: KieuChu.chuNho.copyWith(color: BangMau.nenThe),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Tải PDF',
                  onPressed: _dangTai ? null : _taiPdf,
                  icon: const Icon(
                    Icons.download_outlined,
                    color: BangMau.nenThe,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PdfPreview(
              key: ValueKey(t.sha256),
              build: (_) async => t.noiDung,
              useActions: false,
              allowPrinting: false,
              allowSharing: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              dynamicLayout: false,
              loadingWidget: const HienThiDangTai(kieu: KieuDangTai.toanTrang),
              onError: (_, _) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Không hiển thị được PDF. Bạn có thể tải file để xem bằng ứng dụng PDF.',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _kho,
    builder: (context, _) {
      final h = _kho.theoId(widget.hopDongId);
      final hopLe =
          h != null &&
          _kho.phongTro.any((p) => p.id == h.phongId) &&
          _kho.nguoiThue.any((n) => n.id == h.nguoiThueId);
      final choGui =
          h != null &&
          (h.trangThai == TrangThaiHopDong.nhap ||
              h.trangThai == TrangThaiHopDong.choKy) &&
          !h.daCoChuKy;
      return Scaffold(
        backgroundColor: BangMau.nenThe,
        appBar: AppBar(
          title: Text(
            'Xem trước hợp đồng',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: NutBieuTuong(
            bieuTuong: Icons.arrow_back_ios_new,
            goiY: 'Quay lại',
            khiNhan: _quayLai,
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Menu xem trước',
              onSelected: (v) {
                if (v == 'tai') {
                  _taiPdf();
                } else if (_cuon.hasClients) {
                  _cuon.animateTo(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'thong_tin',
                  child: Text('Xem thông tin hợp đồng'),
                ),
                if (_taiLieu != null)
                  const PopupMenuItem(value: 'tai', child: Text('Tải PDF')),
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
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _cuon,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ThongTinHopDong(hopDong: h, kho: _kho),
                            const SizedBox(height: 16),
                            // Phần tài liệu thật, nội dung được giữ nguyên theo phiên bản.
                            const Text(
                              'Nội dung hợp đồng (PDF)',
                              style: KieuChu.noiDungDam,
                            ),
                            const SizedBox(height: 8),
                            _pdf(),
                            const SizedBox(height: 6),
                            const Text(
                              'PDF demo · Cuộn để xem các trang; chạm trang để phóng to.',
                              style: KieuChu.chuNho,
                            ),
                            const SizedBox(height: 16),
                            MaBamTaiLieu(maBam: _taiLieu?.sha256),
                            if (h.guiKyLuc != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: ThongBaoNoiDung(
                                  noiDung:
                                      'Đã gửi yêu cầu ký trong bản demo lúc ${dinhDangNgayGio(h.guiKyLuc!)}. Hai bên chưa được tự động đánh dấu đã ký.',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    HangNutHopDong(
                      chinh: choGui
                          ? NutBam(
                              nhan: h.guiKyLuc == null
                                  ? 'Gửi cho người thuê ký'
                                  : 'Đã gửi yêu cầu ký',
                              khiNhan: _guiKy,
                              voHieuHoa:
                                  _taiLieu == null ||
                                  h.guiKyLuc != null ||
                                  _dangGui,
                            )
                          : NutBam(
                              nhan: 'Tải PDF',
                              khiNhan: _taiPdf,
                              dangTai: _dangTai,
                              voHieuHoa: _taiLieu == null,
                            ),
                      phu: choGui
                          ? NutBam(
                              nhan: 'Tải PDF',
                              kieu: KieuNut.phu,
                              khiNhan: _taiPdf,
                              dangTai: _dangTai,
                              voHieuHoa: _taiLieu == null,
                            )
                          : null,
                    ),
                  ],
                ),
        ),
      );
    },
  );
}
