# RoomChain AI — hướng dẫn Core UI

Core UI cung cấp token giao diện, theme Material 3 sáng, component nhận dữ liệu/callback, layout theo vai trò, model và mock data thống nhất. Hướng phụ thuộc luôn là **Feature → Core**. Core không import màn hình nghiệp vụ, gọi API, upload ảnh hoặc thực hiện giao dịch.

## Bắt đầu và mở demo

Môi trường đã kiểm tra: Flutter 3.47.6, Dart 3.13.5. Không thêm dependency, không sửa pubspec hoặc main.dart. App hiện có vẫn khởi chạy như trước; theme mới chỉ được gắn vào entrypoint demo.

```bash
cd roomchain_app
flutter pub get
flutter run -t lib/ung_dung/main_demo.dart
```

Chọn thiết bị Flutter đang kết nối khi được hỏi. Demo độc lập có 19 mục, dùng mock data và hỗ trợ tương tác loading, tìm kiếm, validation, chip, dropdown, ngày, dialog, yêu thích, ảnh placeholder và hai thanh navigation. Nút ảnh chỉ thêm placeholder để kiểm tra fallback; không mở camera hay truy cập thư viện ảnh.

## Demo web localhost dạng điện thoại

Project có web bootstrap tối thiểu trong `web/index.html`. Chạy:

```bash
flutter run -d chrome -t lib/ung_dung/main_demo.dart --web-hostname localhost --web-port 8080
```

Mở `http://localhost:8080`. Nếu không muốn Flutter tự mở Chrome, dùng `-d web-server` thay `-d chrome`, rồi tự mở URL trên trình duyệt.

Entrypoint demo bọc Navigator trong `KhungDienThoaiDemo` trên web: khung rộng tối đa 406px, viewport nội dung 390px, chiều cao thích ứng cửa sổ, bo góc và viền điện thoại. Dialog vẫn nằm trong khung. Khi cửa sổ hẹp hoặc thấp hơn 480px, giao diện dùng toàn bộ viewport để dễ thao tác. Android/iOS dùng demo bình thường. Không cần emulator cho web; app root hiện có vẫn giữ nguyên.

## Import

```dart
import 'package:flutter/material.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';
```

Có thể import trực tiếp từng file để giới hạn phạm vi. Các file `mau_sac/bang_mau.dart`, `mau_sac/kieu_chu.dart`, `thanh_phan/nut_bam.dart`, `o_nhap_lieu.dart`, `hop_thoai_xac_nhan.dart`, `thanh_dieu_huong.dart`, `the_thong_tin.dart` là export tương thích cho đường dẫn đã có, không phải implementation thứ hai.

## Theme và token

Khi nhóm tích hợp app root, cấu hình `theme: ChuDeUngDung.sang` trên MaterialApp hiện có. Không tạo thêm MaterialApp trong từng feature. Nhiệm vụ Core chưa sửa app root hoặc router.

```dart
MaterialApp(
  theme: ChuDeUngDung.sang,
  home: const TrinhDienThanhPhan(), // import dung_chung/demo/trinh_dien_thanh_phan.dart
);
```

Dùng `BangMau`, `KieuChu`, `KhoangCach`, `KichThuoc` thay cho định nghĩa màu/style riêng. Nền #F7FAF9, primary #087F74, card trắng, border nhẹ, radius card 14, nút 12. Font hiện là fallback hệ thống hỗ trợ tiếng Việt; chưa có asset Be Vietnam Pro. Không khai báo font/ảnh chưa tồn tại. Các nhãn/ngày đã định dạng tiếng Việt; localization đầy đủ của lịch Material có thể bổ sung qua flutter_localizations trong giai đoạn sau.

## Button và vùng hành động

```dart
NutBam(
  nhan: 'Xác nhận',
  bieuTuong: Icons.check,
  kieu: KieuNut.chinh,
  khiNhan: () {},
);
```

