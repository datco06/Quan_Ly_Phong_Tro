import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'thanh_phan_tien_coc.dart';

// Chạy demo quản lý cọc, chi tiết hợp đồng và tạo quyết toán.
void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    onGenerateRoute: DieuHuong.taoRoute,
    home: const QuanLyTienCoc(),
  ),
);

class QuanLyTienCoc extends StatefulWidget {
  const QuanLyTienCoc({
    super.key,
    this.kho,
    this.trongTab = false,
    this.khiChonDieuHuong,
  });
  final KhoHopDongMau? kho;
  final bool trongTab;
  final ValueChanged<int>? khiChonDieuHuong;
  @override
  State<QuanLyTienCoc> createState() => _QuanLyTienCocState();
}

class _QuanLyTienCocState extends State<QuanLyTienCoc> {
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;
  String _loc = 'tatCa';
  void _veTruoc() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        DieuHuong.danhSachHopDong,
        arguments: _kho,
      );
    }
  }

  void _moChiTiet(HopDong h) => Navigator.pushNamed(
    context,
    DieuHuong.chiTietHopDong,
    arguments: ThamSoHopDong(hopDongId: h.id, kho: _kho),
  );
  Future<void> _quyetToan(HopDong h) async {
    final loi = _kho.lyDoChuaDuDieuKienQuyetToan(h.id);
    if (loi != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chưa thể tạo quyết toán'),
          content: Text(loi),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      return;
    }
    if (mounted) {
      Navigator.pushNamed(
        context,
        DieuHuong.taoQuyetToan,
        arguments: ThamSoHopDong(hopDongId: h.id, kho: _kho),
      );
    }
  }

  Widget _tongCoc() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BangMau.chinh,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng tiền cọc đang khóa',
                style: KieuChu.nhan.copyWith(color: BangMau.nenThe),
              ),
              const SizedBox(height: 8),
              Text(
                '${soTienKhongDonVi(_kho.tongCocDangKhoa)} MockVNDC',
                key: const ValueKey('tongCoc'),
                style: KieuChu.tieuDeTrang.copyWith(color: BangMau.nenThe),
              ),
              const SizedBox(height: 6),
              Text(
                '≈ ${soTienKhongDonVi(_kho.tongCocDangKhoa ~/ KhoHopDongMau.tokenMoiVndDemo)} VND',
                style: KieuChu.chuPhu.copyWith(color: BangMau.nenThe),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          backgroundColor: BangMau.chinhDam,
          child: Icon(Icons.lock_outline, color: BangMau.nenThe),
        ),
      ],
    ),
  );

  Widget _theThongKe(
    String ten,
    String tien,
    String chu,
    Color nen,
    Color mau,
  ) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: nen,
      border: Border.all(color: BangMau.vien),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ten, style: KieuChu.chuPhu),
        const SizedBox(height: 8),
        Text(tien, style: KieuChu.noiDungDam.copyWith(color: mau)),
        const SizedBox(height: 6),
        Text(chu, style: KieuChu.chuNho),
      ],
    ),
  );
  Widget _thongKe() => LayoutBuilder(
    builder: (context, c) {
      final token = _theThongKe(
        'Tiền cọc (Blockchain)',
        '${soTienKhongDonVi(_kho.tongCocDangKhoa)} MockVNDC',
        'Đang giữ trong escrow',
        BangMau.chinhNhat,
        BangMau.chinh,
      );
      final thu = _theThongKe(
        'Doanh thu (VND)',
        dinhDangVND(_kho.doanhThuCocVnd),
        'Từ tiền cọc đã nhận khi quyết toán',
        BangMau.canhBaoNhat,
        BangMau.canhBao,
      );
      if (c.maxWidth < 340 || MediaQuery.textScalerOf(context).scale(14) > 18) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [token, const SizedBox(height: 10), thu],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: token),
            const SizedBox(width: 10),
            Expanded(child: thu),
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final noiDung = ListenableBuilder(
      listenable: _kho,
      builder: (context, _) {
        final ds = _kho.danhSach
            .where(
              (h) =>
                  h.coc != null &&
                  (_loc == 'tatCa' || h.coc!.trangThai.name == _loc),
            )
            .toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  NutBieuTuong(
                    bieuTuong: Icons.arrow_back_ios_new,
                    goiY: 'Quay lại',
                    khiNhan: _veTruoc,
                  ),
                  const Expanded(
                    child: Text(
                      'Quản lý tiền cọc',
                      textAlign: TextAlign.center,
                      style: KieuChu.tieuDeMuc,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Phần tổng cọc và thống kê, lấy từ cùng kho hợp đồng.
                  _tongCoc(),
                  const SizedBox(height: 12),
                  _thongKe(),
                  const SizedBox(height: 10),
                  const Text(
                    'Dữ liệu demo · 1 MockVNDC / 1 VND là quy ước minh họa, không phải tỷ giá hay cam kết đổi tiền thật.',
                    style: KieuChu.chuNho,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      const Text(
                        'Danh sách tiền cọc',
                        style: KieuChu.noiDungDam,
                      ),
                      SizedBox(
                        width: 180,
                        child: OChon<String>(
                          nhan: 'Trạng thái',
                          giaTri: _loc,
                          luaChon: [
                            const LuaChon(giaTri: 'tatCa', nhan: 'Tất cả'),
                            for (final tt in TrangThaiTienCoc.values)
                              LuaChon(giaTri: tt.name, nhan: tt.nhan),
                          ],
                          khiThayDoi: (v) {
                            if (v != null) setState(() => _loc = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (ds.isEmpty)
                    const TrangThaiRong(
                      tieuDe: 'Chưa có khoản cọc',
                      moTa: 'Thử chọn trạng thái khác.',
                      bieuTuong: Icons.lock_outline,
                    ),
                  for (final h in ds) ...[
                    _MucTienCoc(
                      hopDong: h,
                      kho: _kho,
                      khiNhan: () => _moChiTiet(h),
                      khiQuyetToan: () => _quyetToan(h),
                    ),
                    const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
    if (widget.trongTab) return noiDung;
    return BoCucChuTro(
      noiDung: noiDung,
      chiSoChon: 4,
      khiChon: (i) {
        if (widget.khiChonDieuHuong != null) {
          widget.khiChonDieuHuong!(i);
        } else if (i != 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Mục này chưa được kết nối trong bản demo tiền cọc.',
              ),
            ),
          );
        }
      },
    );
  }
}

class _MucTienCoc extends StatelessWidget {
  const _MucTienCoc({
    required this.hopDong,
    required this.kho,
    required this.khiNhan,
    required this.khiQuyetToan,
  });
  final HopDong hopDong;
  final KhoHopDongMau kho;
  final VoidCallback khiNhan, khiQuyetToan;
  @override
  Widget build(BuildContext context) {
    final h = hopDong;
    final coc = h.coc!;
    return Material(
      color: BangMau.nenThe,
      child: InkWell(
        key: ValueKey('coc_${h.id}'),
        onTap: khiNhan,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assignment_outlined, color: BangMau.chinh),
                  const SizedBox(width: 8),
                  Expanded(child: Text(h.maHopDong, style: KieuChu.noiDungDam)),
                  PopupMenuButton<String>(
                    tooltip: 'Thao tác cọc ${h.maHopDong}',
                    onSelected: (_) => khiQuyetToan(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'quyet_toan',
                        child: Text('Tạo quyết toán'),
                      ),
                    ],
                  ),
                ],
              ),
              Text(kho.nguoi(h.nguoiThueId).hoTen, style: KieuChu.chuPhu),
              const SizedBox(height: 4),
              Text(
                'Phòng ${kho.phong(h.phongId).maPhong}',
                style: KieuChu.chuPhu,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: NhanTienCoc(trangThai: coc.trangThai),
              ),
              const SizedBox(height: 6),
              Text(
                '${soTienKhongDonVi(coc.soToken)} ${coc.loaiToken}',
                style: KieuChu.noiDungDam,
                textAlign: TextAlign.right,
              ),
              if (h.ghiNhanCocLuc != null)
                Text(
                  dinhDangNgay(h.ghiNhanCocLuc!),
                  style: KieuChu.chuNho,
                  textAlign: TextAlign.right,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
