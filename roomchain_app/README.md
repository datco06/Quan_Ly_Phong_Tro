# roomchain_app

Flutter/Dart mobile client, sinh bằng Flutter CLI cho Android/iOS. `lib/main.dart` chạy `lib/app/app.dart`; màn hình hiện tại chỉ hiển thị tên ứng dụng.

## Chạy và kiểm tra

```sh
flutter pub get
flutter analyze
flutter devices
flutter run
```

Dùng Flutter 3.47.6/Dart 3.13.5 tương thích `pubspec.yaml`. Android cần Android SDK; iOS cần Xcode và môi trường iOS phù hợp. Phân tích Dart không thay thế build thiết bị.

## Cấu trúc dự kiến

- `app/`: app entry; thêm `router.dart` khi có điều hướng.
- `core/{api,config,constants,theme,utils,widgets}`: dùng chung phía client.
- `features/auth`, `tenant/{discovery,recommendation,my_room,meter_reading}`, `landlord/{dashboard,properties,rooms}`.
- `features/{contracts,deposits,invoices,payments,notifications,profile}`.
- `assets/{images,icons,abi}`: khai báo pubspec khi có asset thật.
- `test/`: bổ sung khi có hành vi cần kiểm chứng. Module chưa triển khai hiện để trống.

Android ID ban đầu: `com.roomchain.roomchain_app`; iOS ID: `com.roomchain.roomchainApp`, theo CLI. Không có ID cũ bị đổi.

Kiểm tra thực tế: `dart analyze lib` đạt, không phát hiện lỗi. `flutter analyze` gặp lỗi giao tiếp LSP (`FormatException` trong analysis server) ở môi trường hiện tại; chưa xác định nguyên nhân, chưa build Android/iOS.

Gọi REST API Spring Boot, không gọi MySQL/AI trực tiếp. Khi thêm API client, cấu hình URL backend phù hợp emulator/thiết bị; hiện chưa có HTTP client hoặc biến API được đọc. Giao dịch cọc qua ví người dùng ký; không lưu private key/seed phrase. Frontend không là nguồn tin cậy của số tiền cuối cùng. ABI sẽ nhận từ project chain khi có contract.
