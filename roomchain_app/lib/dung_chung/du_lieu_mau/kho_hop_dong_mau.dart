import 'package:flutter/foundation.dart';

import '../mo_hinh/hop_dong.dart';
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
            DuLieuGia.hopDong,
            _mau(
              'HD2024-0771',
              'P201',
              DateTime(2024, 1, 1),
              DateTime(2024, 12, 31),
              TrangThaiHopDong.daKetThuc,
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
    );
    _danhSach.insert(0, h);
    notifyListeners();
    return h;
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
    );
  }
}
