import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../dung_chung/roomchain_ui.dart';

class MaBamTaiLieu extends StatelessWidget {
  const MaBamTaiLieu({super.key, this.maBam});
  final String? maBam;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Mã băm hợp đồng (Blockchain)', style: KieuChu.noiDungDam),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: BangMau.nen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                maBam == null
                    ? 'Chưa tạo mã băm'
                    : '${maBam!.substring(0, 12)}…${maBam!.substring(maBam!.length - 10)}',
                style: KieuChu.chuPhu,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            NutBieuTuong(
              bieuTuong: Icons.copy_outlined,
              goiY: 'Sao chép mã băm',
              khiNhan: maBam == null
                  ? null
                  : () async {
                      try {
                        await Clipboard.setData(ClipboardData(text: maBam!));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Đã sao chép toàn bộ SHA-256 của tài liệu.',
                              ),
                            ),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Không thể sao chép. Vui lòng thử lại.',
                              ),
                            ),
                          );
                        }
                      }
                    },
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'SHA-256 của file PDF; chưa ghi lên Blockchain.',
        style: KieuChu.chuNho,
      ),
    ],
  );
}
