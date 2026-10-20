import 'dart:math' as toan;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../dung_chung/giao_dien/bang_mau.dart';
import '../../../../dung_chung/giao_dien/chu_de_ung_dung.dart';
import '../../../../dung_chung/giao_dien/khoang_cach.dart';
import '../../../../dung_chung/giao_dien/kieu_chu.dart';
import '../../../../dung_chung/thanh_phan/nut_bam.dart';

// Chạy riêng màn hình A01 để xem thử.
void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    home: const ManHinhCho(),
  ),
);

class ManHinhCho extends StatelessWidget {
  const ManHinhCho({super.key, this.khiBatDau});

  final VoidCallback? khiBatDau;

  // Xử lý khi nhấn nút Bắt đầu.
  void _batDau(BuildContext context) {
    if (khiBatDau != null) {
      khiBatDau!();
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Phần giới thiệu sẽ sớm có mặt.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: BangMau.chinhNhat,
      ),
      child: Scaffold(
        backgroundColor: BangMau.nen,
        // Phần nền trắng chuyển nhẹ sang xanh mint.
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [BangMau.nenThe, BangMau.nen, BangMau.chinhNhat],
              stops: [0, 0.6, 1],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, gioiHan) {
                // Co giãn bố cục theo màn hình và cỡ chữ.
                final chieuRong = toan.min(gioiHan.maxWidth, 520.0);
                final coChu = MediaQuery.textScalerOf(context).scale(14) / 14;
                final chieuCao = toan.max(
                  gioiHan.maxHeight,
                  530.0 + toan.max(0.0, coChu - 1) * 150,
                );
                // Cho phép cuộn khi màn hình quá thấp.
                return SingleChildScrollView(
                  child: SizedBox(
                    height: chieuCao,
                    width: gioiHan.maxWidth,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: chieuRong,
                        child: Column(
                          children: [
                            const Spacer(flex: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: KhoangCach.lon,
                              ),
                              child: Column(
                                children: [
                                  // Phần logo.
                                  Semantics(
                                    label: 'Logo RoomChain AI, ngôi nhà xanh',
                                    image: true,
                                    child: const SizedBox(
                                      width: 82,
                                      height: 86,
                                      child: CustomPaint(painter: _VeLogo()),
                                    ),
                                  ),
                                  const SizedBox(height: KhoangCach.chuan),
                                  // Phần tên ứng dụng.
                                  Text(
                                    'RoomChain AI',
                                    textAlign: TextAlign.center,
                                    style: KieuChu.tieuDeLon.copyWith(
                                      fontSize: 28,
                                      height: 1.2,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                  const SizedBox(height: KhoangCach.nho),
                                  // Phần slogan.
                                  Text(
                                    'Tìm trọ dễ dàng, quản lý an tâm',
                                    textAlign: TextAlign.center,
                                    style: KieuChu.noiDung.copyWith(
                                      color: BangMau.chuPhu,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(flex: 13),
                            // Phần hình minh họa khu dân cư.
                            ExcludeSemantics(
                              child: RepaintBoundary(
                                child: SizedBox(
                                  width: chieuRong,
                                  height: chieuRong * 0.53,
                                  child: const CustomPaint(
                                    painter: _VeKhuDanCu(),
                                  ),
                                ),
                              ),
                            ),
                            // Phần nút Bắt đầu.
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                KhoangCach.lon,
                                KhoangCach.nho,
                                KhoangCach.lon,
                                KhoangCach.chuan,
                              ),
                              // Đảo thứ tự hàng của Core để icon nằm sau nhãn.
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: NutBam(
                                  nhan: 'Bắt đầu',
                                  bieuTuong: Icons.east,
                                  chieuCao: 54,
                                  khiNhan: () => _batDau(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Vẽ logo ngôi nhà.
class _VeLogo extends CustomPainter {
  const _VeLogo();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 82, size.height / 86);
    final vien = Paint()
      ..color = BangMau.chinh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.square;
    final mai = Path()
      ..moveTo(8, 45)
      ..lineTo(40, 14)
      ..lineTo(73, 45);
    canvas.drawPath(mai, vien);
    final than = Path()
      ..moveTo(15, 41)
      ..lineTo(15, 76)
      ..lineTo(66, 76)
      ..lineTo(66, 41);
    canvas.drawPath(than, vien);
    canvas.drawPath(
      Path()
        ..moveTo(32, 24)
        ..lineTo(55, 47)
        ..lineTo(55, 73),
      vien..color = const Color(0xFF52A486),
    );
    canvas.drawPath(
      Path()
        ..moveTo(57, 22)
        ..cubicTo(51, 9, 58, 2, 62, 5)
        ..cubicTo(68, 10, 64, 19, 63, 25)
        ..close(),
      Paint()..color = const Color(0xFF52A486),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VeLogo oldDelegate) => false;
}

// Vẽ nhà, tòa nhà và cây xanh trong hình minh họa.
class _VeKhuDanCu extends CustomPainter {
  const _VeKhuDanCu();

  static const _xanhXa = Color(0xFFCDE8E8);
  static const _canhNha = Color(0xFFAED4D9);
  static const _maiNha = Color(0xFF316D72);
  static const _tuong = Color(0xFFF3EEDD);
  static const _cua = Color(0xFF79ADAA);
  static const _co = Color(0xFFC4DFC7);

  void _daGiac(Canvas canvas, List<Offset> diem, Color mau) {
    final duong = Path()..addPolygon(diem, true);
    canvas.drawPath(duong, Paint()..color = mau);
  }

  // Vẽ tòa nhà phía sau.
  void _toaNha(Canvas canvas, double x, double y, double rong, double cao) {
    final son = Paint()..color = _xanhXa;
    _daGiac(canvas, [
      Offset(x, y + 10),
      Offset(x + rong * 0.56, y),
      Offset(x + rong, y + 12),
      Offset(x + rong, y + cao),
      Offset(x, y + cao),
    ], _xanhXa);
    _daGiac(canvas, [
      Offset(x + rong * 0.56, y),
      Offset(x + rong, y + 12),
      Offset(x + rong, y + cao),
      Offset(x + rong * 0.56, y + cao),
    ], _canhNha);
    for (var hang = 0; hang < (cao - 20) / 20; hang++) {
      for (var cot = 0; cot < 4; cot++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x + 8 + cot * (rong - 14) / 4,
              y + 21 + hang * 20,
              4,
              10,
            ),
            const Radius.circular(1),
          ),
          son..color = const Color(0xFFE8F3EE),
        );
      }
    }
  }

  // Vẽ cây xanh.
  void _cay(Canvas canvas, double x, double y, double tiLe) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(tiLe);
    final son = Paint()..color = const Color(0xFF8DBD82);
    canvas.drawOval(const Rect.fromLTWH(-17, -81, 33, 47), son);
    canvas.drawOval(const Rect.fromLTWH(-28, -62, 35, 48), son);
    canvas.drawOval(
      const Rect.fromLTWH(-7, -64, 32, 49),
      son..color = const Color(0xFF6FAE89),
    );
    canvas.drawOval(
      const Rect.fromLTWH(-22, -49, 43, 38),
      son..color = const Color(0xFF70AD85),
    );
    final than = Path()
      ..moveTo(0, 0)
      ..lineTo(0, -52)
      ..moveTo(0, -21)
      ..lineTo(-12, -34)
      ..moveTo(0, -32)
      ..lineTo(10, -44)
      ..moveTo(0, -42)
      ..lineTo(-6, -50);
    canvas.drawPath(
      than,
      Paint()
        ..color = const Color(0xFF527E66)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  // Vẽ ngôi nhà phía trước.
  void _nha(Canvas canvas, double x, double y, double tiLe) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(tiLe);
    _daGiac(canvas, const [
      Offset(0, 38),
      Offset(32, 7),
      Offset(65, 38),
      Offset(65, 100),
      Offset(0, 100),
    ], _tuong);
    canvas.drawRect(
      const Rect.fromLTWH(65, 39, 33, 61),
      Paint()..color = const Color(0xFFD9DFCF),
    );
    _daGiac(canvas, const [
      Offset(-5, 38),
      Offset(32, 2),
      Offset(39, 5),
      Offset(3, 40),
    ], _maiNha);
    _daGiac(canvas, const [
      Offset(32, 2),
      Offset(76, 7),
      Offset(103, 40),
      Offset(65, 38),
    ], _maiNha);
    final son = Paint()..color = _cua;
    for (final cuaSo in const [
      Rect.fromLTWH(9, 45, 10, 14),
      Rect.fromLTWH(39, 45, 10, 14),
      Rect.fromLTWH(9, 74, 10, 15),
      Rect.fromLTWH(40, 74, 10, 15),
      Rect.fromLTWH(75, 49, 10, 14),
      Rect.fromLTWH(75, 76, 10, 14),
      Rect.fromLTWH(26, 24, 7, 10),
    ]) {
      canvas.drawRect(cuaSo, son);
      canvas.drawLine(
        Offset(cuaSo.center.dx, cuaSo.top),
        Offset(cuaSo.center.dx, cuaSo.bottom),
        Paint()
          ..color = _tuong
          ..strokeWidth = 1,
      );
    }
    canvas.drawRect(const Rect.fromLTWH(25, 73, 11, 27), son);
    canvas.drawRect(
      const Rect.fromLTWH(22, 99, 17, 3),
      Paint()..color = const Color(0xFFD3CFBC),
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 390, size.height / 207);
    _toaNha(canvas, 54, 40, 76, 145);
    _toaNha(canvas, 125, 78, 51, 109);
    _toaNha(canvas, 228, 64, 55, 123);
    _toaNha(canvas, 283, 26, 72, 161);
    final son = Paint()..color = const Color(0xFFC4E5E2);
    final buiXa = Path()..moveTo(0, 93);
    for (var x = 0.0; x < 390; x += 37) {
      buiXa.quadraticBezierTo(x + 19, 72 + (x % 3) * 13, x + 37, 103);
    }
    buiXa.lineTo(410, 196);
    buiXa.lineTo(0, 196);
    buiXa.close();
    canvas.drawPath(buiXa, son);
    for (var i = 0; i < 13; i++) {
      canvas.drawOval(
        Rect.fromLTWH(i * 33 - 15, 153 - (i % 3) * 12, 54, 51),
        son
          ..color = i.isEven
              ? const Color(0xFFB0D8CA)
              : const Color(0xFF9ECFBF),
      );
    }
    canvas.drawOval(const Rect.fromLTWH(-32, 183, 460, 46), son..color = _co);
    _cay(canvas, 38, 187, 1.12);
    _cay(canvas, 353, 189, 1.2);
    _nha(canvas, 77, 121, 0.69);
    _nha(canvas, 211, 101, 0.88);
    for (final x in [65.0, 169.0, 198.0, 319.0]) {
      canvas.drawOval(
        Rect.fromLTWH(x, 180, 15, 13),
        son..color = const Color(0xFF78B78E),
      );
    }
    canvas.drawRect(
      const Rect.fromLTWH(0, 198, 390, 9),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_co, BangMau.chinhNhat],
        ).createShader(const Rect.fromLTWH(0, 198, 390, 9)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VeKhuDanCu oldDelegate) => false;
}
