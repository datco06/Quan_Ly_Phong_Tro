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

  String? kiemTraDatCocDemo(String id, ViGiaoDichDemo vi) {
    final h = theoId(id);
    if (h == null) return 'Không tìm thấy hợp đồng.';
    if (h.coc?.trangThai.dangGiuTrongEscrow == true) {
      return 'Hợp đồng đã có tiền cọc đang giữ.';
    }
    if (h.trangThai != TrangThaiHopDong.choCoc ||
        h.chuTroKyLuc == null ||
        h.nguoiThueKyLuc == null ||
        h.nguoiThueDongYLuc == null ||
        h.maBamDaKy == null ||
        !_taiLieuKyHopLe(h) ||
        h.tienCoc <= 0) {
      return 'Cần đủ xác nhận ký demo của hai bên và tài liệu hợp lệ trước khi đặt cọc.';
    }
    if (vi.diaChi == null || vi.diaChi != h.viNguoiThueKy) {
      return 'Kết nối đúng ví demo đã xác nhận hợp đồng.';
    }
    if (vi.chainId != CauHinhBlockchainDemo.chainId) {
      return 'Ví demo đang ở sai mạng dự kiến.';
    }
    if (vi.dangDatCoc || h.coc?.trangThai == TrangThaiTienCoc.choXacNhan) {
      return 'Đang có giao dịch cọc demo được xử lý. Vui lòng chờ.';
    }
    if (h.coc != null &&
        h.coc!.trangThai != TrangThaiTienCoc.thatBai &&
        h.coc!.trangThai != TrangThaiTienCoc.chuaDat) {
      return 'Bản ghi cọc hiện tại không cho phép nạp lại.';
    }
    if (vi.soDuToken < h.tienCoc * KhoHopDongMau.tokenMoiVndDemo) {
      return 'Không đủ số dư MockVNDC demo.';
    }
    return null;
  }

  // Số hash cố định chỉ dùng cho biên nhận mẫu, không dẫn đến Explorer.
  static const maApproveMau =
      '0x0000000000000000000000000000000000000000000000000000000000000013';
  static const maDatCocMau =
      '0x0000000000000000000000000000000000000000000000000000000000000014';

  bool daKhoaCocDemo(String id) {
    final h = theoId(id);
    final c = h?.coc;
    final g = c?.giaoDich;
    return h != null &&
        c != null &&
        g != null &&
        g.daKhoa &&
        h.nguoiThueDongYLuc != null &&
        h.maBamDaKy != null &&
        _taiLieuKyHopLe(h) &&
        h.nguoiThueKyLuc != null &&
        h.chuTroKyLuc != null &&
        h.trangThai == TrangThaiHopDong.dangHieuLuc &&
        c.trangThai.dangGiuTrongEscrow &&
        c.hopDongId == h.id &&
        c.loaiToken == CauHinhBlockchainDemo.token &&
        g.hopDongId == h.id &&
        c.soToken == h.tienCoc * KhoHopDongMau.tokenMoiVndDemo &&
        g.soToken == c.soToken &&
        g.chainId == CauHinhBlockchainDemo.chainId &&
        g.diaChiVi == h.viNguoiThueKy &&
        c.diaChiVi == g.diaChiVi &&
        h.maGiaoDichCoc == g.transactionHash &&
        h.ghiNhanCocLuc == g.khoaCocLuc;
  }

  void batDauDatCocDemo(String id, ViGiaoDichDemo vi, {LoiDatCocDemo? gayLoi}) {
    final loi = kiemTraDatCocDemo(id, vi);
    if (loi != null) throw StateError(loi);
    final h = _batBuoc(id);
    final phien = vi.phienKetNoi;
    final soToken = h.tienCoc * KhoHopDongMau.tokenMoiVndDemo;
    vi.batDauDatCoc(soToken, phien);
    final gio = DateTime.now();
    final g = GiaoDichBlockchain(
      hopDongId: id,
      diaChiVi: vi.diaChi!,
      soToken: soToken,
      chainId: vi.chainId,
      diaChiEscrow: GiaoDichBlockchain.diaChiHopLe(h.diaChiEscrow)
          ? h.diaChiEscrow
          : null,
      viXacNhanLuc: gio,
      approveGuiLuc: gio,
    );
    _thay(
      h.copyWith(
        coc: TienCoc(
          id: 'deposit-demo-$id',
          hopDongId: id,
          soToken: soToken,
          loaiToken: 'MockVNDC',
          diaChiVi: vi.diaChi,
          trangThai: TrangThaiTienCoc.choXacNhan,
          giaoDich: g,
        ),
      ),
    );
    unawaited(_chayDatCocDemo(id, vi, phien, g, gayLoi));
  }

  Future<void> _chayDatCocDemo(
    String id,
    ViGiaoDichDemo vi,
    int phien,
    GiaoDichBlockchain banDau,
    LoiDatCocDemo? gayLoi,
  ) async {
    var g = banDau;
    var buoc = LoiDatCocDemo.approve;
    void kiemTra() {
      if (_daHuy ||
          !vi.phienHopLe(phien) ||
          !identical(theoId(id)?.coc?.giaoDich, g)) {
        throw StateError(
          'Phiên ví hoặc bản ghi cọc đã thay đổi. Chưa ghi nhận khóa cọc.',
        );
      }
    }

    void luu(GiaoDichBlockchain moi) {
      kiemTra();
      final h = _batBuoc(id);
      g = moi;
      _thay(h.copyWith(coc: h.coc!.copyWith(giaoDich: moi)));
    }

    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      kiemTra();
      if (gayLoi == LoiDatCocDemo.approve) {
        throw StateError('Approve thất bại (Demo).');
      }
      vi.ghiNhanApprove(g.soToken, phien);
      luu(
        g.copyWith(
          buoc: BuocDatCocDemo.daApprove,
          approveXacNhanLuc: DateTime.now(),
          maApprove: maApproveMau,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      buoc = LoiDatCocDemo.deposit;
      luu(g.copyWith(buoc: BuocDatCocDemo.dangGuiCoc));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      kiemTra();
      if (gayLoi == LoiDatCocDemo.deposit) {
        throw StateError('Deposit thất bại (Demo).');
      }
      luu(
        g.copyWith(
          buoc: BuocDatCocDemo.choXacNhan,
          datCocGuiLuc: DateTime.now(),
          transactionHash: maDatCocMau,
        ),
      );
      buoc = LoiDatCocDemo.xacNhan;
      await Future<void>.delayed(const Duration(milliseconds: 650));
      kiemTra();
      if (gayLoi == LoiDatCocDemo.xacNhan) {
        throw StateError('Biên nhận đặt cọc thất bại (Demo).');
      }
      final gio = DateTime.now();
      final xong = g.copyWith(
        buoc: BuocDatCocDemo.daKhoa,
        blockXacNhanLuc: gio,
        khoaCocLuc: gio,
      );
      if (!xong.daKhoa) throw StateError('Biên nhận demo chưa đủ dữ liệu.');
      vi.ghiNhanChiCoc(xong.soToken, phien);
      final h = _batBuoc(id);
      _thay(
        h.copyWith(
          coc: h.coc!.copyWith(
            trangThai: TrangThaiTienCoc.dangKhoa,
            giaoDich: xong,
          ),
          trangThai: TrangThaiHopDong.dangHieuLuc,
          ghiNhanCocLuc: gio,
          maGiaoDichCoc: xong.transactionHash,
          lichSu: [
            ...h.lichSu,
            SuKienHopDong(
              loai: LoaiSuKienHopDong.datCoc,
              tieuDe: 'Khóa cọc thành công (Demo)',
              thoiGian: gio,
              thamChieu: xong.transactionHash,
              moTa: '${xong.soToken} MockVNDC · Mô phỏng, chưa gọi RPC.',
            ),
          ],
        ),
      );
    } catch (e) {
      if (!_daHuy && identical(theoId(id)?.coc?.giaoDich, g)) {
        final h = _batBuoc(id);
        _thay(
          h.copyWith(
            coc: h.coc!.copyWith(
              trangThai: TrangThaiTienCoc.thatBai,
              giaoDich: g.copyWith(
                buoc: BuocDatCocDemo.thatBai,
                buocThatBai: buoc,
                loi: e is StateError
                    ? e.message.toString()
                    : 'Đặt cọc demo chưa thành công.',
              ),
            ),
          ),
        );
      }
    } finally {
      vi.ketThucDatCoc();
    }
  }
}
