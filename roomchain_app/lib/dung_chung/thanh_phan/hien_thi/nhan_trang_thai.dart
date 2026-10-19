import 'package:flutter/material.dart';

import '../../giao_dien/bang_mau.dart';

enum TrangThaiHienThi {
  thanhCong,
  choDuyet,
  chuaThanhToan,
  quaHan,
  thatBai,
  dangXuLy,
  conTrong,
  dangThue,
}

extension MauTrangThai on TrangThaiHienThi {
  String get nhan => switch (this) {
    TrangThaiHienThi.thanhCong => 'Thành công',
    TrangThaiHienThi.choDuyet => 'Chờ duyệt',
    TrangThaiHienThi.chuaThanhToan => 'Chưa thanh toán',
    TrangThaiHienThi.quaHan => 'Quá hạn',
    TrangThaiHienThi.thatBai => 'Thất bại',
    TrangThaiHienThi.dangXuLy => 'Đang xử lý',
    TrangThaiHienThi.conTrong => 'Còn trống',
    TrangThaiHienThi.dangThue => 'Đang thuê',
  };
  Color get mau => switch (this) {
    TrangThaiHienThi.thatBai ||
    TrangThaiHienThi.quaHan ||
    TrangThaiHienThi.chuaThanhToan => BangMau.loi,
    TrangThaiHienThi.choDuyet => BangMau.canhBao,
    TrangThaiHienThi.dangXuLy => BangMau.thongTin,
    _ => BangMau.thanhCong,
  };
  Color get nen => switch (this) {
    TrangThaiHienThi.thatBai ||
    TrangThaiHienThi.quaHan ||
    TrangThaiHienThi.chuaThanhToan => BangMau.loiNhat,
    TrangThaiHienThi.choDuyet => BangMau.canhBaoNhat,
    TrangThaiHienThi.dangXuLy => BangMau.thongTinNhat,
    _ => BangMau.thanhCongNhat,
  };
}

class NhanTrangThai extends StatelessWidget {
  const NhanTrangThai({super.key, required this.trangThai, this.nhan});
  final TrangThaiHienThi trangThai;
  final String? nhan;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: trangThai.nen,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text(
      nhan ?? trangThai.nhan,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: trangThai.mau, fontWeight: FontWeight.w600),
    ),
  );
}