`KieuNut` có `chinh`, `phu`, `nhat`, `nguyHiem`, `vanBan`. Đặt `dangTai: true` để hiện spinner và chặn callback; `voHieuHoa: true` cũng chặn callback. Loading giữ kích thước nhãn, tránh nút co chiều rộng. `rongHet: false` dùng trong Row/Dialog, mặc định nút rộng theo cha. Các kích thước là tối thiểu, nút được tăng chiều cao khi chữ xuống dòng.

`NutBieuTuong` yêu cầu `bieuTuong` và `goiY` cho tooltip. Dùng `NutDuoiManHinh` cho một hoặc hai nút. Truyền vùng này vào `KhungTrang.hanhDongDuoi` hoặc `BoCucXacThuc.hanhDongDuoi` để Scaffold thu nội dung khi mở bàn phím; SafeArea giữ khoảng trống hệ thống. Không đặt vùng hành động trong Stack có tọa độ cố định.

```dart
KhungTrang(
  tieuDe: 'Tiêu đề',
  noiDung: const Text('Nội dung do feature cung cấp'),
  hanhDongDuoi: NutDuoiManHinh(
    nutPhu: NutBam(nhan: 'Hủy', kieu: KieuNut.phu, khiNhan: () {}),
    nutChinh: NutBam(nhan: 'Lưu', khiNhan: () {}),
  ),
);
```

## Input và validation

Ví dụ một form tự sở hữu controller và dispose đúng vòng đời:

```dart
class FormEmailMau extends StatefulWidget {
  const FormEmailMau({super.key});
  @override
  State<FormEmailMau> createState() => _FormEmailMauState();
}

class _FormEmailMauState extends State<FormEmailMau> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: Column(children: [
      ONhapLieu(
        nhan: 'Email', batBuoc: true, controller: email,
        kieuBanPhim: TextInputType.emailAddress,
        kiemTra: KiemTraDuLieu.email,
      ),
      NutBam(nhan: 'Kiểm tra', khiNhan: () { form.currentState!.validate(); }),
    ]),
  );
}
```

`batBuoc` hiển thị dấu *, validator do caller truyền. `ONhapLieu` hỗ trợ `goiY`, `choPhep`, `chiDoc`, `bieuTuongDau/Cuoi`, `khiThayDoi`, `soDong`, `anNoiDung`, `loi`. Không dispose controller bên ngoài.

`OTimKiem` nhận controller tùy chọn, tự sở hữu/dispose controller khi không truyền; gọi `khiTimKiem` khi nhập, submit và xóa. `OChon<T>` dùng `List<LuaChon<T>>` có giá trị duy nhất; màn hình giữ `giaTri` và cập nhật khi nhận callback. `ChonNgay` dùng `giaTri`, `ngayNhoNhat`, `ngayLonNhat`, `khiThayDoi`. Giới hạn ngày phải hợp lệ; ngày hiển thị và ngày chọn là ngày lịch, không tự đổi múi giờ.

## Card và badge

```dart
ThePhongTro(
  phong: DuLieuGia.phongTro.first,
  kieu: KieuThePhong.ngang, // hoặc doc
  khiNhan: () {},
  khiYeuThich: () {},
  yeuThich: false, // caller giữ state
);

TheHoaDon(
  hoaDon: DuLieuGia.hoaDon,
  tenNguoiThue: DuLieuGia.nguoiThue.hoTen,
  hienCongNo: true,
  khiNhan: () {},
);

const NhanTrangThai(trangThai: TrangThaiHienThi.choDuyet);
```

Card phòng tự chuyển sang dọc khi không đủ chiều ngang hoặc chữ lớn. Ảnh nhận URL HTTP(S) hoặc đường dẫn asset đã đăng ký; ảnh trống/lỗi có fallback. Không cung cấp file path camera trực tiếp cho `AnhThuNho`; tầng tích hợp sau này có thể mở rộng qua ImageProvider.

