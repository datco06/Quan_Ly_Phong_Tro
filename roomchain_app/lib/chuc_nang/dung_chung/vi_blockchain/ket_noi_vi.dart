import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'trang_thai_vi_mau.dart';

class KetNoiVi extends StatefulWidget {
  const KetNoiVi({super.key, required this.hopDongId, this.kho, this.vi});
  final String hopDongId;
  final KhoHopDongMau? kho;
  final TrangThaiViMau? vi;

  @override
  State<KetNoiVi> createState() => _KetNoiViState();
}

class _KetNoiViState extends State<KetNoiVi> {
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;
  TrangThaiViMau get _vi => widget.vi ?? TrangThaiViMau.dungChung;
  bool _dangChon = false;

  void _quayLai() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        DieuHuong.xemHopDongNguoiThue,
        arguments: ThamSoHopDong(hopDongId: widget.hopDongId, kho: _kho),
      );
    }
  }

  // Phần lựa chọn demo: chỉ kết nối sau khi người dùng chủ động chọn mô phỏng.
  Future<void> _ketNoi() async {
    if (_dangChon || _vi.trangThai == TrangThaiKetNoiVi.dangKetNoi) return;
    setState(() => _dangChon = true);
    final ketQua = await showModalBottomSheet<KetQuaKetNoiMau>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kết nối ví · Chế độ mô phỏng',
                style: KieuChu.tieuDeMuc,
              ),
              const SizedBox(height: 12),
              const Text(
                'Ví thật sẽ được tích hợp ở giai đoạn Blockchain. Các lựa chọn dưới đây chỉ thay đổi giao diện demo; không kết nối mạng hoặc ký giao dịch.',
              ),
              const SizedBox(height: 16),
              for (final e in <(KetQuaKetNoiMau, String)>[
                (KetQuaKetNoiMau.thanhCong, 'Mô phỏng kết nối thành công'),
                (KetQuaKetNoiMau.thatBai, 'Mô phỏng kết nối thất bại'),
                (KetQuaKetNoiMau.saiMang, 'Mô phỏng sai mạng'),
              ]) ...[
                NutBam(
                  nhan: e.$2,
                  kieu: KieuNut.phu,
                  khiNhan: () => Navigator.pop(context, e.$1),
                ),
                const SizedBox(height: 8),
              ],
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _dangChon = false);
    if (ketQua != null) await _vi.ketNoi(ketQua);
  }

  Future<void> _copyDiaChi() async {
    final diaChi = _vi.diaChi;
    if (diaChi == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: diaChi));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã sao chép địa chỉ ví mẫu (Demo).')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể sao chép địa chỉ. Vui lòng thử lại.'),
          ),
        );
      }
    }
  }

  String get _tieuDe => switch (_vi.trangThai) {
    TrangThaiKetNoiVi.chuaKetNoi => 'Chưa kết nối ví',
    TrangThaiKetNoiVi.dangKetNoi => 'Đang kết nối ví (Demo)',
    TrangThaiKetNoiVi.daKetNoi => 'Đã kết nối ví (Demo)',
    TrangThaiKetNoiVi.thatBai => 'Kết nối thất bại (Demo)',
    TrangThaiKetNoiVi.saiMang => 'Sai mạng (Demo)',
  };

  Widget _tieuDeMuc(String chu) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(chu, style: KieuChu.noiDungDam),
  );

  Widget _theThongTin(
    IconData icon,
    Color mau,
    String ten,
    String moTa, {
    Widget? nhan,
  }) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: BangMau.nenThe,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: BangMau.vien),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: mau.withValues(alpha: .12),
          child: Icon(icon, color: mau),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ten, style: KieuChu.noiDungDam),
              const SizedBox(height: 4),
              Text(moTa, style: KieuChu.chuPhu),
              if (nhan != null) ...[const SizedBox(height: 8), nhan],
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([_vi, _kho]),
    builder: (context, _) {
      final h = _kho.theoId(widget.hopDongId);
      final dangKetNoi = _vi.trangThai == TrangThaiKetNoiVi.dangKetNoi;
      final diaChi = _vi.diaChi;
      return KhungTrang(
        mauNen: BangMau.nenThe,
        appBar: AppBar(
          centerTitle: true,
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          title: const Text('Kết nối ví'),
          leading: NutBieuTuong(
            bieuTuong: Icons.arrow_back_ios_new,
            goiY: 'Quay lại',
            khiNhan: _quayLai,
          ),
        ),
        noiDung: h == null
            ? const TrangThaiRong(
                tieuDe: 'Không tìm thấy hợp đồng',
                moTa: 'Vui lòng quay lại và chọn hợp đồng cần xử lý.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Phần minh họa ví được vẽ bằng các icon vector Flutter.
                  const SizedBox(height: 12), const Center(child: _MinhHoaVi()),
                  const SizedBox(height: 18),
                  Text(
                    _tieuDe,
                    style: KieuChu.tieuDeMuc,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kết nối ví để ký hợp đồng và thực hiện các giao dịch đặt cọc trên blockchain.',
                    textAlign: TextAlign.center,
                    style: KieuChu.chuPhu,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hợp đồng ${h.maHopDong}',
                    textAlign: TextAlign.center,
                    style: KieuChu.chuNho,
                  ),
                  if (h.choKyVi)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Đã đồng ý điều khoản (Demo) · Chờ ký ví',
                        textAlign: TextAlign.center,
                        style: KieuChu.chuNho,
                      ),
                    ),
                  if (_vi.cheDoMoPhong)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Center(
                        child: NhanTrangThai(
                          trangThai: TrangThaiHienThi.choDuyet,
                          nhan: 'Chế độ mô phỏng',
                        ),
                      ),
                    ),
                  // Phần mạng và token lấy từ môi trường demo đang được dự án sử dụng.
                  _tieuDeMuc('Mạng hỗ trợ'),
                  _theThongTin(
                    Icons.hub_outlined,
                    BangMau.chinh,
                    TrangThaiViMau.mangDuKien,
                    'Mạng phát triển cục bộ theo cấu hình dự án. Chưa kết nối RPC.',
                    nhan: const NhanTrangThai(
                      trangThai: TrangThaiHienThi.dangXuLy,
                      nhan: 'Local · Mạng dự kiến',
                    ),
                  ),
                  _tieuDeMuc('Token sử dụng'),
                  _theThongTin(
                    Icons.toll_outlined,
                    BangMau.canhBao,
                    TrangThaiViMau.tokenDuKien,
                    'Token thử nghiệm cho RoomChain AI, không phải VND thật.',
                  ),
                  const SizedBox(height: 24),
                  if (_vi.trangThai == TrangThaiKetNoiVi.thatBai) ...[
                    const ThongBaoNoiDung(
                      loai: LoaiThongBao.loi,
                      noiDung: 'Tình huống thất bại mô phỏng. Chưa có ví hoặc giao dịch được kết nối.',
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_vi.trangThai == TrangThaiKetNoiVi.saiMang) ...[
                    const ThongBaoNoiDung(
                      loai: LoaiThongBao.canhBao,
                      noiDung: 'Tình huống sai mạng mô phỏng. Mạng dự kiến là Hardhat Local; chưa yêu cầu đổi mạng trên ví thật.',
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (diaChi != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Địa chỉ mẫu (Demo)\n${diaChi.substring(0, 8)}…${diaChi.substring(diaChi.length - 6)}',
                            style: KieuChu.chuPhu,
                          ),
                        ),
                        NutBieuTuong(
                          bieuTuong: Icons.copy_outlined,
                          goiY: 'Sao chép địa chỉ demo',
                          khiNhan: _copyDiaChi,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    NutBam(
                      nhan: 'Ngắt kết nối demo',
                      kieu: KieuNut.phu,
                      khiNhan: _vi.ngatKetNoi,
                    ),
                    const SizedBox(height: 12),
                    NutBam(
                      nhan: 'Tiếp tục ký hợp đồng',
                      voHieuHoa: h.nguoiThueDongYLuc == null,
                      khiNhan: () => Navigator.pushNamed(
                        context,
                        DieuHuong.kyHopDong,
                        arguments: ThamSoHopDong(
                          hopDongId: h.id,
                          kho: _kho,
                          vi: _vi,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ký và đặt cọc ở các bước tiếp theo chỉ là mô phỏng.',
                      style: KieuChu.chuPhu,
                    ),
                  ] else
                    NutBam(
                      nhan: 'Kết nối ví',
                      bieuTuong: Icons.account_balance_wallet_outlined,
                      dangTai: dangKetNoi,
                      voHieuHoa: _dangChon,
                      khiNhan: _ketNoi,
                    ),
                  const SizedBox(height: 16),
                  // Phần an toàn và bảo mật.
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BangMau.thongTinNhat,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: BangMau.thongTin,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'An toàn & bảo mật',
                                style: KieuChu.noiDungDam,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Chúng tôi không lưu private key của bạn. Kết nối ví chỉ dùng để ký giao dịch.',
                                style: KieuChu.chuPhu,
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Hiện tại chỉ mô phỏng giao diện, chưa yêu cầu ví thật ký giao dịch.',
                                style: KieuChu.chuNho,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
      );
    },
  );
}

class _MinhHoaVi extends StatelessWidget {
  const _MinhHoaVi();
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Minh họa kết nối ví',
    child: SizedBox(
      width: 128,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -.2,
            child: const Icon(
              Icons.credit_card_rounded,
              size: 90,
              color: BangMau.chinhNhat,
            ),
          ),
          Icon(
            Icons.account_balance_wallet_rounded,
            size: 100,
            color: BangMau.chinh.withValues(alpha: .55),
          ),
          const Positioned(
            right: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: BangMau.chinh,
              child: Icon(Icons.link, color: BangMau.nenThe, size: 28),
            ),
          ),
        ],
      ),
    ),
  );
}
