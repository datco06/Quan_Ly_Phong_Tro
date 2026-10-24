import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../dung_chung/mo_hinh/giao_dich_blockchain.dart';
import '../../../../ung_dung/dieu_huong.dart';
import '../vi_blockchain/trang_thai_vi_mau.dart';
import '../vi_blockchain/thanh_phan_giao_dich_demo.dart';

class TrangThaiDatCoc extends StatelessWidget {
  const TrangThaiDatCoc({
    super.key,
    required this.hopDongId,
    this.kho,
    this.vi,
  });
  final String hopDongId;
  final KhoHopDongMau? kho;
  final TrangThaiViMau? vi;
  KhoHopDongMau get _kho => kho ?? KhoHopDongMau.dungChung;
  ThamSoHopDong get _thamSo =>
      ThamSoHopDong(hopDongId: hopDongId, kho: _kho, vi: vi);

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _kho,
    builder: (context, _) {
      final h = _kho.theoId(hopDongId);
      final g = h?.coc?.giaoDich;
      final xong = _kho.daKhoaCocDemo(hopDongId);
      final loi = g?.buoc == BuocDatCocDemo.thatBai;
      final ma = GiaoDichBlockchain.hashHopLe(g?.transactionHash)
          ? g!.transactionHash
          : null;
      return KhungTrang(
        mauNen: BangMau.nenThe,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Trạng thái đặt cọc'),
          titleTextStyle: Theme.of(context).textTheme.titleMedium,
          leading: NutBieuTuong(
            bieuTuong: Icons.arrow_back_ios_new,
            goiY: 'Quay lại',
            khiNhan: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  return;
                }
                Navigator.pushReplacementNamed(
                  context,
                  DieuHuong.datCoc,
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
                  // Phần hình trạng thái; chỉ dùng dấu check khi biên nhận demo hợp lệ.
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      height: 120,
                      width: 190,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: xong
                                ? BangMau.thanhCong
                                : loi
                                ? BangMau.loiNhat
                                : BangMau.chinhNhat,
                            child: Icon(
                              xong
                                  ? Icons.check_rounded
                                  : loi
                                  ? Icons.error_outline
                                  : Icons.schedule,
                              size: 60,
                              color: xong
                                  ? BangMau.nenThe
                                  : loi
                                  ? BangMau.loi
                                  : BangMau.chinh,
                            ),
                          ),
                          if (xong) ...[
                            const Positioned(
                              top: 8,
                              left: 20,
                              child: Icon(
                                Icons.star,
                                size: 12,
                                color: BangMau.canhBao,
                              ),
                            ),
                            const Positioned(
                              top: 22,
                              right: 10,
                              child: Icon(
                                Icons.circle,
                                size: 8,
                                color: BangMau.thongTin,
                              ),
                            ),
                            const Positioned(
                              bottom: 8,
                              right: 28,
                              child: Icon(
                                Icons.star,
                                size: 12,
                                color: BangMau.canhBao,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Text(
                    xong
                        ? 'Đã khóa cọc thành công'
                        : loi
                        ? 'Đặt cọc chưa thành công'
                        : 'Đang chờ xác nhận',
                    textAlign: TextAlign.center,
                    style: KieuChu.tieuDeTrang.copyWith(
                      color: xong ? BangMau.chinh : BangMau.chuChinh,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    xong
                        ? '${dinhDangMockVNDC(g!.soToken)} đã được ghi nhận khóa trong escrow mô phỏng.'
                        : loi
                        ? 'Chưa ghi nhận khóa cọc hoặc trừ số dư demo.'
                        : g == null
                        ? 'Chưa bắt đầu quy trình đặt cọc cho hợp đồng này.'
                        : 'Đang xử lý biên nhận đặt cọc mô phỏng.',
                    style: KieuChu.chuPhu,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: NhanTrangThai(
                      trangThai: TrangThaiHienThi.choDuyet,
                      nhan: 'Chế độ mô phỏng',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hợp đồng ${h.maHopDong}',
                    textAlign: TextAlign.center,
                    style: KieuChu.chuNho,
                  ),
                  const SizedBox(height: 24),
                  // Phần timeline xác nhận lấy thời gian từ cùng bản ghi giao dịch.
                  DongThoiGian(
                    cacBuoc: [
                      BuocThoiGian(
                        tieuDe: 'Ví xác nhận',
                        ngayGio: g?.viXacNhanLuc,
                        moTa: 'Xác nhận thao tác demo, chưa yêu cầu ví thật.',
                        trangThai: g?.viXacNhanLuc != null
                            ? TrangThaiBuoc.hoanThanh
                            : TrangThaiBuoc.hienTai,
                      ),
                      BuocThoiGian(
                        tieuDe: 'Đã gửi giao dịch',
                        ngayGio: g?.datCocGuiLuc,
                        moTa: 'Yêu cầu Deposit mô phỏng.',
                        bieuTuong:
                            loi &&
                                !GiaoDichBlockchain.hashHopLe(
                                  g?.transactionHash,
                                )
                            ? Icons.error_outline
                            : null,
                        trangThai: g?.datCocGuiLuc != null && ma != null
                            ? TrangThaiBuoc.hoanThanh
                            : g != null
                            ? TrangThaiBuoc.hienTai
                            : TrangThaiBuoc.chuaDen,
                      ),
                      BuocThoiGian(
                        tieuDe: 'Blockchain xác nhận',
                        ngayGio: xong ? g?.blockXacNhanLuc : null,
                        moTa: 'Biên nhận mẫu, chưa được kiểm chứng bằng RPC.',
                        bieuTuong:
                            loi && g?.buocThatBai == LoiDatCocDemo.xacNhan
                            ? Icons.error_outline
                            : null,
                        trangThai: xong
                            ? TrangThaiBuoc.hoanThanh
                            : ma != null
                            ? TrangThaiBuoc.hienTai
                            : TrangThaiBuoc.chuaDen,
                      ),
                      BuocThoiGian(
                        tieuDe: 'Đã khóa cọc thành công',
                        ngayGio: xong ? g?.khoaCocLuc : null,
                        trangThai: xong
                            ? TrangThaiBuoc.hoanThanh
                            : TrangThaiBuoc.chuaDen,
                      ),
                    ],
                  ),
                  if (loi) ...[
                    ThongBaoNoiDung(
                      noiDung: g?.loi ?? 'Giao dịch mô phỏng thất bại.',
                      loai: LoaiThongBao.loi,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (g?.buoc == BuocDatCocDemo.daKhoa && !xong) ...[
                    const ThongBaoNoiDung(
                      noiDung: 'Biên nhận hoặc dữ liệu hợp đồng chưa đủ điều kiện xác nhận khóa cọc.',
                      loai: LoaiThongBao.canhBao,
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Phần transaction hash: không tạo URL Explorer cho hash mẫu.
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BangMau.thongTinNhat,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DongMaDemo(
                          nhan: 'Transaction hash',
                          giaTri: ma,
                          khiThieu: 'Chưa có giao dịch',
                        ),
                        const Text(
                          'Giao dịch mô phỏng · Hash mẫu cố định, không có Explorer cho biên nhận này.',
                          style: KieuChu.chuNho,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  NutBam(
                    nhan: xong ? 'Về trang phòng của tôi' : 'Quay lại đặt cọc',
                    khiNhan: () {
                      if (xong) {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Phòng của tôi'),
                            content: const Text(
                              'Trang Phòng của tôi chưa được triển khai. Tiền cọc đã được ghi nhận trong kho demo dùng chung.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Đóng'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.pushReplacementNamed(
                          context,
                          DieuHuong.datCoc,
                          arguments: _thamSo,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kết quả demo trong bộ nhớ; chưa có chuyển token hoặc xác nhận trên Blockchain thật.',
                    textAlign: TextAlign.center,
                    style: KieuChu.chuNho,
                  ),
                ],
              ),
      );
    },
  );
}
