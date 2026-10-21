import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';

class DangNhap extends StatefulWidget {
  const DangNhap({super.key, this.khiDangNhap});

  final Future<void> Function(String taiKhoan, String matKhau)? khiDangNhap;

  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  final _khoaForm = GlobalKey<FormState>();
  final _taiKhoan = TextEditingController();
  final _matKhau = TextEditingController();
  final _tapTrungMatKhau = FocusNode();
  bool _anMatKhau = true, _daGui = false, _dangGui = false;
  String? _thongBao;

  @override
  void dispose() {
    _taiKhoan.dispose();
    _matKhau.dispose();
    _tapTrungMatKhau.dispose();
    super.dispose();
  }

  // Kiểm tra dữ liệu và gọi xử lý đăng nhập khi đã có kết nối Backend.
  Future<void> _dangNhap() async {
    if (_dangGui) return;
    setState(() {
      _daGui = true;
      _thongBao = null;
    });
    if (!_khoaForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final xuLy = widget.khiDangNhap;
    if (xuLy == null) {
      setState(() => _thongBao = 'Chức năng đăng nhập chưa kết nối máy chủ.');
      return;
    }
    setState(() => _dangGui = true);
    final taiKhoan = _taiKhoan.text.trim();
    try {
      await xuLy(
        taiKhoan.contains('@') ? taiKhoan : taiKhoan.replaceAll(' ', ''),
        _matKhau.text,
      );
      if (mounted) {
        _daGui = false;
        _matKhau.clear();
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _thongBao =
              'Không thể đăng nhập. Vui lòng kiểm tra thông tin hoặc thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _dangGui = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chuDe = Theme.of(context);
    // Ô nhập cùng màu sắc, bo góc và kích thước với trang đăng ký.
    final vien = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: BangMau.vien),
    );
    return Theme(
      data: chuDe.copyWith(
        inputDecorationTheme: chuDe.inputDecorationTheme.copyWith(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          floatingLabelStyle: KieuChu.noiDung.copyWith(
            fontSize: 16,
            color: BangMau.chuPhu,
          ),
          prefixIconColor: BangMau.chuPhu,
          suffixIconColor: BangMau.chuPhu,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          border: vien,
          enabledBorder: vien,
          focusedBorder: vien.copyWith(
            borderSide: const BorderSide(color: BangMau.chinh, width: 1.5),
          ),
          errorBorder: vien.copyWith(
            borderSide: const BorderSide(color: BangMau.loi),
          ),
          focusedErrorBorder: vien.copyWith(
            borderSide: const BorderSide(color: BangMau.loi, width: 1.5),
          ),
        ),
      ),
      child: BoCucXacThuc(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        noiDung: Form(
          key: _khoaForm,
          autovalidateMode: _daGui
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần quay lại và tiêu đề.
              NutBieuTuong(
                bieuTuong: Icons.arrow_back,
                goiY: 'Quay lại',
                voHieuHoa: _dangGui,
                khiNhan: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 8),
              Text(
                'Đăng nhập tài khoản',
                style: KieuChu.tieuDeLon.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                'Chào mừng bạn trở lại RoomChain AI',
                style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
              ),
              const SizedBox(height: 24),
              // Phần tài khoản.
              ONhapLieu(
                key: const ValueKey('tai_khoan_dang_nhap'),
                nhan: 'Tài khoản',
                goiY: 'Email hoặc số điện thoại',
                controller: _taiKhoan,
                choPhep: !_dangGui,
                bieuTuongDau: const Icon(Icons.person_outline),
                kieuBanPhim: TextInputType.emailAddress,
                hanhDongBanPhim: TextInputAction.next,
                khiGui: (_) => _tapTrungMatKhau.requestFocus(),
                kiemTra: (giaTri) {
                  if (KiemTraDuLieu.rong(giaTri)) {
                    return 'Vui lòng nhập tài khoản';
                  }
                  if (KiemTraDuLieu.email(giaTri) != null &&
                      KiemTraDuLieu.soDienThoai(giaTri?.trim()) != null) {
                    return 'Email hoặc số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Phần mật khẩu và nút hiện/ẩn.
              ONhapLieu(
                key: const ValueKey('mat_khau_dang_nhap'),
                nhan: 'Mật khẩu',
                goiY: 'Nhập mật khẩu',
                controller: _matKhau,
                choPhep: !_dangGui,
                anNoiDung: _anMatKhau,
                bieuTuongDau: const Icon(Icons.lock_outline),
                bieuTuongCuoi: IconButton(
                  tooltip: _anMatKhau ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                  onPressed: _dangGui
                      ? null
                      : () => setState(() => _anMatKhau = !_anMatKhau),
                  icon: Icon(
                    _anMatKhau
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                nutTapTrung: _tapTrungMatKhau,
                hanhDongBanPhim: TextInputAction.done,
                khiGui: (_) => _dangNhap(),
                kiemTra: (giaTri) => KiemTraDuLieu.rong(giaTri)
                    ? 'Vui lòng nhập mật khẩu'
                    : null,
              ),
              if (_thongBao != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _thongBao!,
                    style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Phần nút Đăng nhập.
              NutBam(
                nhan: 'Đăng nhập',
                chieuCao: 52,
                dangTai: _dangGui,
                khiNhan: _dangNhap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
