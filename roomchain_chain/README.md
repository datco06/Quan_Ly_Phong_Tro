# roomchain_chain

Solidity/Hardhat độc lập. Khởi tạo bằng CLI Hardhat 2.29.1, tùy chọn `Create an empty hardhat.config.js`; compiler Solidity 0.8.28 do CLI sinh. Dùng Node.js 20; dependency ghim trong `package-lock.json`.

## Chạy

```sh
npm ci
npm run compile
npm test
npm run node
```

RPC local: `http://127.0.0.1:8545`, chain ID 31337. Dừng node bằng Ctrl+C. Tài khoản Hardhat in ra chỉ dùng local; không nạp tiền thật hay copy khóa vào source.

Chưa có Solidity source hoặc test nghiệp vụ: compile báo không có gì để biên dịch, test có 0 ca. Kết quả này chỉ xác minh công cụ chạy, chưa chứng minh escrow hoạt động. Lần compile contract đầu tiên có thể cần mạng tải compiler. Chưa có deploy script, ABI hay deployment thật.

Kết quả cài dependency hiện tại: npm báo 19 lỗ hổng trong cây dependency công cụ (11 low, 2 moderate, 6 high). Chưa áp dụng `audit fix --force` hoặc nâng major tự động; cần xử lý trước khi dùng cho triển khai thực tế.

## Cấu trúc dự kiến

- `contracts/`: sẽ có `MockVNDC.sol` (ERC-20 thử nghiệm), `RentalEscrow.sol` khi triển khai.
- `scripts/`: deploy và xuất ABI khi có contract.
- `test/`: kiểm tra trạng thái, quyền và quyết toán khi có code.
- `artifacts/`, `cache/`: Hardhat tự sinh, không commit.
- `deployments/`: địa chỉ, chain ID, transaction hash và metadata công khai sau deploy; không có secret.

Escrow tương lai: tạo/xác nhận hợp đồng, đặt và giữ token cọc, kết thúc hợp đồng, xử lý điều khoản chấm dứt trước hạn hợp lệ, đề xuất khấu trừ, xác nhận quyết toán, hoàn/chia cọc. Không có phân xử tranh chấp. Thiếu đồng thuận thì chờ xử lý ngoài ứng dụng; chủ trọ không đơn phương rút cọc.

Flutter yêu cầu ví ký; backend đọc RPC xác minh và đồng bộ. Chỉ tiền cọc token thử nghiệm ở trên chain; tiền phòng hàng tháng dùng VietQR. ABI công khai sẽ xuất có chọn lọc sang `../roomchain_app/assets/abi/`, không copy toàn bộ artifacts.
