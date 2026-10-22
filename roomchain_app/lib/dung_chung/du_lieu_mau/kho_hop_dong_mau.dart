import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart' as bam;

import '../mo_hinh/hop_dong.dart';
import '../mo_hinh/tien_coc.dart';
import '../mo_hinh/quyet_toan_tien_coc.dart';
import '../mo_hinh/nguoi_dung.dart';
import '../mo_hinh/phong_tro.dart';
import 'du_lieu_gia.dart';

// Kho mock trong bộ nhớ, dùng chung giữa danh sách và form.
class KhoHopDongMau extends ChangeNotifier {
  KhoHopDongMau({List<HopDong>? banDau, DateTime? bayGio}) {
    final moc = DateTime(
      bayGio?.year ?? DateTime.now().year,
      bayGio?.month ?? DateTime.now().month,
      bayGio?.day ?? DateTime.now().day,
    );
    _danhSach.addAll(
      banDau ??
          [
            _mau(
              'HD2025-0123',
              'P201',
              moc.add(const Duration(days: 40)),
              moc.add(const Duration(days: 399)),
              TrangThaiHopDong.choKy,
            ),
            _mau(
              'HD2025-0124',
              'P201',
              moc.add(const Duration(days: 400)),
              moc.add(const Duration(days: 760)),
              TrangThaiHopDong.choKy,
            ),
            _mau(
              'HD2025-0122',
              'P302',
              moc.add(const Duration(days: 20)),
              moc.add(const Duration(days: 380)),
              TrangThaiHopDong.choCoc,
            ),
            DuLieuGia.hopDong.copyWith(
              ngayTao: DateTime(2026, 9, 15),
              coc: DuLieuGia.tienCoc,
              ghiNhanCocLuc: DateTime(2026, 10, 1, 10),
              lichSu: [
                SuKienHopDong(
                  loai: LoaiSuKienHopDong.tao,
                  tieuDe: 'Tạo hợp đồng',
                  thoiGian: DateTime(2026, 9, 15),
                ),
                SuKienHopDong(
                  loai: LoaiSuKienHopDong.datCoc,
                  tieuDe: 'Ghi nhận khóa cọc (demo)',
                  thoiGian: DateTime(2026, 10, 1, 10),
                  moTa: '3.800.000 MockVNDC · Bản ghi mẫu, không phải giao dịch vừa xác nhận.',
                ),
              ],
            ),
            _mau(
              'HD2024-0771',
              'P201',
              DateTime(2024, 1, 1),
              DateTime(2024, 12, 31),
              TrangThaiHopDong.daKetThuc,
            ).copyWith(
              chuTroKyLuc: DateTime(2023, 12, 20, 10),
              nguoiThueKyLuc: DateTime(2023, 12, 20, 11),
              coc: const TienCoc(
                id: 'deposit-HD2024-0771',
                hopDongId: 'HD2024-0771',
                soToken: 2500000,
                loaiToken: 'MockVNDC',
                trangThai: TrangThaiTienCoc.choQuyetToan,
              ),
              ghiNhanCocLuc: DateTime(2024, 1, 1, 10),
            ),
          ],
    );
  }

  static final dungChung = KhoHopDongMau();
  final List<HopDong> _danhSach = [];
  int _soThuTu = 0;
  List<HopDong> get danhSach => List.unmodifiable(_danhSach);
  List<PhongTro> get phongTro => DuLieuGia.phongTro;
  List<NguoiDung> get nguoiThue => const [DuLieuGia.nguoiThue];

  PhongTro phong(String id) => phongTro.firstWhere((p) => p.id == id);
  NguoiDung nguoi(String id) => nguoiThue.firstWhere((n) => n.id == id);
  HopDong? theoId(String id) {
    for (final h in _danhSach) {
      if (h.id == id) return h;
    }
    return null;
  }

  List<HopDong> loc({
    required TrangThaiHopDong trangThai,
    String tuKhoa = '',
    String? khuTro,
  }) {
    final tu = tuKhoa.trim().toLowerCase();
    return _danhSach.where((h) {
      final p = phong(h.phongId);
      return h.trangThai == trangThai &&
          (khuTro == null || p.tenKhuTro == khuTro) &&
          '${h.maHopDong} ${nguoi(h.nguoiThueId).hoTen} ${p.maPhong}'
              .toLowerCase()
              .contains(tu);
    }).toList();
  }

