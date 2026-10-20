import 'dart:typed_data';
import 'dart:ui' as giao_dien;

import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';

// Hồ sơ demo trong bộ nhớ, không chứa mật khẩu hoặc trạng thái xác thực.
class HoSoNguoiThue {
  HoSoNguoiThue({
    required this.truongHoc,
    required this.phuongTien,
    required List<String> khuVucQuanTam,
    Uint8List? anhDaiDien,
  }) : khuVucQuanTam = List.unmodifiable(khuVucQuanTam),
       anhDaiDien = anhDaiDien == null ? null : Uint8List.fromList(anhDaiDien);

  final String truongHoc, phuongTien;
  final List<String> khuVucQuanTam;
  final Uint8List? anhDaiDien;
  String get vaiTro => 'TENANT';
}

class HoanThienHoSo extends StatefulWidget {
  const HoanThienHoSo({
    super.key,
    required this.vaiTro,
    this.khiChonAnh,
    this.khiHoanTat,
  }) : assert(vaiTro == 'TENANT');

  final String vaiTro;
  final Future<Uint8List?> Function()? khiChonAnh;
  final Future<void> Function(HoSoNguoiThue hoSo)? khiHoanTat;

  @override
  State<HoanThienHoSo> createState() => _HoanThienHoSoState();
}

class _HoanThienHoSoState extends State<HoanThienHoSo> {
  final _khoaForm = GlobalKey<FormState>();
  final _truongHoc = TextEditingController();
  final _khuVuc = TextEditingController();
  final _tapTrungKhuVuc = FocusNode();
  String _phuongTien = 'XE_MAY';
  Uint8List? _anhDaiDien;
  bool _daGui = false, _dangLuu = false, _dangChonAnh = false;
  HoSoNguoiThue? _hoSoDemo;

  @override
  void dispose() {
    _truongHoc.dispose();
    _khuVuc.dispose();
    _tapTrungKhuVuc.dispose();
    super.dispose();
  }

  // Tách các khu vực bằng dấu phẩy, bỏ trống và loại tên trùng nhau.
  List<String> _tachKhuVuc(String giaTri) {
    final daCo = <String>{};
    return giaTri.split(',').map((ten) => ten.trim()).where((ten) {
      return ten.isNotEmpty && daCo.add(ten.toLowerCase());
    }).toList();
  }

