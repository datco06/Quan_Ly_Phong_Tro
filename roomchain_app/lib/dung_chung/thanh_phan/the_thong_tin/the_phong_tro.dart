import 'package:flutter/material.dart';

import '../../mo_hinh/phong_tro.dart';
import '../../giao_dien/bang_mau.dart';
import '../../tien_ich/dinh_dang_tien.dart';
import '../hien_thi/nhan_trang_thai.dart';
import '../hinh_anh/anh_thu_nho.dart';
import 'khung_the.dart';

enum KieuThePhong { ngang, doc }

class ThePhongTro extends StatelessWidget {
  const ThePhongTro({
    super.key,
    required this.phong,
    this.kieu = KieuThePhong.ngang,
    this.khiNhan,
    this.khiYeuThich,
    this.yeuThich = false,
  });
  final PhongTro phong;
  final KieuThePhong kieu;
  final VoidCallback? khiNhan, khiYeuThich;
  final bool yeuThich;
  @override
  Widget build(BuildContext context) => KhungThe(
    khiNhan: khiNhan,
    child: LayoutBuilder(
      builder: (context, size) {
        final ngang =
            kieu == KieuThePhong.ngang &&
            size.maxWidth >= 280 &&
            MediaQuery.textScalerOf(context).scale(14) < 22;
        final info = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${phong.maPhong} · ${phong.tenKhuTro}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(phong.diaChi, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              '${dinhDangVND(phong.giaThue)}/tháng',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: BangMau.chinh),
            ),
            Text('${phong.dienTich} m² · ${phong.danhSachTienIch.join(' · ')}'),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                NhanTrangThai(
                  trangThai: phong.trangThai == TrangThaiPhong.conTrong
                      ? TrangThaiHienThi.conTrong
                      : phong.trangThai == TrangThaiPhong.dangThue
                      ? TrangThaiHienThi.dangThue
                      : TrangThaiHienThi.choDuyet,
                  nhan: phong.trangThai == TrangThaiPhong.baoTri
                      ? 'Bảo trì'
                      : null,
                ),
                if (khiYeuThich != null)
                  IconButton(
                    tooltip: yeuThich ? 'Bỏ yêu thích' : 'Yêu thích',
                    onPressed: khiYeuThich,
                    icon: Icon(
                      yeuThich ? Icons.favorite : Icons.favorite_border,
                    ),
                  ),
              ],
            ),
          ],
        );
        final image = AnhThuNho(
          nguon: phong.danhSachAnh.firstOrNull,
          rong: ngang ? 96 : double.infinity,
          cao: ngang ? 112 : 160,
        );
        return ngang
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  image,
                  const SizedBox(width: 12),
                  Expanded(child: info),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [image, const SizedBox(height: 12), info],
              );
      },
    ),
  );
}
