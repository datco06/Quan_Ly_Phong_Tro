import 'package:flutter/material.dart';

import 'anh_thu_nho.dart';
import '../hien_thi/hien_thi_dang_tai.dart';

class LuoiHinhAnh extends StatelessWidget {
  const LuoiHinhAnh({
    super.key,
    required this.danhSachAnh,
    this.toiDa = 5,
    this.khiThem,
    this.khiXoa,
    this.dangTai = false,
  }) : assert(toiDa > 0);
  final List<String> danhSachAnh;
  final int toiDa;
  final VoidCallback? khiThem;
  final ValueChanged<int>? khiXoa;
  final bool dangTai;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = (constraints.maxWidth / 100).floor().clamp(1, 6);
      final count = danhSachAnh.length.clamp(0, toiDa);
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          for (var i = 0; i < count; i++)
            Stack(
              fit: StackFit.expand,
              children: [
                AnhThuNho(nguon: danhSachAnh[i]),
                if (khiXoa != null && !dangTai)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      tooltip: 'Xóa ảnh ${i + 1}',
                      onPressed: () => khiXoa!(i),
                      icon: const Icon(Icons.cancel),
                    ),
                  ),
              ],
            ),
          if (dangTai) const Center(child: HienThiDangTai()),
          if (count < toiDa && khiThem != null && !dangTai)
            OutlinedButton(
              onPressed: khiThem,
              child: const Icon(Icons.add, semanticLabel: 'Thêm ảnh'),
            ),
        ],
      );
    },
  );
}
