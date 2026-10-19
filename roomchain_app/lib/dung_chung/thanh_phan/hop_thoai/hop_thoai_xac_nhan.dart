import 'package:flutter/material.dart';

import '../nut_bam/nut_bam.dart';

class HopThoaiXacNhan extends StatelessWidget {
  const HopThoaiXacNhan({
    super.key,
    required this.tieuDe,
    required this.noiDung,
    this.nhanXacNhan = 'Xác nhận',
    this.nhanHuy = 'Hủy',
    this.nguyHiem = false,
    this.khiXacNhan,
  });
  final String tieuDe, noiDung, nhanXacNhan, nhanHuy;
  final bool nguyHiem;
  final VoidCallback? khiXacNhan;
  static Future<bool?> hienThi(
    BuildContext context, {
    required String tieuDe,
    required String noiDung,
    bool nguyHiem = false,
  }) => showDialog<bool>(
    context: context,
    builder: (_) =>
        HopThoaiXacNhan(tieuDe: tieuDe, noiDung: noiDung, nguyHiem: nguyHiem),
  );
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(tieuDe),
    content: Text(noiDung),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(nhanHuy),
      ),
      NutBam(
        nhan: nhanXacNhan,
        rongHet: false,
        kieu: nguyHiem ? KieuNut.nguyHiem : KieuNut.chinh,
        khiNhan: () {
          Navigator.pop(context, true);
          khiXacNhan?.call();
        },
      ),
    ],
  );
}
