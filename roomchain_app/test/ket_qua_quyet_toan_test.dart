import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/chi_tiet_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tien_coc/ket_qua_quyet_toan.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tien_coc/quan_ly_tien_coc.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tien_coc/tao_quyet_toan.dart';
import 'package:roomchain_app/dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import 'package:roomchain_app/dung_chung/mo_hinh/quyet_toan_tien_coc.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/ung_dung/dieu_huong.dart';

const txMau =
    '0x0000000000000000000000000000000000000000000000000000000000000001';
QuyetToanTienCoc ketQuaMau({
  bool chuTro = true,
  bool nguoiThue = false,
  TrangThaiGiaoDichQuyetToan giaoDich = TrangThaiGiaoDichQuyetToan.chuaGui,
  TrangThaiQuyetToan trangThai = TrangThaiQuyetToan.choNguoiThueXacNhan,
  String? tx,
  DateTime? xuLy,
  DateTime? xong,
  int? hoan,
  int? nhan,
  int coc = 6500000,
  int tru = 500000,
}) => QuyetToanTienCoc(
  id: 'qt-l15',
  maQuyetToan: 'QT2025-0001',
  hopDongId: 'hd-l15',
  ngayTao: DateTime(2025, 2, 28, 14, 20),
  tienCocBanDau: coc,
  cacKhoan: [
    KhoanKhauTru(
      id: 'k',
      soTien: tru,
      lyDo: 'Theo bản quyết toán đã thống nhất',
    ),
  ],
  bangChung: [],
  chuTroXacNhanLuc: chuTro ? DateTime(2025, 2, 28, 15, 5) : null,
  nguoiThueXacNhanLuc: nguoiThue ? DateTime(2025, 2, 28, 15, 10) : null,
  trangThai: trangThai,
  trangThaiGiaoDich: giaoDich,
  txHash: tx,
  thoiGianGiaoDich: xuLy,
  hoanTatLuc: xong,
  soTienHoanNguoiThue: hoan,
  soTienChuTroNhan: nhan,
);
QuyetToanTienCoc hoanTat() => ketQuaMau(
  nguoiThue: true,
  giaoDich: TrangThaiGiaoDichQuyetToan.thanhCong,
  trangThai: TrangThaiQuyetToan.daGiaiNgan,
  tx: txMau,
  xuLy: DateTime(2025, 2, 28, 15, 12),
  xong: DateTime(2025, 2, 28, 15, 12),
);
HopDong hopDongMau(QuyetToanTienCoc q) => DuLieuGia.hopDong.copyWith(
  id: q.hopDongId,
  maHopDong: 'HD-L15',
  tienCoc: q.tienCocBanDau,
  quyetToan: q,
  coc: DuLieuGia.tienCoc.copyWith(
    hopDongId: q.hopDongId,
    soToken: q.tienCocBanDau,
    trangThai: q.daHoanTat
        ? TrangThaiTienCoc.daQuyetToan
        : TrangThaiTienCoc.choNguoiThueXacNhan,
  ),
);

