import 'package:flutter/material.dart';

import '../giao_dien/bang_mau.dart';

class MucDieuHuong {
  const MucDieuHuong(this.nhan, this.bieuTuong);
  final String nhan;
  final IconData bieuTuong;
}

class ThanhDieuHuongVaiTro extends StatelessWidget {
  const ThanhDieuHuongVaiTro({
    super.key,
    required this.cacMuc,
    required this.chiSoChon,
    required this.khiChon,
  }) : assert(chiSoChon >= 0 && chiSoChon < cacMuc.length);
  final List<MucDieuHuong> cacMuc;
  final int chiSoChon;
  final ValueChanged<int> khiChon;

  Widget _muc(BuildContext context, int i) {
    final color = i == chiSoChon ? BangMau.chinh : BangMau.chuPhu;
    return Expanded(
      child: Semantics(
        selected: i == chiSoChon,
        button: true,
        child: InkWell(
          onTap: () => khiChon(i),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cacMuc[i].bieuTuong, color: color),
                  const SizedBox(height: 4),
                  Text(
                    cacMuc[i].nhan,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Material(
    color: BangMau.nenThe,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: BangMau.vien)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(cacMuc.length, (i) => _muc(context, i)),
        ),
      ),
    ),
  );
}
