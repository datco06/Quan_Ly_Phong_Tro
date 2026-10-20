import 'dart:async';
import 'dart:io';
import 'dart:ui' as giao_dien;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tai_khoan/dang_ky.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tai_khoan/hoan_thien_ho_so.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/ung_dung/dieu_huong.dart';

void main() {
  const thuMucAnh = String.fromEnvironment('THU_MUC_ANH');
  const tepPhongChu = String.fromEnvironment('TEP_PHONG_CHU');
  late Uint8List anhThu;
  setUpAll(() async {
    if (tepPhongChu.isNotEmpty) {
      final chu = FontLoader('Roboto')
        ..addFont(File(tepPhongChu).readAsBytes().then(ByteData.sublistView));
      await chu.load();
      final icon = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icon.load();
    }
    final boGhi = giao_dien.PictureRecorder();
    Canvas(boGhi).drawColor(BangMau.chinh, BlendMode.src);
    final hinh = boGhi.endRecording();
    final anh = await hinh.toImage(8, 8);
    anhThu = (await anh.toByteData(format: giao_dien.ImageByteFormat.png))!
        .buffer
        .asUint8List();
    anh.dispose();
    hinh.dispose();
  });

  Widget khung(Widget trang, {double coChu = 1}) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    onGenerateRoute: DieuHuong.taoRoute,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(coChu)),
      child: child!,
    ),
    home: trang,
  );
  Finder oNhap(String ten) => find.descendant(
    of: find.byKey(ValueKey(ten)),
    matching: find.byType(TextFormField),
  );
  Future<void> nhap(WidgetTester tester, String ten, String giaTri) async {
    await tester.ensureVisible(oNhap(ten));
    await tester.enterText(oNhap(ten), giaTri);
  }

  Future<void> dienHoSo(WidgetTester tester) async {
    await nhap(tester, 'truong_hoc', '  Đại học Bách Khoa Hà Nội  ');
    await nhap(tester, 'khu_vuc', ' Hà Đông, Cầu Giấy, , hà đông, Thanh Xuân ');
  }

  Future<void> hoanTat(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Hoàn tất'));
    await tester.tap(find.text('Hoàn tất'));
    await tester.pump();
  }

  Future<void> chonAnh(WidgetTester tester) async {
    final hanhDong =
        tester
                .widget<IconButton>(
                  find.byWidgetPredicate(
                    (widget) =>
                        widget is IconButton &&
                        widget.tooltip == 'Đổi ảnh đại diện',
                  ),
                )
                .onPressed!
            as Future<void> Function();
    await tester.runAsync(hanhDong);
    await tester.pumpAndSettle();
  }

  for (final kichThuoc in const [
    Size(360, 740),
    Size(390, 844),
    Size(430, 932),
    Size(320, 480),
  ]) {
    for (final coChu in [1.0, 2.0]) {
      testWidgets(
        'A06 ${kichThuoc.width}x${kichThuoc.height}, chữ $coChu và bàn phím',
        (tester) async {
          tester.view.physicalSize = kichThuoc;
          tester.view.devicePixelRatio = 1;
          tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPadding);
          addTearDown(tester.view.resetViewInsets);
          final khoaAnh = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: khoaAnh,
              child: khung(const HoanThienHoSo(vaiTro: 'TENANT'), coChu: coChu),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Hoàn thiện hồ sơ'), findsOneWidget);
          expect(find.text('Vui lòng nhập trường học'), findsNothing);
          expect(find.byType(OChon<String>), findsOneWidget);
          await dienHoSo(tester);
          if (thuMucAnh.isNotEmpty &&
              coChu == 1 &&
              kichThuoc == const Size(390, 844)) {
            await nhap(tester, 'khu_vuc', 'Hà Đông, Cầu Giấy, Thanh Xuân');
            FocusScope.of(tester.element(find.byType(HoanThienHoSo))).unfocus();
            await tester.drag(
              find.byType(SingleChildScrollView),
              const Offset(0, 1200),
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
              await File('$thuMucAnh/a06_hoan_thien_ho_so.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              anh.dispose();
            });
          }
          tester.view.viewInsets = const FakeViewPadding(bottom: 240);
          await tester.pumpAndSettle();
          await nhap(tester, 'truong_hoc', 'Trường thử nghiệm');
          await tester.ensureVisible(find.text('Hoàn tất'));
          await tester.pumpAndSettle();
          expect(
            tester.getBottomLeft(find.text('Hoàn tất')).dy,
            lessThanOrEqualTo(kichThuoc.height - 240),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'Không lưu khi tên trường hoặc khu vực chỉ có dấu cách/dấu phẩy',
    (tester) async {
      HoSoNguoiThue? hoSo;
      await tester.pumpWidget(
        khung(
          HoanThienHoSo(
            vaiTro: 'TENANT',
            khiHoanTat: (giaTri) async {
              hoSo = giaTri;
            },
          ),
        ),
      );
      await nhap(tester, 'truong_hoc', '   ');
      await nhap(tester, 'khu_vuc', ' , , ');
      await hoanTat(tester);
      expect(find.text('Vui lòng nhập trường học'), findsOneWidget);
      expect(find.text('Vui lòng nhập ít nhất một khu vực'), findsOneWidget);
      expect(hoSo, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Chọn và đổi phương tiện, lưu danh sách khu vực không trùng', (
    tester,
  ) async {
    HoSoNguoiThue? hoSo;
    await tester.pumpWidget(
      khung(
        HoanThienHoSo(
          vaiTro: 'TENANT',
          khiHoanTat: (giaTri) async {
            hoSo = giaTri;
          },
        ),
      ),
    );
    await dienHoSo(tester);
    for (final ten in ['Xe buýt', 'Đi bộ']) {
      await tester.ensureVisible(find.byType(OChon<String>));
      await tester.tap(find.byType(OChon<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ten).last);
      await tester.pumpAndSettle();
    }
    await hoanTat(tester);
    expect(hoSo!.truongHoc, 'Đại học Bách Khoa Hà Nội');
    expect(hoSo!.phuongTien, 'DI_BO');
    expect(hoSo!.vaiTro, 'TENANT');
    expect(hoSo!.khuVucQuanTam, ['Hà Đông', 'Cầu Giấy', 'Thanh Xuân']);
    expect(() => hoSo!.khuVucQuanTam.add('khác'), throwsUnsupportedError);
    expect(find.text('Đã hoàn thiện hồ sơ demo.'), findsOneWidget);
  });

  testWidgets('Ảnh được cập nhật, hủy giữ ảnh cũ và ảnh vào hồ sơ demo', (
    tester,
  ) async {
    Uint8List? ketQua = anhThu;
    HoSoNguoiThue? hoSo;
    await tester.pumpWidget(
      khung(
        HoanThienHoSo(
          vaiTro: 'TENANT',
          khiChonAnh: () async => ketQua,
          khiHoanTat: (giaTri) async {
            hoSo = giaTri;
          },
        ),
      ),
    );
    await chonAnh(tester);
    expect(find.byKey(const ValueKey('anh_dai_dien')), findsOneWidget);
    ketQua = null;
    await chonAnh(tester);
    expect(find.byKey(const ValueKey('anh_dai_dien')), findsOneWidget);
    await dienHoSo(tester);
    await hoanTat(tester);
    expect(hoSo!.anhDaiDien, orderedEquals(anhThu));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Lỗi quyền hoặc ảnh quá lớn/không hợp lệ không làm lỗi màn hình',
    (tester) async {
      var tinhHuong = 0;
      await tester.pumpWidget(
        khung(
          HoanThienHoSo(
            vaiTro: 'TENANT',
            khiChonAnh: () async {
              if (tinhHuong == 0) throw StateError('Không có quyền');
              if (tinhHuong == 1) return Uint8List(5 * 1024 * 1024 + 1);
              return Uint8List.fromList([1, 2, 3]);
            },
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        tinhHuong = i;
        await chonAnh(tester);
        expect(find.byKey(const ValueKey('anh_dai_dien')), findsNothing);
        expect(find.byType(HoanThienHoSo), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Chưa có bộ chọn ảnh/Trang chủ: thông báo trung thực, vẫn lưu demo',
    (tester) async {
      await tester.pumpWidget(khung(const HoanThienHoSo(vaiTro: 'TENANT')));
      await tester.tap(find.byTooltip('Đổi ảnh đại diện'));
      await tester.pump();
      expect(
        find.textContaining('Chọn ảnh chưa được kết nối.'),
        findsOneWidget,
      );
      await dienHoSo(tester);
      await hoanTat(tester);
      expect(
        find.text(
          'Đã hoàn thiện hồ sơ demo. Trang chủ người thuê chưa được triển khai.',
        ),
        findsOneWidget,
      );
      expect(find.byType(HoanThienHoSo), findsOneWidget);
    },
  );

  testWidgets('Đang lưu không gửi lặp và khôi phục sau lỗi điều hướng', (
    tester,
  ) async {
    final cho = Completer<void>();
    var soLan = 0;
    await tester.pumpWidget(
      khung(
        HoanThienHoSo(
          vaiTro: 'TENANT',
          khiHoanTat: (_) {
            soLan++;
            return cho.future;
          },
        ),
      ),
    );
    await dienHoSo(tester);
    await hoanTat(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Hoàn tất'), warnIfMissed: false);
    expect(soLan, 1);
    cho.completeError(StateError('Chưa có trang'));
    await tester.pumpAndSettle();
    expect(
      find.text('Đã lưu hồ sơ demo, nhưng chưa thể mở trang tiếp theo.'),
      findsOneWidget,
    );
  });

  test('Chặn LANDLORD ở constructor và route hồ sơ Tenant', () {
    expect(() => HoanThienHoSo(vaiTro: 'LANDLORD'), throwsAssertionError);
    expect(
      DieuHuong.taoRoute(
        const RouteSettings(
          name: DieuHuong.hoanThienHoSo,
          arguments: 'LANDLORD',
        ),
      ),
      isNull,
    );
  });

  testWidgets('A04 → A06 → Back giữ form đăng ký; route không mang mật khẩu', (
    tester,
  ) async {
    await tester.pumpWidget(khung(const DangKy(vaiTro: 'TENANT')));
    for (final muc in {
      'ho_ten': 'Minh Anh',
      'lien_he': 'anh@example.com',
      'mat_khau': 'ThuNghiem123!',
      'xac_nhan': 'ThuNghiem123!',
    }.entries) {
      await nhap(tester, muc.key, muc.value);
    }
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.ensureVisible(find.text('Tạo tài khoản'));
    await tester.tap(find.text('Tạo tài khoản'));
    await tester.pumpAndSettle();
    expect(find.byType(HoanThienHoSo), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(HoanThienHoSo)))!
          .settings
          .arguments,
      'TENANT',
    );
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.byType(DangKy), findsOneWidget);
    expect(
      tester.widget<TextFormField>(oNhap('ho_ten')).controller!.text,
      'Minh Anh',
    );
    expect(
      tester.widget<TextFormField>(oNhap('mat_khau')).controller!.text,
      'ThuNghiem123!',
    );
    expect(tester.takeException(), isNull);
  });
}
