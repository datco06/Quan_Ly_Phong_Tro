import 'package:flutter/material.dart';

import '../../../../ung_dung/dieu_huong.dart';
import 'khung_gioi_thieu.dart';

class GioiThieuUngDung2 extends StatelessWidget {
  const GioiThieuUngDung2({super.key});

  @override
  Widget build(BuildContext context) => KhungGioiThieu(
    tieuDe: 'Tiết kiệm thời gian\nvà chi phí',
    moTa: 'So sánh giá, xem đường đi, tiện ích và đánh giá thật từ người thuê',
    trang: 1,
    minhHoa: const MinhHoaGioiThieu(trang: 1),
    khiTiepTuc: () => Navigator.of(context).pushNamed(DieuHuong.chonVaiTro),
    khiBoQua: () => Navigator.of(context).pushNamed(DieuHuong.chonVaiTro),
  );
}
