import 'package:flutter/material.dart';

import 'khung_trang.dart';

class BoCucXacThuc extends StatelessWidget {
  const BoCucXacThuc({
    super.key,
    required this.noiDung,
    this.header,
    this.hanhDongDuoi,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget noiDung;
  final Widget? header, hanhDongDuoi;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => KhungTrang(
    padding: padding,
    hanhDongDuoi: hanhDongDuoi,
    noiDung: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[header!, const SizedBox(height: 24)],
        noiDung,
      ],
    ),
  );
}
