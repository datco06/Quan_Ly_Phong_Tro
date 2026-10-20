import 'dart:io';
import 'dart:ui' as giao_dien;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tai_khoan/man_hinh_cho.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';

void main() {
  const thuMucAnh = String.fromEnvironment('THU_MUC_ANH');
  const tepPhongChu = String.fromEnvironment('TEP_PHONG_CHU');

  setUpAll(() async {
    if (tepPhongChu.isNotEmpty) {
      final boNap = FontLoader('Roboto')
        ..addFont(File(tepPhongChu).readAsBytes().then(ByteData.sublistView));
      await boNap.load();
      final boNapBieuTuong = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await boNapBieuTuong.load();
    }
  });

  Widget khung({VoidCallback? khiBatDau, double coChu = 1}) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    builder: (context, noiDung) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(coChu)),
      child: noiDung!,
    ),
    home: ManHinhCho(khiBatDau: khiBatDau),
  );

  for (final kichThuoc in const [
    Size(360, 740),
    Size(390, 844),
    Size(430, 932),
    Size(320, 480),
    Size(740, 360),
  ]) {
    for (final coChu in [1.0, 2.0]) {
      testWidgets('A01 ${kichThuoc.width}x${kichThuoc.height}, chữ $coChu', (
        tester,
      ) async {
        tester.view.physicalSize = kichThuoc;
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        final khoaAnh = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: khoaAnh,
            child: khung(coChu: coChu),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('RoomChain AI'), findsOneWidget);
        expect(find.text('Tìm trọ dễ dàng, quản lý an tâm'), findsOneWidget);
        expect(find.byType(NutBam), findsOneWidget);
        expect(
          tester.getCenter(find.byIcon(Icons.east)).dx,
          greaterThan(tester.getCenter(find.text('Bắt đầu')).dx),
        );
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byType(NutBam));
        await tester.pumpAndSettle();
        final nut = tester.getRect(find.byType(NutBam));
        expect(nut.bottom, lessThanOrEqualTo(kichThuoc.height - 34));
        expect(nut.left, greaterThanOrEqualTo(20));
        expect(nut.right, lessThanOrEqualTo(kichThuoc.width - 20));
        expect(tester.takeException(), isNull);
        if (thuMucAnh.isNotEmpty && coChu == 1 && kichThuoc.height >= 740) {
          final bien =
              khoaAnh.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final anh = await bien.toImage();
            final duLieu = await anh.toByteData(
              format: giao_dien.ImageByteFormat.png,
            );
            final thuMuc = Directory(thuMucAnh);
            await thuMuc.create(recursive: true);
            await File(
              '${thuMuc.path}/a01_${kichThuoc.width.toInt()}x${kichThuoc.height.toInt()}.png',
            ).writeAsBytes(duLieu!.buffer.asUint8List());
            anh.dispose();
          });
        }
      });
    }
  }

  testWidgets('Chỉ gọi callback sau khi nhấn Bắt đầu', (tester) async {
    var soLanNhan = 0;
    await tester.pumpWidget(khung(khiBatDau: () => soLanNhan++));
    await tester.pump(const Duration(seconds: 5));
    expect(soLanNhan, 0);
    await tester.tap(find.byType(NutBam));
    await tester.pumpAndSettle();
    expect(soLanNhan, 1);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('A02 chưa có: phản hồi nhấn, không mở route không tồn tại', (
    tester,
  ) async {
    await tester.pumpWidget(khung());
    await tester.tap(find.byType(NutBam));
    await tester.pumpAndSettle();
    expect(find.text('Phần giới thiệu sẽ sớm có mặt.'), findsOneWidget);
    expect(find.byType(ManHinhCho), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