  bool trungThoiGian(String phongId, DateTime tu, DateTime den) =>
      _danhSach.any(
        (h) =>
            h.phongId == phongId &&
            h.trangThai != TrangThaiHopDong.daKetThuc &&
            h.trangThai != TrangThaiHopDong.nhap &&
            !den.isBefore(h.ngayBatDau) &&
            !tu.isAfter(h.ngayKetThuc),
      );

  String? kiemTra(HopDong h) {
    if (!phongTro.any(
      (p) => p.id == h.phongId && p.trangThai == TrangThaiPhong.conTrong,
    )) {
      return 'Vui lòng chọn phòng còn trống.';
    }
    if (!nguoiThue.any((n) => n.id == h.nguoiThueId)) {
      return 'Vui lòng chọn người thuê hợp lệ.';
    }
    if (!h.ngayKetThuc.isAfter(h.ngayBatDau)) {
      return 'Ngày kết thúc phải sau ngày bắt đầu.';
    }
    if (trungThoiGian(h.phongId, h.ngayBatDau, h.ngayKetThuc)) {
      return 'Phòng đã có hợp đồng trùng thời gian. Vui lòng chọn ngày hoặc phòng khác.';
    }
    final c = h.cauHinh;
    if (h.giaThue <= 0 ||
        [
          h.tienCoc,
          c.phiDichVu,
          c.donGiaDien,
          c.donGiaNuoc,
          c.internet,
          c.khoanKhac,
          c.phuThuCham,
        ].any((v) => v < 0)) {
      return 'Chi phí không hợp lệ.';
    }
    if (c.thanhToanTu < 1 ||
        c.thanhToanDen > 28 ||
        c.thanhToanDen < c.thanhToanTu ||
        c.ngayGhiSo < 1 ||
        c.ngayGhiSo > 28) {
      return 'Ngày thanh toán và ghi số phải trong khoảng 1–28, đúng thứ tự.';
    }
    return null;
  }

  HopDong them(HopDong banNhap) {
    final loi = kiemTra(banNhap);
    if (loi != null) throw StateError(loi);
    final gio = DateTime.now();
    String id;
    String ma;
    do {
      id = 'RC${gio.microsecondsSinceEpoch}-${++_soThuTu}';
      ma =
          'HD${gio.year}-${(_soThuTu + _danhSach.length).toString().padLeft(4, '0')}';
    } while (theoId(id) != null || _danhSach.any((h) => h.maHopDong == ma));
    final h = banNhap.copyWith(
      id: id,
      maHopDong: ma,
      trangThai: TrangThaiHopDong.choKy,
      ngayTao: gio,
      lichSu: [
        SuKienHopDong(
          loai: LoaiSuKienHopDong.tao,
          tieuDe: 'Tạo hợp đồng',
          thoiGian: gio,
        ),
      ],
    );
    _danhSach.insert(0, h);
    notifyListeners();
    return h;
  }

  HopDong _batBuoc(String id) =>
      theoId(id) ?? (throw StateError('Không tìm thấy hợp đồng.'));

  void _thay(HopDong h) {
    final viTri = _danhSach.indexWhere((p) => p.id == h.id);
    if (viTri < 0) throw StateError('Không tìm thấy hợp đồng.');
    _danhSach[viTri] = h;
    notifyListeners();
  }

  TaiLieuHopDong luuTaiLieu(String id, TaiLieuHopDong taiLieu) {
    final h = _batBuoc(id);
    if (h.taiLieu != null) return h.taiLieu!;
    if (h.daCoChuKy) {
      throw StateError(
        'Hợp đồng có xác nhận ký; cần tài liệu gốc, không tạo lại PDF.',
      );
    }
    if (taiLieu.noiDung.length < 5 ||
        String.fromCharCodes(taiLieu.noiDung.take(5)) != '%PDF-' ||
        bam.sha256.convert(taiLieu.noiDung).toString() != taiLieu.sha256) {
      throw StateError('Tài liệu PDF hoặc mã băm không hợp lệ.');
    }
    _thay(h.copyWith(taiLieu: taiLieu));
    return taiLieu;
  }

