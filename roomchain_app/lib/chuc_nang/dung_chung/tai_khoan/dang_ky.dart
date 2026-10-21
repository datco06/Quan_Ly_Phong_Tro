import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../ung_dung/dieu_huong.dart';

// Dữ liệu tạm cho bước 2, chỉ truyền trong bộ nhớ, không ghi log hoặc lưu trữ.
class ThongTinDangKyTam {
  const ThongTinDangKyTam({
    required this.hoTen,
    required this.lienHe,
    required this.matKhau,
    required this.vaiTro,
  });

  final String hoTen, lienHe, matKhau, vaiTro;
}

class DangKy extends StatefulWidget {
  const DangKy({super.key, required this.vaiTro, this.khiTiepTuc})
    : assert(vaiTro == 'TENANT' || vaiTro == 'LANDLORD');

  final String vaiTro;
  final Future<void> Function(ThongTinDangKyTam duLieu)? khiTiepTuc;

  @override
  State<DangKy> createState() => _DangKyState();
}

class _DangKyState extends State<DangKy> {
  final _khoaForm = GlobalKey<FormState>();
  final _hoTen = TextEditingController();
  final _lienHe = TextEditingController();
  final _matKhau = TextEditingController();
  final _xacNhan = TextEditingController();
  final _tapTrungLienHe = FocusNode();
  final _tapTrungMatKhau = FocusNode();
  final _tapTrungXacNhan = FocusNode();
  late final TapGestureRecognizer _nhanDieuKhoan;
  late final TapGestureRecognizer _nhanBaoMat;
  bool _anMatKhau = true, _anXacNhan = true;
  bool _dongY = false, _daGui = false, _dangGui = false;
  String? _loiDieuKhoan, _loiXuLy;

  @override
  void initState() {
    super.initState();
    _nhanDieuKhoan = TapGestureRecognizer()
      ..onTap = () => _xemTaiLieu('Điều khoản sử dụng');
    _nhanBaoMat = TapGestureRecognizer()
      ..onTap = () => _xemTaiLieu('Chính sách bảo mật');
  }

  @override
  void dispose() {
    _hoTen.dispose();
    _lienHe.dispose();
    _matKhau.dispose();
    _xacNhan.dispose();
    _tapTrungLienHe.dispose();
    _tapTrungMatKhau.dispose();
    _tapTrungXacNhan.dispose();
    _nhanDieuKhoan.dispose();
    _nhanBaoMat.dispose();
    super.dispose();
  }

  String? _kiemTraHoTen(String? giaTri) {
    final ten = giaTri?.trim() ?? '';
    if (ten.isEmpty) return 'Vui lòng nhập họ và tên';
    if (ten.length > 100) return 'Họ và tên không quá 100 ký tự';
    return null;
  }

  String? _kiemTraLienHe(String? giaTri) {
    final lienHe = giaTri?.trim() ?? '';
    if (lienHe.isEmpty) return 'Vui lòng nhập email hoặc số điện thoại';
    if (KiemTraDuLieu.email(lienHe) == null ||
        KiemTraDuLieu.soDienThoai(lienHe) == null) {
      return null;
    }
    return 'Email hoặc số điện thoại không hợp lệ';
  }

  String? _kiemTraMatKhau(String? giaTri) {
    if (KiemTraDuLieu.rong(giaTri)) return 'Vui lòng nhập mật khẩu';
    if (giaTri!.length < 8) return 'Mật khẩu cần ít nhất 8 ký tự';
    return null;
  }

