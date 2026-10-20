import 'dart:io';
import 'dart:ui' as giao_dien;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/man_hinh_cho/chon_vai_tro.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/man_hinh_cho/gioi_thieu_ung_dung_1.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/man_hinh_cho/gioi_thieu_ung_dung_2.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/man_hinh_cho/man_hinh_cho.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/ung_dung/dieu_huong.dart';

void main() {
  const thuMucAnh = String.fromEnvironment('THU_MUC_ANH');
  const tepPhongChu = String.fromEnvironment('TEP_PHONG_CHU');
  setUpAll(() async {
    if (tepPhongChu.isNotEmpty) {
      final boNap = FontLoader('Roboto')
        ..addFont(File(tepPhongChu).readAsBytes().then(ByteData.sublistView));
      await boNap.load();
      final boNapIcon = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await boNapIcon.load();
    }
  });

  Widget khung(
    Widget trang, {
    double coChu = 1,
    Map<String, WidgetBuilder>? routes,
  }) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    onGenerateRoute: DieuHuong.taoRoute,
    routes: routes ?? const {},
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(coChu)),
      child: child!,
    ),
    home: trang,
  );

  final cacTrang = <String, Widget>{
    'gioi_thieu_1': const GioiThieuUngDung1(),
    'gioi_thieu_2': const GioiThieuUngDung2(),
    'chon_vai_tro': const ChonVaiTro(),
  };
  for (final kichThuoc in const [
    Size(360, 740),
    Size(390, 844),
    Size(430, 932),
    Size(320, 480),
  ]) {
    for (final coChu in [1.0, 2.0]) {
      for (final muc in cacTrang.entries) {
        testWidgets(
          '${muc.key} ${kichThuoc.width}x${kichThuoc.height}, chữ $coChu',
          (tester) async {
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
                child: khung(muc.value, coChu: coChu),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final nutDuoi = find.byType(NutDuoiManHinh);
            expect(
              tester.getBottomRight(nutDuoi).dy,
              lessThanOrEqualTo(kichThuoc.height),
            );
            final nut = find.descendant(
              of: nutDuoi,
              matching: find.byType(NutBam),
            );
            expect(
              tester.getBottomRight(nut).dy,
              lessThanOrEqualTo(kichThuoc.height - 34),
            );
            if (muc.key == 'chon_vai_tro') {
              await tester.ensureVisible(
                find.byKey(const ValueKey('vai_tro_LANDLORD')),
              );
              await tester.tap(find.byKey(const ValueKey('vai_tro_LANDLORD')));
              await tester.pumpAndSettle();
              expect(find.byIcon(Icons.check_circle), findsOneWidget);
            } else {
              await tester.ensureVisible(find.byKey(const ValueKey('cham_2')));
            }
            expect(tester.takeException(), isNull);
            if (thuMucAnh.isNotEmpty &&
                coChu == 1 &&
                kichThuoc == const Size(390, 844)) {
              if (muc.key == 'chon_vai_tro') {
                await tester.ensureVisible(
                  find.byKey(const ValueKey('vai_tro_TENANT')),
                );
                await tester.tap(find.byKey(const ValueKey('vai_tro_TENANT')));
                await tester.pumpAndSettle();
              }
              // Chụp ở đầu trang để thấy tiêu đề, không ghi asset vào project.
              await tester.drag(
                find.byType(SingleChildScrollView),
                const Offset(0, 1500),
              );
              await tester.pumpAndSettle();
              final bien =
                  khoaAnh.currentContext!.findRenderObject()
                      as RenderRepaintBoundary;
              await tester.runAsync(() async {
                final anh = await bien.toImage();
                final bytes = await anh.toByteData(
                  format: giao_dien.ImageByteFormat.png,
                );
                await Directory(thuMucAnh).create(recursive: true);
                await File('$thuMucAnh/${muc.key}.png')
                    .writeAsBytes(bytes!.buffer.asUint8List());
                anh.dispose();
              });
            }
          },
        );
      }
    }
  }

  testWidgets('Luồng Splash → trang 1 → trang 2 → vai trò; Back đúng lịch sử', (
    tester,
  ) async {
    await tester.pumpWidget(khung(const ManHinhCho()));
    await tester.tap(find.text('Bắt đầu'));
    await tester.pumpAndSettle();
    expect(find.byType(GioiThieuUngDung1), findsOneWidget);
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.byType(GioiThieuUngDung2), findsOneWidget);
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.byType(ChonVaiTro), findsOneWidget);
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.byType(GioiThieuUngDung2), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(GioiThieuUngDung1), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ManHinhCho), findsOneWidget);
  });

  for (final trang in [const GioiThieuUngDung1(), const GioiThieuUngDung2()]) {
    testWidgets('Bỏ qua ${trang.runtimeType} mở vai trò; Back về trang 2', (
      tester,
    ) async {
      await tester.pumpWidget(khung(trang));
      await tester.tap(find.text('Bỏ qua'));
      await tester.pumpAndSettle();
      expect(find.byType(ChonVaiTro), findsOneWidget);
      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();
      expect(find.byType(GioiThieuUngDung2), findsOneWidget);
    });
  }

  for (final vaiTro in ['TENANT', 'LANDLORD']) {
    testWidgets('Chọn $vaiTro, truyền role vào route đăng ký qua callback', (
      tester,
    ) async {
      final khoa = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: khoa,
          theme: ChuDeUngDung.sang,
          routes: {
            '/dang-ky-thu': (context) => Scaffold(
              body: Text(ModalRoute.of(context)!.settings.arguments! as String),
            ),
          },
          home: ChonVaiTro(
            khiDangKy: (role) =>
                khoa.currentState!.pushNamed('/dang-ky-thu', arguments: role),
          ),
        ),
      );
      // TENANT là mặc định; chọn chủ trọ khi cần.
      if (vaiTro == 'LANDLORD') {
        await tester.tap(find.byKey(const ValueKey('vai_tro_LANDLORD')));
        await tester.pumpAndSettle();
      }
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      await tester.tap(find.text('Bắt đầu ngay'));
      await tester.pumpAndSettle();
      expect(find.text(vaiTro), findsOneWidget);
      khoa.currentState!.pop();
      await tester.pumpAndSettle();
      final the = find.byKey(ValueKey('vai_tro_$vaiTro'));
      final semantics = tester.widget<Semantics>(
        find.descendant(of: the, matching: find.byType(Semantics)).first,
      );
      expect(semantics.properties.selected, isTrue);
    });
  }

  testWidgets('Chọn lại vai trò và Bỏ qua chỉ gọi đăng nhập', (tester) async {
    var soLanDangNhap = 0;
    String? vaiTro;
    await tester.pumpWidget(
      khung(
        ChonVaiTro(
          khiDangKy: (role) => vaiTro = role,
          khiDangNhap: () => soLanDangNhap++,
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('vai_tro_LANDLORD')));
    await tester.tap(find.byKey(const ValueKey('vai_tro_TENANT')));
    await tester.tap(find.text('Bắt đầu ngay'));
    expect(vaiTro, 'TENANT');
    await tester.tap(find.text('Bỏ qua'));
    expect(soLanDangNhap, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chưa có đăng ký/đăng nhập: không mở route lỗi hoặc Dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(khung(const ChonVaiTro()));
    await tester.tap(find.text('Bắt đầu ngay'));
    await tester.pump();
    expect(find.text('Màn hình đăng ký đang được hoàn thiện.'), findsOneWidget);
    await tester.tap(find.text('Bỏ qua'));
    await tester.pumpAndSettle();
    expect(
      find.text('Màn hình đăng nhập đang được hoàn thiện.'),
      findsOneWidget,
    );
    expect(find.byType(ChonVaiTro), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
