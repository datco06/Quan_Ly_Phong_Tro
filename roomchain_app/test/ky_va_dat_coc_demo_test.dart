import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/ky_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/tai_lieu_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/xem_hop_dong_nguoi_thue.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/chi_tiet_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tien_coc/dat_coc.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tien_coc/trang_thai_dat_coc.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tien_coc/quan_ly_tien_coc.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/vi_blockchain/trang_thai_vi_mau.dart';
import 'package:roomchain_app/dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import 'package:roomchain_app/dung_chung/mo_hinh/giao_dich_blockchain.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/ung_dung/dieu_huong.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HopDong goc;
  late TaiLieuHopDong pdf;
  setUpAll(() async {
    await (FontLoader(
      'Roboto',
    )..addFont(rootBundle.load('assets/phong_chu/Roboto-Regular.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    goc = HopDong(
      id: 'hd-t13',
      maHopDong: 'RC-DEMO-T13',
      phongId: 'P201',
      nguoiThueId: DuLieuGia.nguoiThue.id,
      ngayBatDau: DateTime(2027, 1, 1),
      ngayKetThuc: DateTime(2027, 12, 31),
      ngayTao: DateTime(2026, 10, 24, 10),
      giaThue: 3800000,
      tienCoc: 3800000,
      trangThai: TrangThaiHopDong.choKy,
    );
    final kho = KhoHopDongMau(banDau: [goc]);
    pdf = await const TaiLieuHopDongDemo().lay(kho, goc.id);
    kho.dispose();
  });

  HopDong banChuan({bool nguoiKy = false, bool chuKy = false}) => goc.copyWith(
    guiKyLuc: DateTime(2026, 10, 24, 10, 1),
    taiLieu: pdf,
    nguoiThueDongYLuc: DateTime(2026, 10, 24, 10, 2),
    nguoiThueKyLuc: nguoiKy ? DateTime(2026, 10, 24, 10, 3) : null,
    chuTroKyLuc: chuKy ? DateTime(2026, 10, 24, 10, 4) : null,
    viNguoiThueKy: nguoiKy ? TrangThaiViMau.diaChiMau : null,
    maBamDaKy: nguoiKy ? pdf.sha256 : null,
    trangThai: nguoiKy && chuKy
        ? TrangThaiHopDong.choCoc
        : TrangThaiHopDong.choKy,
  );
  KhoHopDongMau khoMau({bool daKy = false}) => KhoHopDongMau(
    banDau: [
      banChuan(nguoiKy: daKy, chuKy: daKy),
      DuLieuGia.hopDong.copyWith(coc: DuLieuGia.tienCoc),
    ],
  );
  Widget khung(Widget trang, {double chu = 1}) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    onGenerateRoute: DieuHuong.taoRoute,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(chu)),
      child: child!,
    ),
    home: RepaintBoundary(key: const ValueKey('anh-t13-t15'), child: trang),
  );
  Future<void> ketNoi(WidgetTester t, TrangThaiViMau vi) async {
    final f = vi.ketNoi(KetQuaKetNoiMau.thanhCong);
    await t.pump(const Duration(milliseconds: 700));
    await f;
  }

  Future<void> xuLy(WidgetTester t) async {
    for (final ms in [500, 500, 500, 650]) {
      await t.pump(Duration(milliseconds: ms));
    }
    await t.pump();
  }

  Future<void> nhan(WidgetTester t, String chu) async {
    final nut = find.widgetWithText(NutBam, chu);
    final f = nut.evaluate().isNotEmpty ? nut.last : find.text(chu).last;
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> anh(WidgetTester t, String ten) async {
    const thuMuc = String.fromEnvironment('THU_MUC_ANH');
    if (thuMuc.isEmpty) return;
    final b = t.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('anh-t13-t15')),
    );
    await t.runAsync(() async {
      final img = await b.toImage();
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      await Directory(thuMuc).create(recursive: true);
      await File('$thuMuc/$ten.png').writeAsBytes(data!.buffer.asUint8List());
      img.dispose();
    });
  }

  testWidgets(
    'Ký demo thất bại/đổi phiên không tạo chữ ký; chủ trọ xác nhận riêng',
    (t) async {
      final kho = khoMau();
      final vi = TrangThaiViMau();
      addTearDown(kho.dispose);
      addTearDown(vi.dispose);
      expect(kho.kiemTraKyDemo(goc.id, vi), isNotNull);
      await ketNoi(t, vi);
      final loi = kho.kyNguoiThueDemo(goc.id, vi, thatBai: true);
      expect(kho.theoId(goc.id)!.dangKyDemo, isTrue);
      await t.pump(const Duration(milliseconds: 650));
      expect(await loi, isFalse);
      expect(kho.theoId(goc.id)!.nguoiThueKyLuc, isNull);
      final huy = kho.kyNguoiThueDemo(goc.id, vi);
      vi.ngatKetNoi();
      await t.pump(const Duration(milliseconds: 650));
      expect(await huy, isFalse);
      await ketNoi(t, vi);
      final f = kho.kyNguoiThueDemo(goc.id, vi);
      await t.pump(const Duration(milliseconds: 650));
      expect(await f, isTrue);
      final h = kho.theoId(goc.id)!;
      expect(h.nguoiThueKyLuc, isNotNull);
      expect(h.chuTroKyLuc, isNull);
      expect(h.trangThai, TrangThaiHopDong.choKy);
      expect(h.coc, isNull);
      expect(kho.kiemTraDatCocDemo(h.id, vi), isNotNull);
      kho.chuTroXacNhanKyDemo(h.id);
      expect(kho.theoId(h.id)!.trangThai, TrangThaiHopDong.choCoc);
      expect(kho.kiemTraDatCocDemo(h.id, vi), isNull);
    },
  );

  testWidgets(
    'Chặn thiếu đồng ý/PDF, nhấn ký trùng và thiếu xác nhận chủ trọ',
    (t) async {
      final vi = TrangThaiViMau();
      addTearDown(vi.dispose);
      await ketNoi(t, vi);
      for (final ban in [
        goc,
        goc.copyWith(taiLieu: pdf, guiKyLuc: DateTime(2026)),
      ]) {
        final kho = KhoHopDongMau(banDau: [ban]);
        addTearDown(kho.dispose);
        expect(kho.kiemTraKyDemo(ban.id, vi), isNotNull);
        expect(() => kho.chuTroXacNhanKyDemo(ban.id), throwsStateError);
      }
      final kho = khoMau();
      addTearDown(kho.dispose);
      final f = kho.kyNguoiThueDemo(goc.id, vi);
      expect(kho.kiemTraKyDemo(goc.id, vi), isNotNull);
      await t.pump(const Duration(milliseconds: 650));
      await f;
      expect(
        kho
            .theoId(goc.id)!
            .lichSu
            .where((s) => s.loai == LoaiSuKienHopDong.ky)
            .length,
        1,
      );
    },
  );

  testWidgets(
    'Approve và Deposit riêng; chỉ khóa sau biên nhận, trừ số dư đúng một lần',
    (t) async {
      final kho = khoMau(daKy: true);
      final vi = TrangThaiViMau();
      addTearDown(kho.dispose);
      addTearDown(vi.dispose);
      await ketNoi(t, vi);
      final khac = kho.theoId(DuLieuGia.hopDong.id);
      kho.batDauDatCocDemo(goc.id, vi);
      expect(kho.daKhoaCocDemo(goc.id), isFalse);
      expect(vi.soDuToken, 5000000);
      expect(kho.theoId(goc.id)!.coc!.giaoDich!.maApprove, isNull);
      expect(() => kho.batDauDatCocDemo(goc.id, vi), throwsStateError);
      await t.pump(const Duration(milliseconds: 500));
      expect(kho.theoId(goc.id)!.coc!.giaoDich!.buoc, BuocDatCocDemo.daApprove);
      expect(vi.allowance, 3800000);
      expect(vi.soDuToken, 5000000);
      await t.pump(const Duration(milliseconds: 500));
      expect(
        kho.theoId(goc.id)!.coc!.giaoDich!.buoc,
        BuocDatCocDemo.dangGuiCoc,
      );
      await t.pump(const Duration(milliseconds: 500));
      expect(
        kho.theoId(goc.id)!.coc!.giaoDich!.buoc,
        BuocDatCocDemo.choXacNhan,
      );
      expect(kho.theoId(goc.id)!.coc!.giaoDich!.transactionHash, isNotNull);
      expect(kho.daKhoaCocDemo(goc.id), isFalse);
      expect(vi.soDuToken, 5000000);
      await t.pump(const Duration(milliseconds: 650));
      expect(kho.daKhoaCocDemo(goc.id), isTrue);
      expect(vi.soDuToken, 1200000);
      expect(vi.allowance, 0);
      expect(kho.theoId(goc.id)!.trangThai, TrangThaiHopDong.dangHieuLuc);
      expect(kho.tongCocDangKhoa, 7600000);
      expect(kho.doanhThuCocVnd, 0);
      expect(kho.theoId(DuLieuGia.hopDong.id), same(khac));
      expect(() => kho.batDauDatCocDemo(goc.id, vi), throwsStateError);
      expect(vi.soDuToken, 1200000);
    },
  );

  for (final loi in LoiDatCocDemo.values) {
    testWidgets('Lỗi ${loi.name} giữ số dư, không khóa cọc; có thể thử lại', (
      t,
    ) async {
      final kho = khoMau(daKy: true);
      final vi = TrangThaiViMau();
      addTearDown(kho.dispose);
      addTearDown(vi.dispose);
      await ketNoi(t, vi);
      kho.batDauDatCocDemo(goc.id, vi, gayLoi: loi);
      await xuLy(t);
      final c = kho.theoId(goc.id)!.coc!;
      expect(c.trangThai, TrangThaiTienCoc.thatBai);
      expect(c.giaoDich!.buocThatBai, loi);
      expect(kho.daKhoaCocDemo(goc.id), isFalse);
      expect(vi.soDuToken, 5000000);
      expect(kho.theoId(goc.id)!.ghiNhanCocLuc, isNull);
      expect(kho.theoId(goc.id)!.trangThai, TrangThaiHopDong.choCoc);
      kho.batDauDatCocDemo(goc.id, vi);
      await xuLy(t);
      expect(kho.daKhoaCocDemo(goc.id), isTrue);
      expect(vi.soDuToken, 1200000);
    });
  }

  testWidgets(
    'Thiếu số dư, ngắt ví khi gửi và số dư dùng chung giữa hai hợp đồng',
    (t) async {
      final it = TrangThaiViMau(soDuToken: 100);
      final vi = TrangThaiViMau();
      final kho = khoMau(daKy: true);
      addTearDown(it.dispose);
      addTearDown(vi.dispose);
      addTearDown(kho.dispose);
      await ketNoi(t, it);
      await ketNoi(t, vi);
      expect(kho.kiemTraDatCocDemo(goc.id, it), contains('Không đủ'));
      expect(() => kho.batDauDatCocDemo(goc.id, it), throwsStateError);
      kho.batDauDatCocDemo(goc.id, vi);
      await t.pump(const Duration(milliseconds: 500));
      vi.ngatKetNoi();
      await xuLy(t);
      expect(kho.theoId(goc.id)!.coc!.trangThai, TrangThaiTienCoc.thatBai);
      expect(vi.soDuToken, 5000000);
      final hai = banChuan(nguoiKy: true, chuKy: true).copyWith(id: 'hd-hai');
      final khoHai = KhoHopDongMau(banDau: [hai]);
      addTearDown(khoHai.dispose);
      await ketNoi(t, vi);
      kho.batDauDatCocDemo(goc.id, vi);
      expect(() => khoHai.batDauDatCocDemo(hai.id, vi), throwsStateError);
      await xuLy(t);
      expect(khoHai.kiemTraDatCocDemo(hai.id, vi), contains('Không đủ'));
    },
  );

  testWidgets('Hủy kho trong khi đang mô phỏng không cập nhật sau dispose', (
    t,
  ) async {
    final kho = khoMau(daKy: true);
    final vi = TrangThaiViMau();
    addTearDown(vi.dispose);
    await ketNoi(t, vi);
    kho.batDauDatCocDemo(goc.id, vi);
    kho.dispose();
    await xuLy(t);
    expect(vi.dangDatCoc, isFalse);
    expect(vi.soDuToken, 5000000);
    expect(t.takeException(), isNull);
  });

  test('Enum đã khóa hoặc chỉ có hash không đủ để báo thành công', () {
    final fake = GiaoDichBlockchain(
      hopDongId: goc.id,
      diaChiVi: TrangThaiViMau.diaChiMau,
      soToken: 3800000,
      chainId: 31337,
      buoc: BuocDatCocDemo.daKhoa,
      transactionHash: ThaoTacHopDongDemo.maDatCocMau,
    );
    expect(fake.daKhoa, isFalse);
    final h = banChuan(nguoiKy: true, chuKy: true).copyWith(
      trangThai: TrangThaiHopDong.dangHieuLuc,
      coc: TienCoc(
        id: 'coc-fake',
        hopDongId: goc.id,
        soToken: 3800000,
        loaiToken: 'MockVNDC',
        trangThai: TrangThaiTienCoc.dangKhoa,
        giaoDich: fake,
      ),
    );
    final kho = KhoHopDongMau(banDau: [h]);
    addTearDown(kho.dispose);
    expect(kho.daKhoaCocDemo(h.id), isFalse);
  });

  testWidgets(
    'T13 copy PDF hash/địa chỉ đúng giá trị đầy đủ; chưa có ví chủ trọ',
    (t) async {
      final kho = khoMau();
      final vi = TrangThaiViMau();
      addTearDown(kho.dispose);
      addTearDown(vi.dispose);
      await ketNoi(t, vi);
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await t.pumpWidget(khung(KyHopDong(hopDongId: goc.id, kho: kho, vi: vi)));
      expect(find.text('Chưa có thông tin'), findsOneWidget);
      await t.tap(find.byTooltip('Sao chép Hash hợp đồng'));
      await t.pumpAndSettle();
      expect(copied, pdf.sha256);
      await t.ensureVisible(find.byTooltip('Sao chép Ví của bạn'));
      await t.tap(find.byTooltip('Sao chép Ví của bạn'));
      await t.pumpAndSettle();
      expect(copied, TrangThaiViMau.diaChiMau);
      expect(find.byTooltip('Sao chép Ví chủ trọ'), findsNothing);
    },
  );

  testWidgets('T14 số dư thấp bị chặn, hủy dialog không tạo giao dịch', (
    t,
  ) async {
    final kho = khoMau(daKy: true);
    final vi = TrangThaiViMau(soDuToken: 100);
    final du = TrangThaiViMau();
    addTearDown(kho.dispose);
    addTearDown(vi.dispose);
    addTearDown(du.dispose);
    await ketNoi(t, vi);
    await ketNoi(t, du);
    await t.pumpWidget(khung(DatCoc(hopDongId: goc.id, kho: kho, vi: vi)));
    expect(find.text('Không đủ số dư'), findsOneWidget);
    expect(
      t
          .widget<NutBam>(find.widgetWithText(NutBam, 'Approve & Deposit'))
          .voHieuHoa,
      isTrue,
    );
    await t.pumpWidget(khung(DatCoc(hopDongId: goc.id, kho: kho, vi: du)));
    await nhan(t, 'Approve & Deposit');
    await nhan(t, 'Hủy');
    expect(kho.theoId(goc.id)!.coc, isNull);
  });

  testWidgets(
    'Escrow được cung cấp theo hợp đồng được giữ trong biên nhận demo',
    (t) async {
      const escrow = '0x0000000000000000000000000000000000000015';
      final kho = KhoHopDongMau(
        banDau: [
          banChuan(nguoiKy: true, chuKy: true).copyWith(diaChiEscrow: escrow),
        ],
      );
      final vi = TrangThaiViMau();
      addTearDown(kho.dispose);
      addTearDown(vi.dispose);
      await ketNoi(t, vi);
      await t.pumpWidget(khung(DatCoc(hopDongId: goc.id, kho: kho, vi: vi)));
      expect(find.byTooltip('Sao chép Escrow smart contract'), findsOneWidget);
      expect(find.text('Chưa cấu hình contract'), findsNothing);
      kho.batDauDatCocDemo(goc.id, vi);
      expect(kho.theoId(goc.id)!.coc!.giaoDich!.diaChiEscrow, escrow);
      await xuLy(t);
      expect(kho.daKhoaCocDemo(goc.id), isTrue);
    },
  );

  testWidgets('Luồng T11 → T12 → T13 → T14 → T15 giữ nguyên ID, ví và kho', (
    t,
  ) async {
    TrangThaiViMau.dungChung.ngatKetNoi();
    final kho = khoMau();
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(XemHopDongNguoiThue(hopDongId: goc.id, kho: kho)));
    await t.ensureVisible(find.byType(CheckboxListTile));
    await t.tap(find.byType(CheckboxListTile));
    await t.pump();
    await nhan(t, 'Xác nhận hợp đồng');
    await nhan(t, 'Xác nhận');
    await nhan(t, 'Kết nối ví');
    await nhan(t, 'Mô phỏng kết nối thành công');
    await nhan(t, 'Tiếp tục ký hợp đồng');
    expect(t.widget<KyHopDong>(find.byType(KyHopDong)).hopDongId, goc.id);
    await nhan(t, 'Mở ví để ký');
    await nhan(t, 'Xác nhận');
    expect(kho.theoId(goc.id)!.chuTroKyLuc, isNull);
    await nhan(t, 'Mô phỏng chủ trọ xác nhận');
    await nhan(t, 'Xác nhận');
    await nhan(t, 'Tiếp tục đặt cọc');
    expect(t.widget<DatCoc>(find.byType(DatCoc)).kho, same(kho));
    await nhan(t, 'Approve & Deposit');
    await nhan(t, 'Xác nhận');
    expect(find.byType(TrangThaiDatCoc), findsOneWidget);
    await xuLy(t);
    expect(kho.daKhoaCocDemo(goc.id), isTrue);
    expect(find.text('Đã khóa cọc thành công').first, findsOneWidget);
    await nhan(t, 'Về trang phòng của tôi');
    expect(
      find.textContaining('Trang Phòng của tôi chưa được triển khai.'),
      findsOneWidget,
    );
    await nhan(t, 'Đóng');
    TrangThaiViMau.dungChung.ngatKetNoi();
  });

  testWidgets(
    'T15 chờ/thất bại/hoàn tất, copy hash, không tạo Explorer; L12/L13 đồng bộ',
    (t) async {
      final kho = khoMau(daKy: true);
      final vi = TrangThaiViMau();
      addTearDown(kho.dispose);
      addTearDown(vi.dispose);
      await ketNoi(t, vi);
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await t.pumpWidget(
        khung(TrangThaiDatCoc(hopDongId: goc.id, kho: kho, vi: vi)),
      );
      expect(find.text('Chưa có giao dịch'), findsOneWidget);
      expect(find.byTooltip('Sao chép Transaction hash'), findsNothing);
      kho.batDauDatCocDemo(goc.id, vi, gayLoi: LoiDatCocDemo.xacNhan);
      await xuLy(t);
      expect(find.text('Đặt cọc chưa thành công'), findsOneWidget);
      expect(
        find.widgetWithText(NutBam, 'Về trang phòng của tôi'),
        findsNothing,
      );
      kho.batDauDatCocDemo(goc.id, vi);
      await xuLy(t);
      expect(
        find.widgetWithText(NutBam, 'Về trang phòng của tôi'),
        findsOneWidget,
      );
      await t.ensureVisible(find.byTooltip('Sao chép Transaction hash'));
      await t.tap(find.byTooltip('Sao chép Transaction hash'));
      await t.pumpAndSettle();
      expect(copied, ThaoTacHopDongDemo.maDatCocMau);
      expect(find.byIcon(Icons.open_in_new), findsNothing);
      await t.pumpWidget(khung(ChiTietHopDong(hopDongId: goc.id, kho: kho)));
      expect(find.text('Đã khóa cọc (dữ liệu demo)'), findsOneWidget);
      await t.pumpWidget(khung(QuanLyTienCoc(kho: kho)));
      expect(find.text('7.600.000 MockVNDC'), findsWidgets);
    },
  );

  testWidgets('Route chặn tham số sai và cả ba trang xử lý ID không tồn tại', (
    t,
  ) async {
    final kho = khoMau();
    addTearDown(kho.dispose);
    for (final route in [
      DieuHuong.kyHopDong,
      DieuHuong.datCoc,
      DieuHuong.trangThaiDatCoc,
    ]) {
      expect(
        DieuHuong.taoRoute(RouteSettings(name: route, arguments: 2)),
        isNull,
      );
      expect(
        DieuHuong.taoRoute(
          RouteSettings(
            name: route,
            arguments: const ThamSoHopDong(hopDongId: ''),
          ),
        ),
        isNull,
      );
    }
    for (final w in [
      KyHopDong(hopDongId: 'sai', kho: kho),
      DatCoc(hopDongId: 'sai', kho: kho),
      TrangThaiDatCoc(hopDongId: 'sai', kho: kho),
    ]) {
      await t.pumpWidget(khung(w));
      expect(find.text('Không tìm thấy hợp đồng'), findsOneWidget);
      expect(t.takeException(), isNull);
    }
  });

  for (final size in [
    const Size(360, 740),
    const Size(390, 844),
    const Size(430, 932),
  ]) {
    for (final chu in [1.0, 2.0]) {
      for (final trang in [13, 14, 15]) {
        testWidgets(
          'T$trang ${size.width}×${size.height} chữ $chu không overflow',
          (t) async {
            t.view.physicalSize = size;
            t.view.devicePixelRatio = 1;
            addTearDown(t.view.resetPhysicalSize);
            addTearDown(t.view.resetDevicePixelRatio);
            final vi = TrangThaiViMau();
            final kho = khoMau(daKy: trang != 13);
            addTearDown(vi.dispose);
            addTearDown(kho.dispose);
            await ketNoi(t, vi);
            if (trang == 15) {
              kho.batDauDatCocDemo(goc.id, vi);
              await xuLy(t);
            }
            final Widget w = switch (trang) {
              13 => KyHopDong(hopDongId: goc.id, kho: kho, vi: vi),
              14 => DatCoc(hopDongId: goc.id, kho: kho, vi: vi),
              _ => TrangThaiDatCoc(hopDongId: goc.id, kho: kho, vi: vi),
            };
            await t.pumpWidget(khung(w, chu: chu));
            await t.pumpAndSettle();
            if (size.width == 390 && chu == 1) {
              await anh(t, 't$trang');
            }
            final nut = find.widgetWithText(
              NutBam,
              trang == 13
                  ? 'Mở ví để ký'
                  : trang == 14
                  ? 'Approve & Deposit'
                  : 'Về trang phòng của tôi',
            );
            await t.ensureVisible(nut);
            await t.pumpAndSettle();
            expect(t.takeException(), isNull);
            expect(find.byType(Scaffold), findsOneWidget);
            expect(find.byType(ThanhDieuHuongVaiTro), findsNothing);
          },
        );
      }
    }
  }
}
