import 'package:flutter/foundation.dart';

enum TrangThaiKetNoiVi { chuaKetNoi, dangKetNoi, daKetNoi, thatBai, saiMang }

enum KetQuaKetNoiMau { thanhCong, thatBai, saiMang }

// Chỉ mô phỏng giao diện; không gọi RPC, ký hoặc giữ khóa ví.
class TrangThaiViMau extends ChangeNotifier {
  static final dungChung = TrangThaiViMau();
  static const mangDuKien = 'Hardhat Local';
  static const tokenDuKien = 'MockVNDC';
  static const diaChiMau = '0x000000000000000000000000000000000000dEaD';
  TrangThaiKetNoiVi _trangThai = TrangThaiKetNoiVi.chuaKetNoi;
  bool _cheDoMoPhong = false, _daHuy = false;
  int _lanKetNoi = 0;

  TrangThaiKetNoiVi get trangThai => _trangThai;
  bool get cheDoMoPhong => _cheDoMoPhong;
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
    notifyListeners();
  }

  @override
  void dispose() {
    _daHuy = true;
    super.dispose();
  }
}