  String? kiemTraGuiKy(String id) {
    final h = theoId(id);
    if (h == null) return 'Không tìm thấy hợp đồng.';
    if (h.trangThai != TrangThaiHopDong.choKy &&
        h.trangThai != TrangThaiHopDong.nhap) {
      return 'Trạng thái hợp đồng không cho phép gửi yêu cầu ký.';
    }
    if (h.daCoChuKy) {
      return 'Hợp đồng đã có xác nhận ký, không gửi lại yêu cầu.';
    }
    if (h.guiKyLuc != null) return 'Đã gửi yêu cầu ký trong bản demo.';
    if (!phongTro.any((p) => p.id == h.phongId) ||
        !nguoiThue.any((n) => n.id == h.nguoiThueId) ||
        !h.ngayKetThuc.isAfter(h.ngayBatDau) ||
        h.giaThue <= 0 ||
        h.tienCoc < 0) {
      return 'Thông tin hợp đồng chưa đầy đủ hoặc không hợp lệ.';
    }
    final t = h.taiLieu;
    if (t == null || bam.sha256.convert(t.noiDung).toString() != t.sha256) {
      return 'Chưa có tài liệu PDF hợp lệ.';
    }
    return null;
  }

  void guiYeuCauKy(String id) {
    final loi = kiemTraGuiKy(id);
    if (loi != null) throw StateError(loi);
    final h = _batBuoc(id);
    final gio = DateTime.now();
    _thay(
      h.copyWith(
        trangThai: TrangThaiHopDong.choKy,
        guiKyLuc: gio,
        lichSu: [
          ...h.lichSu,
          SuKienHopDong(
            loai: LoaiSuKienHopDong.guiKy,
            tieuDe: 'Gửi yêu cầu ký (demo)',
            thoiGian: gio,
            moTa: 'Yêu cầu trong bộ nhớ Frontend; chưa gửi lên máy chủ.',
          ),
        ],
      ),
    );
  }

  void nhacDatCoc(String id) {
    final h = _batBuoc(id);
    if (h.trangThai != TrangThaiHopDong.choCoc) {
      throw StateError('Hợp đồng không ở trạng thái chờ cọc.');
    }
    _thay(
      h.copyWith(
        lichSu: [
          ...h.lichSu,
          SuKienHopDong(
            loai: LoaiSuKienHopDong.nhacCoc,
            tieuDe: 'Nhắc đặt cọc (demo)',
            thoiGian: DateTime.now(),
            moTa: 'Ghi nhận lời nhắc trong Frontend, chưa gửi qua máy chủ.',
          ),
        ],
      ),
    );
  }

  // Các khoản chờ quyết toán vẫn nằm trong escrow, không phải doanh thu VND.
  int get tongCocDangKhoa => _danhSach.fold(
    0,
    (tong, h) =>
        tong +
        (h.coc != null &&
                h.coc!.loaiToken == 'MockVNDC' &&
                h.coc!.trangThai.dangGiuTrongEscrow
            ? h.coc!.soToken
            : 0),
  );
  int get doanhThuCocVnd => _danhSach.fold(
    0,
    (tong, h) =>
        tong +
        (h.quyetToan?.daHoanTat == true
            ? h.quyetToan!.doanhThuVndDaGhiNhan
            : 0),
  );
  static const tokenMoiVndDemo = 1;

  String? lyDoChuaDuDieuKienQuyetToan(String id, {DateTime? bayGio}) {
    final h = theoId(id);
    if (h == null) return 'Không tìm thấy hợp đồng.';
    if (h.quyetToan != null) {
      return 'Đã có bản quyết toán. Chờ người thuê xác nhận hoặc xem trạng thái hiện có.';
    }
    if (h.trangThai != TrangThaiHopDong.dangHieuLuc &&
        h.trangThai != TrangThaiHopDong.daKetThuc) {
      return 'Hợp đồng chưa ở giai đoạn được phép quyết toán.';
    }
    final coc = h.coc;
    if (coc == null ||
        coc.hopDongId != h.id ||
        (coc.trangThai != TrangThaiTienCoc.dangKhoa &&
            coc.trangThai != TrangThaiTienCoc.choQuyetToan)) {
      return 'Chưa có bản ghi tiền cọc đã xác nhận khóa trong escrow.';
    }
    if (coc.loaiToken != 'MockVNDC' ||
        coc.soToken != h.tienCoc * tokenMoiVndDemo ||
        h.tienCoc <= 0) {
      return 'Số token đang giữ không khớp quy ước demo 1 MockVNDC / 1 VND. Cần kiểm tra dữ liệu cọc.';
    }
    if (h.chuTroKyLuc == null || h.nguoiThueKyLuc == null) {
      return 'Chưa có đủ xác nhận ký của hai bên trong dữ liệu mock.';
    }
    final gio = bayGio ?? DateTime.now();
    final homNay = DateTime(gio.year, gio.month, gio.day);
    if (h.ngayKetThuc.isAfter(homNay)) {
      final t = h.thoaThuanKetThucSom;
      if (t == null ||
          t.noiDung.trim().isEmpty ||
          t.chuTroXacNhanLuc.isAfter(gio) ||
          t.nguoiThueXacNhanLuc.isAfter(gio) ||
          t.khauTruDaThongNhat < 0 ||
          t.khauTruDaThongNhat > h.tienCoc) {
        return 'Chưa đến ngày kết thúc hợp đồng và chưa có thỏa thuận kết thúc sớm được cả hai bên xác nhận.';
      }
    }
    return null;
  }