  void _thongBao(String noiDung) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(noiDung)));
  }

  // Bộ chọn ảnh được truyền từ nền tảng; hủy chọn không làm mất ảnh cũ.
  Future<void> _chonAnh() async {
    if (_dangChonAnh || _dangLuu) return;
    final chonAnh = widget.khiChonAnh;
    if (chonAnh == null) {
      _thongBao(
        'Chọn ảnh chưa được kết nối. Bạn có thể hoàn tất mà không có ảnh.',
      );
      return;
    }
    setState(() => _dangChonAnh = true);
    try {
      final anh = await chonAnh();
      if (!mounted || anh == null) return;
      if (anh.isEmpty || anh.lengthInBytes > 5 * 1024 * 1024) {
        _thongBao('Vui lòng chọn ảnh hợp lệ, dung lượng không quá 5 MB.');
        return;
      }
      final boGiaiMa = await giao_dien.instantiateImageCodec(
        anh,
        targetWidth: 512,
      );
      try {
        final khung = await boGiaiMa.getNextFrame();
        khung.image.dispose();
      } finally {
        boGiaiMa.dispose();
      }
      if (mounted) setState(() => _anhDaiDien = Uint8List.fromList(anh));
    } catch (_) {
      if (mounted) {
        _thongBao(
          'Không thể mở ảnh. Hãy kiểm tra định dạng hoặc quyền truy cập rồi thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _dangChonAnh = false);
    }
  }

  Future<void> _hoanTat() async {
    if (_dangLuu || _dangChonAnh || widget.vaiTro != 'TENANT') return;
    setState(() => _daGui = true);
    if (!_khoaForm.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final hoSo = HoSoNguoiThue(
      truongHoc: _truongHoc.text.trim(),
      phuongTien: _phuongTien,
      khuVucQuanTam: _tachKhuVuc(_khuVuc.text),
      anhDaiDien: _anhDaiDien,
    );
    setState(() {
      _hoSoDemo = hoSo;
      _dangLuu = true;
    });
    try {
      // Chỉ gọi điều hướng khi Trang chủ Tenant đã có và được nối qua callback.
      await widget.khiHoanTat?.call(hoSo);
    } catch (_) {
      if (mounted) {
        _thongBao('Đã lưu hồ sơ demo, nhưng chưa thể mở trang tiếp theo.');
      }
    } finally {
      if (mounted) setState(() => _dangLuu = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chuDe = Theme.of(context);
    if (widget.vaiTro != 'TENANT') {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: Text('Hồ sơ này chỉ dành cho người thuê.')),
        ),
      );
    }
    return Theme(
      data: chuDe.copyWith(
        inputDecorationTheme: chuDe.inputDecorationTheme.copyWith(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BangMau.vien),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BangMau.chinh, width: 1.5),
          ),
        ),
      ),
      child: BoCucXacThuc(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        // Giữ nút Hoàn tất trên bàn phím và vùng an toàn.
        hanhDongDuoi: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: NutBam(
              nhan: 'Hoàn tất',
              chieuCao: 52,
              dangTai: _dangLuu,
              voHieuHoa: _dangChonAnh,
              khiNhan: _hoanTat,
            ),
          ),
        ),
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
                voHieuHoa: _dangLuu,
                khiNhan: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 8),
              Text(
                'Hoàn thiện hồ sơ',
                style: KieuChu.tieuDeLon.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 6),
              Text(
                'Giúp chúng tôi gợi ý phòng phù hợp hơn với nhu cầu của bạn',
                style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
              ),
              const SizedBox(height: 20),
              // Phần avatar và nút camera.
              Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Semantics(
                          button: true,
                          label: 'Chọn ảnh đại diện',
                          child: Material(
                            color: BangMau.vien,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: _dangLuu || _dangChonAnh ? null : _chonAnh,
                              child: SizedBox(
                                width: 108,
                                height: 108,
                                child: _anhDaiDien == null
                                    ? const Icon(
                                        Icons.person_outline,
                                        size: 58,
                                        color: BangMau.chuPhu,
                                      )
                                    : Image.memory(
                                        _anhDaiDien!,
                                        key: const ValueKey('anh_dai_dien'),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: BangMau.nenThe,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: IconButton(
                            tooltip: 'Đổi ảnh đại diện',
                            onPressed: _dangChonAnh || _dangLuu
                                ? null
                                : _chonAnh,
                            style: IconButton.styleFrom(
                              backgroundColor: BangMau.chinh,
                              foregroundColor: BangMau.nenThe,
                              minimumSize: const Size(40, 40),
                              padding: const EdgeInsets.all(8),
                            ),
                            icon: _dangChonAnh
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: BangMau.nenThe,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Phần trường học.
              Text(
                'Trường học',
                style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
              ),
              const SizedBox(height: 6),
              Semantics(
                label: 'Trường học',
                child: ONhapLieu(
                  key: const ValueKey('truong_hoc'),
                  nhan: '',
                  goiY: 'Đại học Bách Khoa Hà Nội',
                  controller: _truongHoc,
                  choPhep: !_dangLuu,
                  hanhDongBanPhim: TextInputAction.next,
                  khiGui: (_) => _tapTrungKhuVuc.requestFocus(),
                  kiemTra: (ten) {
                    if (KiemTraDuLieu.rong(ten)) {
                      return 'Vui lòng nhập trường học';
                    }
                    if (ten!.trim().length > 200) {
                      return 'Tên trường không quá 200 ký tự';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Phần chọn phương tiện.
              Text(
                'Phương tiện thường dùng',
                style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
              ),
              const SizedBox(height: 6),
              Semantics(
                label: 'Phương tiện thường dùng',
                child: OChon<String>(
                  nhan: '',
                  giaTri: _phuongTien,
                  luaChon: const [
                    LuaChon(giaTri: 'XE_MAY', nhan: 'Xe máy'),
                    LuaChon(giaTri: 'XE_BUYT', nhan: 'Xe buýt'),
                    LuaChon(giaTri: 'DI_BO', nhan: 'Đi bộ'),
                  ],
                  kiemTra: (giaTri) =>
                      const ['XE_MAY', 'XE_BUYT', 'DI_BO'].contains(giaTri)
                      ? null
                      : 'Vui lòng chọn phương tiện hợp lệ',
                  khiThayDoi: _dangLuu
                      ? null
                      : (giaTri) {
                          if (giaTri != null) {
                            setState(() => _phuongTien = giaTri);
                          }
                        },
                ),
              ),
              const SizedBox(height: 16),
              // Phần nhập nhiều khu vực, ngăn cách bằng dấu phẩy.
              Text(
                'Khu vực quan tâm',
                style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
              ),
              const SizedBox(height: 6),
              Semantics(
                label: 'Khu vực quan tâm',
                child: ONhapLieu(
                  key: const ValueKey('khu_vuc'),
                  nhan: '',
                  goiY: 'Hà Đông, Cầu Giấy, Thanh Xuân',
                  controller: _khuVuc,
                  nutTapTrung: _tapTrungKhuVuc,
                  choPhep: !_dangLuu,
                  hanhDongBanPhim: TextInputAction.done,
                  khiGui: (_) => _hoanTat(),
                  kiemTra: (giaTri) => _tachKhuVuc(giaTri ?? '').isEmpty
                      ? 'Vui lòng nhập ít nhất một khu vực'
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              if (_hoSoDemo != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    widget.khiHoanTat == null
                        ? 'Đã hoàn thiện hồ sơ demo. Trang chủ người thuê chưa được triển khai.'
                        : 'Đã hoàn thiện hồ sơ demo.',
                    style: KieuChu.noiDung.copyWith(color: BangMau.chinh),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
