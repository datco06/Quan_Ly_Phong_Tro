import 'package:flutter/material.dart';

import '../../../../dung_chung/giao_dien/bang_mau.dart';
import '../../../../dung_chung/giao_dien/khoang_cach.dart';
import '../../../../dung_chung/giao_dien/kieu_chu.dart';

/// Dòng việc cần xử lý trong màn hình tổng quan.
class TheViecCanXuLy extends StatelessWidget {
  const TheViecCanXuLy({
    super.key,
    required this.bieuTuong,
    required this.mauBieuTuong,
    required this.mauNenBieuTuong,
    required this.tieuDe,
    required this.moTa,
    this.khiNhan,
    this.laDauTien = false,
    this.laCuoi = false,
  });

  final IconData bieuTuong;
  final Color mauBieuTuong;
  final Color mauNenBieuTuong;
  final String tieuDe;
  final String moTa;
  final VoidCallback? khiNhan;
  final bool laDauTien;
  final bool laCuoi;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: khiNhan,
      borderRadius: BorderRadius.vertical(
        top: laDauTien ? const Radius.circular(14) : Radius.zero,
        bottom: laCuoi ? const Radius.circular(14) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KhoangCach.chuan,
          vertical: KhoangCach.vua,
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: mauNenBieuTuong,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(bieuTuong, color: mauBieuTuong, size: 20),
            ),
            const SizedBox(width: KhoangCach.vua),
            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieuDe,
                    style: KieuChu.noiDungDam,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    moTa,
                    style: KieuChu.chuPhu.copyWith(color: BangMau.chuPhu),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: KhoangCach.nho),
            const Icon(
              Icons.chevron_right,
              color: BangMau.chuMo,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
