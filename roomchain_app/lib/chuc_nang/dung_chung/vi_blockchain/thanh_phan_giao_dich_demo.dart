import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../dung_chung/roomchain_ui.dart';

// Dòng hash/địa chỉ: rút gọn trên màn hình, sao chép đầy đủ giá trị.
class DongMaDemo extends StatelessWidget {
  const DongMaDemo({
    super.key,
    required this.nhan,
    this.giaTri,
    this.khiThieu = 'Chưa có thông tin',
  });
  final String nhan, khiThieu;
  final String? giaTri;
  @override
  Widget build(BuildContext context) {
    final ma = giaTri;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(nhan, style: KieuChu.chuPhu)),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              ma == null
                  ? khiThieu
                  : ma.length > 24
                  ? '${ma.substring(0, 12)}…${ma.substring(ma.length - 8)}'
                  : ma,
              textAlign: TextAlign.right,
              style: KieuChu.noiDungDam,
            ),
          ),
          if (ma != null)
            NutBieuTuong(
              bieuTuong: Icons.copy_outlined,
              goiY: 'Sao chép $nhan',
              khiNhan: () async {
                try {
                  await Clipboard.setData(ClipboardData(text: ma));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã sao chép đầy đủ $nhan.')),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không thể sao chép. Vui lòng thử lại.'),
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}
