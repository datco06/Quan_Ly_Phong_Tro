import '../chuc_nang/dung_chung/hop_dong/danh_sach_hop_dong.dart';
import '../chuc_nang/dung_chung/hop_dong/tao_hop_dong.dart';
import '../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';

import 'package:flutter/material.dart';

import '../dung_chung/mo_hinh/nguoi_dung.dart';
import '../chuc_nang/dung_chung/thong_bao/danh_sach_thong_bao.dart';

import '../chuc_nang/dung_chung/tai_khoan/dang_ky.dart';
import '../chuc_nang/dung_chung/tai_khoan/dang_nhap.dart';
import '../chuc_nang/dung_chung/tai_khoan/hoan_thien_ho_so.dart';

import '../chuc_nang/dung_chung/man_hinh_cho/chon_vai_tro.dart';
import '../chuc_nang/dung_chung/man_hinh_cho/gioi_thieu_ung_dung_1.dart';
import '../chuc_nang/dung_chung/man_hinh_cho/gioi_thieu_ung_dung_2.dart';

abstract final class DieuHuong {
  static const gioiThieu1 = '/gioi-thieu-1';
  static const gioiThieu2 = '/gioi-thieu-2';
  static const chonVaiTro = '/chon-vai-tro';
  static const dangKy = '/dang-ky';
  static const dangNhap = '/dang-nhap';
  static const danhSachHopDong = '/hop-dong';
  static const taoHopDong = '/hop-dong/tao';
  static const thongBao = '/thong-bao';
  static const hoanThienHoSo = '/hoan-thien-ho-so';

  // Chỉ đăng ký các màn hình đã có giao diện thật.
  static Route<dynamic>? taoRoute(RouteSettings thongTin) {
    final Widget trang;
    switch (thongTin.name) {
      case danhSachHopDong:
        final kho = thongTin.arguments;
        if (kho != null && kho is! KhoHopDongMau) return null;
        trang = DanhSachHopDong(kho: kho as KhoHopDongMau?);
      case taoHopDong:
        final kho = thongTin.arguments;
        if (kho != null && kho is! KhoHopDongMau) return null;
        return MaterialPageRoute<dynamic>(
          settings: thongTin,
          builder: (_) => TaoHopDong(kho: kho as KhoHopDongMau?),
        );
      case gioiThieu1:
        trang = const GioiThieuUngDung1();
      case gioiThieu2:
        trang = const GioiThieuUngDung2();
      case chonVaiTro:
        trang = const ChonVaiTro();
      case dangKy:
        final vaiTro = thongTin.arguments;
        if (vaiTro != 'TENANT' && vaiTro != 'LANDLORD') return null;
        trang = DangKy(vaiTro: vaiTro! as String);
      case dangNhap:
        trang = const DangNhap();
      case thongBao:
        final vaiTro = thongTin.arguments;
        if (vaiTro != 'TENANT' && vaiTro != 'LANDLORD') return null;
        trang = DanhSachThongBao(
          vaiTro: vaiTro == 'TENANT' ? VaiTro.tenant : VaiTro.landlord,
        );
      case hoanThienHoSo:
        if (thongTin.arguments != 'TENANT') return null;
        trang = const HoanThienHoSo(vaiTro: 'TENANT');
      default:
        return null;
    }
    return MaterialPageRoute<void>(settings: thongTin, builder: (_) => trang);
  }
}