  String? kiemTraQuyetToan(
    String id,
    List<KhoanKhauTru> cacKhoan,
    List<BangChungKhauTru> bangChung, {
    DateTime? bayGio,
  }) {
    final loi = lyDoChuaDuDieuKienQuyetToan(id, bayGio: bayGio);
    if (loi != null) return loi;
    final h = _batBuoc(id);
    if (cacKhoan.isEmpty || cacKhoan.length > 10) {
      return 'Cần từ 1 đến 10 khoản khấu trừ, nhập 0 nếu hoàn đủ cọc.';
    }
    if (cacKhoan.any(
      (k) =>
          k.soTien < 0 ||
          k.soTien > 999999999999999 ||
          (k.soTien > 0 && k.lyDo.trim().isEmpty) ||
          k.lyDo.length > 500,
    )) {
      return 'Khoản khấu trừ cần số tiền không âm và lý do hợp lệ (tối đa 500 ký tự).';
    }
    final tong = cacKhoan.fold(0, (t, k) => t + k.soTien);
    if (tong > h.tienCoc) return 'Tổng khấu trừ không được vượt quá tiền cọc.';
    if (bangChung.length > 5 ||
        bangChung.any(
          (a) => a.noiDung.isEmpty || a.noiDung.length > 5 * 1024 * 1024,
        )) {
      return 'Bằng chứng tối đa 5 ảnh, mỗi ảnh không quá 5 MB.';
    }
    if (tong > 0 && bangChung.isEmpty) {
      return 'Cần ít nhất một ảnh bằng chứng khi có khoản khấu trừ.';
    }
    final gio = bayGio ?? DateTime.now();
    if (h.ngayKetThuc.isAfter(DateTime(gio.year, gio.month, gio.day)) &&
        tong != h.thoaThuanKetThucSom!.khauTruDaThongNhat) {
      return 'Tổng khấu trừ phải đúng thỏa thuận kết thúc trước hạn đã được hai bên xác nhận.';
    }
    return null;
  }

  QuyetToanTienCoc guiQuyetToan({
    required String hopDongId,
    required List<KhoanKhauTru> cacKhoan,
    required List<BangChungKhauTru> bangChung,
    required bool chuTroDaXacNhan,
  }) {
    if (!chuTroDaXacNhan) {
      throw StateError('Vui lòng xác nhận thông tin quyết toán.');
    }
    final loi = kiemTraQuyetToan(hopDongId, cacKhoan, bangChung);
    if (loi != null) throw StateError(loi);
    final h = _batBuoc(hopDongId);
    final gio = DateTime.now();
    final q = QuyetToanTienCoc(
      id: 'QT${gio.microsecondsSinceEpoch}-${++_soThuTu}',
      maQuyetToan: 'QT${gio.year}-${_soThuTu.toString().padLeft(4, '0')}',
      ngayTao: gio,
      hopDongId: h.id,
      tienCocBanDau: h.tienCoc,
      cacKhoan: cacKhoan,
      bangChung: bangChung,
      chuTroXacNhanLuc: gio,
    );
    _thay(
      h.copyWith(
        quyetToan: q,
        coc: h.coc!.copyWith(trangThai: TrangThaiTienCoc.choNguoiThueXacNhan),
        lichSu: [
          ...h.lichSu,
          SuKienHopDong(
            loai: LoaiSuKienHopDong.quyetToan,
            tieuDe: 'Gửi quyết toán chờ người thuê (demo)',
            thoiGian: gio,
            moTa: 'Chưa giải ngân hoặc chuyển token. Mã quyết toán: ${q.id}',
          ),
        ],
      ),
    );
    return q;
  }

  HopDong? hopDongTheoQuyetToan(String id) {
    for (final h in _danhSach) {
      if (h.quyetToan?.id == id) return h;
    }
    return null;
  }

