# Báo cáo bàn giao Core UI RoomChain AI

Branch: `fe-core`. Workspace sạch trước khi thực hiện. Flutter 3.47.6 / Dart 3.13.5. Đã xem bốn storyboard đính kèm; triển khai token màu đúng thông số yêu cầu và component có callback, không gọi dịch vụ ngoài.

## Cập nhật: demo web localhost dạng điện thoại

Theo yêu cầu bổ sung, đã thêm `web/index.html`, `lib/dung_chung/demo/khung_dien_thoai_demo.dart` và `test/demo_web_test.dart`; chỉnh entrypoint demo và hướng dẫn. Flutter tự thêm `web/**` vào danh sách loại trừ thư mục nền tảng trong `analysis_options.yaml`. Không thêm dependency hoặc sửa main.dart.

Chạy `flutter run -d chrome -t lib/ung_dung/main_demo.dart --web-hostname localhost --web-port 8080`, rồi mở http://localhost:8080. Có thể thay chrome bằng web-server để tự mở trình duyệt.

Web desktop có viewport điện thoại 390px, viền bo góc và chiều cao thích ứng; toàn bộ Navigator/dialog nằm trong viewport. Cửa sổ nhỏ dùng toàn bộ diện tích. Mobile giữ giao diện demo cũ.

Kiểm tra bổ sung: `flutter build web -t lib/ung_dung/main_demo.dart` thành công; `dart analyze lib/dung_chung/demo lib/ung_dung/main_demo.dart test/demo_web_test.dart` không có lỗi; toàn bộ **21/21 test** thành công. Ba test mới kiểm tra viewport desktop/mobile/cửa sổ thấp và ranh giới dialog. Build có cảnh báo tham chiếu font CupertinoIcons từ SDK nhưng project chỉ khai báo MaterialIcons; chưa thêm package không cần thiết và build vẫn thành công.

Phần bên dưới là báo cáo và danh sách file của giai đoạn Core ban đầu, trước cập nhật web này.

## Kết quả

- Theme Material 3 sáng, palette, typography, spacing và kích thước tập trung.
- Button đủ năm kiểu, loading/disabled; icon button và vùng hành động một/hai nút.
- Form field, tìm kiếm có xóa, dropdown generic, chọn ngày có giới hạn.
- Bảy card: phòng, khu trọ, thống kê, hóa đơn, chỉ số, hợp đồng, giao dịch.
- Badge, chip, tab, dòng thông tin/tiền, timeline, inline notice, empty và loading/skeleton.
- Vùng chọn ảnh nét đứt, grid thêm/xóa/loading/fallback; không camera/upload thật.
- Dialog trả kết quả, layout trang, người thuê, chủ trọ, xác thực; navigation 5 tab mỗi vai trò.
- Bảy model chính và KhoanThuHoaDon, mock thống nhất, formatter/validator.
- Demo độc lập 19 mục và tài liệu sử dụng cho ba developer.

## Kiểm tra thực tế

| Kiểm tra | Kết quả |
|---|---|
| flutter pub get | Thành công tại workspace gốc, không thêm hoặc đổi dependency. |
| dart analyze lib/dung_chung lib/ung_dung/main_demo.dart test | No issues found tại workspace gốc. |
| flutter analyze tại workspace gốc | SDK analysis server lỗi FormatException ở thông điệp khởi tạo LSP với đường dẫn Unicode. |
| flutter analyze tại bản sao ASCII | No issues found; exit 0. Bản sao tại /private/tmp/roomchain_core_check_800djlh9 có lib, test, pubspec.yaml, pubspec.lock và analysis_options.yaml trùng nội dung bản bàn giao. |
| flutter test tại workspace gốc | 18/18 tests passed; exit 0. |
| git diff --check | Thành công. |
| Core import chuc_nang | Không có. |

Bản sao ASCII giúp kiểm tra mã nguồn mà không phải đổi tên workspace hoặc chỉnh Flutter SDK. Chưa xác minh nguyên nhân lỗi SDK ngoài khác biệt đường dẫn, chưa chạy UI trên thiết bị Android/iOS thật. Layout đã kiểm tra bằng widget test ở 320×568 và text scale 100%/200%, bao gồm toàn bộ demo và bàn phím.

## Chạy demo

```bash
cd roomchain_app
flutter run -t lib/ung_dung/main_demo.dart
```

Không thay đổi main.dart, app/app.dart, router hoặc màn hình khởi động hiện có. Theme chưa tự gắn vào app root, chỉ dùng trong demo; nhóm tích hợp sau này đặt `theme: ChuDeUngDung.sang` trên MaterialApp đang có.