Các card còn lại: `TheKhuTro`, `TheThongKe`, `TheChiSo`, `TheHopDong`, `TheGiaoDich`. Card hợp đồng nhận `maPhong` và `tenNguoiThue` bên ngoài vì model giữ ID. Card giao dịch bắt buộc chỉ rõ `DonViTien`, không suy ra VND từ token. Card chỉ số hiển thị đúng `soTieuThu` được truyền, kể cả khi đồng hồ reset; không tính lại hiệu chỉ số.

Badge có tám trạng thái; truyền thêm `nhan` để đổi chữ mà giữ ý nghĩa màu. Hóa đơn tự ánh xạ đủ năm enum: nháp, chưa thanh toán, đã thanh toán, quá hạn, thanh toán một phần. Không tự gán quá hạn bằng DateTime.now trong card; trạng thái do nguồn dữ liệu quyết định.

## Layout người thuê và chủ trọ

Mỗi layout nhận **một nội dung** và index do màn hình cha giữ; layout không tạo route hoặc tự load màn hình. Không lồng thêm Scaffold không cần thiết trong nội dung. Muốn giữ state nhiều trang, caller có thể truyền IndexedStack.

```dart
BoCucNguoiThue(
  chiSoChon: 0,
  khiChon: (index) { debugPrint('Tenant tab: $index'); },
  noiDung: const Center(child: Text('Nội dung của feature')),
);

BoCucChuTro(
  chiSoChon: 0,
  khiChon: (index) { debugPrint('Landlord tab: $index'); },
  noiDung: const Center(child: Text('Nội dung của feature')),
);
```

Trong StatefulWidget, gọi `setState(() => chiSo = index)` trong callback. Tenant có Khám phá / Gợi ý AI / Phòng của tôi / Thông báo / Tài khoản. Landlord có Tổng quan / Khu trọ / Phòng / Hóa đơn / Thêm. Tab Thêm là callback index 4; feature quyết định mở menu Công nợ, Hợp đồng, Sửa chữa, Thống kê, Tài khoản.

`ThanhDieuHuongVaiTro` là thanh navigation có cấu hình `MucDieuHuong`, dùng outline icon, nhãn tiếng Việt, selected semantics và SafeArea. Có thể dùng độc lập như demo.

`KhungTrang` hỗ trợ appBar tùy chỉnh, tiêu đề, quay lại, actions, màu, padding, scroll, bottom action. Nếu `cuon: false`, nội dung chịu trách nhiệm cuộn. `BoCucXacThuc` có header tùy chọn và form cuộn tránh bàn phím.

## Widget hiển thị và ảnh

- `ChipLoc`: selected và callback bool do caller giữ.
- `ThanhChuyenTab`: danh sách `CauHinhTab`, `chiSoChon`, callback index; có thể cuộn ngang.
- `DongThongTin`, `DongTien`: cặp nhãn/giá trị, xuống dòng khi cần.
- `DongThoiGian`: `List<BuocThoiGian>`, trạng thái hoàn thành/hiện tại/chưa đến.
- `ThongBaoNoiDung`: thông tin/thành công/cảnh báo/lỗi.
- `TrangThaiRong`: icon hoặc minh họa, tiêu đề/mô tả và hành động tùy chọn.
- `HienThiDangTai`: nhỏ/toàn trang/skeleton tĩnh nhẹ.
- `ChonAnh`: viền nét đứt, số ảnh và callback; chặn khi đạt giới hạn.
- `LuoiHinhAnh`: grid thích ứng, thêm/xóa/loading/fallback; `toiDa` giới hạn số thumbnail, caller chịu trách nhiệm giới hạn nguồn dữ liệu.
- `HopThoaiXacNhan.hienThi`: trả `Future<bool?>`; true xác nhận, false hủy, null đóng ngoài/back. Chỉ gọi nghiệp vụ khi kết quả là true. Constructor riêng cho phép tùy nhãn và callback xác nhận.

## Model, mock data và formatter

