import 'package:flutter/material.dart';

class DongThongTin extends StatelessWidget {
  const DongThongTin({
    super.key,
    required this.nhan,
    required this.giaTri,
    this.bieuTuong,
  });
  final String nhan, giaTri;
  final IconData? bieuTuong;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bieuTuong != null) ...[
          Icon(bieuTuong, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(nhan, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(giaTri, textAlign: TextAlign.right)),
      ],
    ),
  );
}
