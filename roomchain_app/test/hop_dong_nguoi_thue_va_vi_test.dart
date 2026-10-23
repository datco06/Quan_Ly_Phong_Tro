import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/tai_lieu_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/xem_hop_dong_nguoi_thue.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/vi_blockchain/ket_noi_vi.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/vi_blockchain/trang_thai_vi_mau.dart';
import 'package:roomchain_app/dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/ung_dung/dieu_huong.dart';

final banGoc = HopDong(
  id: 'hd-t11',
  maHopDong: 'HD-T11-001',
  phongId: 'P201',
  nguoiThueId: DuLieuGia.nguoiThue.id,
  ngayBatDau: DateTime(2027, 1, 1),
  ngayKetThuc: DateTime(2027, 12, 31),
  giaThue: 3500000,
  tienCoc: 7000000,
  trangThai: TrangThaiHopDong.choKy,
  cauHinh: const CauHinhHopDong(
    thanhToanTu: 2,
    thanhToanDen: 7,
    ketThucSom: 'Báo trước 45 ngày. Khấu trừ cọc theo thỏa thuận đã ký.',
    noiQuy: 'Giữ yên lặng sau 22 giờ. Không tự thay đổi thiết bị trong phòng.',
  ),
);

class DichVuTaiThu extends TaiLieuHopDongDemo {
  TaiLieuHopDong? daTai;
  bool ketQua = true;
  bool gayLoi = false;
  @override
  Future<bool> tai(TaiLieuHopDong taiLieu) async {
    if (gayLoi) throw StateError('Lỗi tải');
    daTai = taiLieu;
    return ketQua;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TaiLieuHopDong pdf;
  setUpAll(() async {
    await (FontLoader(
      'Roboto',
    )..addFont(rootBundle.load('assets/phong_chu/Roboto-Regular.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final kho = KhoHopDongMau(banDau: [banGoc]);
    pdf = await const TaiLieuHopDongDemo().lay(kho, banGoc.id);
  });
  tearDown(() => TrangThaiViMau.dungChung.ngatKetNoi());

  KhoHopDongMau khoMau({HopDong? hopDong}) => KhoHopDongMau(
    banDau: [
      hopDong ??
          banGoc.copyWith(taiLieu: pdf, guiKyLuc: DateTime(2026, 10, 23)),
      DuLieuGia.hopDong,
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
    home: RepaintBoundary(key: const ValueKey('anh-t11-t12'), child: trang),
  );
  Future<void> nhan(WidgetTester t, String chu) async {
    final nut = find.widgetWithText(NutBam, chu);
    final f = nut.evaluate().isNotEmpty ? nut.last : find.text(chu).last;
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> chupAnh(WidgetTester t, String ten) async {
    const thuMuc = String.fromEnvironment('THU_MUC_ANH');
    if (thuMuc.isEmpty) return;
    final boundary = t.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('anh-t11-t12')),
    );
    await t.runAsync(() async {
      final img = await boundary.toImage();
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      await Directory(thuMuc).create(recursive: true);
      await File('$thuMuc/$ten.png').writeAsBytes(data!.buffer.asUint8List());
      img.dispose();
    });
  }

  test(
    'Đồng ý demo tách biệt chữ ký, giữ trạng thái thuê và các hợp đồng khác',
    () {
      final kho = khoMau();
      final cu = kho.theoId(banGoc.id)!;
      final khac = kho.theoId(DuLieuGia.hopDong.id);
      kho.nguoiThueDongY(cu.id, banDaDoc: cu);
      final moi = kho.theoId(cu.id)!;
      expect(moi.choKyVi, isTrue);
      expect(moi.trangThai, TrangThaiHopDong.choKy);
      expect(moi.nguoiThueKyLuc, isNull);
      expect(moi.coc, isNull);
      expect(moi.taiLieu, same(pdf));
      expect(moi.lichSu, cu.lichSu);
      expect(kho.theoId(DuLieuGia.hopDong.id), same(khac));
      expect(() => kho.nguoiThueDongY(cu.id, banDaDoc: cu), throwsStateError);
      kho.nguoiThueDongY(moi.id, banDaDoc: moi);
      expect(kho.theoId(moi.id), same(moi));
    },
  );

  test(
    'Chặn hợp đồng thiếu, chưa gửi, PDF hỏng và điều khoản không hợp lệ',
    () {
      final cacBan = [
        banGoc,
        banGoc.copyWith(guiKyLuc: DateTime(2026), taiLieu: pdf, giaThue: -1),
        banGoc.copyWith(
          guiKyLuc: DateTime(2026),
          taiLieu: pdf,
          trangThai: TrangThaiHopDong.dangHieuLuc,
        ),
        banGoc.copyWith(
          guiKyLuc: DateTime(2026),
          taiLieu: pdf,
          cauHinh: const CauHinhHopDong(thanhToanTu: 9, thanhToanDen: 2),
        ),
        banGoc.copyWith(
          guiKyLuc: DateTime(2026),
          taiLieu: TaiLieuHopDong(
            noiDung: pdf.noiDung,
            tenTep: pdf.tenTep,
            sha256: 'sai',
            ngayTao: DateTime(2026),
          ),
        ),
      ];
      for (final h in cacBan) {
        final kho = khoMau(hopDong: h);
        expect(kho.kiemTraNguoiThueDongY(h.id), isNotNull);
        expect(() => kho.nguoiThueDongY(h.id, banDaDoc: h), throwsStateError);
      }
      expect(khoMau().kiemTraNguoiThueDongY('khong-co'), isNotNull);
    },
  );

  test('Router nhận cùng ID/kho và từ chối tham số không hợp lệ', () {
    for (final route in [DieuHuong.xemHopDongNguoiThue, DieuHuong.ketNoiVi]) {
      expect(
        DieuHuong.taoRoute(RouteSettings(name: route, arguments: 123)),
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
      expect(
        DieuHuong.taoRoute(
          RouteSettings(
            name: route,
            arguments: ThamSoHopDong(hopDongId: banGoc.id, kho: khoMau()),
          ),
        ),
        isNotNull,
      );
    }
  });

  testWidgets('Đúng các bên, phòng, số tiền và đầy đủ điều khoản hợp đồng', (
    t,
  ) async {
    await t.pumpWidget(
      khung(XemHopDongNguoiThue(hopDongId: banGoc.id, kho: khoMau())),
    );
    expect(find.text(DuLieuGia.chuTro.hoTen), findsOneWidget);
    expect(find.text(DuLieuGia.nguoiThue.hoTen), findsOneWidget);
    expect(find.text('P201 – An Nhiên Residence'), findsOneWidget);
    expect(find.text('3.500.000đ/tháng'), findsOneWidget);
    expect(find.text('7.000.000đ'), findsOneWidget);
    expect(find.textContaining('từ ngày 2 đến hết ngày 7'), findsOneWidget);
    expect(find.text(banGoc.cauHinh.ketThucSom), findsOneWidget);
    expect(find.text(banGoc.cauHinh.noiQuy), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ThanhDieuHuongVaiTro), findsNothing);
  });

  testWidgets(
    'Checkbox bật/tắt; hủy dialog không ghi nhận, xác nhận chuyển đúng T12',
    (t) async {
      final kho = khoMau();
      await t.pumpWidget(
        khung(XemHopDongNguoiThue(hopDongId: banGoc.id, kho: kho)),
      );
      final nut = find.widgetWithText(NutBam, 'Xác nhận hợp đồng');
      expect(t.widget<NutBam>(nut).voHieuHoa, isTrue);
      final checkbox = find.byType(CheckboxListTile);
      await t.ensureVisible(checkbox);
      await t.tap(checkbox);
      await t.pump();
      expect(t.widget<NutBam>(nut).voHieuHoa, isFalse);
      await t.tap(checkbox);
      await t.pump();
      expect(t.widget<NutBam>(nut).voHieuHoa, isTrue);
      await t.tap(checkbox);
      await t.pump();
      await nhan(t, 'Xác nhận hợp đồng');
      await nhan(t, 'Hủy');
      expect(kho.theoId(banGoc.id)!.nguoiThueDongYLuc, isNull);
      await nhan(t, 'Xác nhận hợp đồng');
      await nhan(t, 'Xác nhận');
      expect(find.byType(KetNoiVi), findsOneWidget);
      expect(t.widget<KetNoiVi>(find.byType(KetNoiVi)).hopDongId, banGoc.id);
      expect(t.widget<KetNoiVi>(find.byType(KetNoiVi)).kho, same(kho));
      expect(kho.theoId(banGoc.id)!.choKyVi, isTrue);
      expect(find.text('Chưa kết nối ví'), findsOneWidget);
      await t.tap(find.byTooltip('Quay lại'));
      await t.pumpAndSettle();
      expect(find.byType(XemHopDongNguoiThue), findsOneWidget);
      expect(kho.theoId(banGoc.id)!.trangThai, TrangThaiHopDong.choKy);
    },
  );

  testWidgets('Tải đúng byte PDF, xử lý tải lỗi và chưa có tài liệu', (
    t,
  ) async {
    final dichVu = DichVuTaiThu();
    await t.pumpWidget(
      khung(
        XemHopDongNguoiThue(
          hopDongId: banGoc.id,
          kho: khoMau(),
          dichVu: dichVu,
        ),
      ),
    );
    await nhan(t, 'Tải về');
    expect(dichVu.daTai, same(pdf));
    dichVu.gayLoi = true;
    await nhan(t, 'Tải về');
    expect(find.text('Không thể tải PDF. Vui lòng thử lại.'), findsOneWidget);
    await t.pumpWidget(
      khung(
        XemHopDongNguoiThue(
          hopDongId: banGoc.id,
          kho: khoMau(hopDong: banGoc),
          dichVu: dichVu,
        ),
      ),
    );
    await nhan(t, 'Tải về');
    expect(
      find.textContaining('Chưa có tài liệu PDF hợp lệ để tải.'),
      findsOneWidget,
    );
    expect(
      t
          .widget<NutBam>(find.widgetWithText(NutBam, 'Xác nhận hợp đồng'))
          .voHieuHoa,
      isTrue,
    );
  });

  testWidgets(
    'Sai ID hoặc phòng hiển thị trạng thái rỗng, không phát sinh lỗi',
    (t) async {
      await t.pumpWidget(
        khung(XemHopDongNguoiThue(hopDongId: 'sai', kho: khoMau())),
      );
      expect(find.text('Không tìm thấy hợp đồng'), findsOneWidget);
      await t.pumpWidget(khung(KetNoiVi(hopDongId: 'sai', kho: khoMau())));
      expect(find.text('Không tìm thấy hợp đồng'), findsOneWidget);
      await t.pumpWidget(
        khung(
          XemHopDongNguoiThue(
            hopDongId: banGoc.id,
            kho: khoMau(hopDong: banGoc.copyWith(phongId: 'sai')),
          ),
        ),
      );
      expect(find.text('Không tìm thấy hợp đồng'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'Ví chỉ mô phỏng sau lựa chọn; đủ trạng thái, copy đầy đủ và ngắt kết nối',
    (t) async {
      final vi = TrangThaiViMau();
      addTearDown(vi.dispose);
      String? daCopy;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              daCopy = (call.arguments as Map)['text'] as String;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final kho = khoMau();
      final cu = kho.theoId(banGoc.id);
      await t.pumpWidget(
        khung(KetNoiVi(hopDongId: banGoc.id, kho: kho, vi: vi)),
      );
      expect(find.text('Hardhat Local'), findsOneWidget);
      expect(find.text('MockVNDC'), findsOneWidget);
      await nhan(t, 'Kết nối ví');
      await nhan(t, 'Đóng');
      expect(vi.trangThai, TrangThaiKetNoiVi.chuaKetNoi);
      expect(vi.cheDoMoPhong, isFalse);
      await nhan(t, 'Kết nối ví');
      await t.tap(find.text('Mô phỏng kết nối thành công'));
      await t.pump(const Duration(milliseconds: 200));
      expect(vi.trangThai, TrangThaiKetNoiVi.dangKetNoi);
      await t.pumpAndSettle();
      expect(find.text('Đã kết nối ví (Demo)'), findsOneWidget);
      expect(find.text('Chế độ mô phỏng'), findsOneWidget);
      await t.ensureVisible(find.byTooltip('Sao chép địa chỉ demo'));
      await t.tap(find.byTooltip('Sao chép địa chỉ demo'));
      await t.pumpAndSettle();
      expect(daCopy, TrangThaiViMau.diaChiMau);
      await nhan(t, 'Ngắt kết nối demo');
      expect(vi.diaChi, isNull);
      for (final muc in [
        (KetQuaKetNoiMau.thatBai, 'Kết nối thất bại (Demo)'),
        (KetQuaKetNoiMau.saiMang, 'Sai mạng (Demo)'),
      ]) {
        final f = vi.ketNoi(muc.$1);
        await t.pump(const Duration(milliseconds: 700));
        await f;
        await t.pumpAndSettle();
        expect(find.text(muc.$2), findsOneWidget);
        expect(vi.diaChi, isNull);
      }
      expect(kho.theoId(banGoc.id), same(cu));
      expect(find.text('Tiếp tục đặt cọc'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets('Ngắt demo trong lúc kết nối không bị callback cũ ghi đè', (
    t,
  ) async {
    final vi = TrangThaiViMau();
    final f = vi.ketNoi(KetQuaKetNoiMau.thanhCong);
    vi.ngatKetNoi();
    await t.pump(const Duration(milliseconds: 700));
    await f;
    expect(vi.trangThai, TrangThaiKetNoiVi.chuaKetNoi);
    expect(vi.diaChi, isNull);
    final dangCho = vi.ketNoi(KetQuaKetNoiMau.thanhCong);
    vi.dispose();
    await t.pump(const Duration(milliseconds: 700));
    await dangCho;
    expect(t.takeException(), isNull);
  });

  for (final size in [
    const Size(360, 740),
    const Size(390, 844),
    const Size(430, 932),
  ]) {
    for (final chu in [1.0, 2.0]) {
      for (final laVi in [false, true]) {
        testWidgets(
          '${laVi ? 'T12' : 'T11'} ${size.width}×${size.height} chữ $chu cuộn đầy đủ',
          (t) async {
            t.view.physicalSize = size;
            t.view.devicePixelRatio = 1;
            addTearDown(t.view.resetPhysicalSize);
            addTearDown(t.view.resetDevicePixelRatio);
            final kho = khoMau();
            await t.pumpWidget(
              khung(
                laVi
                    ? KetNoiVi(hopDongId: banGoc.id, kho: kho)
                    : XemHopDongNguoiThue(hopDongId: banGoc.id, kho: kho),
                chu: chu,
              ),
            );
            await t.pumpAndSettle();
            if (size.width == 390 && chu == 1) {
              await chupAnh(t, laVi ? 't12_ket_noi_vi' : 't11_xem_hop_dong');
            }
            final f = find.text(
              laVi ? 'An toàn & bảo mật' : 'Xác nhận hợp đồng',
            );
            await t.ensureVisible(f);
            await t.pumpAndSettle();
            expect(f, findsOneWidget);
            expect(t.takeException(), isNull);
            expect(find.byType(Scaffold), findsOneWidget);
            expect(find.byType(ThanhDieuHuongVaiTro), findsNothing);
            if (laVi) {
              await nhan(t, 'Kết nối ví');
              await nhan(t, 'Mô phỏng kết nối thành công');
              await t.ensureVisible(find.text('Ngắt kết nối demo'));
              await t.pumpAndSettle();
              expect(t.takeException(), isNull);
            }
          },
        );
      }
    }
  }
}
