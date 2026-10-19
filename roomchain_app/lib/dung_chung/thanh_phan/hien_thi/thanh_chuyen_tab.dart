import 'package:flutter/material.dart';

import 'chip_loc.dart';

class CauHinhTab {
  const CauHinhTab(this.nhan, {this.bieuTuong});
  final String nhan;
  final IconData? bieuTuong;
}

class ThanhChuyenTab extends StatelessWidget {
  const ThanhChuyenTab({
    super.key,
    required this.danhSach,
    required this.chiSoChon,
    required this.khiChon,
  }) : assert(chiSoChon >= 0 && chiSoChon < danhSach.length);
  final List<CauHinhTab> danhSach;
  final int chiSoChon;
  final ValueChanged<int> khiChon;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(
        danhSach.length,
        (i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChipLoc(
            nhan: danhSach[i].nhan,
            bieuTuong: danhSach[i].bieuTuong,
            daChon: chiSoChon == i,
            khiChon: (_) => khiChon(i),
          ),
        ),
      ),
    ),
  );
}
