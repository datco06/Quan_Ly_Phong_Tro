import 'dart:io';
import 'dart:ui' as giao_dien;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/danh_sach_hop_dong.dart';
import 'package:roomchain_app/chuc_nang/dung_chung/hop_dong/tao_hop_dong.dart';
import 'package:roomchain_app/dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/ung_dung/dieu_huong.dart';

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
  Widget khung(Widget trang, {double coChu = 1}) => MaterialApp(
    theme: ChuDeUngDung.sang,
    debugShowCheckedModeBanner: false,
    onGenerateRoute: DieuHuong.taoRoute,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(coChu)),
      child: child!,
    ),
    home: trang,
  );
  Future<void> nhan(WidgetTester t, String nhan) async {
    final nut = find.widgetWithText(NutBam, nhan);
    final f = nut.evaluate().isNotEmpty ? nut.last : find.text(nhan).last;
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> nhap(WidgetTester t, String ten, String giaTri) async {
    final f = find.descendant(
      of: find.byKey(ValueKey(ten)),
      matching: find.byType(TextFormField),
    );
    await t.ensureVisible(f);
    await t.enterText(f, giaTri);
    await t.pump();
  }

  Future<void> chon(WidgetTester t, String tieuDe, String giaTri) async {
    final o = find
        .ancestor(of: find.text(tieuDe), matching: find.byType(InkWell))
        .first;
    await t.ensureVisible(o);
    await t.tap(o);
    await t.pumpAndSettle();
    await nhan(t, giaTri);
  }

  Future<void> thongTin(WidgetTester t) async {
    await chon(t, 'Phòng cho thuê *', 'P403');
    await chon(t, 'Người thuê *', 'Trần Minh Anh');
  }

  Future<void> anh(WidgetTester t, String ten) async {
    if (thuMucAnh.isEmpty) return;
    final b = t.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('anh')),
    );
    await t.runAsync(() async {
      final h = await b.toImage();
      final data = await h.toByteData(format: giao_dien.ImageByteFormat.png);
      await Directory(thuMucAnh).create(recursive: true);
      await File('$thuMucAnh/$ten.png')
          .writeAsBytes(data!.buffer.asUint8List());
      h.dispose();
    });
  }

  HopDong banNhap({
    String phongId = 'P403',
    DateTime? tu,
    DateTime? den,
    int gia = 2600000,
    int coc = 2600000,
    CauHinhHopDong cauHinh = const CauHinhHopDong(),
  }) => HopDong(
    id: '',
    maHopDong: '',
    phongId: phongId,
    nguoiThueId: DuLieuGia.nguoiThue.id,
    ngayBatDau: tu ?? DateTime(2026, 10, 22),
    ngayKetThuc: den ?? DateTime(2027, 10, 22),
    giaThue: gia,
    tienCoc: coc,
    trangThai: TrangThaiHopDong.choKy,
    cauHinh: cauHinh,
  );

  test('Kho dùng lại phòng/người thuê/giá project và đủ bốn trạng thái', () {
    final kho = KhoHopDongMau();
    addTearDown(kho.dispose);
    expect(kho.phong('P502B').giaThue, 3800000);
    expect(kho.nguoiThue.single, same(DuLieuGia.nguoiThue));
    expect(kho.theoId(DuLieuGia.hopDong.id), same(DuLieuGia.hopDong));
    for (final tt in [
      TrangThaiHopDong.choKy,
      TrangThaiHopDong.choCoc,
      TrangThaiHopDong.dangHieuLuc,
      TrangThaiHopDong.daKetThuc,
    ]) {
      expect(kho.loc(trangThai: tt), isNotEmpty);
    }
    expect(
      kho.loc(trangThai: TrangThaiHopDong.choKy, tuKhoa: '  p201  ').length,
      2,
    );
    expect(
      kho
          .loc(trangThai: TrangThaiHopDong.choCoc, tuKhoa: 'trẦn minh anh')
          .length,
      1,
    );
    expect(
      kho.loc(trangThai: TrangThaiHopDong.choKy, tuKhoa: 'HD2025-0123').length,
      1,
    );
    expect(
      kho.loc(trangThai: TrangThaiHopDong.choKy, khuTro: 'Không tồn tại'),
      isEmpty,
    );
  });
  test(
    'Không trùng thời gian, bao gồm hai đầu mút và trạng thái chờ ký/cọc',
    () {
      final kho = KhoHopDongMau(bayGio: DateTime(2026, 10, 22));
      addTearDown(kho.dispose);
      final choKy = kho.loc(trangThai: TrangThaiHopDong.choKy).first;
      final choCoc = kho.loc(trangThai: TrangThaiHopDong.choCoc).first;
      for (final h in [choKy, choCoc, DuLieuGia.hopDong]) {
        expect(
          kho.trungThoiGian(h.phongId, h.ngayBatDau, h.ngayKetThuc),
          isTrue,
        );
        expect(
          kho.trungThoiGian(
            h.phongId,
            h.ngayKetThuc,
            h.ngayKetThuc.add(const Duration(days: 1)),
          ),
          isTrue,
        );
      }
      expect(
        kho.trungThoiGian('P201', DateTime(2024, 2, 1), DateTime(2024, 3, 1)),
        isFalse,
      );
      expect(
        kho.trungThoiGian('P403', DateTime(2026), DateTime(2027)),
        isFalse,
      );
    },
  );
  test('Kho chặn ngày, phòng, người và chi phí không hợp lệ', () {
    final kho = KhoHopDongMau(banDau: []);
    addTearDown(kho.dispose);
    for (final h in [
      banNhap(tu: DateTime(2027), den: DateTime(2026)),
      banNhap(tu: DateTime(2027), den: DateTime(2027)),
      banNhap(gia: 0),
      banNhap(coc: -1),
      banNhap(phongId: 'P502B'),
      banNhap(phongId: 'sai'),
      banNhap().copyWith(nguoiThueId: 'sai'),
      banNhap(cauHinh: const CauHinhHopDong(internet: -1)),
      banNhap(cauHinh: const CauHinhHopDong(ngayGhiSo: 29)),
      banNhap(cauHinh: const CauHinhHopDong(thanhToanTu: 6, thanhToanDen: 5)),
    ]) {
      expect(() => kho.them(h), throwsStateError);
    }
    expect(kho.danhSach, isEmpty);
  });
  test(
    'Thêm, đọc theo ID, giữ cấu hình, ID duy nhất, refresh không mất dữ liệu',
    () {
      final kho = KhoHopDongMau(banDau: []);
      addTearDown(kho.dispose);
      var thongBao = 0;
      kho.addListener(() => thongBao++);
      const c = CauHinhHopDong(
        phiDichVu: 230000,
        internet: 120000,
        noiQuy: 'Giữ yên tĩnh',
      );
      final a = kho.them(banNhap(cauHinh: c));
      final b = kho.them(banNhap(tu: DateTime(2028), den: DateTime(2029)));
      expect(a.id, isNot(b.id));
      expect(a.trangThai, TrangThaiHopDong.choKy);
      expect(kho.theoId(a.id)!.cauHinh, same(c));
      expect(a.copyWith(tienCoc: 0).cauHinh, same(c));
      expect(() => kho.them(banNhap()), throwsStateError);
      kho.lamMoi();
      expect(kho.danhSach.length, 2);
      expect(thongBao, 3);
      expect(() => kho.danhSach.clear(), throwsUnsupportedError);
    },
  );

  for (final size in const [Size(360, 740), Size(390, 844), Size(430, 932)]) {
    for (final coChu in [1.0, 2.0]) {
      for (final tao in [false, true]) {
        testWidgets(
          '${tao ? 'L10' : 'L09'} ${size.width}x${size.height}, chữ $coChu',
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
                  child: tao ? TaoHopDong(kho: kho) : DanhSachHopDong(kho: kho),
                ),
                coChu: coChu,
              ),
            );
            await t.pumpAndSettle();
            expect(t.takeException(), isNull);
            expect(find.byType(Scaffold), findsOneWidget);
            expect(
              find.byType(ThanhDieuHuongVaiTro),
              tao ? findsNothing : findsOneWidget,
            );
            if (size.width == 390 && coChu == 1) {
              await anh(t, tao ? 'l10_tao_hop_dong' : 'l09_danh_sach_hop_dong');
            }
            if (tao) {
              await thongTin(t);
              if (size.width == 390 && coChu == 1) {
                await anh(t, 'l10_tao_hop_dong');
              }
              await nhan(t, 'Tiếp theo');
              expect(find.text('Điều khoản hợp đồng'), findsOneWidget);
              await nhan(t, 'Tiếp theo');
              expect(find.text('Chi phí hàng tháng'), findsOneWidget);
              await nhan(t, 'Tiếp theo');
              expect(find.text('Kiểm tra hợp đồng'), findsOneWidget);
            }
            expect(t.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('L09 tab, tìm kiếm kết hợp, bộ lọc, empty và mở nội dung', (
    t,
  ) async {
    final kho = KhoHopDongMau();
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(DanhSachHopDong(kho: kho)));
    await t.pumpAndSettle();
    expect(find.text('Chờ ký (2)'), findsOneWidget);
    expect(find.text('HD2025-0123'), findsOneWidget);
    await t.enterText(find.byType(TextField), '  p201  ');
    await t.pump();
    expect(find.text('HD2025-0123'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'không có');
    await t.pump();
    expect(find.text('Chưa có hợp đồng'), findsOneWidget);
    await t.tap(find.byTooltip('Xóa tìm kiếm'));
    await t.pump();
    await nhan(t, 'Chờ cọc (1)');
    expect(find.text('HD2025-0122'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('HD2025-0122')));
    await t.pumpAndSettle();
    expect(find.textContaining('Chưa có màn hình chi tiết'), findsOneWidget);
    await nhan(t, 'Đóng');
    await nhan(t, 'Đang thuê (1)');
    expect(find.text(DuLieuGia.hopDong.maHopDong), findsOneWidget);
    await t.ensureVisible(find.text('Đã kết thúc (1)'));
    await nhan(t, 'Đã kết thúc (1)');
    expect(find.text('HD2024-0771'), findsOneWidget);
    await t.tap(find.byTooltip('Lọc khu trọ'));
    await t.pumpAndSettle();
    await nhan(t, 'An Nhiên Residence');
    expect(find.byType(InputChip), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'Form thiếu lựa chọn, tiền bằng 0/âm/chữ, định dạng và không mất bản nháp',
    (t) async {
      final kho = KhoHopDongMau();
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(TaoHopDong(kho: kho)));
      await t.pumpAndSettle();
      await nhan(t, 'Tiếp theo');
      expect(find.text('Vui lòng chọn phòng cho thuê.'), findsOneWidget);
      await thongTin(t);
      await nhap(t, 'giaThue', '0');
      await nhan(t, 'Tiếp theo');
      expect(find.text('Giá thuê phải lớn hơn 0.'), findsOneWidget);
      await nhap(t, 'giaThue', '-10');
      await nhan(t, 'Tiếp theo');
      expect(find.text('Chỉ nhập số tiền nguyên không âm.'), findsOneWidget);
      await nhap(t, 'giaThue', 'abc');
      await nhan(t, 'Tiếp theo');
      expect(find.text('Chỉ nhập số tiền nguyên không âm.'), findsOneWidget);
      await nhap(t, 'giaThue', '3900000');
      await nhap(t, 'tienCoc', '0');
      await nhan(t, 'Tiếp theo');
      expect(find.text('Điều khoản hợp đồng'), findsOneWidget);
      await nhan(t, 'Quay lại');
      expect(find.text('3.900.000'), findsOneWidget);
      expect(find.text('Trần Minh Anh'), findsOneWidget);
      await nhan(t, 'Hủy');
      expect(find.byType(HopThoaiXacNhan), findsOneWidget);
      await t.tap(find.widgetWithText(TextButton, 'Hủy').last);
      await t.pumpAndSettle();
      expect(find.byType(TaoHopDong), findsOneWidget);
    },
  );

  testWidgets(
    'Ngày chồng chéo, phòng đang thuê bị loại, người thuê và date picker hoạt động',
    (t) async {
      final kho = KhoHopDongMau();
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(TaoHopDong(kho: kho)));
      await t.pumpAndSettle();
      await t.tap(
        find
            .ancestor(
              of: find.text('Phòng cho thuê *'),
              matching: find.byType(InkWell),
            )
            .first,
      );
      await t.pumpAndSettle();
      expect(find.text('P502B'), findsNothing);
      await nhan(t, 'P201');
      await chon(t, 'Người thuê *', 'Trần Minh Anh');
      await nhan(t, 'Tiếp theo');
      final loi = find.textContaining('Phòng đã có hợp đồng trùng thời gian');
      await t.ensureVisible(loi);
      expect(loi, findsOneWidget);
      await t.ensureVisible(find.byKey(const ValueKey('ngayBatDau')));
      await t.tap(find.byKey(const ValueKey('ngayBatDau')));
      await t.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await nhan(t, 'Chọn');
      expect(find.byType(DatePickerDialog), findsNothing);
    },
  );

  testWidgets(
    'Đủ 5 bước, sửa chi phí/điều khoản, xác nhận, tạo và về danh sách đồng bộ',
    (t) async {
      t.view.physicalSize = const Size(390, 844);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final kho = KhoHopDongMau();
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(DanhSachHopDong(kho: kho)));
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('Menu hợp đồng'));
      await t.pumpAndSettle();
      await nhan(t, 'Tạo hợp đồng mới');
      expect(find.byType(TaoHopDong), findsOneWidget);
      await thongTin(t);
      await nhan(t, 'Tiếp theo');
      await nhap(t, 'tuNgay', '6');
      await nhan(t, 'Tiếp theo');
      expect(find.text('Phải từ ngày bắt đầu trở đi.'), findsOneWidget);
      await nhap(t, 'tuNgay', '1');
      await nhap(t, 'phuThu', '20000');
      await nhap(t, 'noiQuy', 'Giữ yên tĩnh sau 22 giờ.');
      await nhan(t, 'Tiếp theo');
      await nhap(t, 'internet', '150000');
      await nhap(t, 'khac', '25000');
      await nhap(t, 'ghiSo', '29');
      await nhan(t, 'Tiếp theo');
      expect(find.text('Nhập ngày từ 1 đến 28.'), findsOneWidget);
      await nhap(t, 'ghiSo', '27');
      await nhan(t, 'Tiếp theo');
      await nhan(t, 'Tạo hợp đồng');
      final loi = find.text(
        'Vui lòng xác nhận đã kiểm tra thông tin hợp đồng.',
      );
      await t.ensureVisible(loi);
      expect(loi, findsOneWidget);
      expect(kho.danhSach.length, 5);
      await t.ensureVisible(find.byKey(const ValueKey('xacNhan')));
      await t.tap(find.byKey(const ValueKey('xacNhan')));
      await t.pump();
      await nhan(t, 'Tạo hợp đồng');
      expect(find.text('Tạo hợp đồng thành công'), findsOneWidget);
      final moi = kho.danhSach.first;
      expect(moi.phongId, 'P403');
      expect(moi.trangThai, TrangThaiHopDong.choKy);
      expect(moi.cauHinh.internet, 150000);
      expect(moi.cauHinh.khoanKhac, 25000);
      expect(moi.cauHinh.ngayGhiSo, 27);
      expect(moi.cauHinh.phuThuCham, 20000);
      expect(moi.cauHinh.noiQuy, 'Giữ yên tĩnh sau 22 giờ.');
      await nhan(t, 'Xem hợp đồng');
      expect(find.byType(AlertDialog), findsOneWidget);
      await nhan(t, 'Đóng');
      await nhan(t, 'Về danh sách hợp đồng');
      expect(find.byType(TaoHopDong), findsNothing);
      expect(find.text(moi.maHopDong), findsOneWidget);
      expect(find.text('Chờ ký (3)'), findsOneWidget);
      await t.tap(find.byTooltip('Menu hợp đồng'));
      await t.pumpAndSettle();
      await nhan(t, 'Làm mới danh sách');
      expect(find.text(moi.maHopDong), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'Back hệ thống đi lùi bước; hủy bản nháp cần xác nhận, không thêm hợp đồng',
    (t) async {
      final kho = KhoHopDongMau();
      addTearDown(kho.dispose);
      await t.pumpWidget(
        khung(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                DieuHuong.taoHopDong,
                arguments: kho,
              ),
              child: const Text('Mở'),
            ),
          ),
        ),
      );
      await nhan(t, 'Mở');
      await thongTin(t);
      await nhan(t, 'Tiếp theo');
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.text('Thông tin cơ bản'), findsOneWidget);
      await t.binding.handlePopRoute();
      await t.pumpAndSettle();
      expect(find.byType(HopThoaiXacNhan), findsOneWidget);
      await nhan(t, 'Xác nhận');
      expect(find.byType(TaoHopDong), findsNothing);
      expect(kho.danhSach.length, 5);
    },
  );

  testWidgets('Nhúng trong layout cha không nhân đôi Scaffold và navigation', (
    t,
  ) async {
    final kho = KhoHopDongMau();
    addTearDown(kho.dispose);
    await t.pumpWidget(
      khung(
        BoCucChuTro(
          chiSoChon: 4,
          khiChon: (_) {},
          noiDung: DanhSachHopDong(kho: kho, trongTab: true),
        ),
      ),
    );
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ThanhDieuHuongVaiTro), findsOneWidget);
  });

  testWidgets(
    'Ngày kết thúc bằng hoặc trước ngày bắt đầu không được tiếp tục',
    (t) async {
      final kho = KhoHopDongMau();
      addTearDown(kho.dispose);
      await t.pumpWidget(khung(TaoHopDong(kho: kho)));
      await t.pumpAndSettle();
      await thongTin(t);
      final chonTu = t.widget<ChonNgay>(
        find.byKey(const ValueKey('ngayBatDau')),
      );
      chonTu.khiThayDoi!(DateTime(2028, 2, 1));
      await t.pump();
      for (final den in [DateTime(2028, 2, 1), DateTime(2028, 1, 31)]) {
        t
            .widget<ChonNgay>(find.byKey(const ValueKey('ngayKetThuc')))
            .khiThayDoi!(den);
        await t.pump();
        await nhan(t, 'Tiếp theo');
        expect(
          find.text('Ngày kết thúc phải sau ngày bắt đầu.'),
          findsOneWidget,
        );
        expect(find.text('Điều khoản hợp đồng'), findsNothing);
      }
    },
  );
  testWidgets('Chỉnh sửa từ xem lại giữ dữ liệu và yêu cầu xác nhận lại', (
    t,
  ) async {
    final kho = KhoHopDongMau();
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(TaoHopDong(kho: kho)));
    await t.pumpAndSettle();
    await thongTin(t);
    for (var i = 0; i < 3; i++) {
      await nhan(t, 'Tiếp theo');
    }
    final sua = find.widgetWithText(TextButton, 'Chỉnh sửa').first;
    await t.ensureVisible(sua);
    await t.tap(sua);
    await t.pumpAndSettle();
    expect(find.text('Thông tin cơ bản'), findsOneWidget);
    expect(find.text('P403'), findsOneWidget);
    await nhap(t, 'tienCoc', '500000');
    for (var i = 0; i < 3; i++) {
      await nhan(t, 'Tiếp theo');
    }
    expect(find.text('500.000đ'), findsOneWidget);
    final xacNhan = t.widget<CheckboxListTile>(
      find.byKey(const ValueKey('xacNhan')),
    );
    expect(xacNhan.value, isFalse);
    expect(kho.danhSach.length, 5);
  });
  testWidgets('Bàn phím mở, màn hình 360px và chữ lớn vẫn thấy nút tiếp theo', (
    t,
  ) async {
    t.view.physicalSize = const Size(360, 740);
    t.view.devicePixelRatio = 1;
    t.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.view.resetViewInsets);
    final kho = KhoHopDongMau();
    addTearDown(kho.dispose);
    await t.pumpWidget(khung(TaoHopDong(kho: kho), coChu: 2));
    await t.pumpAndSettle();
    expect(
      find.widgetWithText(NutBam, 'Tiếp theo').hitTestable(),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });
}