`NguoiDung`, `PhongTro`, `KhuTro`, `HopDong`, `HoaDon`, `KhoanThuHoaDon`, `ChiSoDienNuoc`, `TienCoc` không gọi API, có trường final và copyWith khi phù hợp. Danh sách trong model do caller cung cấp; ưu tiên const hoặc List.unmodifiable khi dựng dữ liệu. Enum vai trò Dart dùng `VaiTro.tenant/landlord`, tương ứng TENANT/LANDLORD khi đội tích hợp DTO sau này. Các trạng thái có enum tách theo miền dữ liệu.

```dart
final phong = DuLieuGia.phongTro.first;
final hoaDon = DuLieuGia.hoaDon;
final nguoiThue = DuLieuGia.nguoiThue;
final soTien = dinhDangVND(phong.giaThue); // 2.500.000đ
final coc = dinhDangMockVNDC(DuLieuGia.tienCoc.soToken); // 3.800.000 MockVNDC
final ngay = dinhDangNgay(hoaDon.ngayDenHan); // 05/11/2026
```

Nguồn mock duy nhất là `DuLieuGia`. Tổng hóa đơn 5.126.000đ bằng tổng sáu khoản; chỉ số mẫu điện 5432→5586, 154 kWh và nước 158→164, 6 m³ được ưu tiên theo yêu cầu dù ảnh hiển thị số khác. Khoản điện/nước hóa đơn là số tiền mock cố định; không suy ra đơn giá từ hai bộ dữ liệu này. Các tên, địa chỉ và giá phòng thống nhất theo yêu cầu; không trộn các biến thể Hà Nội/Thủ Đức trong storyboard.

VND lưu số nguyên đồng. `TienCoc.soToken` là số token nguyên dùng riêng cho UI mock. Khi tích hợp blockchain phải thiết kế amount nguyên nhỏ nhất với decimals; không dùng field mock này như đơn vị giao dịch thật. Mọi cọc/giao dịch demo đều ghi rõ dữ liệu mẫu.

Formatter ngày chỉ đọc các trường ngày/giờ đầu vào, không gọi toLocal/toUtc. Tầng dữ liệu phải quyết định timezone trước khi hiển thị. Không cắt hoặc làm tròn số tiền âm trong formatter.

## Chia việc cho ba developer

| Nhóm | Cách sử dụng Core |
|---|---|
| Dev 1 — người thuê | Dùng BoCucNguoiThue, ThePhongTro, bộ input/filter, trạng thái rỗng và timeline; cung cấp callback điều hướng/feature. |
| Dev 2 — chủ trọ | Dùng BoCucChuTro, TheKhuTro, TheThongKe, TheHoaDon, TheChiSo, form và dialog; caller tính nghiệp vụ và truyền kết quả. |
| Dev 3 — tài khoản, hợp đồng, thanh toán | Dùng BoCucXacThuc, KhungTrang, TheHopDong, TheGiaoDich, DongTien và formatter; tách VND/MockVNDC. |

Trước khi thêm Button/Input/Card mới, kiểm tra Core và mở rộng API đang có khi khác biệt chỉ là cấu hình. Không copy component sang feature, không tạo theme riêng. Không đưa dữ liệu mẫu, API, router hoặc màn hình feature vào Core. Mọi thay đổi API cần phối hợp cả ba nhóm và chạy test.

## Kiểm tra và phần tích hợp sau này

```bash
flutter pub get
flutter analyze
flutter test
```

Test nằm trong `test/core_ui_test.dart`: formatter, validator, tính nhất quán mock, button/loading/disabled, badge màu, năm trạng thái hóa đơn, tab, form/controller, tìm kiếm, dialog, navigation, keyboard, ảnh lỗi và chỉ số reset. Demo được render đầy đủ ở 320×568 với text scale 1.0 và 2.0 để phát hiện overflow.

Phần bổ sung sau này: font Be Vietnam Pro hợp lệ và localization đầy đủ, asset ảnh thật, backend/DTO, router theo feature, camera/upload, AI, ví/blockchain và thanh toán. Core hiện chỉ cung cấp UI và callback. Chưa kiểm tra trực tiếp trên thiết bị Android/iOS thật; widget test xác minh layout và tương tác trong môi trường Flutter test.