void main() {
  const thuMucAnh = String.fromEnvironment('THU_MUC_ANH');
  const tepPhongChu = String.fromEnvironment('TEP_PHONG_CHU');
  setUpAll(() async {
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
  KhoHopDongMau khoMau(QuyetToanTienCoc q) =>
      KhoHopDongMau(banDau: [hopDongMau(q)]);
  Future<void> nhan(WidgetTester t, String chu) async {
    final f = find.text(chu).last;
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> anh(WidgetTester t, String ten) async {
    if (thuMucAnh.isEmpty) return;
    final b = t.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('anh')),
    );
    await t.runAsync(() async {
      final img = await b.toImage();
      final d = await img.toByteData(format: ui.ImageByteFormat.png);
      await Directory(thuMucAnh).create(recursive: true);
      await File('$thuMucAnh/$ten.png').writeAsBytes(d!.buffer.asUint8List());
      img.dispose();
    });
  }

  test('Phân chia VND đúng số nguyên, giữ kết quả cung cấp và không suy diễn mất cọc', () {
    final q = ketQuaMau();
    expect(q.tongKhauTru, 500000);
    expect(q.nguoiThueNhanThamChieu, 6000000);
    expect(q.chuTroNhanThamChieu, 500000);
    expect(q.phanChiaHopLe, isTrue);
    expect(q.nguoiThueNhanThamChieu + q.chuTroNhanThamChieu, q.tienCocBanDau);
    final rieng = ketQuaMau(hoan: 5000000, nhan: 1500000);
    expect(rieng.nguoiThueNhanThamChieu, 5000000);
    expect(rieng.chuTroNhanThamChieu, 1500000);
    expect(rieng.phanChiaHopLe, isTrue);
    for (final sai in [
      ketQuaMau(hoan: -1),
      ketQuaMau(hoan: 6000000, nhan: 1000000),
      ketQuaMau(tru: 7000000),
      ketQuaMau(tru: -1),
    ]) {
      expect(sai.phanChiaHopLe, isFalse);
    }
  });
  test('Hoàn tất cần hai xác nhận, đúng enum giải ngân, hash và thời điểm giao dịch', () {
    expect(ketQuaMau().daHoanTat, isFalse);
    expect(
      ketQuaMau(
        nguoiThue: true,
        trangThai: TrangThaiQuyetToan.daGiaiNgan,
      ).daHoanTat,
      isFalse,
    );
    expect(
      ketQuaMau(
        nguoiThue: true,
        giaoDich: TrangThaiGiaoDichQuyetToan.thanhCong,
        trangThai: TrangThaiQuyetToan.daGiaiNgan,
        tx: txMau,
      ).daHoanTat,
      isFalse,
    );
    expect(
      ketQuaMau(
        nguoiThue: true,
        chuTro: false,
        giaoDich: TrangThaiGiaoDichQuyetToan.thanhCong,
        trangThai: TrangThaiQuyetToan.daGiaiNgan,
        tx: txMau,
        xuLy: DateTime(2025),
        xong: DateTime(2025),
      ).daHoanTat,
      isFalse,
    );
    expect(hoanTat().daHoanTat, isTrue);
    expect(
      hoanTat()
          .copyWith(trangThaiGiaoDich: TrangThaiGiaoDichQuyetToan.thatBai)
          .daHoanTat,
      isFalse,
    );
    expect(hoanTat().copyWith(txHash: '0x123').txHashHopLe, isNull);
    expect(hoanTat().copyWith(txHash: 'hash-pdf').daHoanTat, isFalse);
  });
  test('Kho cập nhật cùng bản ghi; chỉ biên nhận thành công mới mở khóa số liệu escrow', () {
    final q = ketQuaMau();
    final kho = khoMau(q);
    addTearDown(kho.dispose);
    expect(kho.tongCocDangKhoa, 6500000);
    expect(kho.doanhThuCocVnd, 0);
    final du = q.copyWith(
      nguoiThueXacNhanLuc: DateTime(2025, 2, 28, 15, 10),
      trangThai: TrangThaiQuyetToan.daXacNhan,
    );
    kho.capNhatQuyetToanMau(du);
    expect(kho.tongCocDangKhoa, 6500000);
    expect(kho.doanhThuCocVnd, 0);
    final xong = du.copyWith(
      trangThai: TrangThaiQuyetToan.daGiaiNgan,
      trangThaiGiaoDich: TrangThaiGiaoDichQuyetToan.thanhCong,
      txHash: txMau,
      thoiGianGiaoDich: DateTime(2025, 2, 28, 15, 12),
      hoanTatLuc: DateTime(2025, 2, 28, 15, 12),
    );
    kho.capNhatQuyetToanMau(xong);
    expect(kho.hopDongTheoQuyetToan(q.id)!.quyetToan, same(xong));
    expect(kho.tongCocDangKhoa, 0);
    expect(kho.doanhThuCocVnd, 0);
    expect(
      kho.theoId(q.hopDongId)!.coc!.trangThai,
      TrangThaiTienCoc.daQuyetToan,
    );
    expect(() => kho.capNhatQuyetToanMau(du), throwsStateError);
    expect(
      () => kho.capNhatQuyetToanMau(
        xong.copyWith(
          txHash: '0x0000000000000000000000000000000000000000000000000000000000000002',
        ),
      ),
      throwsStateError,
    );
  });
  test('Kho từ chối dữ liệu thành công thiếu biên nhận, tiền sai hoặc bản ghi không tồn tại', () {
    final q = ketQuaMau();
    final kho = khoMau(q);
    addTearDown(kho.dispose);
    expect(
      () => kho.capNhatQuyetToanMau(
        q.copyWith(trangThaiGiaoDich: TrangThaiGiaoDichQuyetToan.thanhCong),
      ),
      throwsStateError,
    );
    expect(
      () => kho.capNhatQuyetToanMau(ketQuaMau(hoan: 1, nhan: 1)),
      throwsStateError,
    );
    final rong = KhoHopDongMau(banDau: []);
    addTearDown(rong.dispose);
    expect(() => rong.capNhatQuyetToanMau(q), throwsStateError);
    expect(kho.hopDongTheoQuyetToan(q.id)!.quyetToan, same(q));
  });
  test(
    'Bộ dữ liệu hoàn tất demo tách biệt với kho tạo quyết toán thông thường',
    () {
      final kho = KhoHopDongMau.demoKetQuaHoanTat();
      final goc = KhoHopDongMau();
      addTearDown(kho.dispose);
      addTearDown(goc.dispose);
      expect(
        kho.hopDongTheoQuyetToan('QT-demo-hoan-tat')!.quyetToan!.daHoanTat,
        isTrue,
      );
      expect(kho.tongCocDangKhoa, 3800000);
      expect(kho.doanhThuCocVnd, 0);
      expect(goc.hopDongTheoQuyetToan('QT-demo-hoan-tat'), isNull);
      expect(goc.tongCocDangKhoa, 6300000);
    },
  );

  for (final size in const [Size(360, 740), Size(390, 844), Size(430, 932)]) {
    for (final chu in [1.0, 2.0]) {
      testWidgets('L15 ${size.width}x${size.height}, chữ $chu', (t) async {
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1;
        t.view.padding = const FakeViewPadding(top: 24, bottom: 24);
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        addTearDown(t.view.resetPadding);
        final kho = KhoHopDongMau.demoKetQuaHoanTat();
        addTearDown(kho.dispose);
        await t.pumpWidget(
          khung(
            RepaintBoundary(
              key: const ValueKey('anh'),
              child: KetQuaQuyetToan(quyetToanId: 'QT-demo-hoan-tat', kho: kho),
            ),
            chu: chu,
          ),
        );
        await t.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(ThanhDieuHuongVaiTro), findsNothing);
        expect(t.takeException(), isNull);
        if (size.width == 390 && chu == 1) {
          await anh(t, 'l15_ket_qua_quyet_toan');
        }
        await t.ensureVisible(find.byTooltip('Sao chép Tx Hash'));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      });
    }
  }
  final trangThai = [
    (ketQuaMau(), 'Chờ người thuê xác nhận'),
    (ketQuaMau(chuTro: false, nguoiThue: true), 'Chờ chủ trọ xác nhận'),
    (
      ketQuaMau(nguoiThue: true, trangThai: TrangThaiQuyetToan.daXacNhan),
      'Đã đủ xác nhận',
    ),
    (
      ketQuaMau(
        nguoiThue: true,
        trangThai: TrangThaiQuyetToan.daXacNhan,
        giaoDich: TrangThaiGiaoDichQuyetToan.dangXuLy,
        tx: txMau,
      ),
      'Đang thực hiện giao dịch',
    ),
    (hoanTat(), 'Hoàn tất'),
    (
      hoanTat().copyWith(trangThaiGiaoDich: TrangThaiGiaoDichQuyetToan.thatBai),
      'Thất bại',
    ),
  ];
  for (final muc in trangThai) {
    testWidgets('L15 trạng thái ${muc.$2}', (t) async {
      final kho = khoMau(muc.$1);
      addTearDown(kho.dispose);
      await t.pumpWidget(
        khung(KetQuaQuyetToan(quyetToanId: muc.$1.id, kho: kho)),
      );
      await t.pumpAndSettle();
      expect(
        find.text(muc.$2),
        muc.$2 == 'Thất bại' ? findsNWidgets(2) : findsOneWidget,
      );
      if (muc.$2 != 'Hoàn tất') expect(find.text('Hoàn tất'), findsNothing);
      final noiDung = find.text(
        'Phân chia dự kiến theo bản quyết toán, chưa ghi nhận đã nhận tiền.',
      );
      await t.ensureVisible(find.text('Kết quả quyết toán').last);
      await t.pump();
      expect(noiDung, muc.$1.daHoanTat ? findsNothing : findsOneWidget);
      expect(kho.hopDongTheoQuyetToan(muc.$1.id)!.quyetToan, same(muc.$1));
    });
  }
  testWidgets(
    'Hai xác nhận không tạo Tx, không tự đặt thời gian hoặc báo hoàn tất',
    (t) async {
      final q = ketQuaMau(
        nguoiThue: true,
        trangThai: TrangThaiQuyetToan.daGiaiNgan,
      );
      final kho = khoMau(q);
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(KetQuaQuyetToan(quyetToanId: q.id, kho: kho)));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Chưa phát sinh giao dịch'));
      expect(find.text('Hoàn tất'), findsNothing);
      expect(find.byTooltip('Sao chép Tx Hash'), findsNothing);
      expect(find.text('Hoàn tất lúc'), findsNothing);
      expect(find.text('Thời gian xử lý'), findsNothing);
      expect(q.txHash, isNull);
      expect(q.hoanTatLuc, isNull);
    },
  );
  testWidgets(
    'Tx hash hỏng và thành công thiếu dữ liệu không hiển thị thành công',
    (t) async {
      final q = hoanTat().copyWith(txHash: 'hash-pdf');
      final kho = khoMau(q);
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(KetQuaQuyetToan(quyetToanId: q.id, kho: kho)));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('Tx Hash không hợp lệ'));
      expect(find.byTooltip('Sao chép Tx Hash'), findsNothing);
      expect(find.text('Thành công'), findsNothing);
      expect(find.text('Hoàn tất'), findsNothing);
    },
  );
  testWidgets('Copy đầy đủ hash và điều hướng về hợp đồng/tiền cọc', (t) async {
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
    final kho = khoMau(hoanTat());
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(KetQuaQuyetToan(quyetToanId: 'qt-l15', kho: kho)));
    await t.pumpAndSettle();
    final nut = find.byTooltip('Sao chép Tx Hash');
    await t.ensureVisible(nut);
    await t.tap(nut);
    await t.pumpAndSettle();
    expect(copy, txMau);
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
    await nhan(t, 'Xem hợp đồng');
    expect(
      t.widget<ChiTietHopDong>(find.byType(ChiTietHopDong)).hopDongId,
      'hd-l15',
    );
    await t.tap(find.byTooltip('Quay lại'));
    await t.pumpAndSettle();
    await nhan(t, 'Quản lý tiền cọc');
    expect(find.byType(QuanLyTienCoc), findsOneWidget);
  });
  testWidgets(
    'Cập nhật kho chung làm L15 hiển thị trạng thái mới, không đổi bản phân chia',
    (t) async {
      final q = ketQuaMau();
      final kho = khoMau(q);
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(KetQuaQuyetToan(quyetToanId: q.id, kho: kho)));
      await t.pumpAndSettle();
      expect(find.text('Chờ người thuê xác nhận'), findsOneWidget);
      kho.capNhatQuyetToanMau(
        q.copyWith(
          nguoiThueXacNhanLuc: DateTime(2025, 2, 28, 15, 10),
          trangThai: TrangThaiQuyetToan.daXacNhan,
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Đã đủ xác nhận'), findsOneWidget);
      expect(find.text('Hoàn tất'), findsNothing);
      expect(kho.tongCocDangKhoa, 6500000);
      kho.capNhatQuyetToanMau(hoanTat());
      await t.pumpAndSettle();
      expect(find.text('Hoàn tất'), findsOneWidget);
      expect(kho.tongCocDangKhoa, 0);
    },
  );
  testWidgets(
    'ID không tồn tại và phân chia không hợp lệ hiện trạng thái lỗi',
    (t) async {
      final kho = KhoHopDongMau(banDau: []);
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(KetQuaQuyetToan(quyetToanId: 'sai', kho: kho)));
      expect(find.text('Không tìm thấy quyết toán'), findsOneWidget);
      final sai = khoMau(ketQuaMau(hoan: -1));
      addTearDown(sai.dispose);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(
        khung(KetQuaQuyetToan(quyetToanId: 'qt-l15', kho: sai)),
      );
      expect(find.text('Dữ liệu quyết toán chưa hợp lệ'), findsOneWidget);
      expect(
        DieuHuong.taoRoute(
          const RouteSettings(name: DieuHuong.ketQuaQuyetToan),
        ),
        isNull,
      );
    },
  );
  testWidgets('L14 gửi mới mở L15 đúng ID và vẫn chờ người thuê xác nhận', (
    t,
  ) async {
    final kho = KhoHopDongMau();
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(TaoQuyetToan(hopDongId: 'HD2024-0771', kho: kho)));
    await t.pumpAndSettle();
    final cb = find.byKey(const ValueKey('xacNhanQuyetToan'));
    await t.ensureVisible(cb);
    await t.tap(cb);
    await t.pump();
    await nhan(t, 'Gửi người thuê xác nhận');
    await nhan(t, 'Xác nhận');
    await nhan(t, 'Xem kết quả quyết toán');
    final q = kho.theoId('HD2024-0771')!.quyetToan!;
    expect(
      t.widget<KetQuaQuyetToan>(find.byType(KetQuaQuyetToan)).quyetToanId,
      q.id,
    );
    expect(find.text('Chờ người thuê xác nhận'), findsOneWidget);
    expect(find.text('Hoàn tất'), findsNothing);
    expect(q.trangThaiGiaoDich, TrangThaiGiaoDichQuyetToan.chuaGui);
    expect(kho.tongCocDangKhoa, 6300000);
    expect(kho.doanhThuCocVnd, 0);
    await t.tap(find.byTooltip('Quay lại'));
    await t.pumpAndSettle();
    expect(find.byType(TaoQuyetToan), findsOneWidget);
  });
}
