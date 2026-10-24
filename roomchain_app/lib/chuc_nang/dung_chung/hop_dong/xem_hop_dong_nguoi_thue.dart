import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../dung_chung/demo/khung_dien_thoai_demo.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'tai_lieu_hop_dong.dart';
import 'thanh_phan_hop_dong.dart';

// Chạy demo T11 → T15 với PDF do dịch vụ hợp đồng hiện có tạo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final kho = KhoHopDongMau();
  final id = kho.danhSach.first.id;
  await const TaiLieuHopDongDemo().lay(kho, id);
  kho.guiYeuCauKy(id);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ChuDeUngDung.sang,
      onGenerateRoute: DieuHuong.taoRoute,
      builder: (context, child) => KhungDienThoaiDemo(child: child!),
      home: XemHopDongNguoiThue(hopDongId: id, kho: kho),
    ),
  );
}

class XemHopDongNguoiThue extends StatefulWidget {
  const XemHopDongNguoiThue({
    super.key,
    required this.hopDongId,
    this.kho,
    this.dichVu = const TaiLieuHopDongDemo(),
  });
  final String hopDongId;
  final KhoHopDongMau? kho;
  final TaiLieuHopDongDemo dichVu;

  @override
  State<XemHopDongNguoiThue> createState() => _XemHopDongNguoiThueState();
}

class _XemHopDongNguoiThueState extends State<XemHopDongNguoiThue> {
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;
  bool _dongY = false, _dangXacNhan = false, _dangTai = false;
  HopDong? _banDaDoc;

