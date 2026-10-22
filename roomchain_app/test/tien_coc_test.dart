import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/chi_tiet_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tien_coc/anh_bang_chung.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tien_coc/quan_ly_tien_coc.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/tien_coc/tao_quyet_toan.dart';
import 'package:roomchain_app/dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import 'package:roomchain_app/dung_chung/mo_hinh/quyet_toan_tien_coc.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/ung_dung/dieu_huong.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAAEUlEQVR4nGPgqC/5D8IMMAYAQYYH6X0RBxAAAAAASUVORK5CYII=',
);
BangChungKhauTru anhMau(String id) =>
    BangChungKhauTru(id: id, tenTep: '$id.png', noiDung: _png);

class _AnhMau extends DichVuAnhBangChung {
  _AnhMau(this.ketQua);
  final List<BangChungKhauTru> ketQua;
  @override
  Future<List<BangChungKhauTru>> chon() async => ketQua;
}

class _AnhLoi extends DichVuAnhBangChung {
  @override
  Future<List<BangChungKhauTru>> chon() async =>
      throw const FormatException('Không đọc được ảnh.');
}

HopDong hopDongMau({
  String id = 'HD-QT',
  TrangThaiTienCoc tt = TrangThaiTienCoc.dangKhoa,
  TrangThaiHopDong trangThai = TrangThaiHopDong.dangHieuLuc,
  int token = 1000000,
  String loaiToken = 'MockVNDC',
  DateTime? den,
  ThoaThuanKetThucSom? thoaThuan,
}) => HopDong(
  id: id,
  maHopDong: id,
  phongId: 'P502B',
  nguoiThueId: DuLieuGia.nguoiThue.id,
  ngayBatDau: DateTime(2025, 1, 1),
  ngayKetThuc: den ?? DateTime(2025, 12, 31),
  giaThue: 3800000,
  tienCoc: 1000000,
  trangThai: trangThai,
  chuTroKyLuc: DateTime(2024, 12, 30, 10),
  nguoiThueKyLuc: DateTime(2024, 12, 30, 11),
  coc: TienCoc(
    id: 'coc-$id',
    hopDongId: id,
    soToken: token,
    loaiToken: loaiToken,
    trangThai: tt,
  ),
  ghiNhanCocLuc: DateTime(2025, 1, 1),
  thoaThuanKetThucSom: thoaThuan,
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
    theme: ChuDeUngDung.sang,
    debugShowCheckedModeBanner: false,
    onGenerateRoute: DieuHuong.taoRoute,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(chu)),
      child: child!,
    ),
    home: trang,
  );
  Future<void> nhan(WidgetTester t, String chu) async {
    final nut = find.widgetWithText(NutBam, chu);
    final nutChu = find.widgetWithText(TextButton, chu);
    final f = nut.evaluate().isNotEmpty
        ? nut.last
        : nutChu.evaluate().isNotEmpty
        ? nutChu.last
        : find.text(chu).last;
    await t.pumpAndSettle();
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> nhap(WidgetTester t, String key, String chu) async {
    final f = find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(TextFormField),
    );
    await t.ensureVisible(f);
    await t.enterText(f, chu);
    await t.pump();
  }

  Future<void> xacNhan(WidgetTester t) async {
    final f = find.byKey(const ValueKey('xacNhanQuyetToan'));
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pump();
  }

  Future<void> chupAnh(WidgetTester t, String ten) async {
    if (thuMucAnh.isEmpty) return;
    final b = t.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('anh')),
    );
    await t.runAsync(() async {
      final h = await b.toImage();
      final d = await h.toByteData(format: ui.ImageByteFormat.png);
      await Directory(thuMucAnh).create(recursive: true);
      await File('$thuMucAnh/$ten.png').writeAsBytes(d!.buffer.asUint8List());
      h.dispose();
    });
  }

  const khongTru = [KhoanKhauTru(id: 'k1', soTien: 0, lyDo: '')];

  test(
    'Bộ chọn ảnh kiểm tra ảnh thật và giữ byte gốc, mã SHA cho chống trùng',
    () async {
      final dv = DichVuAnhBangChung(
        khiMoTep: () async => [
          XFile.fromData(_png, name: 'anh.png', path: 'anh.png'),
        ],
      );
      final ds = await dv.chon();
      expect(ds.single.tenTep, 'anh.png');
      expect(ds.single.noiDung, orderedEquals(_png));
      expect(ds.single.id.length, 64);
    },
  );
  test('Bộ chọn ảnh xử lý hủy, file hỏng, quá 5 MB và quá 5 ảnh', () async {
    expect(await DichVuAnhBangChung(khiMoTep: () async => []).chon(), isEmpty);
    await expectLater(
      DichVuAnhBangChung(
        khiMoTep: () async => [
          XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'sai.png'),
        ],
      ).chon(),
      throwsFormatException,
    );
    await expectLater(
      DichVuAnhBangChung(
        khiMoTep: () async => [
          XFile.fromData(Uint8List(5 * 1024 * 1024 + 1), name: 'lon.png'),
        ],
      ).chon(),
      throwsFormatException,
    );
    await expectLater(
      DichVuAnhBangChung(
        khiMoTep: () async => [
          for (var i = 0; i < 6; i++) XFile.fromData(_png, name: '$i.png'),
        ],
      ).chon(),
      throwsFormatException,
    );
  });
  test('Tổng escrow bao gồm chờ quyết toán/xác nhận, loại khoản chưa khóa và đã giải ngân', () {
    final ds = [
      for (var i = 0; i < TrangThaiTienCoc.values.length; i++)
        hopDongMau(id: 'HD$i', tt: TrangThaiTienCoc.values[i], token: 1000000),
    ];
    final kho = KhoHopDongMau(banDau: ds);
    addTearDown(kho.dispose);
    expect(kho.tongCocDangKhoa, 3000000);
    expect(kho.doanhThuCocVnd, 0);
  });
  test('Doanh thu VND chỉ lấy số đã ghi nhận khi quyết toán giải ngân, không suy từ token', () {
    QuyetToanTienCoc q(TrangThaiQuyetToan tt, int thu) => QuyetToanTienCoc(
      id: 'q',
      hopDongId: 'a',
      tienCocBanDau: 1000000,
      cacKhoan: khongTru,
      bangChung: [],
      chuTroXacNhanLuc: DateTime(2026),
      trangThai: tt,
      nguoiThueXacNhanLuc: tt == TrangThaiQuyetToan.daGiaiNgan
          ? DateTime(2026)
          : null,
      trangThaiGiaoDich: tt == TrangThaiQuyetToan.daGiaiNgan
          ? TrangThaiGiaoDichQuyetToan.thanhCong
          : TrangThaiGiaoDichQuyetToan.chuaGui,
      txHash: tt == TrangThaiQuyetToan.daGiaiNgan
          ? '0x0000000000000000000000000000000000000000000000000000000000000001'
          : null,
      thoiGianGiaoDich: tt == TrangThaiQuyetToan.daGiaiNgan
          ? DateTime(2026)
          : null,
      hoanTatLuc: tt == TrangThaiQuyetToan.daGiaiNgan ? DateTime(2026) : null,
      doanhThuVndDaGhiNhan: thu,
    );
    final kho = KhoHopDongMau(
      banDau: [
        hopDongMau(id: 'a')
            .copyWith(quyetToan: q(TrangThaiQuyetToan.daGiaiNgan, 50000)),
        hopDongMau(id: 'b').copyWith(
          quyetToan: q(TrangThaiQuyetToan.choNguoiThueXacNhan, 999999),
        ),
      ],
    );
    addTearDown(kho.dispose);
    expect(kho.doanhThuCocVnd, 50000);
    expect(kho.tongCocDangKhoa, 2000000);
  });
  test(
    'Kho mặc định giữ giá/phòng và bổ sung cọc cho hợp đồng kết thúc hiện có',
    () {
      final kho = KhoHopDongMau();
      addTearDown(kho.dispose);
      expect(kho.danhSach.length, 5);
      expect(kho.tongCocDangKhoa, 6300000);
      expect(kho.lyDoChuaDuDieuKienQuyetToan('HD2024-0771'), isNull);
      expect(kho.phong('P502B').giaThue, 3800000);
    },
  );
  test(
    'Điều kiện chặn trạng thái, escrow, tỷ lệ token và hợp đồng chưa đến hạn',
    () {
      for (final h in [
        hopDongMau(trangThai: TrangThaiHopDong.choKy),
        hopDongMau(tt: TrangThaiTienCoc.choXacNhan),
        hopDongMau(token: 900000),
        hopDongMau(loaiToken: 'khac'),
        hopDongMau(den: DateTime(2090)),
      ]) {
        final kho = KhoHopDongMau(banDau: [h]);
        expect(kho.lyDoChuaDuDieuKienQuyetToan(h.id), isNotNull);
        kho.dispose();
      }
      final kho = KhoHopDongMau(banDau: []);
      addTearDown(kho.dispose);
      expect(kho.lyDoChuaDuDieuKienQuyetToan('sai'), isNotNull);
    },
  );
  test('Nhiều khoản tính tổng, hoàn dự kiến; gửi giữ nguyên token, tiền và trạng thái hợp đồng', () {
    final h = hopDongMau();
    final kho = KhoHopDongMau(banDau: [h]);
    addTearDown(kho.dispose);
    final so = kho.tongCocDangKhoa;
    final q = kho.guiQuyetToan(
      hopDongId: h.id,
      cacKhoan: const [
        KhoanKhauTru(id: 'a', soTien: 200000, lyDo: 'Vệ sinh'),
        KhoanKhauTru(id: 'b', soTien: 300000, lyDo: 'Sửa ghế'),
      ],
      bangChung: [anhMau('a')],
      chuTroDaXacNhan: true,
    );
    expect(q.tongKhauTru, 500000);
    expect(q.soHoanDuKien, 500000);
    expect(q.trangThai, TrangThaiQuyetToan.choNguoiThueXacNhan);
    final sau = kho.theoId(h.id)!;
    expect(sau.coc!.trangThai, TrangThaiTienCoc.choNguoiThueXacNhan);
    expect(sau.coc!.soToken, h.coc!.soToken);
    expect(sau.trangThai, h.trangThai);
    expect(kho.tongCocDangKhoa, so);
    expect(kho.doanhThuCocVnd, 0);
    expect(q.nguoiThueXacNhanLuc, isNull);
    expect(() => q.cacKhoan.clear(), throwsUnsupportedError);
    expect(
      () => kho.guiQuyetToan(
        hopDongId: h.id,
        cacKhoan: khongTru,
        bangChung: [],
        chuTroDaXacNhan: true,
      ),
      throwsStateError,
    );
  });
  test('Hoàn đủ cọc cho phép 0, không ảnh; vẫn cần chủ trọ xác nhận', () {
    final h = hopDongMau();
    final kho = KhoHopDongMau(banDau: [h]);
    addTearDown(kho.dispose);
    expect(
      () => kho.guiQuyetToan(
        hopDongId: h.id,
        cacKhoan: khongTru,
        bangChung: [],
        chuTroDaXacNhan: false,
      ),
      throwsStateError,
    );
    final q = kho.guiQuyetToan(
      hopDongId: h.id,
      cacKhoan: khongTru,
      bangChung: [],
      chuTroDaXacNhan: true,
    );
    expect(q.soHoanDuKien, 1000000);
  });
  test(
    'Chặn khoản âm/vượt cọc/thiếu lý do/thiếu bằng chứng/quá nhiều khoản ảnh',
    () {
      final h = hopDongMau();
      final kho = KhoHopDongMau(banDau: [h]);
      addTearDown(kho.dispose);
      for (final ds in [
        <KhoanKhauTru>[],
        [const KhoanKhauTru(id: 'a', soTien: -1, lyDo: 'âm')],
        [const KhoanKhauTru(id: 'a', soTien: 1000001, lyDo: 'vượt')],
        [const KhoanKhauTru(id: 'a', soTien: 1, lyDo: '  ')],
        [
          for (var i = 0; i < 11; i++)
            KhoanKhauTru(id: '$i', soTien: 0, lyDo: ''),
        ],
      ]) {
        expect(kho.kiemTraQuyetToan(h.id, ds, [anhMau('a')]), isNotNull);
      }
      expect(
        kho.kiemTraQuyetToan(h.id, [
          const KhoanKhauTru(id: 'a', soTien: 1, lyDo: 'có khấu trừ'),
        ], []),
        isNotNull,
      );
      expect(
        kho.kiemTraQuyetToan(h.id, khongTru, [
          for (var i = 0; i < 6; i++) anhMau('$i'),
        ]),
        isNotNull,
      );
      expect(kho.theoId(h.id), same(h));
    },
  );
  test(
    'Kết thúc trước hạn phải theo đúng thỏa thuận xác nhận của cả hai bên',
    () {
      final h = hopDongMau(
        den: DateTime(2090),
        thoaThuan: ThoaThuanKetThucSom(
          noiDung: 'Thỏa thuận kết thúc sớm, khấu trừ 100.000đ',
          khauTruDaThongNhat: 100000,
          chuTroXacNhanLuc: DateTime(2026),
          nguoiThueXacNhanLuc: DateTime(2026),
        ),
      );
      final kho = KhoHopDongMau(banDau: [h]);
      addTearDown(kho.dispose);
      expect(kho.lyDoChuaDuDieuKienQuyetToan(h.id), isNull);
      expect(kho.kiemTraQuyetToan(h.id, khongTru, []), contains('thỏa thuận'));
      expect(
        kho.kiemTraQuyetToan(
          h.id,
          [
            const KhoanKhauTru(
              id: 'k',
              soTien: 100000,
              lyDo: 'Theo thỏa thuận',
            ),
          ],
          [anhMau('a')],
        ),
        isNull,
      );
    },
  );

  for (final size in const [Size(360, 740), Size(390, 844), Size(430, 932)]) {
    for (final chu in [1.0, 2.0]) {
      for (final tao in [false, true]) {
        testWidgets(
          '${tao ? 'L14' : 'L13'} ${size.width}x${size.height}, chữ $chu',
          (t) async {
            t.view.physicalSize = size;
            t.view.devicePixelRatio = 1;
            t.view.padding = const FakeViewPadding(top: 24, bottom: 24);
            addTearDown(t.view.resetPhysicalSize);
            addTearDown(t.view.resetDevicePixelRatio);
            addTearDown(t.view.resetPadding);
            final kho = KhoHopDongMau();
            addTearDown(kho.dispose);
            await t.pumpWidget(
              khung(
                RepaintBoundary(
                  key: const ValueKey('anh'),
                  child: tao
                      ? TaoQuyetToan(kho: kho, hopDongId: 'HD2024-0771')
                      : QuanLyTienCoc(kho: kho),
                ),
                chu: chu,
              ),
            );
            await t.pumpAndSettle();
            expect(find.byType(Scaffold), findsOneWidget);
            expect(
              find.byType(ThanhDieuHuongVaiTro),
              tao ? findsNothing : findsOneWidget,
            );
            expect(t.takeException(), isNull);
            if (size.width == 390 && chu == 1) {
              await chupAnh(
                t,
                tao ? 'l14_tao_quyet_toan' : 'l13_quan_ly_tien_coc',
              );
            }
            if (tao) {
              await nhap(t, 'soTien_1', '500000');
              await nhap(t, 'lyDo_1', 'Sửa ghế');
              await nhan(t, 'Thêm khoản khấu trừ');
              await nhap(t, 'soTien_2', '200000');
              expect(find.text('700.000đ'), findsOneWidget);
              expect(find.text('1.800.000đ'), findsOneWidget);
            }
            expect(t.takeException(), isNull);
          },
        );
      }
    }
  }
  testWidgets('L13 lọc tất cả trạng thái, empty và mở L12 đúng ID', (t) async {
    final kho = KhoHopDongMau();
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(QuanLyTienCoc(kho: kho)));
    await t.pumpAndSettle();
    expect(find.text('6.300.000 MockVNDC'), findsNWidgets(2));
    expect(find.text('0đ'), findsOneWidget);
    Future<void> loc(String nhan) async {
      final o = find.byType(DropdownButtonFormField<String>);
      await t.ensureVisible(o);
      await t.tap(o);
      await t.pumpAndSettle();
      await nhanChon(nhan, t);
    }

    await loc('Đã hoàn');
    expect(find.text('Chưa có khoản cọc'), findsOneWidget);
    await loc('Chờ quyết toán');
    expect(find.byKey(const ValueKey('coc_HD2024-0771')), findsOneWidget);
    final muc = find.byKey(const ValueKey('coc_HD2024-0771'));
    await t.ensureVisible(muc);
    await t.tap(muc);
    await t.pumpAndSettle();
    expect(
      t.widget<ChiTietHopDong>(find.byType(ChiTietHopDong)).hopDongId,
      'HD2024-0771',
    );
    final thaoTac = find.byKey(const ValueKey('chi_tiet_tab_3'));
    await t.ensureVisible(thaoTac);
    await t.tap(thaoTac);
    await t.pumpAndSettle();
    await nhan(t, 'Tạo quyết toán');
    expect(
      t.widget<TaoQuyetToan>(find.byType(TaoQuyetToan)).hopDongId,
      'HD2024-0771',
    );
  });
  testWidgets(
    'Thêm/xóa khoản không mất dữ liệu, số âm/chữ và lý do rỗng bị chặn',
    (t) async {
      final h = hopDongMau();
      final kho = KhoHopDongMau(banDau: [h]);
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(TaoQuyetToan(kho: kho, hopDongId: h.id)));
      await t.pumpAndSettle();
      await nhap(t, 'soTien_1', 'abc');
      await nhan(t, 'Gửi người thuê xác nhận');
      expect(
        find.text('Nhập số nguyên không âm, tối đa 15 chữ số.'),
        findsOneWidget,
      );
      await nhap(t, 'soTien_1', '-1');
      await nhan(t, 'Gửi người thuê xác nhận');
      expect(kho.theoId(h.id)!.quyetToan, isNull);
      await nhap(t, 'soTien_1', '200000');
      await nhan(t, 'Gửi người thuê xác nhận');
      expect(find.text('Vui lòng nhập lý do khấu trừ.'), findsOneWidget);
      await nhap(t, 'lyDo_1', 'Vệ sinh');
      await nhan(t, 'Thêm khoản khấu trừ');
      await nhap(t, 'soTien_2', '300000');
      expect(find.text('500.000đ'), findsNWidgets(2));
      await t.ensureVisible(find.byTooltip('Xóa khoản 2'));
      await t.tap(find.byTooltip('Xóa khoản 2'));
      await t.pumpAndSettle();
      expect(find.text('200.000'), findsOneWidget);
      expect(find.text('Vệ sinh'), findsOneWidget);
    },
  );
  testWidgets('Ảnh được chọn, xem lớn, xóa và không thêm trùng', (t) async {
    final h = hopDongMau();
    final kho = KhoHopDongMau(banDau: [h]);
    addTearDown(kho.dispose);
    await t.pumpWidget(
      khung(
        TaoQuyetToan(
          kho: kho,
          hopDongId: h.id,
          dichVuAnh: _AnhMau([anhMau('a'), anhMau('a')]),
        ),
      ),
    );
    await t.pumpAndSettle();
    await nhan(t, 'Thêm ảnh (0/5)');
    expect(find.byType(AnhBangChung), findsOneWidget);
    final anh = find.byType(AnhBangChung);
    await t.ensureVisible(anh);
    await t.tapAt(t.getBottomLeft(anh) + const Offset(10, -10));
    await t.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await t.tap(find.byTooltip('Đóng ảnh'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Xóa ảnh a.png'));
    await t.pumpAndSettle();
    expect(find.byType(AnhBangChung), findsNothing);
  });
  testWidgets(
    'Gửi nhiều khoản và ảnh: xác nhận, chờ người thuê, giữ nguyên tiền trong escrow',
    (t) async {
      final h = hopDongMau();
      final kho = KhoHopDongMau(banDau: [h]);
      addTearDown(kho.dispose);
      await t.pumpWidget(
        khung(
          TaoQuyetToan(
            kho: kho,
            hopDongId: h.id,
            dichVuAnh: _AnhMau([anhMau('a')]),
          ),
        ),
      );
      await t.pumpAndSettle();
      await nhap(t, 'soTien_1', '500000');
      await nhap(t, 'lyDo_1', 'Sửa ghế');
      await nhan(t, 'Gửi người thuê xác nhận');
      expect(find.textContaining('Cần ít nhất một ảnh'), findsOneWidget);
      await nhan(t, 'Thêm ảnh (0/5)');
      await nhan(t, 'Gửi người thuê xác nhận');
      expect(
        find.textContaining('Vui lòng xác nhận các khoản'),
        findsOneWidget,
      );
      await xacNhan(t);
      await nhan(t, 'Gửi người thuê xác nhận');
      expect(find.byType(HopThoaiXacNhan), findsOneWidget);
      await nhan(t, 'Hủy');
      expect(kho.theoId(h.id)!.quyetToan, isNull);
      await nhan(t, 'Gửi người thuê xác nhận');
      await nhan(t, 'Xác nhận');
      expect(find.text('Chờ người thuê xác nhận'), findsOneWidget);
      final q = kho.theoId(h.id)!.quyetToan!;
      expect(q.tongKhauTru, 500000);
      expect(q.soHoanDuKien, 500000);
      expect(q.bangChung.single.tenTep, 'a.png');
      expect(kho.tongCocDangKhoa, 1000000);
      expect(kho.doanhThuCocVnd, 0);
      expect(kho.theoId(h.id)!.trangThai, h.trangThai);
      await nhan(t, 'Về quản lý tiền cọc');
      expect(find.byType(QuanLyTienCoc), findsOneWidget);
      expect(find.text('Chờ người thuê xác nhận'), findsOneWidget);
    },
  );
  testWidgets('Hoàn đủ cọc không cần ảnh; gửi lại cùng ID mở bản đã lưu', (
    t,
  ) async {
    final h = hopDongMau();
    final kho = KhoHopDongMau(banDau: [h]);
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(TaoQuyetToan(kho: kho, hopDongId: h.id)));
    await t.pumpAndSettle();
    await xacNhan(t);
    await nhan(t, 'Gửi người thuê xác nhận');
    await nhan(t, 'Xác nhận');
    expect(kho.theoId(h.id)!.quyetToan!.soHoanDuKien, 1000000);
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(khung(TaoQuyetToan(kho: kho, hopDongId: h.id)));
    await t.pumpAndSettle();
    expect(find.text('Chờ người thuê xác nhận'), findsOneWidget);
    expect(find.text('Gửi người thuê xác nhận'), findsNothing);
  });
  testWidgets(
    'Lỗi chọn ảnh, vượt giới hạn, empty selector và ID không hợp lệ',
    (t) async {
      final h = hopDongMau();
      final kho = KhoHopDongMau(banDau: [h]);
      addTearDown(kho.dispose);
      await t.pumpWidget(
        khung(TaoQuyetToan(kho: kho, hopDongId: h.id, dichVuAnh: _AnhLoi())),
      );
      await t.pumpAndSettle();
      await nhan(t, 'Thêm ảnh (0/5)');
      expect(find.text('Không đọc được ảnh.'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(
        khung(
          TaoQuyetToan(
            kho: kho,
            hopDongId: h.id,
            dichVuAnh: _AnhMau([for (var i = 0; i < 6; i++) anhMau('$i')]),
          ),
        ),
      );
      await t.pumpAndSettle();
      await nhan(t, 'Thêm ảnh (0/5)');
      expect(find.textContaining('Tối đa 5 ảnh. Vui lòng'), findsOneWidget);
      expect(find.byType(AnhBangChung), findsNothing);
      final rong = KhoHopDongMau(banDau: []);
      addTearDown(rong.dispose);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(khung(TaoQuyetToan(kho: rong)));
      await t.pumpAndSettle();
      expect(
        find.text('Chưa có hợp đồng đủ điều kiện quyết toán.'),
        findsOneWidget,
      );
      await nhan(t, 'Gửi người thuê xác nhận');
      expect(find.text('Vui lòng chọn hợp đồng đủ điều kiện.'), findsOneWidget);
    },
  );
  testWidgets(
    'L14 vượt cọc không gửi, Back xác nhận hủy và không tạo quyết toán',
    (t) async {
      final h = hopDongMau();
      final kho = KhoHopDongMau(banDau: [h]);
      addTearDown(kho.dispose);
      await t.pumpWidget(
        khung(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                DieuHuong.taoQuyetToan,
                arguments: ThamSoHopDong(hopDongId: h.id, kho: kho),
              ),
              child: const Text('Mở'),
            ),
          ),
        ),
      );
      await nhan(t, 'Mở');
      await nhap(t, 'soTien_1', '1000001');
      await nhap(t, 'lyDo_1', 'Sửa ghế');
      await nhan(t, 'Gửi người thuê xác nhận');
      expect(
        find.text('Tổng khấu trừ không được vượt quá tiền cọc.'),
        findsOneWidget,
      );
      await t.tap(find.byTooltip('Quay lại'));
      await t.pumpAndSettle();
      expect(find.byType(HopThoaiXacNhan), findsOneWidget);
      await nhan(t, 'Xác nhận');
      expect(find.byType(TaoQuyetToan), findsNothing);
      expect(kho.theoId(h.id)!.quyetToan, isNull);
    },
  );
  testWidgets('Nhúng L13 không nhân đôi nav, bàn phím L14 không che nút', (
    t,
  ) async {
    final kho = KhoHopDongMau();
    addTearDown(kho.dispose);
    await t.pumpWidget(
      khung(
        BoCucChuTro(
          chiSoChon: 4,
          khiChon: (_) {},
          noiDung: QuanLyTienCoc(kho: kho, trongTab: true),
        ),
      ),
    );
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ThanhDieuHuongVaiTro), findsOneWidget);
    t.view.physicalSize = const Size(360, 740);
    t.view.devicePixelRatio = 1;
    t.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.view.resetViewInsets);
    await t.pumpWidget(
      khung(TaoQuyetToan(kho: kho, hopDongId: 'HD2024-0771'), chu: 2),
    );
    await t.pumpAndSettle();
    expect(
      find.widgetWithText(NutBam, 'Gửi người thuê xác nhận').hitTestable(),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'Đổi hợp đồng hỏi xác nhận, hủy giữ dữ liệu và đồng ý tạo bản nháp riêng',
    (t) async {
      final a = hopDongMau(id: 'HD-A');
      final b = hopDongMau(id: 'HD-B');
      final kho = KhoHopDongMau(banDau: [a, b]);
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(TaoQuyetToan(kho: kho)));
      await t.pumpAndSettle();
      Future<void> chon(String id) async {
        final f = find.byType(DropdownButtonFormField<String>);
        await t.ensureVisible(f);
        await t.tap(f);
        await t.pumpAndSettle();
        await nhanChon('$id – Trần Minh Anh (P502B)', t);
      }

      await chon('HD-A');
      await nhap(t, 'soTien_2', '100000');
      await nhap(t, 'lyDo_2', 'Bản nháp A');
      final f = find.byType(DropdownButtonFormField<String>);
      await t.ensureVisible(f);
      await t.tap(f);
      await t.pumpAndSettle();
      await t.tap(find.text('HD-B – Trần Minh Anh (P502B)').last);
      await t.pump();
      await nhan(t, 'Hủy');
      expect(find.text('100.000'), findsOneWidget);
      expect(find.text('Bản nháp A'), findsOneWidget);
      await t.ensureVisible(f);
      await t.tap(f);
      await t.pumpAndSettle();
      await t.tap(find.text('HD-B – Trần Minh Anh (P502B)').last);
      await t.pump();
      await nhan(t, 'Xác nhận');
      expect(find.text('Bản nháp A'), findsNothing);
      expect(find.text('HD-B – Trần Minh Anh (P502B)'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'Bản quyết toán lịch sử hiển thị đúng trạng thái đã xác nhận/giải ngân, không tạo lại',
    (t) async {
      for (final trangThai in [
        TrangThaiQuyetToan.daXacNhan,
        TrangThaiQuyetToan.daGiaiNgan,
      ]) {
        final q = QuyetToanTienCoc(
          id: 'QT-cu',
          hopDongId: 'HD-QT',
          tienCocBanDau: 1000000,
          cacKhoan: khongTru,
          bangChung: [],
          chuTroXacNhanLuc: DateTime(2026),
          nguoiThueXacNhanLuc: DateTime(2026),
          trangThai: trangThai,
          trangThaiGiaoDich: trangThai == TrangThaiQuyetToan.daGiaiNgan
              ? TrangThaiGiaoDichQuyetToan.thanhCong
              : TrangThaiGiaoDichQuyetToan.chuaGui,
          txHash: trangThai == TrangThaiQuyetToan.daGiaiNgan
              ? '0x0000000000000000000000000000000000000000000000000000000000000001'
              : null,
          thoiGianGiaoDich: trangThai == TrangThaiQuyetToan.daGiaiNgan
              ? DateTime(2026)
              : null,
          hoanTatLuc: trangThai == TrangThaiQuyetToan.daGiaiNgan
              ? DateTime(2026)
              : null,
        );
        final h = hopDongMau().copyWith(quyetToan: q);
        final kho = KhoHopDongMau(banDau: [h]);
        addTearDown(kho.dispose);
        await t.pumpWidget(const SizedBox());
        await t.pumpWidget(khung(TaoQuyetToan(kho: kho, hopDongId: h.id)));
        await t.pumpAndSettle();
        expect(
          find.text(
            trangThai == TrangThaiQuyetToan.daXacNhan
                ? 'Đã xác nhận, chờ giải ngân'
                : 'Đã giải ngân (dữ liệu demo)',
          ),
          findsOneWidget,
        );
        expect(find.text('Gửi người thuê xác nhận'), findsNothing);
        expect(kho.theoId(h.id), same(h));
      }
    },
  );
}

Future<void> nhanChon(String chu, WidgetTester t) async {
  final f = find.text(chu).last;
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
}
