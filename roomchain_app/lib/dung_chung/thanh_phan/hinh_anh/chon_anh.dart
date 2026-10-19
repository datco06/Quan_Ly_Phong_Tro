import 'package:flutter/material.dart';

import '../../giao_dien/bang_mau.dart';

class ChonAnh extends StatelessWidget {
  const ChonAnh({super.key, this.soAnh = 0, this.toiDa = 5, this.khiChon})
    : assert(soAnh >= 0 && toiDa > 0);
  final int soAnh, toiDa;
  final VoidCallback? khiChon;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _VienNetDut(),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: soAnh < toiDa ? khiChon : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.add_a_photo_outlined),
            const SizedBox(height: 8),
            const Text('Chụp hoặc tải ảnh'),
            Text('$soAnh/$toiDa', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ),
  );
}

class _VienNetDut extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BangMau.vien
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      );
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VienNetDut oldDelegate) => false;
}