## Bắt đầu cho ba developer

Import `package:roomchain_app/dung_chung/roomchain_ui.dart`. Dev 1 dùng BoCucNguoiThue và card/filter phòng; Dev 2 dùng BoCucChuTro, card khu trọ/thống kê/hóa đơn/chỉ số; Dev 3 dùng BoCucXacThuc, card hợp đồng/giao dịch và formatter. Đọc [hướng dẫn và ví dụ](huong_dan_core_ui.md). Các feature giữ state, điều hướng và xử lý nghiệp vụ qua callback.

## Cấu hình và giới hạn

Không thêm package, không sửa pubspec/lockfile hay cấu hình nền tảng. Font fallback hệ thống hỗ trợ tiếng Việt; Be Vietnam Pro và ảnh thật cần asset hợp lệ trước khi cấu hình. Localization đầy đủ của lịch Material, API/DTO, router, AI, camera/upload, ví/blockchain và thanh toán thuộc giai đoạn tích hợp sau.

Dữ liệu mẫu theo yêu cầu đã chốt: giá phòng 2,5/2,8/2,6/3,8 triệu; hóa đơn 5.126.000đ; điện 154 kWh, nước 6 m³. Chỉ số này khác trong storyboard và không dùng để suy ra đơn giá hóa đơn. MockVNDC có formatter riêng; amount blockchain thật phải thiết kế theo đơn vị nhỏ nhất và decimals.

Không chỉnh file nghiệp vụ, không commit, merge hoặc push.

## Cây thư mục thực tế của các khu vực liên quan

```text
roomchain_app/
lib/dung_chung/
    ├── bo_cuc/
    │   ├── bo_cuc_chu_tro.dart
    │   ├── bo_cuc_nguoi_thue.dart
    │   ├── bo_cuc_xac_thuc.dart
    │   ├── khung_trang.dart
    │   └── thanh_dieu_huong_vai_tro.dart
    ├── cau_hinh/
    │   └── cau_hinh_ung_dung.dart
    ├── demo/
    │   └── trinh_dien_thanh_phan.dart
    ├── du_lieu_mau/
    │   └── du_lieu_gia.dart
    ├── giao_dien/
    │   ├── bang_mau.dart
    │   ├── chu_de_ung_dung.dart
    │   ├── khoang_cach.dart
    │   ├── kich_thuoc.dart
    │   └── kieu_chu.dart
    ├── mau_sac/
    │   ├── bang_mau.dart
    │   └── kieu_chu.dart
    ├── mo_hinh/
    │   ├── chi_so_dien_nuoc.dart
    │   ├── hoa_don.dart
    │   ├── hop_dong.dart
    │   ├── khu_tro.dart
    │   ├── nguoi_dung.dart
    │   ├── phong_tro.dart
    │   └── tien_coc.dart
    ├── thanh_phan/
    │   ├── hien_thi/
    │   │   ├── chip_loc.dart
    │   │   ├── dong_thoi_gian.dart
    │   │   ├── dong_thong_tin.dart
    │   │   ├── dong_tien.dart
    │   │   ├── hien_thi_dang_tai.dart
    │   │   ├── nhan_trang_thai.dart
    │   │   ├── thanh_chuyen_tab.dart
    │   │   ├── thong_bao_noi_dung.dart
    │   │   └── trang_thai_rong.dart
    │   ├── hinh_anh/
    │   │   ├── anh_thu_nho.dart
    │   │   ├── chon_anh.dart
    │   │   └── luoi_hinh_anh.dart
    │   ├── hop_thoai/
    │   │   └── hop_thoai_xac_nhan.dart
    │   ├── nut_bam/
    │   │   ├── nut_bam.dart
    │   │   ├── nut_bieu_tuong.dart
    │   │   └── nut_duoi_man_hinh.dart
    │   ├── o_nhap/
    │   │   ├── chon_ngay.dart
    │   │   ├── o_chon.dart
    │   │   ├── o_nhap_lieu.dart
    │   │   └── o_tim_kiem.dart
    │   ├── the_thong_tin/
    │   │   ├── khung_the.dart
    │   │   ├── the_chi_so.dart
    │   │   ├── the_giao_dich.dart
    │   │   ├── the_hoa_don.dart
    │   │   ├── the_hop_dong.dart
    │   │   ├── the_khu_tro.dart
    │   │   ├── the_phong_tro.dart
    │   │   └── the_thong_ke.dart
    │   ├── hop_thoai_xac_nhan.dart
    │   ├── nut_bam.dart
    │   ├── o_nhap_lieu.dart
    │   ├── thanh_dieu_huong.dart
    │   └── the_thong_tin.dart
    ├── tien_ich/
    │   ├── dinh_dang_ngay.dart
    │   ├── dinh_dang_tien.dart
    │   └── kiem_tra_du_lieu.dart
    └── roomchain_ui.dart
lib/ung_dung/
    ├── dieu_huong.dart
    ├── main_demo.dart
    └── ung_dung.dart
test/
    └── core_ui_test.dart
docs/
    ├── bao_cao_core_ui.md
    └── huong_dan_core_ui.md
```