  // Áp dụng một bản ghi demo được cung cấp; không gửi hoặc tạo transaction.
  void capNhatQuyetToanMau(QuyetToanTienCoc moi) {
    final h = _batBuoc(moi.hopDongId);
    final cu = h.quyetToan;
    if (cu == null || cu.id != moi.id) {
      throw StateError('Không tìm thấy bản quyết toán cần cập nhật.');
    }
    if (!moi.phanChiaHopLe ||
        moi.tienCocBanDau != cu.tienCocBanDau ||
        moi.tongKhauTru != cu.tongKhauTru ||
        moi.nguoiThueNhanThamChieu != cu.nguoiThueNhanThamChieu ||
        moi.chuTroNhanThamChieu != cu.chuTroNhanThamChieu ||
        moi.doanhThuVndDaGhiNhan < 0) {
      throw StateError('Dữ liệu phân chia không khớp bản quyết toán đã gửi.');
    }
    if (cu.daHoanTat && (!moi.daHoanTat || cu.txHashHopLe != moi.txHashHopLe)) {
      throw StateError(
        'Không thay đổi biên nhận của bản quyết toán đã hoàn tất.',
      );
    }
    if (moi.trangThaiGiaoDich == TrangThaiGiaoDichQuyetToan.thanhCong &&
        !moi.daHoanTat) {
      throw StateError(
        'Biên nhận giao dịch thành công chưa đủ dữ liệu xác nhận.',
      );
    }
    _thay(
      h.copyWith(
        quyetToan: moi,
        coc: moi.daHoanTat
            ? h.coc?.copyWith(
                trangThai: moi.chuTroNhanThamChieu == 0
                    ? TrangThaiTienCoc.daHoan
                    : TrangThaiTienCoc.daQuyetToan,
              )
            : h.coc,
      ),
    );
  }

  // Bộ dữ liệu xem giao diện hoàn tất, tách khỏi phiên tạo quyết toán mới.
  factory KhoHopDongMau.demoKetQuaHoanTat() {
    final kho = KhoHopDongMau();
    final h = kho.theoId('HD2024-0771')!;
    final q = QuyetToanTienCoc(
      id: 'QT-demo-hoan-tat',
      maQuyetToan: 'QT2025-0001',
      hopDongId: h.id,
      ngayTao: DateTime(2025, 1, 2, 14, 20),
      tienCocBanDau: h.tienCoc,
      cacKhoan: const [
        KhoanKhauTru(
          id: 'demo-khau-tru',
          soTien: 500000,
          lyDo: 'Khấu trừ theo thỏa thuận demo',
        ),
      ],
      bangChung: [],
      chuTroXacNhanLuc: DateTime(2025, 1, 2, 15, 5),
      nguoiThueXacNhanLuc: DateTime(2025, 1, 2, 15, 10),
      trangThai: TrangThaiQuyetToan.daGiaiNgan,
      trangThaiGiaoDich: TrangThaiGiaoDichQuyetToan.thanhCong,
      txHash:
          '0x0000000000000000000000000000000000000000000000000000000000000001',
      thoiGianGiaoDich: DateTime(2025, 1, 2, 15, 12),
      hoanTatLuc: DateTime(2025, 1, 2, 15, 12),
    );
    kho._thay(
      h.copyWith(
        quyetToan: q,
        coc: h.coc!.copyWith(trangThai: TrangThaiTienCoc.daQuyetToan),
      ),
    );
    return kho;
  }

  // Làm mới giao diện từ kho hiện tại; giữ các hợp đồng vừa tạo.
  void lamMoi() => notifyListeners();

  HopDong _mau(
    String ma,
    String phongId,
    DateTime tu,
    DateTime den,
    TrangThaiHopDong trangThai,
  ) {
    final p = phong(phongId);
    return HopDong(
      id: ma,
      maHopDong: ma,
      phongId: phongId,
      nguoiThueId: DuLieuGia.nguoiThue.id,
      ngayBatDau: tu,
      ngayKetThuc: den,
      giaThue: p.giaThue,
      tienCoc: p.tienCoc,
      trangThai: trangThai,
      ngayTao: tu.subtract(const Duration(days: 15)),
      lichSu: [
        SuKienHopDong(
          loai: LoaiSuKienHopDong.tao,
          tieuDe: 'Tạo hợp đồng',
          thoiGian: tu.subtract(const Duration(days: 15)),
        ),
      ],
    );
  }
}
