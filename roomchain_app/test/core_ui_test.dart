import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
import 'package:roomchain_app/dung_chung/demo/trinh_dien_thanh_phan.dart';

Widget host(Widget child, {double scale = 1}) => MaterialApp(
  theme: ChuDeUngDung.sang,
  builder: (context, widget) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: widget!,
  ),
  home: child,
);

void main() {
  test('Định dạng VND và MockVNDC tách biệt, hỗ trợ số âm và số 0', () {
    expect(dinhDangVND(3800000), '3.800.000đ');
    expect(dinhDangMockVNDC(3800000), '3.800.000 MockVNDC');
    expect(dinhDangVND(0), '0đ');
    expect(dinhDangVND(-1250), '-1.250đ');
  });

  test('Ngày Việt Nam giữ nguyên các thành phần thời gian UTC', () {
    final date = DateTime.utc(2026, 11, 5, 23, 7);
    expect(dinhDangNgay(date), '05/11/2026');
    expect(dinhDangKy(date), '11/2026');
    expect(dinhDangNgayGio(date), '05/11/2026 23:07');
    expect(date.isUtc, isTrue);
  });

  test('Validation dữ liệu phổ biến và trường hợp không hợp lệ', () {
    expect(KiemTraDuLieu.email('minhanh@gmail.com'), isNull);
    expect(KiemTraDuLieu.email('sai@'), isNotNull);
    expect(KiemTraDuLieu.soDienThoai('+84901234567'), isNull);
    expect(KiemTraDuLieu.soDienThoai('123'), isNotNull);
    expect(KiemTraDuLieu.batBuoc('  '), isNotNull);
    expect(KiemTraDuLieu.tienKhongAm('-1'), isNotNull);
    expect(KiemTraDuLieu.tienKhongAm('0'), isNull);
  });

  test('Mock hóa đơn, chỉ số và cọc nhất quán với thông số đã chốt', () {
    final bill = DuLieuGia.hoaDon;
    expect(
      bill.danhSachKhoanThu.fold<int>(0, (s, k) => s + k.soTien),
      bill.tongTien,
    );
    expect(bill.tongTien - bill.daThanhToan, bill.congNoConLai);
    expect(DuLieuGia.chiSo.first.soTieuThu, 154);
    expect(DuLieuGia.chiSo.last.soTieuThu, 6);
    expect(DuLieuGia.tienCoc.loaiToken, 'MockVNDC');
    expect(
      DuLieuGia.nguoiThue.copyWith(hoTen: 'Tên mới').id,
      DuLieuGia.nguoiThue.id,
    );
  });

  testWidgets(
    'NutBam hiển thị nhãn, gọi callback và giữ chiều rộng khi loading',
    (tester) async {
      var taps = 0;
      Widget button({bool loading = false, bool disabled = false}) => host(
        Scaffold(
          body: Center(
            child: NutBam(
              nhan: 'Xác nhận',
              rongHet: false,
              dangTai: loading,
              voHieuHoa: disabled,
              khiNhan: () => taps++,
            ),
          ),
        ),
      );
      await tester.pumpWidget(button());
      expect(find.text('Xác nhận'), findsOneWidget);
      final width = tester.getSize(find.byType(TextButton)).width;
      await tester.tap(find.byType(TextButton));
      expect(taps, 1);
      await tester.pumpWidget(button(disabled: true));
      await tester.tap(find.byType(TextButton));
      expect(taps, 1);
      await tester.pumpWidget(button(loading: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.getSize(find.byType(TextButton)).width, width);
      await tester.tap(find.byType(TextButton));
      expect(taps, 1);
    },
  );

  testWidgets('Badge thành công và thất bại dùng đúng nhãn, màu riêng', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const Scaffold(
          body: Column(
            children: [
              NhanTrangThai(trangThai: TrangThaiHienThi.thanhCong),
              NhanTrangThai(trangThai: TrangThaiHienThi.thatBai),
            ],
          ),
        ),
      ),
    );
    expect(
      tester.widget<Text>(find.text('Thành công')).style!.color,
      BangMau.thanhCong,
    );
    expect(
      tester.widget<Text>(find.text('Thất bại')).style!.color,
      BangMau.loi,
    );
  });

  testWidgets('Hóa đơn hiển thị tiền, hạn và đủ năm trạng thái', (
    tester,
  ) async {
    final labels = [
      'Nháp',
      'Chưa thanh toán',
      'Đã thanh toán',
      'Quá hạn',
      'Thanh toán một phần',
    ];
    for (var i = 0; i < TrangThaiHoaDon.values.length; i++) {
      await tester.pumpWidget(
        host(
          Scaffold(
            body: TheHoaDon(
              hoaDon: DuLieuGia.hoaDon.copyWith(
                trangThai: TrangThaiHoaDon.values[i],
              ),
            ),
          ),
        ),
      );
      expect(find.text('5.126.000đ'), findsNWidgets(2));
      expect(find.text('05/11/2026'), findsOneWidget);
      expect(find.text(labels[i]), findsOneWidget);
    }
  });

  testWidgets('ThanhChuyenTab trả đúng index và cập nhật lựa chọn', (
    tester,
  ) async {
    var index = 0;
    await tester.pumpWidget(
      host(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ThanhChuyenTab(
              danhSach: const [CauHinhTab('Điện'), CauHinhTab('Nước')],
              chiSoChon: index,
              khiChon: (v) => setState(() => index = v),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Nước'));
    await tester.pump();
    expect(index, 1);
    final chips = tester
        .widgetList<FilterChip>(find.byType(FilterChip))
        .toList();
    expect(chips[0].selected, isFalse);
    expect(chips[1].selected, isTrue);
  });

  testWidgets(
    'Form hiện lỗi rồi chấp nhận email đúng, không dispose controller bên ngoài',
    (tester) async {
      final key = GlobalKey<FormState>();
      final controller = TextEditingController();
      await tester.pumpWidget(
        host(
          Scaffold(
            body: Form(
              key: key,
              child: ONhapLieu(
                nhan: 'Email',
                controller: controller,
                kiemTra: KiemTraDuLieu.email,
              ),
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Email không hợp lệ'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'minhanh@gmail.com');
      expect(key.currentState!.validate(), isTrue);
      await tester.pumpWidget(const SizedBox());
      controller.text = 'Vẫn sử dụng được';
      controller.dispose();
    },
  );

  testWidgets('Search cập nhật và xóa nội dung bằng callback', (tester) async {
    String? value;
    await tester.pumpWidget(
      host(Scaffold(body: OTimKiem(khiTimKiem: (v) => value = v))),
    );
    await tester.enterText(find.byType(TextField), 'Hà Đông');
    await tester.pump();
    expect(value, 'Hà Đông');
    await tester.tap(find.byTooltip('Xóa tìm kiếm'));
    await tester.pump();
    expect(value, '');
    expect(find.byTooltip('Xóa tìm kiếm'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dialog trả kết quả xác nhận và hủy', (tester) async {
    bool? result;
    await tester.pumpWidget(
      host(
        Scaffold(
          body: Builder(
            builder: (context) => NutBam(
              nhan: 'Mở',
              khiNhan: () async {
                result = await HopThoaiXacNhan.hienThi(
                  context,
                  tieuDe: 'Xác nhận mẫu',
                  noiDung: 'Nội dung mẫu',
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Mở'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    await tester.tap(find.text('Mở'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  for (final landlord in [false, true]) {
    testWidgets(
      'Navigation ${landlord ? 'chủ trọ' : 'người thuê'}: 5 tab trên màn hình nhỏ',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var index = 0;
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, setState) => landlord
                  ? BoCucChuTro(
                      noiDung: const Center(child: Text('Nội dung')),
                      chiSoChon: index,
                      khiChon: (v) => setState(() => index = v),
                    )
                  : BoCucNguoiThue(
                      noiDung: const Center(child: Text('Nội dung')),
                      chiSoChon: index,
                      khiChon: (v) => setState(() => index = v),
                    ),
            ),
            scale: 2,
          ),
        );
        await tester.tap(find.text(landlord ? 'Thêm' : 'Tài khoản'));
        await tester.pump();
        expect(index, 4);
        expect(tester.takeException(), isNull);
        expect(
          tester.getBottomLeft(find.text('Nội dung')).dy,
          lessThan(tester.getTopLeft(find.byType(ThanhDieuHuongVaiTro)).dy),
        );
      },
    );
  }

  testWidgets('Auth layout cuộn được, hành động cuối trang nằm trên bàn phím', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      host(
        BoCucXacThuc(
          header: const Text('Đăng ký'),
          noiDung: Column(
            children: List.generate(
              8,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ONhapLieu(nhan: 'Trường $i'),
              ),
            ),
          ),
          hanhDongDuoi: NutDuoiManHinh(
            nutChinh: NutBam(nhan: 'Hoàn tất', khiNhan: () {}),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getBottomLeft(find.text('Hoàn tất')).dy,
      lessThanOrEqualTo(328),
    );
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ảnh lỗi có fallback, grid chặn thêm khi đạt giới hạn', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        Scaffold(
          body: LuoiHinhAnh(
            danhSachAnh: const ['missing-image'],
            toiDa: 1,
            khiThem: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Card chỉ số dùng số tiêu thụ được truyền vào khi đồng hồ reset',
    (tester) async {
      await tester.pumpWidget(
        host(
          Scaffold(
            body: TheChiSo(
              chiSo: DuLieuGia.chiSo.first.copyWith(
                chiSoCu: 9999,
                chiSoMoi: 10,
                soTieuThu: 25,
              ),
            ),
          ),
        ),
      );
      expect(find.text('25 kWh'), findsOneWidget);
      expect(find.text('-9989 kWh'), findsNothing);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'Toàn bộ demo render ở 320dp, text scale $scale, không overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(host(const TrinhDienThanhPhan(), scale: scale));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        final scroll = find.byType(SingleChildScrollView).first;
        // Traverse every section, including the two navigation bars and bottom actions.
        for (var i = 0; i < 45; i++) {
          await tester.drag(scroll, const Offset(0, -400));
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
        }
        expect(find.text('19 · Bottom action'), findsOneWidget);
        await tester.ensureVisible(find.text('Lưu mẫu'));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
