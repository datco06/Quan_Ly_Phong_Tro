import 'package:flutter/material.dart';

import 'nhan_trang_thai.dart';

enum LoaiThongBao { thongTin, thanhCong, canhBao, loi }

class ThongBaoNoiDung extends StatelessWidget {
  const ThongBaoNoiDung({
    super.key,
    required this.noiDung,
    this.loai = LoaiThongBao.thongTin,
  });
  final String noiDung;
  final LoaiThongBao loai;
  @override
  Widget build(BuildContext context) {
    final status = switch (loai) {
      LoaiThongBao.thongTin => TrangThaiHienThi.dangXuLy,
      LoaiThongBao.thanhCong => TrangThaiHienThi.thanhCong,
      LoaiThongBao.canhBao => TrangThaiHienThi.choDuyet,
      LoaiThongBao.loi => TrangThaiHienThi.thatBai,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.nen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            loai == LoaiThongBao.canhBao
                ? Icons.warning_amber
                : Icons.info_outline,
            color: status.mau,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(noiDung)),
        ],
      ),
    );
  }
}
