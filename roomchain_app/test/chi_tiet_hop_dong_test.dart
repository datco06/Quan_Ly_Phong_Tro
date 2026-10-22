import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/chi_tiet_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/danh_sach_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/tai_lieu_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/xem_truoc_hop_dong.dart';
import 'package:roomchain_app/dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/ung_dung/dieu_huong.dart';

class _TaiLoi extends TaiLieuHopDongDemo {
  const _TaiLoi();
  @override
  Future<bool> tai(TaiLieuHopDong t) async => throw StateError('Lỗi thiết bị');
}

class _NapCham extends TaiLieuHopDongDemo {
  _NapCham(this.cho);
  final Completer<TaiLieuHopDong> cho;
  @override
  Future<TaiLieuHopDong> lay(KhoHopDongMau kho, String id) => cho.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const thuMucAnh = String.fromEnvironment('THU_MUC_ANH');
  const tepPhongChu = String.fromEnvironment('TEP_PHONG_CHU');
  late TaiLieuHopDong taiLieu;
  late HopDong mau;
  final tepDaTai = <String>[];
  Uint8List? byteDaTai;
  setUpAll(() async {
    final kho = KhoHopDongMau();
    mau = kho.danhSach.first;
    taiLieu = await const TaiLieuHopDongDemo().lay(kho, mau.id);
    kho.dispose();
    if (thuMucAnh.isNotEmpty) {
      await Directory(thuMucAnh).create(recursive: true);
      await File('$thuMucAnh/hop_dong_demo.pdf').writeAsBytes(taiLieu.noiDung);
    }
    if (tepPhongChu.isNotEmpty) {
      await (FontLoader('Roboto')..addFont(
            File(tepPhongChu).readAsBytes().then(ByteData.sublistView),
          ))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });
  setUp(() {
    tepDaTai.clear();
    byteDaTai = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('net.nfet.printing'), (
          call,
        ) async {
          if (call.method == 'printingInfo') {
            return {'canRaster': false, 'canShare': true};
          }
          if (call.method == 'sharePdf') {
            final a = call.arguments as Map;
            tepDaTai.add(a['name'] as String);
            byteDaTai = a['doc'] as Uint8List;
            return 1;
          }
          return null;
        });
  });
  KhoHopDongMau khoMau({HopDong? h}) =>
      KhoHopDongMau(banDau: [h ?? mau.copyWith(taiLieu: taiLieu)]);
  Widget khung(Widget trang, {double chu = 1}) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    onGenerateRoute: DieuHuong.taoRoute,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(chu)),
      child: child!,
    ),
    home: trang,
  );
  Future<void> nhan(WidgetTester t, String chu) async {
    final nut = find.widgetWithText(NutBam, chu);
    final f = nut.evaluate().isNotEmpty ? nut.last : find.text(chu).last;
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> tab(WidgetTester t, int i) async {
    final f = find.byKey(ValueKey('chi_tiet_tab_$i'));
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> anh(WidgetTester t, String ten) async {
    if (thuMucAnh.isEmpty) return;
    final b = t.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('anh')),
    );
    await t.runAsync(() async {
      final h = await b.toImage();
      final data = await h.toByteData(format: ui.ImageByteFormat.png);
      await File('$thuMucAnh/$ten.png')
          .writeAsBytes(data!.buffer.asUint8List());
      h.dispose();
    });
  }

  test(
    'PDF thật, hash đúng byte, bộ nhớ chỉ đọc và tái sử dụng nguyên phiên bản',
    () async {
      final kho = khoMau(h: mau);
      addTearDown(kho.dispose);
      final a = await const TaiLieuHopDongDemo().lay(kho, mau.id);
      expect(String.fromCharCodes(a.noiDung.take(5)), '%PDF-');
      expect(
        String.fromCharCodes(a.noiDung.skip(a.noiDung.length - 10)),
        contains('%%EOF'),
      );
      expect(sha256.convert(a.noiDung).toString(), a.sha256);
      expect(a.sha256.length, 64);
      final b = await const TaiLieuHopDongDemo().lay(kho, mau.id);
      expect(b, same(a));
      expect(kho.theoId(mau.id)!.taiLieu, same(a));
      expect(() => a.noiDung[0] = 0, throwsUnsupportedError);
      expect(kho.luuTaiLieu(mau.id, taiLieu), same(a));
    },
  );
  test(
    'PDF của hai hợp đồng có mã băm khác nhau, dùng đúng phòng và giá thuê',
    () async {
      final kho = KhoHopDongMau();
      addTearDown(kho.dispose);
      final a = await const TaiLieuHopDongDemo().lay(kho, kho.danhSach[0].id);
      final b = await const TaiLieuHopDongDemo().lay(kho, kho.danhSach[1].id);
      expect(a.sha256, isNot(b.sha256));
      expect(a.tenTep, isNot(b.tenTep));
      expect(kho.phong(kho.danhSach[0].phongId).giaThue, 2500000);
    },
  );
  test(
    'Thiếu tài liệu đã ký và tài liệu hỏng không bị tự tạo/ghi đè',
    () async {
      final ky = mau.copyWith(chuTroKyLuc: DateTime(2026, 10, 1));
      final kho = khoMau(h: ky);
      addTearDown(kho.dispose);
      await expectLater(
        const TaiLieuHopDongDemo().lay(kho, mau.id),
        throwsStateError,
      );
      expect(() => kho.luuTaiLieu(mau.id, taiLieu), throwsStateError);
      final hong = TaiLieuHopDong(
        noiDung: Uint8List.fromList([1, 2, 3]),
        tenTep: 'hong.pdf',
        sha256: 'sai',
        ngayTao: DateTime(2026),
      );
      final khac = khoMau(h: mau.copyWith(taiLieu: hong));
      addTearDown(khac.dispose);
      await expectLater(
        const TaiLieuHopDongDemo().lay(khac, mau.id),
        throwsStateError,
      );
      expect(khac.theoId(mau.id)!.taiLieu, same(hong));
    },
  );
  test(
    'Gửi ký chỉ tạo yêu cầu một lần, không tạo chữ ký/cọc, không sửa PDF',
    () {
      final kho = khoMau();
      addTearDown(kho.dispose);
      final truoc = kho.theoId(mau.id)!;
      kho.guiYeuCauKy(mau.id);
      final sau = kho.theoId(mau.id)!;
      expect(sau.guiKyLuc, isNotNull);
      expect(sau.trangThai, TrangThaiHopDong.choKy);
      expect(sau.chuTroKyLuc, isNull);
      expect(sau.nguoiThueKyLuc, isNull);
      expect(sau.coc, isNull);
      expect(sau.taiLieu, same(truoc.taiLieu));
      expect(sau.lichSu.last.loai, LoaiSuKienHopDong.guiKy);
      expect(() => kho.guiYeuCauKy(mau.id), throwsStateError);
    },
  );
  test(
    'Gửi ký chặn thiếu file, thông tin sai, trạng thái sai, đã ký và ID lạ',
    () {
      for (final h in [
        mau,
        mau.copyWith(giaThue: 0, taiLieu: taiLieu),
        mau.copyWith(taiLieu: taiLieu, trangThai: TrangThaiHopDong.choCoc),
        mau.copyWith(taiLieu: taiLieu, chuTroKyLuc: DateTime(2026)),
      ]) {
        final kho = khoMau(h: h);
        expect(() => kho.guiYeuCauKy(mau.id), throwsStateError);
        kho.dispose();
      }
      final kho = khoMau();
      addTearDown(kho.dispose);
      expect(() => kho.guiYeuCauKy('khong-co'), throwsStateError);
    },
  );
  test('Nhắc đặt cọc cập nhật lịch sử demo và giữ nguyên cọc/trạng thái', () {
    final kho = khoMau(h: mau.copyWith(trangThai: TrangThaiHopDong.choCoc));
    addTearDown(kho.dispose);
    kho.nhacDatCoc(mau.id);
    final h = kho.theoId(mau.id)!;
    expect(h.lichSu.last.loai, LoaiSuKienHopDong.nhacCoc);
    expect(h.coc, isNull);
    expect(h.trangThai, TrangThaiHopDong.choCoc);
  });

  for (final size in const [Size(360, 740), Size(390, 844), Size(430, 932)]) {
    for (final chu in [1.0, 2.0]) {
      for (final xem in [false, true]) {
        testWidgets(
          '${xem ? 'L11' : 'L12'} ${size.width} x ${size.height}, chữ $chu',
          (t) async {
            t.view.physicalSize = size;
            t.view.devicePixelRatio = 1;
            t.view.padding = const FakeViewPadding(top: 24, bottom: 24);
            addTearDown(t.view.resetPhysicalSize);
            addTearDown(t.view.resetDevicePixelRatio);
            addTearDown(t.view.resetPadding);
            final kho = khoMau();
            addTearDown(kho.dispose);
            await t.pumpWidget(
              khung(
                RepaintBoundary(
                  key: const ValueKey('anh'),
                  child: xem
                      ? XemTruocHopDong(hopDongId: mau.id, kho: kho)
                      : ChiTietHopDong(hopDongId: mau.id, kho: kho),
                ),
                chu: chu,
              ),
            );
            await t.pumpAndSettle();
            expect(find.byType(Scaffold), findsOneWidget);
            expect(find.byType(ThanhDieuHuongVaiTro), findsNothing);
            expect(t.takeException(), isNull);
            if (!xem) {
              if (size.width == 390 && chu == 1) {
                await anh(t, 'l12_chi_tiet_hop_dong');
              }
              for (var i = 1; i < 4; i++) {
                await tab(t, i);
                expect(t.takeException(), isNull);
              }
            } else {
              final hash = find.byType(PdfPreview);
              await t.ensureVisible(hash);
              expect(hash, findsOneWidget);
              expect(find.textContaining('/ 12'), findsNothing);
            }
          },
        );
      }
    }
  }

  testWidgets(
    'L09 mở L12 đúng ID, tab tài liệu mở L11; back giữ trang và dữ liệu',
    (t) async {
      final kho = khoMau();
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(DanhSachHopDong(kho: kho)));
      await t.pumpAndSettle();
      await t.tap(find.byKey(ValueKey(mau.id)));
      await t.pumpAndSettle();
      expect(
        t.widget<ChiTietHopDong>(find.byType(ChiTietHopDong)).hopDongId,
        mau.id,
      );
      await tab(t, 2);
      expect(find.text(taiLieu.tenTep), findsOneWidget);
      await nhan(t, 'Xem trước hợp đồng');
      expect(
        t.widget<XemTruocHopDong>(find.byType(XemTruocHopDong)).hopDongId,
        mau.id,
      );
      await t.tap(find.byTooltip('Quay lại'));
      await t.pumpAndSettle();
      expect(find.byType(ChiTietHopDong), findsOneWidget);
      await t.tap(find.byTooltip('Quay lại'));
      await t.pumpAndSettle();
      expect(find.byType(DanhSachHopDong), findsOneWidget);
    },
  );
  testWidgets('Copy hash đầy đủ, tải đúng file và xác nhận gửi ký', (t) async {
    String? copy;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copy = (call.arguments as Map)['text'] as String;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final kho = khoMau();
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(XemTruocHopDong(hopDongId: mau.id, kho: kho)));
    await t.pumpAndSettle();
    final nutCopy = find.byTooltip('Sao chép mã băm');
    await t.ensureVisible(nutCopy);
    await t.tap(nutCopy);
    await t.pumpAndSettle();
    expect(copy, taiLieu.sha256);
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
    await nhan(t, 'Tải PDF');
    expect(tepDaTai, [taiLieu.tenTep]);
    expect(byteDaTai, orderedEquals(taiLieu.noiDung));
    await nhan(t, 'Gửi cho người thuê ký');
    expect(find.byType(HopThoaiXacNhan), findsOneWidget);
    await nhan(t, 'Hủy');
    expect(kho.theoId(mau.id)!.guiKyLuc, isNull);
    await nhan(t, 'Gửi cho người thuê ký');
    await nhan(t, 'Xác nhận');
    expect(kho.theoId(mau.id)!.guiKyLuc, isNotNull);
    expect(kho.theoId(mau.id)!.daCoChuKy, isFalse);
    expect(find.text('Đã gửi yêu cầu ký'), findsOneWidget);
  });
  testWidgets('L11 có loading, lỗi tải, lỗi PDF và trạng thái không tìm thấy', (
    t,
  ) async {
    final kho = khoMau();
    addTearDown(kho.dispose);
    final cho = Completer<TaiLieuHopDong>();
    await t.pumpWidget(
      khung(
        XemTruocHopDong(hopDongId: mau.id, kho: kho, dichVu: _NapCham(cho)),
      ),
    );
    expect(find.text('Đang mở PDF...'), findsOneWidget);
    cho.completeError(StateError('Không đọc được file PDF.'));
    await t.pumpAndSettle();
    expect(find.text('Không đọc được file PDF.'), findsOneWidget);
    expect(find.byType(PdfPreview), findsNothing);
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(
      khung(
        XemTruocHopDong(hopDongId: mau.id, kho: kho, dichVu: const _TaiLoi()),
      ),
    );
    await t.pumpAndSettle();
    await nhan(t, 'Tải PDF');
    expect(find.textContaining('Không thể tải PDF'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(khung(XemTruocHopDong(hopDongId: 'khong-co', kho: kho)));
    await t.pumpAndSettle();
    expect(find.text('Không tìm thấy hợp đồng'), findsOneWidget);
  });
  testWidgets(
    'Đang thuê không suy ra chữ ký; cọc/token demo, quyết toán/gia hạn giữ nguyên dữ liệu',
    (t) async {
      final kho = KhoHopDongMau();
      addTearDown(kho.dispose);
      final h = kho.theoId(DuLieuGia.hopDong.id)!;
      await t.pumpWidget(khung(ChiTietHopDong(hopDongId: h.id, kho: kho)));
      await t.pumpAndSettle();
      expect(find.text('Chưa ký'), findsNWidgets(2));
      final coc = find.text('Đã khóa cọc (dữ liệu demo)');
      await t.ensureVisible(coc);
      expect(coc, findsOneWidget);
      expect(find.text('3.800.000 MockVNDC'), findsOneWidget);
      await nhan(t, 'Tạo quyết toán');
      expect(find.text('Chưa đủ điều kiện quyết toán'), findsOneWidget);
      await nhan(t, 'Đóng');
      await nhan(t, 'Gia hạn hợp đồng');
      expect(find.textContaining('Màn hình gia hạn chưa'), findsOneWidget);
      await nhan(t, 'Đóng');
      expect(kho.theoId(h.id), same(h));
      await tab(t, 1);
      expect(find.text('Ghi nhận khóa cọc (demo)'), findsOneWidget);
      await tab(t, 2);
      expect(find.text('Chưa có tài liệu PDF'), findsOneWidget);
    },
  );
  testWidgets(
    'Chữ ký chỉ hiển thị theo timestamp và từng trạng thái có thao tác phù hợp',
    (t) async {
      final h = mau.copyWith(
        taiLieu: taiLieu,
        chuTroKyLuc: DateTime(2026, 10, 1),
        trangThai: TrangThaiHopDong.choCoc,
      );
      final kho = khoMau(h: h);
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(ChiTietHopDong(hopDongId: h.id, kho: kho)));
      await t.pumpAndSettle();
      expect(find.text('Đã ký (demo)'), findsOneWidget);
      expect(find.text('Chưa ký'), findsOneWidget);
      expect(find.text('Tạo quyết toán'), findsNothing);
      await tab(t, 3);
      expect(find.text('Nhắc người thuê đặt cọc'), findsOneWidget);
      expect(find.text('Gửi yêu cầu ký'), findsNothing);
      await nhan(t, 'Nhắc người thuê đặt cọc');
      await nhan(t, 'Xác nhận');
      expect(kho.theoId(h.id)!.lichSu.last.loai, LoaiSuKienHopDong.nhacCoc);
      await tab(t, 1);
      expect(find.text('Nhắc đặt cọc (demo)'), findsOneWidget);
    },
  );
  testWidgets(
    'Lịch sử rỗng, hợp đồng kết thúc, ID không tồn tại và route có kiểm tra tham số',
    (t) async {
      final h = mau.copyWith(lichSu: [], trangThai: TrangThaiHopDong.daKetThuc);
      final kho = khoMau(h: h);
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(ChiTietHopDong(hopDongId: h.id, kho: kho)));
      await t.pumpAndSettle();
      await tab(t, 1);
      expect(find.text('Chưa có lịch sử giao dịch'), findsOneWidget);
      await tab(t, 3);
      expect(find.text('Tạo quyết toán'), findsOneWidget);
      expect(find.text('Gửi yêu cầu ký'), findsNothing);
      await nhan(t, 'Xem lịch sử hoàn cọc');
      expect(find.text('Chưa có lịch sử giao dịch'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(
        khung(ChiTietHopDong(hopDongId: 'khong-co', kho: kho)),
      );
      await t.pumpAndSettle();
      expect(find.text('Không tìm thấy hợp đồng'), findsOneWidget);
      expect(
        DieuHuong.taoRoute(const RouteSettings(name: DieuHuong.chiTietHopDong)),
        isNull,
      );
    },
  );

  testWidgets('L12 báo tài liệu hỏng và không cho tải/copy mã băm sai', (
    t,
  ) async {
    final hong = TaiLieuHopDong(
      noiDung: Uint8List.fromList([1, 2, 3]),
      tenTep: 'hong.pdf',
      sha256: 'sai',
      ngayTao: DateTime(2026),
    );
    final kho = khoMau(h: mau.copyWith(taiLieu: hong));
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(ChiTietHopDong(hopDongId: mau.id, kho: kho)));
    await t.pumpAndSettle();
    await tab(t, 2);
    expect(
      find.textContaining('Tài liệu PDF hoặc mã băm không hợp lệ'),
      findsOneWidget,
    );
    expect(find.text('Tải PDF'), findsNothing);
    expect(find.byTooltip('Sao chép mã băm'), findsNothing);
    expect(t.takeException(), isNull);
  });
}