## File mới (47)

- `roomchain_app/docs/bao_cao_core_ui.md`
- `roomchain_app/docs/huong_dan_core_ui.md`
- `roomchain_app/lib/dung_chung/bo_cuc/bo_cuc_chu_tro.dart`
- `roomchain_app/lib/dung_chung/bo_cuc/bo_cuc_nguoi_thue.dart`
- `roomchain_app/lib/dung_chung/bo_cuc/bo_cuc_xac_thuc.dart`
- `roomchain_app/lib/dung_chung/bo_cuc/khung_trang.dart`
- `roomchain_app/lib/dung_chung/bo_cuc/thanh_dieu_huong_vai_tro.dart`
- `roomchain_app/lib/dung_chung/demo/trinh_dien_thanh_phan.dart`
- `roomchain_app/lib/dung_chung/giao_dien/bang_mau.dart`
- `roomchain_app/lib/dung_chung/giao_dien/khoang_cach.dart`
- `roomchain_app/lib/dung_chung/giao_dien/kich_thuoc.dart`
- `roomchain_app/lib/dung_chung/giao_dien/kieu_chu.dart`
- `roomchain_app/lib/dung_chung/mo_hinh/khu_tro.dart`
- `roomchain_app/lib/dung_chung/roomchain_ui.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hien_thi/chip_loc.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hien_thi/dong_thoi_gian.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hien_thi/dong_thong_tin.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hien_thi/dong_tien.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hien_thi/hien_thi_dang_tai.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hien_thi/nhan_trang_thai.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hien_thi/thanh_chuyen_tab.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hien_thi/thong_bao_noi_dung.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hien_thi/trang_thai_rong.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hinh_anh/anh_thu_nho.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hinh_anh/chon_anh.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hinh_anh/luoi_hinh_anh.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hop_thoai/hop_thoai_xac_nhan.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/nut_bam/nut_bam.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/nut_bam/nut_bieu_tuong.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/nut_bam/nut_duoi_man_hinh.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/o_nhap/chon_ngay.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/o_nhap/o_chon.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/o_nhap/o_nhap_lieu.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/o_nhap/o_tim_kiem.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/the_thong_tin/khung_the.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/the_thong_tin/the_chi_so.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/the_thong_tin/the_giao_dich.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/the_thong_tin/the_hoa_don.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/the_thong_tin/the_hop_dong.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/the_thong_tin/the_khu_tro.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/the_thong_tin/the_phong_tro.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/the_thong_tin/the_thong_ke.dart`
- `roomchain_app/lib/dung_chung/tien_ich/dinh_dang_ngay.dart`
- `roomchain_app/lib/dung_chung/tien_ich/dinh_dang_tien.dart`
- `roomchain_app/lib/dung_chung/tien_ich/kiem_tra_du_lieu.dart`
- `roomchain_app/lib/ung_dung/main_demo.dart`
- `roomchain_app/test/core_ui_test.dart`

## File có sẵn đã chỉnh (15)

- `roomchain_app/lib/dung_chung/du_lieu_mau/du_lieu_gia.dart`
- `roomchain_app/lib/dung_chung/giao_dien/chu_de_ung_dung.dart`
- `roomchain_app/lib/dung_chung/mau_sac/bang_mau.dart`
- `roomchain_app/lib/dung_chung/mau_sac/kieu_chu.dart`
- `roomchain_app/lib/dung_chung/mo_hinh/chi_so_dien_nuoc.dart`
- `roomchain_app/lib/dung_chung/mo_hinh/hoa_don.dart`
- `roomchain_app/lib/dung_chung/mo_hinh/hop_dong.dart`
- `roomchain_app/lib/dung_chung/mo_hinh/nguoi_dung.dart`
- `roomchain_app/lib/dung_chung/mo_hinh/phong_tro.dart`
- `roomchain_app/lib/dung_chung/mo_hinh/tien_coc.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/hop_thoai_xac_nhan.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/nut_bam.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/o_nhap_lieu.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/thanh_dieu_huong.dart`
- `roomchain_app/lib/dung_chung/thanh_phan/the_thong_tin.dart`
