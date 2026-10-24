import 'package:flutter/material.dart';

import '../../../../dung_chung/giao_dien/bang_mau.dart';
import '../../../../dung_chung/giao_dien/khoang_cach.dart';
import '../../../../dung_chung/giao_dien/kieu_chu.dart';
import '../../../../dung_chung/giao_dien/kich_thuoc.dart';

class OThongKeNho extends StatelessWidget {
  const OThongKeNho({
    super.key,
    required this.tieuDe,
    required this.giaTri,
    required this.bieuTuong,
    required this.mauBieuTuong,
    required this.mauNen,
    this.mauGiaTri,
    this.khiNhan,
  });

  final String tieuDe;
  final String giaTri;
  final IconData bieuTuong;
  final Color mauBieuTuong;
  final Color mauNen;
  final Color? mauGiaTri;
  final VoidCallback? khiNhan;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: khiNhan,
      child: Container(
        padding: const EdgeInsets.all(KhoangCach.vua),
        decoration: BoxDecoration(
          color: BangMau.nenThe,
          borderRadius: BorderRadius.circular(KichThuoc.boThe),
          border: Border.all(color: BangMau.vien),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: mauNen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(bieuTuong, color: mauBieuTuong, size: 20),
            ),
            const SizedBox(width: KhoangCach.nho),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieuDe,
                    style: KieuChu.chuNho.copyWith(color: BangMau.chuPhu),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    giaTri,
                    style: KieuChu.tieuDeThe.copyWith(
                      color: mauGiaTri ?? BangMau.chuChinh,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
