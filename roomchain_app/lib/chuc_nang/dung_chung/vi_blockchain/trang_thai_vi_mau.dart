import 'package:flutter/foundation.dart';

import '../../../../dung_chung/mo_hinh/giao_dich_blockchain.dart';
import '../../../../dung_chung/cau_hinh/cau_hinh_blockchain_demo.dart';

enum TrangThaiKetNoiVi { chuaKetNoi, dangKetNoi, daKetNoi, thatBai, saiMang }

enum KetQuaKetNoiMau { thanhCong, thatBai, saiMang }

// Chỉ mô phỏng giao diện; không gọi RPC, ký hoặc giữ khóa ví.
class TrangThaiViMau extends ChangeNotifier implements ViGiaoDichDemo {
  TrangThaiViMau({int soDuToken = 5000000}) : _soDuToken = soDuToken {
    if (soDuToken < 0) throw ArgumentError.value(soDuToken, 'soDuToken');
  }
  static final dungChung = TrangThaiViMau();
  static const mangDuKien = CauHinhBlockchainDemo.tenMang;
  static const tokenDuKien = CauHinhBlockchainDemo.token;
  // Theo roomchain_chain/README.md; không dùng thông tin này để gọi RPC.
  static const chainIdDuKien = CauHinhBlockchainDemo.chainId;
  static const diaChiMau = '0x000000000000000000000000000000000000dEaD';
  TrangThaiKetNoiVi _trangThai = TrangThaiKetNoiVi.chuaKetNoi;
  bool _cheDoMoPhong = false, _daHuy = false;
  int _lanKetNoi = 0;
  int _soDuToken, _allowance = 0;
  bool _dangDatCoc = false;
  @override
  int get soDuToken => _soDuToken;
  int get allowance => _allowance;
  @override
  bool get dangDatCoc => _dangDatCoc;
  @override
  int get phienKetNoi => _lanKetNoi;
  @override
  int get chainId => chainIdDuKien;
  @override
  bool phienHopLe(int phien) =>
      !_daHuy && phien == _lanKetNoi && diaChi != null;

  @override
  void batDauDatCoc(int soToken, int phien) {
    if (!phienHopLe(phien) ||
        _dangDatCoc ||
        soToken <= 0 ||
        _soDuToken < soToken) {
      throw StateError('Ví demo chưa sẵn sàng hoặc số dư không đủ.');
    }
    _dangDatCoc = true;
  }

  @override
  void ghiNhanApprove(int soToken, int phien) {
    if (!phienHopLe(phien) || !_dangDatCoc) {
      throw StateError('Phiên ví demo đã thay đổi.');
    }
    _allowance = soToken;
    notifyListeners();
  }

  @override
  void ghiNhanChiCoc(int soToken, int phien) {
    if (!phienHopLe(phien) ||
        !_dangDatCoc ||
        _allowance < soToken ||
        _soDuToken < soToken) {
      throw StateError('Chưa đủ điều kiện ghi nhận cọc demo.');
    }
    _soDuToken -= soToken;
    _allowance -= soToken;
    notifyListeners();
  }

  @override
  void ketThucDatCoc() {
    _dangDatCoc = false;
    if (!_daHuy) notifyListeners();
  }

  TrangThaiKetNoiVi get trangThai => _trangThai;
  bool get cheDoMoPhong => _cheDoMoPhong;
  @override
  String? get diaChi =>
      _trangThai == TrangThaiKetNoiVi.daKetNoi ? diaChiMau : null;

  Future<void> ketNoi(KetQuaKetNoiMau ketQua) async {
    if (_daHuy || _trangThai == TrangThaiKetNoiVi.dangKetNoi) return;
    final lan = ++_lanKetNoi;
    _cheDoMoPhong = true;
    _trangThai = TrangThaiKetNoiVi.dangKetNoi;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (_daHuy || lan != _lanKetNoi) return;
    _trangThai = switch (ketQua) {
      KetQuaKetNoiMau.thanhCong => TrangThaiKetNoiVi.daKetNoi,
      KetQuaKetNoiMau.thatBai => TrangThaiKetNoiVi.thatBai,
      KetQuaKetNoiMau.saiMang => TrangThaiKetNoiVi.saiMang,
    };
    notifyListeners();
  }

  void ngatKetNoi() {
    if (_daHuy) return;
    ++_lanKetNoi;
    _trangThai = TrangThaiKetNoiVi.chuaKetNoi;
    _cheDoMoPhong = false;
    _allowance = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _daHuy = true;
    super.dispose();
  }
}
