part of 'kho_hop_dong_mau.dart';

// Quy trình mô phỏng dùng cùng bản ghi với L12–L15; không gửi giao dịch thật.
extension ThaoTacHopDongDemo on KhoHopDongMau {
  bool _taiLieuKyHopLe(HopDong h) {
    final t = h.taiLieu;
    return t != null &&
        t.noiDung.length >= 5 &&
        String.fromCharCodes(t.noiDung.take(5)) == '%PDF-' &&
        bam.sha256.convert(t.noiDung).toString() == t.sha256 &&
        (h.maBamDaKy == null || h.maBamDaKy == t.sha256);
  }

  String? kiemTraKyDemo(String id, ViGiaoDichDemo vi) {
    final h = theoId(id);
    if (h == null) return 'Không tìm thấy hợp đồng.';
    if (h.dangKyDemo) return 'Đang xử lý ký demo. Vui lòng chờ.';
    final loi = kiemTraNguoiThueDongY(id);
    if (loi != null) return loi;
    if (h.nguoiThueDongYLuc == null) {
      return 'Bạn cần đồng ý điều khoản tại T11 trước khi ký demo.';
    }
    if (vi.diaChi == null) return 'Bạn cần kết nối ví demo tại T12.';
    return null;
  }

  Future<bool> kyNguoiThueDemo(
    String id,
    ViGiaoDichDemo vi, {
    bool thatBai = false,
  }) async {
    final loi = kiemTraKyDemo(id, vi);
    if (loi != null) throw StateError(loi);
    final cu = _batBuoc(id);
    final phien = vi.phienKetNoi;
    final diaChi = vi.diaChi!;
    final dangKy = cu.copyWith(dangKyDemo: true, xoaLoiKyDemo: true);
    _thay(dangKy);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (_daHuy) return false;
    if (!vi.phienHopLe(phien) || !identical(theoId(id), dangKy) || thatBai) {
      final h = _batBuoc(id);
      _thay(
        h.copyWith(
          dangKyDemo: false,
          loiKyDemo: thatBai
              ? 'Ký thất bại trong tình huống mô phỏng.'
              : 'Phiên ví hoặc hợp đồng đã thay đổi. Vui lòng kiểm tra lại.',
        ),
      );
      return false;
    }
    final gio = DateTime.now();
    _thay(
      dangKy.copyWith(
        dangKyDemo: false,
        xoaLoiKyDemo: true,
        nguoiThueKyLuc: gio,
        viNguoiThueKy: diaChi,
        maBamDaKy: cu.taiLieu!.sha256,
        trangThai: cu.chuTroKyLuc != null
            ? TrangThaiHopDong.choCoc
            : TrangThaiHopDong.choKy,
        lichSu: [
          ...cu.lichSu,
          SuKienHopDong(
            loai: LoaiSuKienHopDong.ky,
            tieuDe: 'Người thuê xác nhận ký (Demo)',
            thoiGian: gio,
            moTa: 'Mô phỏng trong bộ nhớ; chưa có chữ ký Blockchain.',
          ),
        ],
      ),
    );
    return true;
  }

  // Chỉ áp dụng sau thao tác mô phỏng chủ trọ riêng biệt, không ký thay tự động.
  void chuTroXacNhanKyDemo(String id) {
    final h = _batBuoc(id);
    if (h.nguoiThueKyLuc == null ||
        h.nguoiThueDongYLuc == null ||
        h.dangKyDemo ||
        h.trangThai != TrangThaiHopDong.choKy ||
        !_taiLieuKyHopLe(h)) {
      throw StateError('Chưa đủ điều kiện nhận xác nhận chủ trọ trong demo.');
    }
    if (h.chuTroKyLuc != null) return;
    final gio = DateTime.now();
    _thay(
      h.copyWith(
        chuTroKyLuc: gio,
        trangThai: TrangThaiHopDong.choCoc,
        lichSu: [
          ...h.lichSu,
          SuKienHopDong(
            loai: LoaiSuKienHopDong.ky,
            tieuDe: 'Chủ trọ xác nhận ký (Demo)',
            thoiGian: gio,
            moTa:
                'Bản ghi mô phỏng được chọn rõ ràng; chưa phải chữ ký ví thật.',
          ),
        ],
      ),
    );
  }

}
