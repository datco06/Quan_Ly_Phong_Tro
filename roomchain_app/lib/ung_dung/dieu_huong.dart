import 'package:flutter/material.dart';

import '../chuc_nang/dung_chung/man_hinh_cho/chon_vai_tro.dart';
import '../chuc_nang/dung_chung/man_hinh_cho/gioi_thieu_ung_dung_1.dart';
import '../chuc_nang/dung_chung/man_hinh_cho/gioi_thieu_ung_dung_2.dart';

abstract final class DieuHuong {
  static const gioiThieu1 = '/gioi-thieu-1';
  static const gioiThieu2 = '/gioi-thieu-2';
  static const chonVaiTro = '/chon-vai-tro';

  // Chỉ đăng ký các màn hình đã có giao diện thật.
  static Route<dynamic>? taoRoute(RouteSettings thongTin) {
    final Widget trang;
    switch (thongTin.name) {
      case gioiThieu1:
        trang = const GioiThieuUngDung1();
      case gioiThieu2:
        trang = const GioiThieuUngDung2();
      case chonVaiTro:
        trang = const ChonVaiTro();
      default:
        return null;
    }
    return MaterialPageRoute<void>(settings: thongTin, builder: (_) => trang);
  }
}
