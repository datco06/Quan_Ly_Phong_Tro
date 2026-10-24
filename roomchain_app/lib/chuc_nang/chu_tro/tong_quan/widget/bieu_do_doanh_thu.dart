import 'package:flutter/material.dart';

import '../../../../dung_chung/giao_dien/bang_mau.dart';

/// Biểu đồ cột mini hiển thị doanh thu theo tháng.
class BieuDoCotDoanhThu extends StatelessWidget {
  const BieuDoCotDoanhThu({super.key});

  // Dữ liệu giả: tỉ lệ doanh thu 6 tháng gần nhất (0.0 - 1.0)
  static const _duLieu = [0.55, 0.62, 0.48, 0.70, 0.80, 1.0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_duLieu.length, (i) {
          final laCuoi = i == _duLieu.length - 1;
          return _Cot(
            tiLe: _duLieu[i],
            mau: laCuoi ? BangMau.chinh : BangMau.chinhNhat,
          );
        }),
      ),
    );
  }
}

class _Cot extends StatelessWidget {
  const _Cot({required this.tiLe, required this.mau});
  final double tiLe;
  final Color mau;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: FractionallySizedBox(
          heightFactor: tiLe,
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: mau,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