  void _bao(String chu) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(chu)));
  }

  void _quayLai() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, DieuHuong.dangNhap);
    }
  }

  Future<void> _taiPdf(HopDong h) async {
    if (_dangTai) return;
    final t = h.taiLieu;
    if (t == null || !TaiLieuHopDongDemo.hopLe(t)) {
      _bao('Chưa có tài liệu PDF hợp lệ để tải. Vui lòng liên hệ chủ trọ.');
      return;
    }
    setState(() => _dangTai = true);
    try {
      final ok = await widget.dichVu.tai(t);
      if (mounted && !ok) _bao('Thao tác tải hoặc chia sẻ chưa hoàn tất.');
    } catch (_) {
      if (mounted) _bao('Không thể tải PDF. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  Future<void> _xacNhan(HopDong h) async {
    if (_dangXacNhan || !_dongY || !identical(_banDaDoc, h)) return;
    final loi = _kho.kiemTraNguoiThueDongY(h.id);
    if (loi != null) {
      _bao(loi);
      return;
    }
    setState(() => _dangXacNhan = true);
    final ok = await HopThoaiXacNhan.hienThi(
      context,
      tieuDe: 'Xác nhận hợp đồng?',
      noiDung: 'Ghi nhận bạn đồng ý điều khoản trong bản demo. Hợp đồng vẫn chờ ký ví; thao tác này chưa tạo chữ ký Blockchain hoặc đặt cọc.',
    );
    if (!mounted) return;
    if (ok == true) {
      try {
        _kho.nguoiThueDongY(h.id, banDaDoc: h);
        setState(() => _dangXacNhan = false);
        await Navigator.pushNamed(
          context,
          DieuHuong.ketNoiVi,
          arguments: ThamSoHopDong(hopDongId: h.id, kho: _kho),
        );
        return;
      } on StateError catch (e) {
        _bao(e.message.toString());
      }
    }
    if (mounted) setState(() => _dangXacNhan = false);
  }

  Widget _tieuDe(String chu) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(chu, style: KieuChu.noiDungDam),
  );

  // Phần thẻ PDF; không tự tạo lại tài liệu người thuê đang xem.
  Widget _taiLieu(HopDong h) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: BangMau.nen,
      border: Border.all(color: BangMau.vien),
      borderRadius: BorderRadius.circular(12),
    ),
    child: LayoutBuilder(
      builder: (context, size) {
        final tai = NutBam(
          nhan: 'Tải về',
          kieu: KieuNut.phu,
          rongHet: false,
          dangTai: _dangTai,
          khiNhan: () => _taiPdf(h),
        );
        final ten = Row(
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              color: BangMau.loi,
              size: 36,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hợp đồng thuê phòng', style: KieuChu.noiDungDam),
                  const SizedBox(height: 4),
                  Text(h.maHopDong, style: KieuChu.chuNho),
                ],
              ),
            ),
          ],
        );
        if (size.maxWidth < 320 ||
            MediaQuery.textScalerOf(context).scale(14) > 20) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ten,
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: tai),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: ten),
            const SizedBox(width: 8),
            tai,
          ],
        );
      },
    ),
  );

  Widget _nguoi(String nhan, NguoiDung n) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: BangMau.chinhNhat,
          child: Icon(Icons.person_outline, color: BangMau.chinh),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nhan, style: KieuChu.chuPhu),
              Text(n.hoTen, style: KieuChu.noiDungDam),
              Text('SĐT: ${n.soDienThoai}', style: KieuChu.chuPhu),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _thongTin(IconData icon, String ten, String moTa) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: BangMau.chuChinh),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ten, style: KieuChu.noiDungDam),
              const SizedBox(height: 4),
              Text(moTa, style: KieuChu.chuPhu),
            ],
          ),
        ),
      ],
    ),
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
      final loi = _kho.kiemTraNguoiThueDongY(widget.hopDongId);
      final p = hopLe ? _kho.phong(h.phongId) : null;
      final c = h?.cauHinh;
      final daChon = _dongY && identical(_banDaDoc, h);
      return KhungTrang(
        mauNen: BangMau.nenThe,
        appBar: AppBar(
          centerTitle: true,
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          title: const Text('Xem hợp đồng'),
          leading: NutBieuTuong(
            bieuTuong: Icons.arrow_back_ios_new,
            goiY: 'Quay lại',
            khiNhan: _quayLai,
          ),
        ),
        noiDung: !hopLe
            ? const TrangThaiRong(
                tieuDe: 'Không tìm thấy hợp đồng',
                moTa: 'Vui lòng chọn hợp đồng hợp lệ từ yêu cầu ký.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _taiLieu(h),
                  _tieuDe('Thông tin các bên'),
                  _nguoi('Chủ trọ', _kho.chuTro),
                  _nguoi('Người thuê', _kho.nguoi(h.nguoiThueId)),
                  _tieuDe('Thông tin phòng'),
                  _thongTin(
                    Icons.meeting_room_outlined,
                    '${p!.maPhong} – ${p.tenKhuTro}',
                    p.diaChi,
                  ),
                  _thongTin(
                    Icons.calendar_month_outlined,
                    'Thời hạn thuê',
                    '${dinhDangNgay(h.ngayBatDau)} – ${dinhDangNgay(h.ngayKetThuc)}',
                  ),
                  _tieuDe('Giá thuê và đặt cọc'),
                  DongThongTin(
                    nhan: 'Giá thuê',
                    giaTri: '${dinhDangVND(h.giaThue)}/tháng',
                  ),
                  DongThongTin(
                    nhan: 'Tiền đặt cọc',
                    giaTri: dinhDangVND(h.tienCoc),
                  ),
                  const Text(
                    'Giá trị thỏa thuận bằng VND; MockVNDC là token thử nghiệm ở bước đặt cọc.',
                    style: KieuChu.chuNho,
                  ),
                  // Phần điều khoản giữ nguyên nội dung từ hợp đồng chủ trọ.
                  _tieuDe('Điều khoản thanh toán'),
                  Text(
                    'Thanh toán hằng tháng, từ ngày ${c!.thanhToanTu} đến hết ngày ${c.thanhToanDen}.',
                  ),
                  Text(
                    'Phụ thu trả chậm: ${dinhDangVND(c.phuThuCham)}/ngày. $luuYPhuThu',
                    style: KieuChu.chuPhu,
                  ),
                  _tieuDe('Chi phí và dịch vụ'),
                  DongThongTin(
                    nhan: 'Dịch vụ / tháng',
                    giaTri: dinhDangVND(c.phiDichVu),
                  ),
                  DongThongTin(
                    nhan: 'Điện / kWh',
                    giaTri: dinhDangVND(c.donGiaDien),
                  ),
                  DongThongTin(
                    nhan: 'Nước / m³',
                    giaTri: dinhDangVND(c.donGiaNuoc),
                  ),
                  DongThongTin(
                    nhan: 'Internet / tháng',
                    giaTri: dinhDangVND(c.internet),
                  ),
                  DongThongTin(
                    nhan: 'Khoản khác / tháng',
                    giaTri: dinhDangVND(c.khoanKhac),
                  ),
                  Text(
                    'Ghi số điện nước ngày ${c.ngayGhiSo} hằng tháng.',
                    style: KieuChu.chuPhu,
                  ),
                  _tieuDe('Điều khoản chấm dứt hợp đồng'), Text(c.ketThucSom),
                  const SizedBox(height: 8),
                  const Text(dieuKhoanHoanCoc, style: KieuChu.chuPhu),
                  if (c.noiQuy.isNotEmpty) ...[
                    _tieuDe('Nội quy bổ sung'),
                    Text(c.noiQuy),
                  ],
                  const SizedBox(height: 12),
                  if (loi != null)
                    ThongBaoNoiDung(noiDung: loi, loai: LoaiThongBao.canhBao),
                  if (h.choKyVi)
                    const ThongBaoNoiDung(
                      noiDung: 'Đã đồng ý điều khoản (Demo) · Chờ ký ví. Chưa có chữ ký Blockchain.',
                    ),
                  // Phần đồng ý điều khoản và nút xác nhận.
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: daChon,
                    onChanged: loi != null || _dangXacNhan
                        ? null
                        : (value) => setState(() {
                            _dongY = value ?? false;
                            _banDaDoc = h;
                          }),
                    title: const Text(
                      'Tôi đã đọc và đồng ý với các điều khoản trong hợp đồng',
                      style: KieuChu.chuPhu,
                    ),
                  ),
                  NutBam(
                    nhan: 'Xác nhận hợp đồng',
                    voHieuHoa: _dangXacNhan || !daChon || loi != null,
                    khiNhan: () => _xacNhan(h),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
      );
    },
  );
}
