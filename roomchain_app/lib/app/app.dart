import 'package:flutter/material.dart';

import '../dung_chung/bo_cuc/bo_cuc_chu_tro.dart';
import '../dung_chung/giao_dien/chu_de_ung_dung.dart';
import '../chuc_nang/chu_tro/tong_quan/trang_tong_quan.dart';

class RoomChainApp extends StatelessWidget {
  const RoomChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomChain AI',
      debugShowCheckedModeBanner: false,
      theme: ChuDeUngDung.sang,
      home: const _ManHinhChuTro(),
    );
  }
}

class _ManHinhChuTro extends StatefulWidget {
  const _ManHinhChuTro();

  @override
  State<_ManHinhChuTro> createState() => _ManHinhChuTroState();
}

class _ManHinhChuTroState extends State<_ManHinhChuTro> {
  int _chiSoChon = 0;

  static const _cacTrang = <Widget>[
    TrangTongQuan(),
    _TrangChoXay(nhan: 'Khu trọ'),
    _TrangChoXay(nhan: 'Phòng'),
    _TrangChoXay(nhan: 'Hóa đơn'),
    _TrangChoXay(nhan: 'Thêm'),
  ];

  @override
  Widget build(BuildContext context) {
    return BoCucChuTro(
      chiSoChon: _chiSoChon,
      khiChon: (i) => setState(() => _chiSoChon = i),
      noiDung: _cacTrang[_chiSoChon],
    );
  }
}

/// Placeholder cho các tab chưa xây dựng
class _TrangChoXay extends StatelessWidget {
  const _TrangChoXay({required this.nhan});
  final String nhan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        nhan,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
