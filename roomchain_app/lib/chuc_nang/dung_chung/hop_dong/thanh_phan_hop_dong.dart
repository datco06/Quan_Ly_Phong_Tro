import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';

const dieuKhoanHoanCoc =
    'Tiền cọc thử nghiệm được Smart Contract giữ. Khi kết thúc hợp đồng, '
    'hai bên quyết toán; chủ trọ nhập các khoản khấu trừ đã thỏa thuận và người thuê xác nhận. '
    'Smart Contract giải ngân khi đủ điều kiện. Ứng dụng không có module phân xử tranh chấp.';
const luuYPhuThu =
    'Khoản phụ thu chỉ được áp dụng khi có thỏa thuận hợp lệ và phù hợp quy định pháp luật.';
const cacDieuKhoanKetThuc = [
  'Kết thúc đúng hạn',
  'Người thuê kết thúc sớm: xử lý cọc theo điều khoản hợp lệ',
  'Hai bên thỏa thuận kết thúc sớm',
  'Chủ trọ vi phạm: xử lý theo quyền và nghĩa vụ hợp lệ',
];

extension HienThiHopDong on TrangThaiHopDong {
  String get nhan => switch (this) {
    TrangThaiHopDong.nhap => 'Nháp',
    TrangThaiHopDong.choKy => 'Chờ ký',
    TrangThaiHopDong.choCoc => 'Chờ cọc',
    TrangThaiHopDong.dangHieuLuc => 'Đang thuê',
    TrangThaiHopDong.daKetThuc => 'Đã kết thúc',
  };
}

class NhanHopDong extends StatelessWidget {
  const NhanHopDong({super.key, required this.trangThai});
  final TrangThaiHopDong trangThai;
  @override
  Widget build(BuildContext context) {
    if (trangThai == TrangThaiHopDong.daKetThuc ||
        trangThai == TrangThaiHopDong.nhap) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: BangMau.nen,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          trangThai.nhan,
          style: KieuChu.chuNho.copyWith(color: BangMau.chuPhu),
        ),
      );
    }
    return NhanTrangThai(
      nhan: trangThai.nhan,
      trangThai: switch (trangThai) {
        TrangThaiHopDong.choKy => TrangThaiHienThi.choDuyet,
        TrangThaiHopDong.choCoc => TrangThaiHienThi.dangXuLy,
        _ => TrangThaiHienThi.dangThue,
      },
    );
  }
}

class ThongTinHopDong extends StatelessWidget {
  const ThongTinHopDong({super.key, required this.hopDong, required this.kho});
  final HopDong hopDong;
  final KhoHopDongMau kho;
  @override
  Widget build(BuildContext context) {
    final h = hopDong;
    final p = kho.phong(h.phongId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thông tin hợp đồng', style: KieuChu.noiDungDam),
        const SizedBox(height: 8),
        DongThongTin(nhan: 'Mã hợp đồng', giaTri: h.maHopDong),
        DongThongTin(
          nhan: 'Phòng',
          giaTri: '${p.maPhong} · ${p.dienTich.toStringAsFixed(0)}m²',
        ),
        DongThongTin(
          nhan: 'Người thuê',
          giaTri: kho.nguoi(h.nguoiThueId).hoTen,
        ),
        DongThongTin(
          nhan: 'Thời hạn',
          giaTri:
              '${dinhDangNgay(h.ngayBatDau)} – ${dinhDangNgay(h.ngayKetThuc)}',
        ),
        DongThongTin(
          nhan: 'Giá thuê',
          giaTri: '${dinhDangVND(h.giaThue)}/tháng',
        ),
        DongThongTin(nhan: 'Tiền cọc (VND)', giaTri: dinhDangVND(h.tienCoc)),
        DongThongTin(
          nhan: 'Phí dịch vụ',
          giaTri: '${dinhDangVND(h.cauHinh.phiDichVu)}/tháng',
        ),
      ],
    );
  }
}

class HangNutHopDong extends StatelessWidget {
  const HangNutHopDong({super.key, required this.chinh, this.phu});
  final Widget chinh;
  final Widget? phu;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: LayoutBuilder(
      builder: (context, c) {
        if (phu == null) return chinh;
        if (c.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(14) > 18) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [chinh, const SizedBox(height: 8), phu!],
          );
        }
        return Row(
          children: [
            Expanded(flex: 3, child: chinh),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: phu!),
          ],
        );
      },
    ),
  );
}
