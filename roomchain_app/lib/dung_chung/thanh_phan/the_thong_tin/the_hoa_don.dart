import 'package:flutter/material.dart';

import '../../mo_hinh/hoa_don.dart';
import '../../tien_ich/dinh_dang_tien.dart';
import '../../tien_ich/dinh_dang_ngay.dart';
import '../hien_thi/nhan_trang_thai.dart';
import '../hien_thi/dong_thong_tin.dart';
import 'khung_the.dart';

class TheHoaDon extends StatelessWidget {
  const TheHoaDon({
    super.key,
    required this.hoaDon,
    this.tenNguoiThue,
    this.hienCongNo = true,
    this.khiNhan,
  });
  final HoaDon hoaDon;
  final String? tenNguoiThue;
  final bool hienCongNo;
  final VoidCallback? khiNhan;
  @override
  Widget build(BuildContext context) {
    final (status, label) = switch (hoaDon.trangThai) {
      TrangThaiHoaDon.nhap => (TrangThaiHienThi.choDuyet, 'Nháp'),
      TrangThaiHoaDon.chuaThanhToan => (
        TrangThaiHienThi.chuaThanhToan,
        'Chưa thanh toán',
      ),
      TrangThaiHoaDon.daThanhToan => (
        TrangThaiHienThi.thanhCong,
        'Đã thanh toán',
      ),
      TrangThaiHoaDon.quaHan => (TrangThaiHienThi.quaHan, 'Quá hạn'),
      TrangThaiHoaDon.thanhToanMotPhan => (
        TrangThaiHienThi.choDuyet,
        'Thanh toán một phần',
      ),
    };
    return KhungThe(
      khiNhan: khiNhan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tháng ${dinhDangKy(hoaDon.kyHoaDon)} · ${hoaDon.maPhong}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          NhanTrangThai(trangThai: status, nhan: label),
          if (tenNguoiThue != null) Text(tenNguoiThue!),
          const SizedBox(height: 12),
          Text(
            dinhDangVND(hoaDon.tongTien),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          DongThongTin(
            nhan: 'Hạn thanh toán',
            giaTri: dinhDangNgay(hoaDon.ngayDenHan),
            bieuTuong: Icons.calendar_today_outlined,
          ),
          if (hienCongNo)
            DongThongTin(
              nhan: 'Còn phải thanh toán',
              giaTri: dinhDangVND(hoaDon.congNoConLai),
            ),
        ],
      ),
    );
  }
}
