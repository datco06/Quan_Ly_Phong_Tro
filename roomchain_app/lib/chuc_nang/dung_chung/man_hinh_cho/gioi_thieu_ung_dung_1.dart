import 'package:flutter/material.dart';

import '../../../../ung_dung/dieu_huong.dart';
import 'khung_gioi_thieu.dart';

class GioiThieuUngDung1 extends StatelessWidget {
  const GioiThieuUngDung1({super.key});

  @override
  Widget build(BuildContext context) => KhungGioiThieu(
    tieuDe: 'Tìm phòng\nhợp với hành trình\nđến trường',
    moTa: 'AI gợi ý phòng phù hợp dựa trên vị trí trường, phương tiện và ngân sách của bạn',
    trang: 0,
    minhHoa: const MinhHoaGioiThieu(trang: 0),
    khiTiepTuc: () => Navigator.of(context).pushNamed(DieuHuong.gioiThieu2),
    // Giữ trang 2 trong lịch sử để quay lại đúng thứ tự khi bỏ qua.
    khiBoQua: () {
      Navigator.of(context)
        ..pushNamed(DieuHuong.gioiThieu2)
        ..pushNamed(DieuHuong.chonVaiTro);
    },
  );
}
