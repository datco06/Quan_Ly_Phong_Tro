import 'package:flutter/material.dart';

import '../../giao_dien/bang_mau.dart';

enum KieuDangTai { nho, toanTrang, skeleton }

class HienThiDangTai extends StatelessWidget {
  const HienThiDangTai({
    super.key,
    this.kieu = KieuDangTai.nho,
    this.thongDiep,
  });
  final KieuDangTai kieu;
  final String? thongDiep;
  @override
  Widget build(BuildContext context) {
    if (kieu == KieuDangTai.skeleton) {
      return Semantics(
        label: thongDiep ?? 'Đang tải',
        child: Column(
          children: [
            for (final width in [double.infinity, 180.0, 120.0])
              Container(
                height: 16,
                width: width,
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: BangMau.vien,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ],
        ),
      );
    }
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        if (thongDiep != null) ...[
          const SizedBox(height: 12),
          Text(thongDiep!),
        ],
      ],
    );
    return kieu == KieuDangTai.toanTrang ? Center(child: child) : child;
  }
}
