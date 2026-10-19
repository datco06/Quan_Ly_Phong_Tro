import 'package:flutter/material.dart';

import 'thanh_dieu_huong_vai_tro.dart';

class BoCucNguoiThue extends StatelessWidget {
  const BoCucNguoiThue({
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
    MucDieuHuong('Khám phá', Icons.home_outlined),
    MucDieuHuong('Gợi ý AI', Icons.explore_outlined),
    MucDieuHuong('Phòng của tôi', Icons.calendar_today_outlined),
    MucDieuHuong('Thông báo', Icons.notifications_outlined),
    MucDieuHuong('Tài khoản', Icons.person_outline),
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
