import 'package:flutter/material.dart';

import '../../giao_dien/bang_mau.dart';

class AnhThuNho extends StatelessWidget {
  const AnhThuNho({super.key, this.nguon, this.rong, this.cao = 100});
  final String? nguon;
  final double? rong;
  final double cao;
  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: BangMau.chinhNhat,
      alignment: Alignment.center,
      child: const Icon(Icons.home_outlined, color: BangMau.chinh, size: 32),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: rong,
        height: cao,
        child: nguon == null || nguon!.isEmpty
            ? fallback
            : (nguon!.startsWith('https://') || nguon!.startsWith('http://'))
            ? Image.network(
                nguon!,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => fallback,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
              )
            : Image.asset(
                nguon!,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) => fallback,
              ),
      ),
    );
  }
}
