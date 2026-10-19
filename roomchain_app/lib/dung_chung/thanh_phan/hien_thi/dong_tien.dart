import 'package:flutter/material.dart';

import '../../tien_ich/dinh_dang_tien.dart';

class DongTien extends StatelessWidget {
  const DongTien({
    super.key,
    required this.tenKhoanThu,
    required this.soTien,
    this.bieuTuong,
    this.mau,
    this.inDam = false,
    this.donVi = DonViTien.vnd,
  });
  final String tenKhoanThu;
  final int soTien;
  final IconData? bieuTuong;
  final Color? mau;
  final bool inDam;
  final DonViTien donVi;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bieuTuong != null) ...[
          Icon(bieuTuong, color: mau, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(tenKhoanThu)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            dinhDangTien(soTien, donVi: donVi),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: mau,
              fontWeight: inDam ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}
