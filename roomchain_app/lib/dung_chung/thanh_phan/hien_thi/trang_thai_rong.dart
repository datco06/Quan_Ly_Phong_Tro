import 'package:flutter/material.dart';

import '../nut_bam/nut_bam.dart';

class TrangThaiRong extends StatelessWidget {
  const TrangThaiRong({
    super.key,
    required this.tieuDe,
    required this.moTa,
    this.bieuTuong = Icons.inbox_outlined,
    this.minhHoa,
    this.nhanHanhDong,
    this.khiNhan,
  });
  final String tieuDe, moTa;
  final IconData bieuTuong;
  final Widget? minhHoa;
  final String? nhanHanhDong;
  final VoidCallback? khiNhan;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        minhHoa ?? Icon(bieuTuong, size: 56),
        const SizedBox(height: 16),
        Text(
          tieuDe,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(moTa, textAlign: TextAlign.center),
        if (nhanHanhDong != null) ...[
          const SizedBox(height: 16),
          NutBam(nhan: nhanHanhDong!, khiNhan: khiNhan),
        ],
      ],
    ),
  );
}
