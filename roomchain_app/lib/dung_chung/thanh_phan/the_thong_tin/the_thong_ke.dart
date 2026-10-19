import 'package:flutter/material.dart';

import '../../giao_dien/bang_mau.dart';
import 'khung_the.dart';

class TheThongKe extends StatelessWidget {
  const TheThongKe({
    super.key,
    required this.tieuDe,
    required this.giaTri,
    required this.bieuTuong,
    this.mau = BangMau.chinh,
    this.phanTram,
    this.khiNhan,
  });
  final String tieuDe, giaTri;
  final IconData bieuTuong;
  final Color mau;
  final double? phanTram;
  final VoidCallback? khiNhan;
  @override
  Widget build(BuildContext context) => KhungThe(
    khiNhan: khiNhan,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(bieuTuong, color: mau),
        const SizedBox(height: 8),
        Text(tieuDe),
        Text(
          giaTri,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: mau),
        ),
        if (phanTram != null)
          Text(
            '${phanTram! >= 0 ? '+' : ''}$phanTram%',
            style: TextStyle(
              color: phanTram! >= 0 ? BangMau.thanhCong : BangMau.loi,
            ),
          ),
      ],
    ),
  );
}