  // Xử lý form; chưa gọi API đăng ký thật.
  Future<void> _taoTaiKhoan() async {
    if (_dangGui) return;
    setState(() {
      _daGui = true;
      _loiXuLy = null;
      _loiDieuKhoan = _dongY
          ? null
          : 'Vui lòng đồng ý điều khoản và chính sách bảo mật';
    });
    final hopLe = _khoaForm.currentState!.validate();
    if (!hopLe || !_dongY) return;
    FocusScope.of(context).unfocus();
    if (widget.khiTiepTuc == null) {
      if (widget.vaiTro == 'TENANT') {
        // Giữ form A04 khi quay lại; không truyền mật khẩu vào route hồ sơ.
        setState(() => _dangGui = true);
        try {
          await Navigator.of(context)
              .pushNamed(DieuHuong.hoanThienHoSo, arguments: widget.vaiTro);
        } finally {
          if (mounted) setState(() => _dangGui = false);
        }
        return;
      }
      final hoSo = 'chủ trọ';
      setState(
        () => _loiXuLy =
            'Thông tin hợp lệ. Bước hoàn thiện hồ sơ $hoSo chưa có. Tài khoản chưa được tạo.',
      );
      return;
    }
    setState(() => _dangGui = true);
    final lienHe = _lienHe.text.trim();
    try {
      await widget.khiTiepTuc!(
        ThongTinDangKyTam(
          hoTen: _hoTen.text.trim(),
          lienHe: lienHe.contains('@') ? lienHe : lienHe.replaceAll(' ', ''),
          matKhau: _matKhau.text,
          vaiTro: widget.vaiTro,
        ),
      );
      if (mounted) {
        _matKhau.clear();
        _xacNhan.clear();
        _daGui = false;
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loiXuLy = 'Chưa thể tiếp tục. Vui lòng thử lại.');
      }
    } finally {
      if (mounted) setState(() => _dangGui = false);
    }
  }

  void _xemTaiLieu(String tieuDe) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tieuDe),
        content: const Text('Nội dung tài liệu chưa được cung cấp.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chuDe = Theme.of(context);
    // Điều chỉnh input riêng cho A04, giữ nguyên Theme dùng chung.
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BangMau.vien),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BangMau.chinh, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BangMau.loi),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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
              // Phần quay lại, tiêu đề và bước đăng ký.
              NutBieuTuong(
                bieuTuong: Icons.arrow_back,
                goiY: 'Quay lại',
                voHieuHoa: _dangGui,
                khiNhan: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 8),
              Text(
                'Tạo tài khoản mới',
                style: KieuChu.tieuDeLon.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                'Bước 1/2',
                style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
              ),
              const SizedBox(height: 24),
              // Phần bốn ô nhập thông tin.
              ONhapLieu(
                key: const ValueKey('ho_ten'),
                nhan: 'Họ và tên',
                goiY: 'Nhập họ và tên',
                controller: _hoTen,
                kiemTra: _kiemTraHoTen,
                choPhep: !_dangGui,
                bieuTuongDau: const Icon(Icons.person_outline),
                hanhDongBanPhim: TextInputAction.next,
                khiGui: (_) => _tapTrungLienHe.requestFocus(),
              ),
              const SizedBox(height: 16),
              ONhapLieu(
                key: const ValueKey('lien_he'),
                nhan: 'Email hoặc số điện thoại',
                goiY: 'Nhập email hoặc số điện thoại',
                controller: _lienHe,
                kiemTra: _kiemTraLienHe,
                choPhep: !_dangGui,
                kieuBanPhim: TextInputType.emailAddress,
                bieuTuongDau: const Icon(Icons.mail_outline),
                nutTapTrung: _tapTrungLienHe,
                hanhDongBanPhim: TextInputAction.next,
                khiGui: (_) => _tapTrungMatKhau.requestFocus(),
              ),
              const SizedBox(height: 16),
              ONhapLieu(
                key: const ValueKey('mat_khau'),
                nhan: 'Mật khẩu',
                goiY: 'Nhập mật khẩu',
                controller: _matKhau,
                kiemTra: _kiemTraMatKhau,
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
                hanhDongBanPhim: TextInputAction.next,
                khiGui: (_) => _tapTrungXacNhan.requestFocus(),
              ),
              const SizedBox(height: 16),
              ONhapLieu(
                key: const ValueKey('xac_nhan'),
                nhan: 'Xác nhận mật khẩu',
                goiY: 'Nhập lại mật khẩu',
                controller: _xacNhan,
                choPhep: !_dangGui,
                kiemTra: (giaTri) {
                  if (giaTri == null || giaTri.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  return giaTri == _matKhau.text
                      ? null
                      : 'Mật khẩu xác nhận không khớp';
                },
                anNoiDung: _anXacNhan,
                bieuTuongDau: const Icon(Icons.verified_user_outlined),
                bieuTuongCuoi: IconButton(
                  tooltip: _anXacNhan
                      ? 'Hiện xác nhận mật khẩu'
                      : 'Ẩn xác nhận mật khẩu',
                  onPressed: _dangGui
                      ? null
                      : () => setState(() => _anXacNhan = !_anXacNhan),
                  icon: Icon(
                    _anXacNhan
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                nutTapTrung: _tapTrungXacNhan,
                hanhDongBanPhim: TextInputAction.done,
                khiGui: (_) => _taoTaiKhoan(),
              ),
              const SizedBox(height: 16),
              // Phần đồng ý điều khoản.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    semanticLabel: 'Đồng ý điều khoản và chính sách bảo mật',
                    value: _dongY,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: _dangGui
                        ? null
                        : (giaTri) => setState(() {
                            _dongY = giaTri ?? false;
                            _loiDieuKhoan = _dongY
                                ? null
                                : (_daGui
                                      ? 'Vui lòng đồng ý điều khoản và chính sách bảo mật'
                                      : null);
                          }),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text.rich(
                        TextSpan(
                          style: KieuChu.noiDung.copyWith(
                            color: BangMau.chuPhu,
                          ),
                          children: [
                            const TextSpan(text: 'Tôi đồng ý với '),
                            TextSpan(
                              text: 'Điều khoản sử dụng',
                              style: const TextStyle(
                                color: BangMau.chinh,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: _nhanDieuKhoan,
                            ),
                            const TextSpan(text: ' và '),
                            TextSpan(
                              text: 'Chính sách bảo mật',
                              style: const TextStyle(
                                color: BangMau.chinh,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: _nhanBaoMat,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_loiDieuKhoan != null) ...[
                const SizedBox(height: 8),
                Text(
                  _loiDieuKhoan!,
                  style: KieuChu.chuPhu.copyWith(color: BangMau.loi),
                ),
              ],
              if (_loiXuLy != null) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _loiXuLy!,
                    style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              // Phần nút Tạo tài khoản, cuộn cùng form khi có bàn phím.
              NutBam(
                nhan: 'Tạo tài khoản',
                chieuCao: 52,
                dangTai: _dangGui,
                khiNhan: _taoTaiKhoan,
              ),
              const SizedBox(height: 12),
              // Phần chuyển sang đăng nhập khi đã có tài khoản.
              Center(
                child: TextButton(
                  onPressed: _dangGui
                      ? null
                      : () =>
                            Navigator.of(context).pushNamed(DieuHuong.dangNhap),
                  child: Text.rich(
                    TextSpan(
                      text: 'Bạn đã có tài khoản? ',
                      style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
                      children: const [
                        TextSpan(
                          text: 'Đăng nhập',
                          style: TextStyle(
                            color: BangMau.chinh,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
