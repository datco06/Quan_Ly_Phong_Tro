import 'package:flutter/material.dart';

import '../giao_dien/kich_thuoc.dart';

class KhungTrang extends StatelessWidget {
  const KhungTrang({
    super.key,
    this.tieuDe,
    required this.noiDung,
    this.coQuayLai = true,
    this.hanhDong,
    this.hanhDongDuoi,
    this.cuon = true,
    this.mauNen,
    this.padding = const EdgeInsets.all(KichThuoc.leTrang),
    this.appBar,
  });
  final String? tieuDe;
  final Widget noiDung;
  final bool coQuayLai, cuon;
  final List<Widget>? hanhDong;
  final Widget? hanhDongDuoi;
  final Color? mauNen;
  final EdgeInsetsGeometry padding;
  final PreferredSizeWidget? appBar;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: mauNen,
    resizeToAvoidBottomInset: true,
    appBar:
        appBar ??
        (tieuDe == null
            ? null
            : AppBar(
                title: Text(tieuDe!),
                automaticallyImplyLeading: coQuayLai,
                actions: hanhDong,
              )),
    body: SafeArea(
      bottom: hanhDongDuoi == null,
      child: Column(
        children: [
          Expanded(
            child: cuon
                ? SingleChildScrollView(padding: padding, child: noiDung)
                : Padding(padding: padding, child: noiDung),
          ),
          ?hanhDongDuoi,
        ],
      ),
    ),
  );
}
