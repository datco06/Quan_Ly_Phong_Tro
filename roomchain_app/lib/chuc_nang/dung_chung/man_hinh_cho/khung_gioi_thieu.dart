import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';

// Bố cục chung cho hai trang giới thiệu.
class KhungGioiThieu extends StatelessWidget {
  const KhungGioiThieu({
    super.key,
    required this.tieuDe,
    required this.moTa,
    required this.trang,
    required this.minhHoa,
    required this.khiTiepTuc,
    required this.khiBoQua,
  });

  final String tieuDe, moTa;
  final int trang;
  final Widget minhHoa;
  final VoidCallback khiTiepTuc, khiBoQua;

  @override
  Widget build(BuildContext context) => BoCucXacThuc(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
    // Phần nút Bỏ qua.
    header: Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: khiBoQua,
        style: TextButton.styleFrom(foregroundColor: BangMau.chuPhu),
        child: const Text(
          'Bỏ qua',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ),
    ),
    noiDung: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần tiêu đề và mô tả.
        Text(tieuDe, style: KieuChu.tieuDeLon.copyWith(height: 1.3)),
        const SizedBox(height: 14),
        Text(moTa, style: KieuChu.noiDung.copyWith(color: BangMau.chuPhu)),
        const SizedBox(height: 18),
        // Phần hình minh họa.
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: AspectRatio(aspectRatio: 1.4, child: minhHoa),
          ),
        ),
        const SizedBox(height: 12),
        // Phần ba chấm chỉ trang.
        Semantics(
          label: 'Trang ${trang + 1} trên 3',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (chiSo) => Container(
                key: ValueKey('cham_$chiSo'),
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: chiSo == trang ? BangMau.chinh : BangMau.vien,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    ),
    // Phần nút Tiếp tục nằm trên vùng an toàn.
    hanhDongDuoi: NutDuoiManHinh(
      nutChinh: NutBam(nhan: 'Tiếp tục', chieuCao: 52, khiNhan: khiTiepTuc),
    ),
  );
}

// Minh họa riêng theo ảnh thiết kế, không chứa chữ hoặc nút giao diện.
class MinhHoaGioiThieu extends StatelessWidget {
  const MinhHoaGioiThieu({super.key, required this.trang});
  final int trang;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/hinh_anh/gioi_thieu/${trang == 0 ? 'ban_do_den_truong' : 'dien_thoai_tim_phong'}.png',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        filterQuality: FilterQuality.medium,
      ),
    ),
  );
}

// Nhân vật minh họa trên thẻ chọn vai trò.
class HinhNhanVat extends StatelessWidget {
  const HinhNhanVat({super.key, this.laChuTro = false});
  final bool laChuTro;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Image.asset(
      'assets/hinh_anh/gioi_thieu/${laChuTro ? 'chu_tro' : 'nguoi_thue'}.png',
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      filterQuality: FilterQuality.medium,
    ),
  );
}
