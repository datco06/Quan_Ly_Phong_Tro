import 'package:flutter/material.dart';

import '../../giao_dien/bang_mau.dart';

class ChipLoc extends StatelessWidget {
  const ChipLoc({
    super.key,
    required this.nhan,
    this.daChon = false,
    this.khiChon,
    this.bieuTuong,
  });
  final String nhan;
  final bool daChon;
  final ValueChanged<bool>? khiChon;
  final IconData? bieuTuong;
  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(nhan),
    selected: daChon,
    onSelected: khiChon,
    avatar: bieuTuong == null ? null : Icon(bieuTuong, size: 18),
    selectedColor: BangMau.chinhNhat,
    side: const BorderSide(color: BangMau.vien),
  );
}
