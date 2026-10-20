import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'khung_gioi_thieu.dart';

class ChonVaiTro extends StatefulWidget {
  const ChonVaiTro({super.key, this.khiDangKy, this.khiDangNhap});

  // Nối hai callback khi màn hình đăng ký và đăng nhập đã sẵn sàng.
  final ValueChanged<String>? khiDangKy;
  final VoidCallback? khiDangNhap;

  @override
  State<ChonVaiTro> createState() => _ChonVaiTroState();
}

class _ChonVaiTroState extends State<ChonVaiTro> {
  VaiTro _vaiTro = VaiTro.tenant;

  void _batDau() {
    final vaiTro = _vaiTro == VaiTro.tenant ? 'TENANT' : 'LANDLORD';
    if (widget.khiDangKy != null) {
      widget.khiDangKy!(vaiTro);
    } else {
      Navigator.of(context).pushNamed(DieuHuong.dangKy, arguments: vaiTro);
    }
  }

  void _boQua() {
    if (widget.khiDangNhap != null) {
      widget.khiDangNhap!();
    } else {
      _thongBao('Màn hình đăng nhập đang được hoàn thiện.');
    }
  }

  void _thongBao(String noiDung) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(noiDung)));
  }

  @override
  Widget build(BuildContext context) => BoCucXacThuc(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
    // Phần nút quay lại và Bỏ qua.
    header: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NutBieuTuong(
          bieuTuong: Icons.arrow_back,
          goiY: 'Quay lại',
          khiNhan: Navigator.of(context).canPop()
              ? () => Navigator.of(context).pop()
              : null,
        ),
        TextButton(
          onPressed: _boQua,
          style: TextButton.styleFrom(foregroundColor: BangMau.chuPhu),
          child: const Text(
            'Bỏ qua',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    ),
    noiDung: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần tiêu đề và mô tả.
        Text(
          'Ở trọ an tâm\nvới cộng đồng đáng tin',
          style: KieuChu.tieuDeLon.copyWith(height: 1.3),
        ),
        const SizedBox(height: 14),
        Text(
          'Xem đánh giá, liên hệ chủ trọ và quản lý hợp đồng dễ dàng',
          style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu),
        ),
        const SizedBox(height: 32),
        // Phần chọn người thuê.
        _TheVaiTro(
          key: const ValueKey('vai_tro_TENANT'),
          tieuDe: 'Tôi muốn tìm\nvà thuê phòng',
          moTa: 'Dành cho sinh viên, người đi làm',
          daChon: _vaiTro == VaiTro.tenant,
          khiChon: () => setState(() => _vaiTro = VaiTro.tenant),
        ),
        const SizedBox(height: 16),
        // Phần chọn chủ trọ.
        _TheVaiTro(
          key: const ValueKey('vai_tro_LANDLORD'),
          tieuDe: 'Tôi là chủ trọ',
          moTa: 'Quản lý phòng trọ, hợp đồng và tài chính',
          laChuTro: true,
          daChon: _vaiTro == VaiTro.landlord,
          khiChon: () => setState(() => _vaiTro = VaiTro.landlord),
        ),
        const SizedBox(height: 24),
      ],
    ),
    // Phần nút Bắt đầu ngay.
    hanhDongDuoi: NutDuoiManHinh(
      nutChinh: NutBam(nhan: 'Bắt đầu ngay', chieuCao: 52, khiNhan: _batDau),
    ),
  );
}

// Thẻ chọn vai trò, chỉ dùng cho màn hình này.
class _TheVaiTro extends StatelessWidget {
  const _TheVaiTro({
    super.key,
    required this.tieuDe,
    required this.moTa,
    required this.daChon,
    required this.khiChon,
    this.laChuTro = false,
  });

  final String tieuDe, moTa;
  final bool daChon, laChuTro;
  final VoidCallback khiChon;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: daChon,
    inMutuallyExclusiveGroup: true,
    button: true,
    child: Material(
      color: BangMau.nenThe,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: daChon ? BangMau.chinh.withValues(alpha: 0.3) : BangMau.vien,
          width: daChon ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: khiChon,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 30, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Phần nhân vật sát cạnh dưới của thẻ.
                  SizedBox(
                    width: 100,
                    height: 136,
                    child: HinhNhanVat(laChuTro: laChuTro),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tieuDe, style: KieuChu.tieuDeThe),
                          const SizedBox(height: 8),
                          Text(
                            moTa,
                            style: KieuChu.noiDung.copyWith(
                              color: BangMau.chuPhu,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Phần dấu chọn ở góc trên bên phải.
            Positioned(
              top: 14,
              right: 14,
              child: Icon(
                daChon ? Icons.check_circle : Icons.radio_button_unchecked,
                color: daChon ? BangMau.chinh : BangMau.chuMo,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
