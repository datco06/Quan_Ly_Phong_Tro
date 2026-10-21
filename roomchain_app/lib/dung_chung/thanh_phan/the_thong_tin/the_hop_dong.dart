import 'package:flutter/material.dart';

import '../../mo_hinh/hop_dong.dart';
import '../../tien_ich/dinh_dang_ngay.dart';
import '../../tien_ich/dinh_dang_tien.dart';
import '../hien_thi/dong_thong_tin.dart';
import '../hien_thi/nhan_trang_thai.dart';
import 'khung_the.dart';

class TheHopDong extends StatelessWidget {
  const TheHopDong({
    super.key,
    required this.hopDong,
    required this.maPhong,
    required this.tenNguoiThue,
    this.khiNhan,
  });
  final HopDong hopDong;
  final String maPhong, tenNguoiThue;
  final VoidCallback? khiNhan;
  @override
  Widget build(BuildContext context) => KhungThe(
    khiNhan: khiNhan,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hopDong.maHopDong, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        NhanTrangThai(
          trangThai: hopDong.trangThai == TrangThaiHopDong.dangHieuLuc
              ? TrangThaiHienThi.dangThue
              : TrangThaiHienThi.choDuyet,
          nhan: switch (hopDong.trangThai) {
            TrangThaiHopDong.nhap => 'Nháp',
            TrangThaiHopDong.choKy => 'Chờ ký',
            TrangThaiHopDong.choCoc => 'Chờ cọc',
            TrangThaiHopDong.dangHieuLuc => 'Đang hiệu lực',
            TrangThaiHopDong.daKetThuc => 'Đã kết thúc',
          },
        ),
        DongThongTin(nhan: 'Phòng', giaTri: maPhong),
        DongThongTin(nhan: 'Người thuê', giaTri: tenNguoiThue),
        DongThongTin(nhan: 'Bắt đầu', giaTri: dinhDangNgay(hopDong.ngayBatDau)),
        DongThongTin(
          nhan: 'Kết thúc',
          giaTri: dinhDangNgay(hopDong.ngayKetThuc),
        ),
        DongThongTin(
          nhan: 'Giá thuê',
          giaTri: '${dinhDangVND(hopDong.giaThue)}/tháng',
        ),
      ],
    ),
  );
}
