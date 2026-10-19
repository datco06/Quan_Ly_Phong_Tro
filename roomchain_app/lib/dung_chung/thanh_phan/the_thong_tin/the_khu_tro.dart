import 'package:flutter/material.dart';

import '../../mo_hinh/khu_tro.dart';
import '../hinh_anh/anh_thu_nho.dart';
import '../hien_thi/nhan_trang_thai.dart';
import 'khung_the.dart';

class TheKhuTro extends StatelessWidget {
  const TheKhuTro({super.key, required this.khuTro, this.khiNhan});
  final KhuTro khuTro;
  final VoidCallback? khiNhan;
  @override
  Widget build(BuildContext context) => KhungThe(
    khiNhan: khiNhan,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnhThuNho(nguon: khuTro.anhDaiDien, rong: double.infinity, cao: 120),
        const SizedBox(height: 12),
        Text(khuTro.tenKhuTro, style: Theme.of(context).textTheme.titleMedium),
        Text(khuTro.diaChi),
        const SizedBox(height: 8),
        NhanTrangThai(
          trangThai: khuTro.dangHoatDong
              ? TrangThaiHienThi.thanhCong
              : TrangThaiHienThi.choDuyet,
          nhan: khuTro.dangHoatDong ? 'Đang hoạt động' : 'Tạm ngừng',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            Text('${khuTro.tongSoPhong} Tổng phòng'),
            Text('${khuTro.soPhongDangThue} Đang thuê'),
            Text('${khuTro.soPhongTrong} Phòng trống'),
          ],
        ),
      ],
    ),
  );
}
