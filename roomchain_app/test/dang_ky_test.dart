import 'dart:async';
import 'dart:io';
import 'dart:ui' as giao_dien;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/man_hinh_cho/chon_vai_tro.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tai_khoan/dang_ky.dart';
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
  Future<void> nhap(WidgetTester tester, String ten, String noiDung) async {
    await tester.ensureVisible(oNhap(ten));
    await tester.enterText(oNhap(ten), noiDung);
  }

  Future<void> gui(WidgetTester tester) async {
    tester.testTextInput.hide();
    await tester.ensureVisible(find.text('Tạo tài khoản'));
    await tester.tap(find.text('Tạo tài khoản'));
    await tester.pump();
  }

  Future<void> dienHopLe(
    WidgetTester tester, {
    String lienHe = 'minhanh@gmail.com',
  }) async {
    await nhap(tester, 'ho_ten', '  Trần Minh Anh  ');
    await nhap(tester, 'lien_he', lienHe);
    await nhap(tester, 'mat_khau', 'MatKhau123!');
    await nhap(tester, 'xac_nhan', 'MatKhau123!');
  }

  Future<void> dongY(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
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
        'A04 ${kichThuoc.width}x${kichThuoc.height}, chữ $coChu, bàn phím',
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
              child: khung(const DangKy(vaiTro: 'TENANT'), coChu: coChu),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(TextFormField), findsNWidgets(4));
          expect(find.text('Vui lòng nhập họ và tên'), findsNothing);
          expect(tester.takeException(), isNull);
          if (thuMucAnh.isNotEmpty &&
              kichThuoc == const Size(390, 844) &&
              coChu == 1) {
            await dienHopLe(tester);
            await dongY(tester);
            FocusScope.of(tester.element(find.byType(DangKy))).unfocus();
            await tester.pump(const Duration(milliseconds: 500));
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
              await File('$thuMucAnh/a04_dang_ky.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              anh.dispose();
            });
          }
          tester.view.viewInsets = const FakeViewPadding(bottom: 240);
          await nhap(tester, 'ho_ten', 'Minh Anh');
          await tester.testTextInput.receiveAction(TextInputAction.next);
          await tester.pump();
          expect(
            tester
                .widget<EditableText>(
                  find.descendant(
                    of: oNhap('lien_he'),
                    matching: find.byType(EditableText),
                  ),
                )
                .focusNode
                .hasFocus,
            isTrue,
          );
          await tester.ensureVisible(find.text('Tạo tài khoản'));
          await tester.pumpAndSettle();
          expect(
            tester.getBottomLeft(find.text('Tạo tài khoản')).dy,
            lessThanOrEqualTo(kichThuoc.height - 240),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Form trống, tên toàn khoảng trắng và tên quá dài bị chặn', (
    tester,
  ) async {
    await tester.pumpWidget(khung(const DangKy(vaiTro: 'TENANT')));
    await gui(tester);
    expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
    expect(find.text('Vui lòng nhập email hoặc số điện thoại'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    expect(find.text('Vui lòng xác nhận mật khẩu'), findsOneWidget);
    await nhap(tester, 'ho_ten', '   ');
    await gui(tester);
    expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
    await nhap(tester, 'ho_ten', 'A' * 101);
    await gui(tester);
    expect(find.text('Họ và tên không quá 100 ký tự'), findsOneWidget);
  });

  testWidgets('Email/số điện thoại sai, mật khẩu ngắn và xác nhận khác', (
    tester,
  ) async {
    await tester.pumpWidget(khung(const DangKy(vaiTro: 'TENANT')));
    await dienHopLe(tester, lienHe: 'sai@');
    await nhap(tester, 'mat_khau', '123');
    await nhap(tester, 'xac_nhan', '456');
    await gui(tester);
    expect(find.text('Email hoặc số điện thoại không hợp lệ'), findsOneWidget);
    expect(find.text('Mật khẩu cần ít nhất 8 ký tự'), findsOneWidget);
    expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    await nhap(tester, 'lien_he', '012345');
    await gui(tester);
    expect(find.text('Email hoặc số điện thoại không hợp lệ'), findsOneWidget);
  });

  testWidgets('Hai nút hiện/ẩn mật khẩu hoạt động độc lập', (tester) async {
    await tester.pumpWidget(khung(const DangKy(vaiTro: 'TENANT')));
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: oNhap('mat_khau'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isTrue,
    );
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: oNhap('xac_nhan'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Hiện mật khẩu'));
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: oNhap('mat_khau'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isFalse,
    );
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: oNhap('xac_nhan'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Hiện xác nhận mật khẩu'));
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: oNhap('xac_nhan'),
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
              of: oNhap('mat_khau'),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText,
      isTrue,
    );
  });

  for (final lienHe in [
    ' minhanh@gmail.com ',
    '0901 234 567',
    '+84901234567',
  ]) {
    testWidgets(
      'Dữ liệu hợp lệ: $lienHe; bắt buộc đồng ý, giữ role và trim tên',
      (tester) async {
        ThongTinDangKyTam? daNhan;
        await tester.pumpWidget(
          khung(
            DangKy(
              vaiTro: 'LANDLORD',
              khiTiepTuc: (duLieu) async {
                daNhan = duLieu;
              },
            ),
          ),
        );
        await dienHopLe(tester, lienHe: lienHe);
        await gui(tester);
        expect(daNhan, isNull);
        expect(
          find.text('Vui lòng đồng ý điều khoản và chính sách bảo mật'),
          findsOneWidget,
        );
        await dongY(tester);
        await gui(tester);
        expect(daNhan!.hoTen, 'Trần Minh Anh');
        expect(daNhan!.vaiTro, 'LANDLORD');
        expect(daNhan!.lienHe, lienHe.trim().replaceAll(' ', ''));
        expect(
          tester.widget<TextFormField>(oNhap('mat_khau')).controller!.text,
          isEmpty,
        );
      },
    );
  }

  testWidgets('Loading chặn gửi lặp, lỗi callback không lộ nội dung nhạy cảm', (
    tester,
  ) async {
    final cho = Completer<void>();
    var soLan = 0;
    await tester.pumpWidget(
      khung(
        DangKy(
          vaiTro: 'TENANT',
          khiTiepTuc: (_) {
            soLan++;
            return cho.future;
          },
        ),
      ),
    );
    await dienHopLe(tester);
    await dongY(tester);
    await gui(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Tạo tài khoản'), warnIfMissed: false);
    expect(soLan, 1);
    expect(tester.widget<TextFormField>(oNhap('ho_ten')).enabled, isFalse);
    cho.completeError(StateError('Lỗi nội bộ không hiển thị'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa thể tiếp tục. Vui lòng thử lại.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  for (final vaiTro in ['TENANT', 'LANDLORD']) {
    testWidgets('Route giữ $vaiTro và Back về chọn vai trò', (tester) async {
      await tester.pumpWidget(khung(const ChonVaiTro()));
      if (vaiTro == 'LANDLORD') {
        await tester.tap(find.byKey(const ValueKey('vai_tro_LANDLORD')));
      }
      await tester.tap(find.text('Bắt đầu ngay'));
      await tester.pumpAndSettle();
      expect(tester.widget<DangKy>(find.byType(DangKy)).vaiTro, vaiTro);
      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();
      expect(find.byType(ChonVaiTro), findsOneWidget);
    });
  }

  testWidgets(
    'LANDLORD: Done báo hồ sơ chủ trọ chưa có, không mở hồ sơ Tenant',
    (tester) async {
      await tester.pumpWidget(khung(const DangKy(vaiTro: 'LANDLORD')));
      await dienHopLe(tester);
      await dongY(tester);
      await tester.showKeyboard(oNhap('xac_nhan'));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.textContaining('Tài khoản chưa được tạo.'), findsOneWidget);
      expect(find.byType(DangKy), findsOneWidget);
    },
  );

  testWidgets('Điều khoản và bảo mật mở thông báo trung thực', (tester) async {
    await tester.pumpWidget(khung(const DangKy(vaiTro: 'TENANT')));
    final doan = tester.widget<RichText>(
      find
          .descendant(
            of: find.byType(DangKy),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is RichText &&
                  w.text.toPlainText().startsWith('Tôi đồng ý'),
            ),
          )
          .first,
    );
    final cacLienKet = <TapGestureRecognizer>[];
    void timLienKet(InlineSpan span) {
      if (span is TextSpan) {
        if (span.recognizer is TapGestureRecognizer) {
          cacLienKet.add(span.recognizer! as TapGestureRecognizer);
        }
        for (final con in span.children ?? <InlineSpan>[]) {
          timLienKet(con);
        }
      }
    }

    timLienKet(doan.text);
    expect(cacLienKet, hasLength(2));
    for (final lienKet in cacLienKet) {
      lienKet.onTap!();
      await tester.pumpAndSettle();
      expect(
        find.text('Nội dung tài liệu chưa được cung cấp.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
    }
  });
}
