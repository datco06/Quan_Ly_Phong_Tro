import 'package:flutter/material.dart';

import '../../tien_ich/dinh_dang_ngay.dart';
import '../../tien_ich/dinh_dang_tien.dart';
import '../hien_thi/nhan_trang_thai.dart';
import 'khung_the.dart';

class TheGiaoDich extends StatelessWidget {
  const TheGiaoDich({
    super.key,
    required this.tenGiaoDich,
    required this.soTien,
    required this.ngayGio,
    required this.trangThai,
    required this.donVi,
    this.khiNhan,
  });
  final String tenGiaoDich;
  final int soTien;
  final DateTime ngayGio;
  final TrangThaiHienThi trangThai;
  final DonViTien donVi;
  final VoidCallback? khiNhan;
  @override
  Widget build(BuildContext context) => KhungThe(
    khiNhan: khiNhan,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tenGiaoDich, style: Theme.of(context).textTheme.titleMedium),
        Text(dinhDangTien(soTien, donVi: donVi)),
        Text(dinhDangNgayGio(ngayGio)),
        const SizedBox(height: 8),
        NhanTrangThai(trangThai: trangThai),
      ],
    ),
  );
}
