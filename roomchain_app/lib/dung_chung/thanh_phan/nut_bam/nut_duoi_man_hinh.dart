import 'package:flutter/material.dart';

import '../../giao_dien/bang_mau.dart';

class NutDuoiManHinh extends StatelessWidget {
  const NutDuoiManHinh({
    super.key,
    required this.nutChinh,
    this.nutPhu,
    this.hienThi = true,
  });
  final Widget nutChinh;
  final Widget? nutPhu;
  final bool hienThi;
  @override
  Widget build(BuildContext context) => !hienThi
      ? const SizedBox.shrink()
      : Container(
          decoration: const BoxDecoration(
            color: BangMau.nenThe,
            border: Border(top: BorderSide(color: BangMau.vien)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (nutPhu != null) ...[
                    Expanded(child: nutPhu!),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: nutChinh),
                ],
              ),
            ),
          ),
        );
}
