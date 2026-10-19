import 'package:flutter/material.dart';

import '../../giao_dien/bang_mau.dart';
import '../../tien_ich/dinh_dang_ngay.dart';

enum TrangThaiBuoc { hoanThanh, hienTai, chuaDen }

class BuocThoiGian {
  const BuocThoiGian({
    required this.tieuDe,
    this.moTa,
    this.ngayGio,
    this.bieuTuong,
    this.trangThai = TrangThaiBuoc.chuaDen,
  });
  final String tieuDe;
  final String? moTa;
  final DateTime? ngayGio;
  final IconData? bieuTuong;
  final TrangThaiBuoc trangThai;
}

class DongThoiGian extends StatelessWidget {
  const DongThoiGian({super.key, required this.cacBuoc});
  final List<BuocThoiGian> cacBuoc;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < cacBuoc.length; i++)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Icon(
                      cacBuoc[i].bieuTuong ??
                          switch (cacBuoc[i].trangThai) {
                            TrangThaiBuoc.hoanThanh => Icons.check_circle,
                            TrangThaiBuoc.hienTai => Icons.schedule,
                            _ => Icons.radio_button_unchecked,
                          },
                      color: switch (cacBuoc[i].trangThai) {
                        TrangThaiBuoc.hoanThanh => BangMau.thanhCong,
                        TrangThaiBuoc.hienTai => BangMau.chinh,
                        _ => BangMau.chuMo,
                      },
                    ),
                    if (i < cacBuoc.length - 1)
                      const Expanded(child: VerticalDivider()),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cacBuoc[i].tieuDe,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      if (cacBuoc[i].moTa != null) Text(cacBuoc[i].moTa!),
                      if (cacBuoc[i].ngayGio != null)
                        Text(
                          dinhDangNgayGio(cacBuoc[i].ngayGio!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
