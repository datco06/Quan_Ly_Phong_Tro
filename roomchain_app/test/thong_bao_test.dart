import 'dart:io';
import 'dart:ui' as giao_dien;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/thong_bao/danh_sach_thong_bao.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/thong_bao/du_lieu_thong_bao_mau.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tai_khoan/dang_nhap.dart';
import 'package:roomchain_app/dung_chung/mo_hinh/thong_bao.dart';
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
  Future<void> chuyenTab(WidgetTester tester, String nhan) async {
    final tab = find.widgetWithText(ChoiceChip, nhan);
    await tester.ensureVisible(tab);
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }

  Future<void> docTin(WidgetTester tester, String id) async {
    final muc = find.byKey(ValueKey(id));
    await tester.ensureVisible(muc);
    await tester.tap(muc);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();
  }

  test('Mốc thời gian tương đối và ngày cũ được định dạng đúng', () {
    final moc = DateTime(2026, 10, 21, 10);
    for (final muc in <Duration, String>{
      const Duration(seconds: -5): 'Vừa xong',
      const Duration(seconds: 59): 'Vừa xong',
      const Duration(minutes: 5): '5 phút trước',
      const Duration(minutes: 30): '30 phút trước',
      const Duration(hours: 2): '2 giờ trước',
      const Duration(days: 3): '3 ngày trước',
      const Duration(days: 7): '1 tuần trước',
      const Duration(days: 14): '2 tuần trước',
      const Duration(days: 30): '21/09/2026',
    }.entries) {
      expect(
        dinhDangThoiGianThongBao(moc.subtract(muc.key), bayGio: moc),
        muc.value,
      );
    }
  });

  for (final kichThuoc in const [
    Size(360, 740),
    Size(390, 844),
    Size(430, 932),
    Size(320, 480),
  ]) {
    for (final coChu in [1.0, 2.0]) {
      testWidgets('S01 ${kichThuoc.width}x${kichThuoc.height}, chữ $coChu', (
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
            child: khung(
              const DanhSachThongBao(vaiTro: VaiTro.tenant),
              coChu: coChu,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Thông báo'), findsOneWidget);
        expect(find.byType(ChoiceChip), findsNWidgets(3));
        expect(find.byType(BottomNavigationBar), findsNothing);
        expect(tester.takeException(), isNull);
        if (thuMucAnh.isNotEmpty &&
            kichThuoc == const Size(390, 844) &&
            coChu == 1) {
          await tester.runAsync(
            () => precacheImage(
              const AssetImage('assets/hinh_anh/gioi_thieu/chu_tro.png'),
              tester.element(find.byType(DanhSachThongBao)),
            ),
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
            await File('$thuMucAnh/s01_thong_bao.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            anh.dispose();
          });
        }
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('TB005')),
          200,
          scrollable: find.descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          ),
        );
        expect(find.byKey(const ValueKey('TB005')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Đúng 5 mock; lọc nhóm và giữ trạng thái đọc khi chuyển tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      khung(const DanhSachThongBao(vaiTro: VaiTro.tenant)),
    );
    expect(find.byKey(const ValueKey('chua_doc_TB001')), findsOneWidget);
    expect(find.text('Nguyễn Văn Minh'), findsOneWidget);
    await docTin(tester, 'TB001');
    expect(find.byKey(const ValueKey('chua_doc_TB001')), findsNothing);
    expect(find.byKey(const ValueKey('TB001')), findsOneWidget);
    await chuyenTab(tester, 'Tin nhắn');
    expect(find.byKey(const ValueKey('TB001')), findsOneWidget);
    expect(find.byKey(const ValueKey('TB002')), findsNothing);
    await chuyenTab(tester, 'Hệ thống');
    expect(find.byKey(const ValueKey('TB001')), findsNothing);
    for (var i = 2; i <= 5; i++) {
      expect(find.byKey(ValueKey('TB00$i')), findsOneWidget);
    }
    await chuyenTab(tester, 'Tất cả');
    expect(find.byKey(const ValueKey('chua_doc_TB001')), findsNothing);
  });

  testWidgets('Nút thông tin và đánh dấu tất cả đã đọc', (tester) async {
    await tester.pumpWidget(
      khung(const DanhSachThongBao(vaiTro: VaiTro.landlord)),
    );
    await tester.tap(find.byTooltip('Thông tin thông báo'));
    await tester.pumpAndSettle();
    expect(find.text('Về thông báo'), findsOneWidget);
    await tester.tap(find.text('Đánh dấu tất cả đã đọc'));
    await tester.pumpAndSettle();
    for (var i = 1; i <= 5; i++) {
      expect(find.byKey(ValueKey('chua_doc_TB00$i')), findsNothing);
      expect(find.byKey(ValueKey('TB00$i')), findsOneWidget);
    }
  });

  testWidgets(
    'Làm mới giữ đã đọc, nhận thông báo mới và không sửa list đầu vào',
    (tester) async {
      final dau = taoThongBaoMau();
      final moi = ThongBao(
        id: 'TB006',
        tieuDe: 'Tin mới',
        noiDung: 'Nội dung mới',
        loai: NhomThongBao.heThong,
        suKien: SuKienThongBao.heThong,
        thoiGian: DateTime.now(),
      );
      await tester.pumpWidget(
        khung(
          DanhSachThongBao(
            vaiTro: VaiTro.tenant,
            duLieuBanDau: dau,
            khiLamMoi: () async => [...dau, moi],
          ),
        ),
      );
      await docTin(tester, 'TB001');
      expect(dau.first.daDoc, isFalse);
      await tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      await tester.pumpAndSettle();
      expect(find.text('Tin mới'), findsOneWidget);
      expect(find.byKey(const ValueKey('chua_doc_TB001')), findsNothing);
      expect(find.byKey(const ValueKey('chua_doc_TB006')), findsOneWidget);
    },
  );

  testWidgets('Kéo xuống làm mới và xử lý lỗi không mất danh sách', (
    tester,
  ) async {
    var soLan = 0;
    await tester.pumpWidget(
      khung(
        DanhSachThongBao(
          vaiTro: VaiTro.tenant,
          khiLamMoi: () async {
            soLan++;
            throw StateError('Lỗi demo');
          },
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, 350));
    await tester.pumpAndSettle();
    expect(soLan, 1);
    expect(
      find.text('Chưa thể làm mới thông báo. Vui lòng thử lại.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('TB001')), findsOneWidget);
  });

  testWidgets('Empty state cho toàn bộ và bộ lọc không có tin', (tester) async {
    await tester.pumpWidget(
      khung(const DanhSachThongBao(vaiTro: VaiTro.tenant, duLieuBanDau: [])),
    );
    expect(find.byType(TrangThaiRong), findsOneWidget);
    expect(find.text('Chưa có thông báo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      khung(
        DanhSachThongBao(
          vaiTro: VaiTro.tenant,
          duLieuBanDau: taoThongBaoMau()
              .where((muc) => muc.loai == NhomThongBao.heThong)
              .toList(),
        ),
      ),
    );
    await chuyenTab(tester, 'Tin nhắn');
    expect(find.text('Các thông báo mới sẽ xuất hiện tại đây'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Đích chưa có: dialog chứa nội dung đầy đủ, callback đích có ID đúng',
    (tester) async {
      final muc = ThongBao(
        id: 'dai',
        tieuDe: 'Thông báo dài',
        noiDung: 'Nội dung rất dài ' * 30,
        loai: NhomThongBao.heThong,
        suKien: SuKienThongBao.hopDong,
        thoiGian: DateTime.now(),
        duongDanDich: '/chua-co',
        doiTuongId: 'HD001',
      );
      await tester.pumpWidget(
        khung(DanhSachThongBao(vaiTro: VaiTro.landlord, duLieuBanDau: [muc])),
      );
      await tester.tap(find.byKey(const ValueKey('dai')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(muc.noiDung),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      ThongBao? daMo;
      await tester.pumpWidget(
        khung(
          DanhSachThongBao(
            vaiTro: VaiTro.landlord,
            duLieuBanDau: [muc],
            khiMoThongBao: (tb) async {
              daMo = tb;
            },
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('dai')));
      await tester.pumpAndSettle();
      expect(daMo!.doiTuongId, 'HD001');
      expect(daMo!.daDoc, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final vaiTro in VaiTro.values) {
    testWidgets('Back không có lịch sử dùng callback đúng role $vaiTro', (
      tester,
    ) async {
      VaiTro? daNhan;
      await tester.pumpWidget(
        khung(
          DanhSachThongBao(
            vaiTro: vaiTro,
            khiVeTrangChinh: (role) => daNhan = role,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Quay lại'));
      expect(daNhan, vaiTro);
    });
    testWidgets('S01 nhúng layout $vaiTro: một Scaffold và một navigation', (
      tester,
    ) async {
      final trang = DanhSachThongBao(vaiTro: vaiTro, trongTab: true);
      await tester.pumpWidget(
        khung(
          vaiTro == VaiTro.tenant
              ? BoCucNguoiThue(noiDung: trang, chiSoChon: 3, khiChon: (_) {})
              : BoCucChuTro(noiDung: trang, chiSoChon: 4, khiChon: (_) {}),
        ),
      );
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ThanhDieuHuongVaiTro), findsOneWidget);
      expect(find.byTooltip('Quay lại'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Route truyền role, Back về trang trước; root fallback đăng nhập',
    (tester) async {
      await tester.pumpWidget(
        khung(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  DieuHuong.thongBao,
                  arguments: 'LANDLORD',
                ),
                child: const Text('Mở'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Mở'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<DanhSachThongBao>(find.byType(DanhSachThongBao)).vaiTro,
        VaiTro.landlord,
      );
      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();
      expect(find.text('Mở'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        khung(const DanhSachThongBao(vaiTro: VaiTro.landlord)),
      );
      await tester.tap(find.byTooltip('Quay lại'));
      await tester.pumpAndSettle();
      expect(find.byType(DangNhap), findsOneWidget);
    },
  );
}
