# Quản lý phòng trọ — RoomChain AI

Monorepo modular cho ứng dụng tìm kiếm và quản lý phòng trọ. Mở **thư mục này** trong VS Code.

```text
QUẢN_LÝ _PHÒNG_TRỌ/
├── roomchain_app/       Flutter/Dart — mobile client
├── roomchain_backend/   Spring Boot/Maven/MySQL — API và nghiệp vụ
├── roomchain_ai/        Python/FastAPI — dịch vụ AI
├── roomchain_chain/     Solidity/Hardhat — tiền cọc token thử nghiệm
├── .gitignore
└── README.md
```

## Phạm vi đã tạo

Workspace ban đầu trống và chưa có Git; không có mã nguồn cũ cần di chuyển. Flutter được sinh bằng CLI cho Android/iOS; backend từ Spring Initializr; Hardhat từ CLI với tùy chọn tạo config trống. Repository Git được quản lý tại thư mục gốc, remote: https://github.com/datco06/Quan_Ly_Phong_Tro.git.

Đã có Flutter tối thiểu, backend cấu hình MySQL, FastAPI `/health` và Hardhat local. Chưa triển khai JWT, OCR, gợi ý phòng, ví, token hoặc escrow. Các thư mục nghiệp vụ đã được chuẩn bị; chỉ tạo router, DTO, migration, model, ABI, contract và deploy script khi triển khai phần tương ứng. Các thư mục source trống có `.gitkeep` để được lưu trong Git; cấu trúc dự kiến được ghi ở README mỗi project.

## Chạy riêng

| Project | Môi trường đã chọn | Hướng dẫn |
| --- | --- | --- |
| Flutter | Flutter 3.47.6, Dart 3.13.5 | [roomchain_app](roomchain_app/README.md) |
| Backend | Spring Boot 4.1.1, JDK 25, MySQL 8+ | [roomchain_backend](roomchain_backend/README.md) |
| AI | Python 3.14.1, FastAPI | [roomchain_ai](roomchain_ai/README.md) |
| Blockchain | Node.js 20, Hardhat 2.29.1, Solidity 0.8.28 | [roomchain_chain](roomchain_chain/README.md) |

Mỗi project tự cài dependency và chạy riêng, không import source xuyên project.

## Ranh giới tích hợp

```text
Flutter <-> Spring Boot <-> MySQL
                |
                +------> FastAPI (HTTP)
                +------> Blockchain RPC (đọc/xác minh)
Flutter <-> Ví người dùng <-> Smart Contract
```

- Backend là nguồn tin cậy cho tiền thuê, hóa đơn, công nợ và xác nhận thanh toán VietQR. Frontend không quyết định số tiền cuối cùng.
- AI nhận ảnh hoặc danh sách phòng ứng viên từ backend; không truy cập database nghiệp vụ. OCR trả chỉ số/độ tin cậy, backend tính hóa đơn sau bước kiểm tra chỉ số.
- Smart Commute dự kiến dùng dữ liệu tuyến đường backend cung cấp để xếp hạng theo trọng số, trả lý do gợi ý. Chưa triển khai thuật toán/client định tuyến.
- Ví người dùng ký giao dịch. Không lưu private key/seed phrase. Chỉ token tiền cọc thử nghiệm đưa lên chain; tiền phòng hàng tháng dùng VietQR.
- Escrow tương lai cần xác nhận hai bên, điều khoản chấm dứt trước hạn hợp lệ và đồng thuận quyết toán. Không phân xử tranh chấp; thiếu đồng thuận thì chờ xử lý ngoài ứng dụng, chủ trọ không đơn phương rút cọc.
- ABI công khai sẽ xuất có chọn lọc từ chain sang `roomchain_app/assets/abi/`; metadata công khai lưu ở `roomchain_chain/deployments/`. Chưa có contract nên chưa có ABI/deployment.

## Git và tài nguyên sinh tự động

Commit source, `pubspec.lock`, `package-lock.json` và Maven Wrapper. `.gitignore` loại build/cache, `.dart_tool`, `.venv`, `node_modules`, model/data cục bộ và secrets phổ biến. Không commit ảnh đồng hồ hoặc thông tin người thuê thật. Dùng biến môi trường cho credentials; YAML hiện tại không tự đọc `.env`.

Nguồn: [Flutter CLI](https://docs.flutter.dev/reference/flutter-cli), [Spring Initializr](https://start.spring.io/), [yêu cầu Spring Boot](https://docs.spring.io/spring-boot/system-requirements.html), [khởi tạo Hardhat 2](https://v2.hardhat.org/hardhat-runner/docs/getting-started).

## Kết quả kiểm tra nền tảng

- Cấu trúc gốc: đúng 4 thư mục dự án, mỗi project có manifest và README riêng.
- Flutter: `dart analyze lib` đạt; `flutter analyze` gặp lỗi giao tiếp LSP. Chưa build Android/iOS.
- Backend: Maven Wrapper/JDK 25 chạy `test` thành công, 1 test context với H2. Đã sửa parent version Initializr sinh từ `4.1.1.RELEASE` thành `4.1.1` để Maven Central resolve được. Chưa kiểm chứng kết nối MySQL thật.
- AI: `python -m pytest tests` đạt 1 test HTTP health, có cảnh báo deprecation TestClient/httpx từ dependency.
- Chain: compile thành công (`Nothing to compile`), test chạy với 0 ca; chưa có contract. Npm báo lỗ hổng dependency công cụ, chi tiết ở README chain.
- Các thư mục build/cache/dependency cục bộ được giữ để chạy riêng nhưng bị `.gitignore` loại khỏi Git.
