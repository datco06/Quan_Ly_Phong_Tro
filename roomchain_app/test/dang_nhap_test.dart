import 'dart:async';
import 'dart:io';
import 'dart:ui' as giao_dien;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tai_khoan/dang_ky.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tai_khoan/dang_nhap.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/ung_dung/dieu_huong.dart';

void main() {
  const thuMucAnh = String.fromEnvironment('THU_MUC_ANH');
  const tepPhongChu = String.fromEnvironment('TEP_PHONG_CHU');
  setUpAll(() async {
    if (tepPhongChu.isNotEmpty) {
      final chu = FontLoader('Roboto')
        ..addFont(File(tepPhongChu).readAsBytes().then(ByteData.sublistView));
      await chu.load();
      final icon = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icon.load();
    }
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

  Future<void> gui(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Đăng nhập'));
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump();
  }

  for (final kichThuoc in const [
    Size(360, 740),
    Size(390, 844),
    Size(430, 932),
    Size(320, 480),
  ]) {
    for (final coChu in [1.0, 2.0]) {
      testWidgets(
        'Đăng nhập ${kichThuoc.width}x${kichThuoc.height}, chữ $coChu',
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
              child: khung(const DangNhap(), coChu: coChu),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(TextFormField), findsNWidgets(2));
          expect(find.text('Vui lòng nhập tài khoản'), findsNothing);
          if (thuMucAnh.isNotEmpty &&
              kichThuoc == const Size(390, 844) &&
              coChu == 1) {
            await nhap(tester, 'tai_khoan_dang_nhap', 'minhanh@gmail.com');
            await nhap(tester, 'mat_khau_dang_nhap', 'ThuNghiem123!');
            FocusScope.of(tester.element(find.byType(DangNhap))).unfocus();
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
              await File('$thuMucAnh/dang_nhap.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              anh.dispose();
            });
          }
          tester.view.viewInsets = const FakeViewPadding(bottom: 240);
          await tester.pumpAndSettle();
          await nhap(tester, 'tai_khoan_dang_nhap', 'anh@example.com');
          await tester.testTextInput.receiveAction(TextInputAction.next);
          await tester.pumpAndSettle();
          final oMatKhau = tester.widget<EditableText>(
            find.descendant(
              of: oNhap('mat_khau_dang_nhap'),
              matching: find.byType(EditableText),
            ),
          );
          expect(oMatKhau.focusNode.hasFocus, isTrue);
          await tester.ensureVisible(find.text('Đăng nhập'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Kiểm tra trống, tài khoản sai và nút hiện/ẩn mật khẩu', (
    tester,
  ) async {
    await tester.pumpWidget(khung(const DangNhap()));
    await gui(tester);
    expect(find.text('Vui lòng nhập tài khoản'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    await nhap(tester, 'tai_khoan_dang_nhap', 'sai@');
    await nhap(tester, 'mat_khau_dang_nhap', '12345678');
    await gui(tester);
    expect(find.text('Email hoặc số điện thoại không hợp lệ'), findsOneWidget);
    await tester.tap(find.byTooltip('Hiện mật khẩu'));
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: oNhap('mat_khau_dang_nhap'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isFalse,
    );
    await tester.tap(find.byTooltip('Ẩn mật khẩu'));
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: oNhap('mat_khau_dang_nhap'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isTrue,
    );
  });

  for (final taiKhoan in [' anh@example.com ', '0901 234 567']) {
    testWidgets('Truyền tài khoản $taiKhoan và mật khẩu qua callback', (
      tester,
    ) async {
      String? daNhan;
      var dungMatKhau = false;
      await tester.pumpWidget(
        khung(
          DangNhap(
            khiDangNhap: (tk, mk) async {
              daNhan = tk;
              dungMatKhau = mk == 'ThuNghiem123!';
            },
          ),
        ),
      );
      await nhap(tester, 'tai_khoan_dang_nhap', taiKhoan);
      await nhap(tester, 'mat_khau_dang_nhap', 'ThuNghiem123!');
      await gui(tester);
      expect(daNhan, taiKhoan.trim().replaceAll(' ', ''));
      expect(dungMatKhau, isTrue);
      expect(
        tester
            .widget<TextFormField>(oNhap('mat_khau_dang_nhap'))
            .controller!
            .text,
        isEmpty,
      );
    });
  }

  testWidgets('Loading chặn gửi lặp và lỗi không hiển thị chi tiết nội bộ', (
    tester,
  ) async {
    final cho = Completer<void>();
    var soLan = 0;
    await tester.pumpWidget(
      khung(
        DangNhap(
          khiDangNhap: (_, _) {
            soLan++;
            return cho.future;
          },
        ),
      ),
    );
    await nhap(tester, 'tai_khoan_dang_nhap', 'anh@example.com');
    await nhap(tester, 'mat_khau_dang_nhap', 'ThuNghiem123!');
    await gui(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Đăng nhập'), warnIfMissed: false);
    expect(soLan, 1);
    cho.completeError(StateError('Chi tiết nội bộ'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Không thể đăng nhập. Vui lòng kiểm tra thông tin hoặc thử lại.',
      ),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Chưa có Backend: Done chỉ thông báo, không đăng nhập giả', (
    tester,
  ) async {
    await tester.pumpWidget(khung(const DangNhap()));
    await nhap(tester, 'tai_khoan_dang_nhap', 'anh@example.com');
    await nhap(tester, 'mat_khau_dang_nhap', 'ThuNghiem123!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(
      find.text('Chức năng đăng nhập chưa kết nối máy chủ.'),
      findsOneWidget,
    );
    expect(find.byType(DangNhap), findsOneWidget);
  });

  testWidgets('Liên kết đăng ký mở đăng nhập; Back giữ dữ liệu đăng ký', (
    tester,
  ) async {
    await tester.pumpWidget(khung(const DangKy(vaiTro: 'LANDLORD')));
    await nhap(tester, 'ho_ten', 'Minh Anh');
    final lienKet = find.textContaining('Bạn đã có tài khoản?');
    await tester.ensureVisible(lienKet);
    await tester.tap(lienKet);
    await tester.pumpAndSettle();
    expect(find.byType(DangNhap), findsOneWidget);
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.byType(DangKy), findsOneWidget);
    expect(
      tester.widget<TextFormField>(oNhap('ho_ten')).controller!.text,
      'Minh Anh',
    );
    expect(tester.takeException(), isNull);
  });
}
