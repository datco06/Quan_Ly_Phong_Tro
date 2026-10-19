import 'package:flutter/material.dart';

class NutBieuTuong extends StatelessWidget {
  const NutBieuTuong({
    super.key,
    required this.bieuTuong,
    required this.goiY,
    this.khiNhan,
    this.mau,
    this.nen,
    this.voHieuHoa = false,
  });
  final IconData bieuTuong;
  final String goiY;
  final VoidCallback? khiNhan;
  final Color? mau, nen;
  final bool voHieuHoa;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: goiY,
    onPressed: voHieuHoa ? null : khiNhan,
    icon: Icon(bieuTuong),
    color: mau,
    style: IconButton.styleFrom(
      backgroundColor: nen,
      minimumSize: const Size(48, 48),
    ),
  );
}
