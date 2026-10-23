import '../chuc_nang/dung_chung/tien_coc/ket_qua_quyet_toan.dart';
import '../chuc_nang/dung_chung/tien_coc/quan_ly_tien_coc.dart';
import '../chuc_nang/dung_chung/tien_coc/tao_quyet_toan.dart';
import '../chuc_nang/dung_chung/hop_dong/chi_tiet_hop_dong.dart';
import '../chuc_nang/dung_chung/hop_dong/xem_truoc_hop_dong.dart';
import '../chuc_nang/dung_chung/hop_dong/danh_sach_hop_dong.dart';
import '../chuc_nang/dung_chung/hop_dong/tao_hop_dong.dart';
import '../chuc_nang/dung_chung/hop_dong/xem_hop_dong_nguoi_thue.dart';
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

class ThamSoHopDong {
  const ThamSoHopDong({required this.hopDongId, this.kho});
  final String hopDongId;
  final KhoHopDongMau? kho;
}

class ThamSoQuyetToan {
  const ThamSoQuyetToan({required this.quyetToanId, this.kho});
  final String quyetToanId;
  final KhoHopDongMau? kho;
}

abstract final class DieuHuong {
  static const gioiThieu1 = '/gioi-thieu-1';
  static const gioiThieu2 = '/gioi-thieu-2';
  static const chonVaiTro = '/chon-vai-tro';
  static const dangKy = '/dang-ky';
  static const dangNhap = '/dang-nhap';
  static const danhSachHopDong = '/hop-dong';
  static const taoHopDong = '/hop-dong/tao';
  static const chiTietHopDong = '/hop-dong/chi-tiet';
  static const xemTruocHopDong = '/hop-dong/xem-truoc';
  static const xemHopDongNguoiThue = '/hop-dong/nguoi-thue/xem';
  static const ketNoiVi = '/vi/ket-noi';
  static const quanLyTienCoc = '/tien-coc';
  static const taoQuyetToan = '/tien-coc/tao-quyet-toan';
  static const ketQuaQuyetToan = '/tien-coc/ket-qua';
  static const thongBao = '/thong-bao';
  static const hoanThienHoSo = '/hoan-thien-ho-so';

  // Chỉ đăng ký các màn hình đã có giao diện thật.
  static Route<dynamic>? taoRoute(RouteSettings thongTin) {
    final Widget trang;
    switch (thongTin.name) {
      case ketQuaQuyetToan:
        final duLieu = thongTin.arguments;
        final ThamSoQuyetToan thamSo;
        if (duLieu is ThamSoQuyetToan) {
          thamSo = duLieu;
        } else if (duLieu is String && duLieu.isNotEmpty) {
          thamSo = ThamSoQuyetToan(quyetToanId: duLieu);
        } else {
          return null;
        }
        trang = KetQuaQuyetToan(
          quyetToanId: thamSo.quyetToanId,
          kho: thamSo.kho,
        );
      case quanLyTienCoc:
        final kho = thongTin.arguments;
        if (kho != null && kho is! KhoHopDongMau) return null;
        trang = QuanLyTienCoc(kho: kho as KhoHopDongMau?);
      case taoQuyetToan:
        final duLieu = thongTin.arguments;
        final String? id;
        final KhoHopDongMau? kho;
        if (duLieu is ThamSoHopDong) {
          id = duLieu.hopDongId;
          kho = duLieu.kho;
        } else if (duLieu is String && duLieu.isNotEmpty) {
          id = duLieu;
          kho = null;
        } else if (duLieu == null || duLieu is KhoHopDongMau) {
          id = null;
          kho = duLieu as KhoHopDongMau?;
        } else {
          return null;
        }
        return MaterialPageRoute<dynamic>(
          settings: thongTin,
          builder: (_) => TaoQuyetToan(hopDongId: id, kho: kho),
        );
      case chiTietHopDong:
      case xemTruocHopDong:
      case xemHopDongNguoiThue:
        final duLieu = thongTin.arguments;
        final ThamSoHopDong thamSo;
        if (duLieu is String && duLieu.isNotEmpty) {
          thamSo = ThamSoHopDong(hopDongId: duLieu);
        } else if (duLieu is ThamSoHopDong &&
            duLieu.hopDongId.trim().isNotEmpty) {
          thamSo = duLieu;
        } else {
          return null;
        }
        trang = switch (thongTin.name) {
          chiTietHopDong => ChiTietHopDong(
            hopDongId: thamSo.hopDongId,
            kho: thamSo.kho,
          ),
          xemHopDongNguoiThue => XemHopDongNguoiThue(
            hopDongId: thamSo.hopDongId,
            kho: thamSo.kho,
          ),
          _ => XemTruocHopDong(hopDongId: thamSo.hopDongId, kho: thamSo.kho),
        };
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
