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

Future<void> hienThiHopDongMau(
  BuildContext context,
  HopDong h,
  KhoHopDongMau kho,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(h.maHopDong),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chưa có màn hình chi tiết hợp đồng. Đây là thông tin trong bộ nhớ demo.',
          ),
          const SizedBox(height: 12),
          NhanHopDong(trangThai: h.trangThai),
          DongThongTin(nhan: 'Phòng', giaTri: kho.phong(h.phongId).maPhong),
          DongThongTin(
            nhan: 'Người thuê',
            giaTri: kho.nguoi(h.nguoiThueId).hoTen,
          ),
          DongThongTin(nhan: 'Bắt đầu', giaTri: dinhDangNgay(h.ngayBatDau)),
          DongThongTin(nhan: 'Kết thúc', giaTri: dinhDangNgay(h.ngayKetThuc)),
          DongThongTin(nhan: 'Tiền phòng', giaTri: dinhDangVND(h.giaThue)),
          DongThongTin(nhan: 'Tiền cọc', giaTri: dinhDangVND(h.tienCoc)),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Đóng'),
      ),
    ],
  ),
);
