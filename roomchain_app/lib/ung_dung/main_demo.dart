import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../dung_chung/demo/khung_dien_thoai_demo.dart';
import '../dung_chung/demo/trinh_dien_thanh_phan.dart';
import '../dung_chung/giao_dien/chu_de_ung_dung.dart';

void main() => runApp(
  MaterialApp(
    title: 'RoomChain UI Demo',
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    builder: (context, child) =>
        kIsWeb ? KhungDienThoaiDemo(child: child!) : child!,
    home: const TrinhDienThanhPhan(),
  ),
);
