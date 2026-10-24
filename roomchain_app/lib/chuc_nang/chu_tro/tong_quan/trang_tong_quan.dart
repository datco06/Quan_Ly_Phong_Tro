import 'package:flutter/material.dart';

import '../../../dung_chung/giao_dien/bang_mau.dart';
import '../../../dung_chung/giao_dien/khoang_cach.dart';
import '../../../dung_chung/giao_dien/kieu_chu.dart';
import '../../../dung_chung/giao_dien/kich_thuoc.dart';
import '../../../dung_chung/tien_ich/dinh_dang_tien.dart';
import 'widget/the_viec_can_xu_ly.dart';
import 'widget/o_thong_ke_nho.dart';
import 'widget/bieu_do_doanh_thu.dart';

class TrangTongQuan extends StatelessWidget {
  const TrangTongQuan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BangMau.nen,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _DauTrangChuTro()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                KhoangCach.chuan,
                KhoangCach.chuan,
                KhoangCach.chuan,
                0,
              ),
              child: _LuoiThongKe(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                KhoangCach.chuan,
                KhoangCach.chuan,
                KhoangCach.chuan,
                0,
              ),
              child: _KhoiDoanhThu(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(KhoangCach.chuan),
              child: _KhoiViecCanXuLy(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PHẦN ĐẦU TRANG ──────────────────────────────────────────────────────────

class _DauTrangChuTro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BangMau.nenThe,
        border: Border(bottom: BorderSide(color: BangMau.vien)),
      ),
      padding: const EdgeInsets.fromLTRB(
        KhoangCach.chuan,
        KhoangCach.chuan,
        KhoangCach.chuan,
        KhoangCach.chuan,
      ),
      child: Row(
        children: [
          // Avatar chủ trọ
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: BangMau.chinhNhat,
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: BangMau.chinh, width: 2),
            ),
            child: const Icon(Icons.person, color: BangMau.chinh, size: 26),
          ),
          const SizedBox(width: KhoangCach.vua),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Chào anh Minh ',
                      style: KieuChu.tieuDeThe.copyWith(
                        color: BangMau.chuChinh,
                      ),
                    ),
                    const Text('👋', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'An Nhiên Residence',
                  style: KieuChu.chuPhu.copyWith(color: BangMau.chuPhu),
                ),
              ],
            ),
          ),
          // Nút thông báo
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: BangMau.chuPhu,
                  size: KichThuoc.bieuTuong,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: BangMau.loi,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── LƯỚI THỐNG KÊ 4 Ô ───────────────────────────────────────────────────────

class _LuoiThongKe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OThongKeNho(
                tieuDe: 'Tổng số phòng',
                giaTri: '24',
                bieuTuong: Icons.home_outlined,
                mauBieuTuong: BangMau.chinh,
                mauNen: BangMau.chinhNhat,
              ),
            ),
            const SizedBox(width: KhoangCach.nho),
            Expanded(
              child: OThongKeNho(
                tieuDe: 'Đang thuê',
                giaTri: '18',
                bieuTuong: Icons.people_outline,
                mauBieuTuong: BangMau.thanhCong,
                mauNen: BangMau.thanhCongNhat,
              ),
            ),
          ],
        ),
        const SizedBox(height: KhoangCach.nho),
        Row(
          children: [
            Expanded(
              child: OThongKeNho(
                tieuDe: 'Phòng trống',
                giaTri: '6',
                bieuTuong: Icons.meeting_room_outlined,
                mauBieuTuong: BangMau.canhBao,
                mauNen: BangMau.canhBaoNhat,
              ),
            ),
            const SizedBox(width: KhoangCach.nho),
            Expanded(
              child: OThongKeNho(
                tieuDe: 'Tổng công nợ',
                giaTri: dinhDangVND(12250000),
                bieuTuong: Icons.account_balance_wallet_outlined,
                mauBieuTuong: BangMau.loi,
                mauNen: BangMau.loiNhat,
                mauGiaTri: BangMau.loi,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── KHỐI DOANH THU ──────────────────────────────────────────────────────────

class _KhoiDoanhThu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KhoangCach.chuan),
      decoration: BoxDecoration(
        color: BangMau.nenThe,
        borderRadius: BorderRadius.circular(KichThuoc.boThe),
        border: Border.all(color: BangMau.vien),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doanh thu tháng 11/2026',
            style: KieuChu.chuPhu.copyWith(color: BangMau.chuPhu),
          ),
          const SizedBox(height: KhoangCach.ratNho),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dinhDangVND(92268000),
                      style: KieuChu.soTienLon.copyWith(
                        color: BangMau.chuChinh,
                      ),
                    ),
                    const SizedBox(height: KhoangCach.ratNho),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: BangMau.thanhCongNhat,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.arrow_upward,
                                size: 12,
                                color: BangMau.thanhCong,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '+12%',
                                style: KieuChu.chuNho.copyWith(
                                  color: BangMau.thanhCong,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: KhoangCach.nho),
                        Text(
                          'so với tháng trước',
                          style: KieuChu.chuNho.copyWith(
                            color: BangMau.chuPhu,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KhoangCach.chuan),
              const BieuDoCotDoanhThu(),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── KHỐI VIỆC CẦN XỬ LÝ ────────────────────────────────────────────────────

class _KhoiViecCanXuLy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Việc cần xử lý', style: KieuChu.tieuDeThe),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: BangMau.chinh,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Xem tất cả',
                style: KieuChu.noiDung.copyWith(color: BangMau.chinh),
              ),
            ),
          ],
        ),
        const SizedBox(height: KhoangCach.vua),
        Container(
          decoration: BoxDecoration(
            color: BangMau.nenThe,
            borderRadius: BorderRadius.circular(KichThuoc.boThe),
            border: Border.all(color: BangMau.vien),
          ),
          child: Column(
            children: [
              TheViecCanXuLy(
                bieuTuong: Icons.build_outlined,
                mauBieuTuong: BangMau.canhBao,
                mauNenBieuTuong: BangMau.canhBaoNhat,
                tieuDe: '2 yêu cầu sửa chữa mới',
                moTa: 'Cần tiếp nhận và xử lý',
                khiNhan: () {},
                laDauTien: true,
              ),
              const Divider(height: 1, indent: 56),
              TheViecCanXuLy(
                bieuTuong: Icons.receipt_long_outlined,
                mauBieuTuong: BangMau.loi,
                mauNenBieuTuong: BangMau.loiNhat,
                tieuDe: '3 hóa đơn quá hạn',
                moTa: dinhDangVND(12250000),
                khiNhan: () {},
              ),
              const Divider(height: 1, indent: 56),
              TheViecCanXuLy(
                bieuTuong: Icons.description_outlined,
                mauBieuTuong: BangMau.chinh,
                mauNenBieuTuong: BangMau.chinhNhat,
                tieuDe: '1 phòng sắp hết hạn hợp đồng',
                moTa: 'Trong 7 ngày tới',
                khiNhan: () {},
                laCuoi: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
