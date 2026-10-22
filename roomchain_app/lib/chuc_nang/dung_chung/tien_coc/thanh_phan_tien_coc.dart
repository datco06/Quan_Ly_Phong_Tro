import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';

class NhanTienCoc extends StatelessWidget {
  const NhanTienCoc({super.key, required this.trangThai});
  final TrangThaiTienCoc trangThai;
  @override
  Widget build(BuildContext context) => NhanTrangThai(
    nhan: trangThai.nhan,
    trangThai: switch (trangThai) {
      TrangThaiTienCoc.thatBai => TrangThaiHienThi.thatBai,
      TrangThaiTienCoc.choQuyetToan ||
      TrangThaiTienCoc.choNguoiThueXacNhan ||
      TrangThaiTienCoc.choXacNhan => TrangThaiHienThi.choDuyet,
      TrangThaiTienCoc.chuaDat => TrangThaiHienThi.dangXuLy,
      _ => TrangThaiHienThi.thanhCong,
    },
  );
}

String soTienKhongDonVi(int giaTri) => dinhDangVND(giaTri).replaceAll('đ', '');
