import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../ung_dung/dieu_huong.dart';
import '../vi_blockchain/trang_thai_vi_mau.dart';
import '../vi_blockchain/thanh_phan_giao_dich_demo.dart';
import 'tai_lieu_hop_dong.dart';

// Chạy từ T13; vẫn có thể quay về T12 để kết nối ví demo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final kho = KhoHopDongMau();
  final id = kho.danhSach.first.id;
  await const TaiLieuHopDongDemo().lay(kho, id);
  kho.guiYeuCauKy(id);
  kho.nguoiThueDongY(id, banDaDoc: kho.theoId(id)!);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ChuDeUngDung.sang,
      onGenerateRoute: DieuHuong.taoRoute,
      home: KyHopDong(hopDongId: id, kho: kho),
    ),
  );
}

class KyHopDong extends StatefulWidget {
  const KyHopDong({super.key, required this.hopDongId, this.kho, this.vi});
  final String hopDongId;
  final KhoHopDongMau? kho;
  final TrangThaiViMau? vi;
  @override
  State<KyHopDong> createState() => _KyHopDongState();
}

class _KyHopDongState extends State<KyHopDong> {
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;
  TrangThaiViMau get _vi => widget.vi ?? TrangThaiViMau.dungChung;
  bool _dangHoi = false;
  ThamSoHopDong get _thamSo =>
      ThamSoHopDong(hopDongId: widget.hopDongId, kho: _kho, vi: _vi);

