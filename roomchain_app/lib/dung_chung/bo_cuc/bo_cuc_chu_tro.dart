import 'package:flutter/material.dart';

import 'thanh_dieu_huong_vai_tro.dart';

class BoCucChuTro extends StatelessWidget {
  const BoCucChuTro({
    super.key,
    required this.noiDung,
    required this.chiSoChon,
    required this.khiChon,
    this.appBar,
  });
  final Widget noiDung;
  final int chiSoChon;
  final ValueChanged<int> khiChon;
  final PreferredSizeWidget? appBar;
  static const cacMuc = [
    MucDieuHuong('Tổng quan', Icons.home_outlined),
    MucDieuHuong('Khu trọ', Icons.holiday_village_outlined),
    MucDieuHuong('Phòng', Icons.meeting_room_outlined),
    MucDieuHuong('Hóa đơn', Icons.receipt_long_outlined),
    MucDieuHuong('Thêm', Icons.more_horiz),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    body: SafeArea(child: noiDung),
    bottomNavigationBar: ThanhDieuHuongVaiTro(
      cacMuc: cacMuc,
      chiSoChon: chiSoChon,
      khiChon: khiChon,
    ),
  );
}
