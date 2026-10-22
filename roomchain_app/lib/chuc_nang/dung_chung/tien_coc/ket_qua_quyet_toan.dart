import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/mo_hinh/quyet_toan_tien_coc.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../ung_dung/dieu_huong.dart';

// Chạy riêng L15 bằng bản ghi hoàn tất được đánh dấu rõ là dữ liệu demo.
void main() {
  final kho = KhoHopDongMau.demoKetQuaHoanTat();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ChuDeUngDung.sang,
      onGenerateRoute: DieuHuong.taoRoute,
      home: KetQuaQuyetToan(quyetToanId: 'QT-demo-hoan-tat', kho: kho),
    ),
  );
}

class KetQuaQuyetToan extends StatelessWidget {
  const KetQuaQuyetToan({super.key, required this.quyetToanId, this.kho});
  final String quyetToanId;
  final KhoHopDongMau? kho;
  KhoHopDongMau get _kho => kho ?? KhoHopDongMau.dungChung;

  void _quayLai(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        DieuHuong.quanLyTienCoc,
        arguments: _kho,
      );
    }
  }

  Widget _tieuDe(String chu) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 12),
    child: Text(chu, style: KieuChu.noiDungDam.copyWith(fontSize: 16)),
  );

  Future<void> _copyTx(BuildContext context, String tx) async {
    try {
      await Clipboard.setData(ClipboardData(text: tx));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã sao chép toàn bộ Tx Hash demo.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể sao chép. Vui lòng thử lại.'),
          ),
        );
      }
    }
  }

  // Phần đầu trang: trạng thái lấy từ xác nhận và biên nhận giao dịch.
  Widget _thongTinDau(BuildContext context, QuyetToanTienCoc q) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.description_outlined, color: BangMau.chinh),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.maQuyetToan, style: KieuChu.tieuDeThe),
            const SizedBox(height: 4),
            Text(
              q.ngayTao == null
                  ? 'Chưa ghi nhận ngày tạo'
                  : 'Tạo ngày ${dinhDangNgayGio(q.ngayTao!)}',
              style: KieuChu.chuNho,
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .4,
        ),
        child: NhanTrangThai(nhan: q.nhanKetQua, trangThai: q.mauKetQua),
      ),
    ],
  );

  Widget _thongTinHopDong(HopDong h) => Column(
    children: [
      DongThongTin(nhan: 'Hợp đồng', giaTri: h.maHopDong),
      DongThongTin(nhan: 'Phòng', giaTri: _kho.phong(h.phongId).maPhong),
      DongThongTin(nhan: 'Người thuê', giaTri: _kho.nguoi(h.nguoiThueId).hoTen),
      DongThongTin(
        nhan: 'Thời hạn',
        giaTri:
            '${dinhDangNgay(h.ngayBatDau)} – ${dinhDangNgay(h.ngayKetThuc)}',
      ),
    ],
  );

  Widget _xacNhan(QuyetToanTienCoc q) => Column(
    children: [
      _MocXacNhan(
        nhan: 'Người thuê xác nhận',
        thoiGian: q.nguoiThueXacNhanLuc,
        cuoi: false,
      ),
      _MocXacNhan(
        nhan: 'Bên cho thuê',
        thoiGian: q.chuTroXacNhanLuc,
        cuoi: true,
      ),
    ],
  );

  // Các con số là tham chiếu VND; khi chưa hoàn tất chỉ hiển thị phân chia dự kiến.
  Widget _phanChia(HopDong h, QuyetToanTienCoc q) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!q.daHoanTat)
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Phân chia dự kiến theo bản quyết toán, chưa ghi nhận đã nhận tiền.',
            style: KieuChu.chuPhu,
          ),
        ),
      DongTien(tenKhoanThu: 'Tổng tiền cọc', soTien: q.tienCocBanDau),
      DongTien(
        tenKhoanThu: 'Tổng khấu trừ',
        soTien: q.tongKhauTru,
        mau: BangMau.loi,
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: BangMau.chinhNhat,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DongTien(
          tenKhoanThu: 'Hoàn trả cho người thuê',
          soTien: q.nguoiThueNhanThamChieu,
          mau: BangMau.chinh,
          inDam: true,
        ),
      ),
      DongTien(
        tenKhoanThu: 'Nhận về cho chủ nhà',
        soTien: q.chuTroNhanThamChieu,
        inDam: true,
      ),
      const SizedBox(height: 8),
      const Text(
        'Giá trị tham chiếu VND của biên bản. MockVNDC là token thử nghiệm, không cam kết quy đổi thành VND thật.',
        style: KieuChu.chuNho,
      ),
      if (h.thoaThuanKetThucSom != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Theo thỏa thuận kết thúc sớm: ${h.thoaThuanKetThucSom!.noiDung}',
            style: KieuChu.chuPhu,
          ),
        ),
    ],
  );

  Widget _giaoDich(BuildContext context, HopDong h, QuyetToanTienCoc q) {
    final tx = q.txHashHopLe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Giao dịch mô phỏng · Dữ liệu demo', style: KieuChu.chuPhu),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: Text('Tx Hash', style: KieuChu.chuPhu)),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                tx == null
                    ? (q.txHash == null
                          ? 'Chưa phát sinh giao dịch'
                          : 'Tx Hash không hợp lệ')
                    : '${tx.substring(0, 12)}…${tx.substring(tx.length - 10)}',
                style: KieuChu.chuPhu,
                textAlign: TextAlign.right,
              ),
            ),
            if (tx != null)
              NutBieuTuong(
                bieuTuong: Icons.copy_outlined,
                goiY: 'Sao chép Tx Hash',
                khiNhan: () => _copyTx(context, tx),
              ),
          ],
        ),
        if (q.thoiGianGiaoDich != null)
          DongThongTin(
            nhan: 'Thời gian xử lý',
            giaTri: dinhDangNgayGio(q.thoiGianGiaoDich!),
          ),
        if (q.daHoanTat)
          DongThongTin(
            nhan: 'Hoàn tất lúc',
            giaTri: dinhDangNgayGio(q.hoanTatLuc!),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text('Trạng thái giao dịch', style: KieuChu.chuPhu),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: NhanTrangThai(
                  nhan: q.nhanGiaoDich,
                  trangThai: q.mauGiaoDich,
                ),
              ),
            ],
          ),
        ),
        if (h.coc != null)
          DongThongTin(
            nhan: 'Token theo bản ghi cọc',
            giaTri:
                '${dinhDangVND(h.coc!.soToken).replaceAll('đ', '')} ${h.coc!.loaiToken}',
          ),
        if (q.trangThaiGiaoDich == TrangThaiGiaoDichQuyetToan.thatBai)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: ThongBaoNoiDung(
              loai: LoaiThongBao.loi,
              noiDung: 'Giao dịch demo thất bại. Chưa ghi nhận hoàn cọc hoặc phân chia cho các bên.',
            ),
          ),
        if (q.trangThaiGiaoDich == TrangThaiGiaoDichQuyetToan.thanhCong &&
            !q.daHoanTat)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: ThongBaoNoiDung(
              loai: LoaiThongBao.canhBao,
              noiDung: 'Biên nhận chưa đủ xác nhận, mã giao dịch hoặc thời điểm hoàn thành. Chưa thể kết luận đã giải ngân.',
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Tx Hash demo không phải hash tài liệu PDF và chưa được kiểm chứng trên mạng Blockchain.',
          style: KieuChu.chuNho,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _kho,
    builder: (context, _) {
      final h = _kho.hopDongTheoQuyetToan(quyetToanId);
      final q = h?.quyetToan;
      final hopLe =
          h != null &&
          q != null &&
          q.hopDongId == h.id &&
          _kho.phongTro.any((p) => p.id == h.phongId) &&
          _kho.nguoiThue.any((n) => n.id == h.nguoiThueId);
      final tienHopLe =
          hopLe && q.phanChiaHopLe && q.tienCocBanDau == h.tienCoc;
      return Scaffold(
        backgroundColor: BangMau.nenThe,
        appBar: AppBar(
          title: Text(
            'Kết quả quyết toán',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: NutBieuTuong(
            bieuTuong: Icons.arrow_back_ios_new,
            goiY: 'Quay lại',
            khiNhan: () => _quayLai(context),
          ),
        ),
        body: SafeArea(
          child: !hopLe
              ? const TrangThaiRong(
                  tieuDe: 'Không tìm thấy quyết toán',
                  moTa: 'Vui lòng quay lại và chọn bản quyết toán đã được lưu.',
                  bieuTuong: Icons.description_outlined,
                )
              : !tienHopLe
              ? const TrangThaiRong(
                  tieuDe: 'Dữ liệu quyết toán chưa hợp lệ',
                  moTa: 'Kiểm tra tiền cọc và tổng phân chia trước khi xem kết quả.',
                  bieuTuong: Icons.error_outline,
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _thongTinDau(context, q),
                    const SizedBox(height: 16),
                    const Divider(),
                    _tieuDe('Thông tin hợp đồng'),
                    _thongTinHopDong(h),
                    _tieuDe('Trạng thái xác nhận'),
                    _xacNhan(q),
                    _tieuDe('Kết quả quyết toán'),
                    _phanChia(h, q),
                    _tieuDe('Giao dịch trên blockchain'),
                    _giaoDich(context, h, q),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            DieuHuong.chiTietHopDong,
                            arguments: ThamSoHopDong(
                              hopDongId: h.id,
                              kho: _kho,
                            ),
                          ),
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('Xem hợp đồng'),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            DieuHuong.quanLyTienCoc,
                            arguments: _kho,
                          ),
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('Quản lý tiền cọc'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      );
    },
  );
}

extension _HienThiKetQua on QuyetToanTienCoc {
  String get nhanKetQua {
    if (!phanChiaHopLe) return 'Cần kiểm tra dữ liệu';
    if (trangThaiGiaoDich == TrangThaiGiaoDichQuyetToan.thatBai) {
      return 'Thất bại';
    }
    if (daHoanTat) return 'Hoàn tất';
    if (chuTroXacNhanLuc == null) return 'Chờ chủ trọ xác nhận';
    if (nguoiThueXacNhanLuc == null) return 'Chờ người thuê xác nhận';
    if (trangThaiGiaoDich == TrangThaiGiaoDichQuyetToan.dangXuLy) {
      return 'Đang thực hiện giao dịch';
    }
    return 'Đã đủ xác nhận';
  }

  TrangThaiHienThi get mauKetQua => daHoanTat
      ? TrangThaiHienThi.thanhCong
      : trangThaiGiaoDich == TrangThaiGiaoDichQuyetToan.thatBai
      ? TrangThaiHienThi.thatBai
      : TrangThaiHienThi.choDuyet;
  String get nhanGiaoDich => switch (trangThaiGiaoDich) {
    TrangThaiGiaoDichQuyetToan.chuaGui => 'Chưa gửi',
    TrangThaiGiaoDichQuyetToan.dangXuLy => 'Đang xử lý',
    TrangThaiGiaoDichQuyetToan.thanhCong =>
      daHoanTat ? 'Thành công' : 'Cần kiểm tra biên nhận',
    TrangThaiGiaoDichQuyetToan.thatBai => 'Thất bại',
  };
  TrangThaiHienThi get mauGiaoDich => switch (trangThaiGiaoDich) {
    TrangThaiGiaoDichQuyetToan.chuaGui => TrangThaiHienThi.choDuyet,
    TrangThaiGiaoDichQuyetToan.dangXuLy => TrangThaiHienThi.dangXuLy,
    TrangThaiGiaoDichQuyetToan.thanhCong =>
      daHoanTat ? TrangThaiHienThi.thanhCong : TrangThaiHienThi.choDuyet,
    TrangThaiGiaoDichQuyetToan.thatBai => TrangThaiHienThi.thatBai,
  };
}

class _MocXacNhan extends StatelessWidget {
  const _MocXacNhan({
    required this.nhan,
    required this.thoiGian,
    required this.cuoi,
  });
  final String nhan;
  final DateTime? thoiGian;
  final bool cuoi;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final trangThai = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          NhanTrangThai(
            nhan: thoiGian == null ? 'Chờ xác nhận' : 'Đã xác nhận',
            trangThai: thoiGian == null
                ? TrangThaiHienThi.choDuyet
                : TrangThaiHienThi.thanhCong,
          ),
          if (thoiGian != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                dinhDangNgayGio(thoiGian!),
                style: KieuChu.chuNho,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      );
      final doc =
          c.maxWidth < 352 || MediaQuery.textScalerOf(context).scale(14) > 18;
      final noiDung = doc
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nhan, style: KieuChu.chuPhu),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: trangThai),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(nhan, style: KieuChu.chuPhu)),
                const SizedBox(width: 8),
                Flexible(child: trangThai),
              ],
            );
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Icon(
                    thoiGian == null ? Icons.schedule : Icons.check_circle,
                    size: 21,
                    color: thoiGian == null
                        ? BangMau.canhBao
                        : BangMau.thanhCong,
                  ),
                  if (!cuoi)
                    const Expanded(
                      child: VerticalDivider(
                        color: BangMau.chinh,
                        thickness: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: noiDung,
              ),
            ),
          ],
        ),
      );
    },
  );
}
