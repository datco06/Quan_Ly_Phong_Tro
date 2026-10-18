# roomchain_ai

Dịch vụ Python FastAPI độc lập. Có `GET /health`, OpenAPI và test HTTP; chưa triển khai OCR/recommendation.

## Cài và chạy

Môi trường kiểm tra: Python 3.14.1. Từ thư mục project:

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -m uvicorn api.main:app --host 127.0.0.1 --port 8000
```

Windows kích hoạt qua `.venv/Scripts/activate`. Kiểm tra `http://localhost:8000/health`; tài liệu `http://localhost:8000/docs`. Test: `python -m pytest tests`.

`requirements.txt` ghim dependency môi trường đã kiểm tra, gồm công cụ test; không commit `.venv`.

## Cấu trúc dự kiến

- `api/main.py`: entry point; thêm `meter_routes.py`, `recommendation_routes.py` khi có endpoint thực.
- `core/`: sẽ chứa `meter_ocr.py`, `image_processing.py`, `recommendation.py`.
- `data/raw`, `data/processed`, `models`: dữ liệu/model cục bộ, bỏ qua trong Git.
- `scripts/`: xử lý dữ liệu/đánh giá khi cần; `tests/`: kiểm tra API/thuật toán.
- Chỉ tạo `config.py` khi có cấu hình thực.

Spring Boot gọi HTTP; AI không truy cập database nghiệp vụ. OCR dự kiến tiền xử lý ảnh, dùng PaddleOCR, trả chỉ số và độ tin cậy để xác nhận; không quyết định tiền hóa đơn. Chưa cài PaddleOCR/PaddlePaddle; cần chọn runtime Python tương thích ở bước triển khai.

Smart Commute nhận ngân sách, trường học, phương tiện và phòng ứng viên kèm dữ liệu tuyến đường backend cung cấp; bản đầu tính điểm trọng số và trả lý do gợi ý, chưa cần ML.