  void _bao(String chu) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(chu)));
  Future<void> _ky({bool thatBai = false}) async {
    if (_dangHoi) return;
    if (_vi.diaChi == null) {
      Navigator.pushReplacementNamed(
        context,
        DieuHuong.ketNoiVi,
        arguments: _thamSo,
      );
      return;
    }
    final loi = _kho.kiemTraKyDemo(widget.hopDongId, _vi);
    if (loi != null) {
      _bao(loi);
      return;
    }
    setState(() => _dangHoi = true);
    final ok = await HopThoaiXacNhan.hienThi(
      context,
      tieuDe: 'Ký hợp đồng (Demo)?',
      noiDung: thatBai
          ? 'Chạy tình huống ký thất bại mô phỏng. Không tạo chữ ký hoặc gửi transaction.'
          : 'Ghi nhận xác nhận ký của người thuê trong bộ nhớ. Đây là mô phỏng, chưa có chữ ký Blockchain; chủ trọ cần xác nhận riêng.',
    );
    if (!mounted) return;
    setState(() => _dangHoi = false);
    if (ok != true) return;
    try {
      await _kho.kyNguoiThueDemo(widget.hopDongId, _vi, thatBai: thatBai);
    } on StateError catch (e) {
      if (mounted) _bao(e.message.toString());
    }
  }

  Future<void> _chuTroKy() async {
    if (_dangHoi) return;
    setState(() => _dangHoi = true);
    final ok = await HopThoaiXacNhan.hienThi(
      context,
      tieuDe: 'Mô phỏng chủ trọ xác nhận?',
      noiDung: 'Áp dụng bản ghi xác nhận ký mẫu của chủ trọ cho hợp đồng này. Thao tác chỉ phục vụ demo; không ký thay chủ trọ trên Blockchain.',
    );
    if (!mounted) return;
    setState(() => _dangHoi = false);
    if (ok == true) {
      try {
        _kho.chuTroXacNhanKyDemo(widget.hopDongId);
      } on StateError catch (e) {
        _bao(e.message.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([_kho, _vi]),
    builder: (context, _) {
      final h = _kho.theoId(widget.hopDongId);
      final daKy = h?.nguoiThueKyLuc != null;
      final duKy = daKy && h?.chuTroKyLuc != null;
      final t = h?.taiLieu;
      final hash = t != null && TaiLieuHopDongDemo.hopLe(t) ? t.sha256 : null;
      final loi = _kho.kiemTraKyDemo(widget.hopDongId, _vi);
      final nhan = h?.dangKyDemo == true
          ? 'Đang ký (Demo)'
          : h?.loiKyDemo != null
          ? 'Ký thất bại (Demo)'
          : duKy
          ? 'Đã đủ xác nhận (Demo)'
          : daKy
          ? 'Chờ chủ trọ ký (Demo)'
          : _vi.diaChi == null
          ? 'Chưa kết nối ví'
          : 'Chờ người thuê ký';
      return KhungTrang(
        mauNen: BangMau.nenThe,
        appBar: AppBar(
          title: const Text('Ký hợp đồng'),
          centerTitle: true,
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          leading: NutBieuTuong(
            bieuTuong: Icons.arrow_back_ios_new,
            goiY: 'Quay lại',
            khiNhan: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  DieuHuong.ketNoiVi,
                  arguments: _thamSo,
                );
              }
            },
          ),
        ),
        noiDung: h == null
            ? const TrangThaiRong(
                tieuDe: 'Không tìm thấy hợp đồng',
                moTa: 'Vui lòng quay lại và chọn hợp đồng hợp lệ.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Phần minh họa tài liệu và bút ký.
                  const SizedBox(height: 8),
                  const SizedBox(
                    height: 90,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 76,
                            color: BangMau.thongTin,
                          ),
                          Positioned(
                            right: -8,
                            bottom: 0,
                            child: Icon(
                              Icons.edit_rounded,
                              size: 36,
                              color: BangMau.chinh,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    'Ký hợp đồng trên blockchain',
                    textAlign: TextAlign.center,
                    style: KieuChu.tieuDeMuc,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vui lòng kiểm tra thông tin và mở ví để ký hợp đồng thuê phòng.',
                    textAlign: TextAlign.center,
                    style: KieuChu.chuPhu,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: NhanTrangThai(
                      nhan: nhan,
                      trangThai: h.loiKyDemo != null
                          ? TrangThaiHienThi.thatBai
                          : duKy
                          ? TrangThaiHienThi.thanhCong
                          : TrangThaiHienThi.dangXuLy,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Phần dữ liệu lấy từ hợp đồng và ví hiện tại.
                  const Text('Thông tin giao dịch', style: KieuChu.noiDungDam),
                  DongThongTin(nhan: 'Mã hợp đồng', giaTri: h.maHopDong),
                  DongMaDemo(nhan: 'Hash hợp đồng', giaTri: hash),
                  const Text(
                    'SHA-256 của PDF gốc, chưa phải transaction hash hoặc bằng chứng ghi trên Blockchain.',
                    style: KieuChu.chuNho,
                  ),
                  const DongMaDemo(nhan: 'Ví chủ trọ'),
                  DongMaDemo(nhan: 'Ví của bạn', giaTri: _vi.diaChi),
                  const SizedBox(height: 20),
                  // Phần timeline ký; chủ trọ không được tự động đánh dấu đã ký.
                  const Text('Trạng thái ký', style: KieuChu.noiDungDam),
                  const SizedBox(height: 12),
                  DongThoiGian(
                    cacBuoc: [
                      BuocThoiGian(
                        tieuDe: 'Hợp đồng đã được tạo',
                        ngayGio: h.ngayTao ?? h.guiKyLuc,
                        trangThai: h.ngayTao != null || h.guiKyLuc != null
                            ? TrangThaiBuoc.hoanThanh
                            : TrangThaiBuoc.chuaDen,
                      ),
                      BuocThoiGian(
                        tieuDe: daKy
                            ? 'Người thuê đã xác nhận (Demo)'
                            : 'Chờ bạn ký hợp đồng',
                        ngayGio: h.nguoiThueKyLuc,
                        trangThai: daKy
                            ? TrangThaiBuoc.hoanThanh
                            : TrangThaiBuoc.hienTai,
                        bieuTuong: h.loiKyDemo != null
                            ? Icons.error_outline
                            : null,
                      ),
                      BuocThoiGian(
                        tieuDe: 'Chủ trọ ký xác nhận',
                        ngayGio: h.chuTroKyLuc,
                        trangThai: h.chuTroKyLuc != null
                            ? TrangThaiBuoc.hoanThanh
                            : daKy
                            ? TrangThaiBuoc.hienTai
                            : TrangThaiBuoc.chuaDen,
                      ),
                      BuocThoiGian(
                        tieuDe: 'Hoàn tất ký hợp đồng (Demo)',
                        moTa: duKy
                            ? 'Đủ xác nhận trong dữ liệu demo.'
                            : 'Chờ đủ xác nhận của hai bên.',
                        trangThai: duKy
                            ? TrangThaiBuoc.hoanThanh
                            : TrangThaiBuoc.chuaDen,
                      ),
                    ],
                  ),
                  if (h.loiKyDemo != null)
                    ThongBaoNoiDung(
                      noiDung: h.loiKyDemo!,
                      loai: LoaiThongBao.loi,
                    ),
                  if (!daKy && h.nguoiThueDongYLuc == null)
                    const ThongBaoNoiDung(
                      noiDung: 'Cần đọc và đồng ý hợp đồng tại T11 trước khi ký demo.',
                    ),
                  if (daKy && !duKy) ...[
                    const ThongBaoNoiDung(
                      noiDung: 'Người thuê đã xác nhận demo. Chưa có xác nhận chủ trọ để chuyển sang đặt cọc.',
                    ),
                    TextButton(
                      onPressed: _dangHoi ? null : _chuTroKy,
                      child: const Text('Mô phỏng chủ trọ xác nhận'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  NutBam(
                    nhan: duKy
                        ? 'Tiếp tục đặt cọc'
                        : daKy
                        ? 'Chờ chủ trọ ký'
                        : 'Mở ví để ký',
                    bieuTuong: Icons.account_balance_wallet_outlined,
                    dangTai: h.dangKyDemo,
                    voHieuHoa:
                        _dangHoi ||
                        (daKy && !duKy) ||
                        (!duKy && _vi.diaChi != null && loi != null),
                    khiNhan: duKy
                        ? () => Navigator.pushNamed(
                            context,
                            DieuHuong.datCoc,
                            arguments: _thamSo,
                          )
                        : _ky,
                  ),
                  if (!daKy && _vi.diaChi != null && !h.dangKyDemo)
                    TextButton(
                      onPressed: _dangHoi || loi != null
                          ? null
                          : () => _ky(thatBai: true),
                      child: const Text('Thử tình huống ký thất bại (Demo)'),
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chế độ mô phỏng · Chưa có chữ ký Blockchain hoặc giao dịch thật.',
                    textAlign: TextAlign.center,
                    style: KieuChu.chuNho,
                  ),
                ],
              ),
      );
    },
  );
}
