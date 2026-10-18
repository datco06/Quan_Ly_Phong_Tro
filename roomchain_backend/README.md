# roomchain_backend

REST backend Spring Boot 4.1.1, Maven, JDK 25; sinh từ Spring Initializr với Web MVC, Validation, Actuator, JPA và MySQL. Package `com.roomchain`, entry point `RoomChainApplication`.

## Chạy

Cài JDK 25, MySQL 8+. Tạo database bằng công cụ quản trị MySQL:

```sql
CREATE DATABASE roomchain CHARACTER SET utf8mb4;
```

Tạo tài khoản `roomchain` và cấp quyền phù hợp cho database. Từ thư mục project (macOS; hệ khác chọn JAVA_HOME tương ứng):

```sh
export JAVA_HOME="$(/usr/libexec/java_home -v 25)"
export DB_URL='jdbc:mysql://localhost:3306/roomchain'
export DB_USERNAME='roomchain'
read -s DB_PASSWORD
export DB_PASSWORD
./mvnw spring-boot:run
```

`read` chờ bạn nhập mật khẩu rồi Enter. Windows dùng `mvnw.cmd`. MySQL phải đang chạy và credentials hợp lệ. Endpoint kiểm tra: `http://localhost:8080/actuator/health`.

`PORT` mặc định 8080; `AI_BASE_URL` mặc định `http://localhost:8000`; `BLOCKCHAIN_RPC_URL` mặc định `http://127.0.0.1:8545`. Hai URL mới được khai báo, chưa có client HTTP/web3j. Spring Boot hiện không tự đọc `.env`.

## Kiểm tra độc lập

```sh
./mvnw test
./mvnw package
```

Test context dùng profile `test` với H2 chỉ trong test scope, không cần MySQL. Test này kiểm tra khởi tạo Spring/JPA, chưa xác minh MySQL thật. Runtime dùng `ddl-auto: validate`; chưa có entity/migration và không sửa schema. `db/migration/` dành cho bước sau; chưa cài Flyway.

## Module dự kiến

Package theo nghiệp vụ: `auth`, `user`, `property`, `room`, `rental`, `contract`, `deposit`, `meter`, `invoice`, `payment`, `notification`. Hạ tầng: `config`, `security`, `ai`, `blockchain`. Khi triển khai, mỗi module chứa controller/service/repository/entity/dto/mapper cần thiết, không tạo lớp rỗng trước.

JWT, LANDLORD/TENANT, Scheduler, FCM, VietQR, công nợ và client AI/RPC chưa được triển khai. Backend sẽ tính hóa đơn và xác minh thanh toán. Blockchain chỉ giữ token tiền cọc thử nghiệm; không lưu khóa người dùng.
