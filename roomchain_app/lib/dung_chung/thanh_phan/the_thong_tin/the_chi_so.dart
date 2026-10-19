import 'package:flutter/material.dart';

import '../../mo_hinh/chi_so_dien_nuoc.dart';
import '../../tien_ich/dinh_dang_ngay.dart';
import '../hien_thi/dong_thong_tin.dart';
import '../hien_thi/nhan_trang_thai.dart';
import '../hinh_anh/anh_thu_nho.dart';
import 'khung_the.dart';

class TheChiSo extends StatelessWidget {
  const TheChiSo({super.key, required this.chiSo, this.khiNhan});
  final ChiSoDienNuoc chiSo;
  final VoidCallback? khiNhan;
  @override
  Widget build(BuildContext context) => KhungThe(
    khiNhan: khiNhan,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${chiSo.loaiDongHo == LoaiDongHo.dien ? 'Chỉ số điện' : 'Chỉ số nước'} · ${chiSo.maPhong}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        NhanTrangThai(
          trangThai: switch (chiSo.trangThai) {
            TrangThaiChiSo.daDuyet => TrangThaiHienThi.thanhCong,
            TrangThaiChiSo.tuChoi => TrangThaiHienThi.thatBai,
            _ => TrangThaiHienThi.choDuyet,
          },
          nhan: switch (chiSo.trangThai) {
            TrangThaiChiSo.daDuyet => 'Đã duyệt',
            TrangThaiChiSo.tuChoi => 'Từ chối',
            TrangThaiChiSo.chuaGui => 'Chưa gửi',
            TrangThaiChiSo.choDuyet => 'Chờ duyệt',
          },
        ),
        DongThongTin(
          nhan: 'Chỉ số trước',
          giaTri: '${chiSo.chiSoCu} ${chiSo.donVi}',
        ),
        DongThongTin(
          nhan: 'Chỉ số mới',
          giaTri: '${chiSo.chiSoMoi} ${chiSo.donVi}',
        ),
        DongThongTin(
          nhan: 'Tiêu thụ',
          giaTri: '${chiSo.soTieuThu} ${chiSo.donVi}',
        ),
        DongThongTin(nhan: 'Ngày ghi', giaTri: dinhDangNgay(chiSo.ngayGhi)),
        if (chiSo.anhDongHo != null) AnhThuNho(nguon: chiSo.anhDongHo),
      ],
    ),
  );
}
