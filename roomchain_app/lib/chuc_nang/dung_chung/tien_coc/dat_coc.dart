import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../dung_chung/mo_hinh/giao_dich_blockchain.dart';
import '../../../../ung_dung/dieu_huong.dart';
import '../vi_blockchain/trang_thai_vi_mau.dart';
import '../vi_blockchain/thanh_phan_giao_dich_demo.dart';

class DatCoc extends StatefulWidget {
  const DatCoc({super.key, required this.hopDongId, this.kho, this.vi});
  final String hopDongId;
  final KhoHopDongMau? kho;
  final TrangThaiViMau? vi;
  @override
  State<DatCoc> createState() => _DatCocState();
}

class _DatCocState extends State<DatCoc> {
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;
  TrangThaiViMau get _vi => widget.vi ?? TrangThaiViMau.dungChung;
  ThamSoHopDong get _thamSo =>
      ThamSoHopDong(hopDongId: widget.hopDongId, kho: _kho, vi: _vi);
  bool _dangHoi = false;

  Future<void> _datCoc({LoiDatCocDemo? gayLoi}) async {
    if (_dangHoi) return;
    final loi = _kho.kiemTraDatCocDemo(widget.hopDongId, _vi);
    if (loi != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loi)));
      return;
    }
    setState(() => _dangHoi = true);
    final ok = await HopThoaiXacNhan.hienThi(
      context,
      tieuDe: 'Approve & Deposit (Demo)?',
      noiDung:
          'Chạy hai bước Approve và Deposit mô phỏng cho hợp đồng này. Số dư chỉ là dữ liệu mẫu; không kết nối RPC hoặc chuyển token thật.${gayLoi != null ? '\nTình huống được chọn: ${gayLoi.name} thất bại.' : ''}',
    );
    if (!mounted) return;
    setState(() => _dangHoi = false);
    if (ok != true) return;
    try {
      _kho.batDauDatCocDemo(widget.hopDongId, _vi, gayLoi: gayLoi);
      Navigator.pushNamed(
        context,
        DieuHuong.trangThaiDatCoc,
        arguments: _thamSo,
      );
    } on StateError catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([_kho, _vi]),
    builder: (context, _) {
      final h = _kho.theoId(widget.hopDongId);
      final g = h?.coc?.giaoDich;
      final escrow = g?.diaChiEscrow ?? h?.diaChiEscrow;
      final loi = _kho.kiemTraDatCocDemo(widget.hopDongId, _vi);
      final daKhoa = _kho.daKhoaCocDemo(widget.hopDongId);
      final duSoDu =
          h != null &&
          _vi.soDuToken >= h.tienCoc * KhoHopDongMau.tokenMoiVndDemo;
      final daApprove =
          g?.approveXacNhanLuc != null &&
          GiaoDichBlockchain.hashHopLe(g?.maApprove);
      final daGui = g?.datCocGuiLuc != null;
      final daXacNhan = g?.blockXacNhanLuc != null;
      return KhungTrang(
        mauNen: BangMau.nenThe,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Đặt cọc'),
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
                  DieuHuong.kyHopDong,
                  arguments: _thamSo,
                );
              }
            },
          ),
          actions: [
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: NhanTrangThai(
                  trangThai: TrangThaiHienThi.dangXuLy,
                  nhan: 'Local',
                ),
              ),
            ),
            PopupMenuButton<LoiDatCocDemo>(
              tooltip: 'Tình huống đặt cọc demo',
              enabled: loi == null && !_dangHoi,
              onSelected: (loi) => _datCoc(gayLoi: loi),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: LoiDatCocDemo.approve,
                  child: Text('Approve thất bại (Demo)'),
                ),
                PopupMenuItem(
                  value: LoiDatCocDemo.deposit,
                  child: Text('Deposit thất bại (Demo)'),
                ),
                PopupMenuItem(
                  value: LoiDatCocDemo.xacNhan,
                  child: Text('Biên nhận thất bại (Demo)'),
                ),
              ],
            ),
          ],
        ),
        noiDung: h == null
            ? const TrangThaiRong(
                tieuDe: 'Không tìm thấy hợp đồng',
                moTa: 'Vui lòng quay lại và chọn hợp đồng hợp lệ.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Phần số tiền lấy từ hợp đồng, tính bằng số nguyên MockVNDC.
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BangMau.chinhNhat,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Số tiền đặt cọc',
                                style: KieuChu.chuPhu,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                dinhDangMockVNDC(
                                  h.tienCoc * KhoHopDongMau.tokenMoiVndDemo,
                                ),
                                style: KieuChu.soTienVua,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '≈ ${dinhDangVND(h.tienCoc)} (quy ước demo 1:1)',
                                style: KieuChu.chuNho,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.lock_outline,
                          color: BangMau.chinh,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Token thử nghiệm; tỷ lệ demo không phải cam kết đổi sang VND thật.',
                    style: KieuChu.chuNho,
                  ),
                  const SizedBox(height: 20),
                  // Phần số dư, mạng và escrow dự kiến.
                  DongThongTin(
                    nhan: 'Số dư ví của bạn',
                    giaTri: dinhDangMockVNDC(_vi.soDuToken),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: NhanTrangThai(
                      trangThai: duSoDu
                          ? TrangThaiHienThi.thanhCong
                          : TrangThaiHienThi.thatBai,
                      nhan: duSoDu ? 'Đủ số dư (Demo)' : 'Không đủ số dư',
                    ),
                  ),
                  DongThongTin(
                    nhan: 'Allowance (Demo)',
                    giaTri: dinhDangMockVNDC(_vi.allowance),
                  ),
                  const DongThongTin(
                    nhan: 'Mạng lưới',
                    giaTri: TrangThaiViMau.mangDuKien,
                  ),
                  DongMaDemo(
                    nhan: 'Escrow smart contract',
                    giaTri: GiaoDichBlockchain.diaChiHopLe(escrow)
                        ? escrow
                        : null,
                    khiThieu: 'Chưa cấu hình contract',
                  ),
                  const Text(
                    'Hợp đồng thông minh thử nghiệm sẽ giữ tiền cọc sau khi triển khai. Hiện chỉ mô phỏng trong bộ nhớ.',
                    style: KieuChu.chuNho,
                  ),
                  const SizedBox(height: 20),
                  const Text('Các bước thực hiện', style: KieuChu.noiDungDam),
                  const SizedBox(height: 12),
                  DongThoiGian(
                    cacBuoc: [
                      BuocThoiGian(
                        tieuDe: 'Approve Token',
                        moTa: 'Cho phép dùng đúng số MockVNDC đặt cọc (Demo).',
                        ngayGio: g?.approveXacNhanLuc,
                        bieuTuong: g?.buocThatBai == LoiDatCocDemo.approve
                            ? Icons.error_outline
                            : null,
                        trangThai: daApprove
                            ? TrangThaiBuoc.hoanThanh
                            : TrangThaiBuoc.hienTai,
                      ),
                      BuocThoiGian(
                        tieuDe: 'Deposit (Đặt cọc)',
                        moTa: daGui && !daXacNhan
                            ? 'Đã gửi yêu cầu demo, đang chờ biên nhận.'
                            : 'Gửi token vào Escrow trong quy trình mô phỏng.',
                        bieuTuong: g?.buocThatBai == LoiDatCocDemo.deposit
                            ? Icons.error_outline
                            : null,
                        trangThai: daXacNhan
                            ? TrangThaiBuoc.hoanThanh
                            : daApprove
                            ? TrangThaiBuoc.hienTai
                            : TrangThaiBuoc.chuaDen,
                      ),
                      BuocThoiGian(
                        tieuDe: 'Chờ xác nhận',
                        moTa: 'Kiểm tra biên nhận mẫu, chưa đọc RPC.',
                        ngayGio: g?.blockXacNhanLuc,
                        bieuTuong: g?.buocThatBai == LoiDatCocDemo.xacNhan
                            ? Icons.error_outline
                            : null,
                        trangThai: daKhoa
                            ? TrangThaiBuoc.hoanThanh
                            : daGui
                            ? TrangThaiBuoc.hienTai
                            : TrangThaiBuoc.chuaDen,
                      ),
                      BuocThoiGian(
                        tieuDe: 'Hoàn tất',
                        moTa: 'Cọc được ghi nhận khóa trong dữ liệu demo.',
                        ngayGio: daKhoa ? g?.khoaCocLuc : null,
                        trangThai: daKhoa
                            ? TrangThaiBuoc.hoanThanh
                            : TrangThaiBuoc.chuaDen,
                      ),
                    ],
                  ),
                  if (!daKhoa && loi != null)
                    ThongBaoNoiDung(noiDung: loi, loai: LoaiThongBao.canhBao),
                  if (_vi.diaChi == null)
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        DieuHuong.ketNoiVi,
                        arguments: _thamSo,
                      ),
                      child: const Text('Kết nối lại ví demo'),
                    ),
                  const SizedBox(height: 12),
                  NutBam(
                    nhan:
                        daKhoa ||
                            h.coc?.trangThai == TrangThaiTienCoc.choXacNhan
                        ? 'Xem trạng thái đặt cọc'
                        : 'Approve & Deposit',
                    bieuTuong: Icons.account_balance_wallet_outlined,
                    voHieuHoa:
                        _dangHoi ||
                        (!daKhoa &&
                            h.coc?.trangThai != TrangThaiTienCoc.choXacNhan &&
                            loi != null),
                    khiNhan:
                        daKhoa ||
                            h.coc?.trangThai == TrangThaiTienCoc.choXacNhan
                        ? () => Navigator.pushNamed(
                            context,
                            DieuHuong.trangThaiDatCoc,
                            arguments: _thamSo,
                          )
                        : _datCoc,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chế độ mô phỏng · Approve và Deposit là hai hoạt động riêng. Không chuyển token thật.',
                    textAlign: TextAlign.center,
                    style: KieuChu.chuNho,
                  ),
                ],
              ),
      );
    },
  );
}
