import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'thanh_phan_hop_dong.dart';

// Chạy demo danh sách và quy trình tạo hợp đồng.
void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    onGenerateRoute: DieuHuong.taoRoute,
    home: const DanhSachHopDong(),
  ),
);

class DanhSachHopDong extends StatefulWidget {
  const DanhSachHopDong({
    super.key,
    this.kho,
    this.trongTab = false,
    this.khiChonDieuHuong,
    this.khiMoChiTiet,
  });
  final KhoHopDongMau? kho;
  final bool trongTab;
  final ValueChanged<int>? khiChonDieuHuong;
  final ValueChanged<String>? khiMoChiTiet;
  @override
  State<DanhSachHopDong> createState() => _DanhSachHopDongState();
}

class _DanhSachHopDongState extends State<DanhSachHopDong> {
  final _timKiem = TextEditingController();
  TrangThaiHopDong _trangThai = TrangThaiHopDong.choKy;
  String? _khuTro;
  KhoHopDongMau get _kho => widget.kho ?? KhoHopDongMau.dungChung;
  static const _cacTab = [
    TrangThaiHopDong.choKy,
    TrangThaiHopDong.choCoc,
    TrangThaiHopDong.dangHieuLuc,
    TrangThaiHopDong.daKetThuc,
  ];

  @override
  void dispose() {
    _timKiem.dispose();
    super.dispose();
  }

  Future<void> _taoMoi() async {
    final ketQua = await Navigator.pushNamed(
      context,
      DieuHuong.taoHopDong,
      arguments: _kho,
    );
    if (!mounted || ketQua is! HopDong) return;
    setState(() {
      _trangThai = TrangThaiHopDong.choKy;
      _khuTro = null;
      _timKiem.clear();
    });
  }

  Future<void> _locKhuTro() async {
    final chon = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Lọc theo khu trọ', style: KieuChu.tieuDeMuc),
              ),
              ListTile(
                title: const Text('Tất cả khu trọ'),
                trailing: _khuTro == null ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, ''),
              ),
              for (final khu in _kho.phongTro.map((p) => p.tenKhuTro).toSet())
                ListTile(
                  title: Text(khu),
                  trailing: _khuTro == khu ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, khu),
                ),
            ],
          ),
        ),
      ),
    );
    if (mounted && chon != null) {
      setState(() => _khuTro = chon.isEmpty ? null : chon);
    }
  }

  void _quayLai() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, DieuHuong.dangNhap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noiDung = ListenableBuilder(
      listenable: _kho,
      builder: (context, _) {
        final ds = _kho.loc(
          trangThai: _trangThai,
          tuKhoa: _timKiem.text,
          khuTro: _khuTro,
        );
        return Column(
          children: [
            // Phần tiêu đề và menu tạo hợp đồng.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  NutBieuTuong(
                    bieuTuong: Icons.arrow_back_ios_new,
                    goiY: 'Quay lại',
                    khiNhan: _quayLai,
                  ),
                  const Expanded(
                    child: Text(
                      'Hợp đồng thuê',
                      textAlign: TextAlign.center,
                      style: KieuChu.tieuDeMuc,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Menu hợp đồng',
                    icon: const Icon(Icons.more_vert),
                    onSelected: (muc) {
                      if (muc == 'tao') {
                        _taoMoi();
                      } else {
                        _kho.lamMoi();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'tao',
                        child: Text('Tạo hợp đồng mới'),
                      ),
                      PopupMenuItem(
                        value: 'lam_moi',
                        child: Text('Làm mới danh sách'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final tab in _cacTab)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        key: ValueKey('tab_${tab.name}'),
                        selected: _trangThai == tab,
                        showCheckmark: false,
                        selectedColor: BangMau.chinh,
                        backgroundColor: BangMau.nenThe,
                        labelStyle: KieuChu.chuNho.copyWith(
                          color: _trangThai == tab
                              ? BangMau.nenThe
                              : BangMau.chuPhu,
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide.none,
                        label: Text(
                          '${tab.nhan} (${_kho.danhSach.where((h) => h.trangThai == tab).length})',
                        ),
                        onSelected: (_) => setState(() => _trangThai = tab),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: OTimKiem(
                      controller: _timKiem,
                      goiY: 'Tìm theo mã HĐ, tên người thuê...',
                      khiTimKiem: (_) => setState(() {}),
                    ),
                  ),
                  NutBieuTuong(
                    bieuTuong: _khuTro == null
                        ? Icons.filter_alt_outlined
                        : Icons.filter_alt,
                    goiY: 'Lọc khu trọ',
                    khiNhan: _locKhuTro,
                  ),
                ],
              ),
            ),
            if (_khuTro != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    label: Text(_khuTro!),
                    onDeleted: () => setState(() => _khuTro = null),
                  ),
                ),
              ),
            // Phần danh sách hợp đồng.
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _kho.lamMoi(),
                child: ds.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          TrangThaiRong(
                            tieuDe: 'Chưa có hợp đồng',
                            moTa: 'Thử đổi bộ lọc hoặc tạo hợp đồng mới.',
                            bieuTuong: Icons.description_outlined,
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: ds.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) => _MucHopDong(
                          hopDong: ds[i],
                          kho: _kho,
                          khiNhan: () {
                            if (widget.khiMoChiTiet != null) {
                              widget.khiMoChiTiet!(ds[i].id);
                            } else {
                              hienThiHopDongMau(context, ds[i], _kho);
                            }
                          },
                        ),
                      ),
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
      khiChon: (chiSo) {
        if (widget.khiChonDieuHuong != null) {
          widget.khiChonDieuHuong!(chiSo);
        } else if (chiSo != 4) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Trang này chưa được kết nối trong bản demo hợp đồng.',
              ),
            ),
          );
        }
      },
    );
  }
}

class _MucHopDong extends StatelessWidget {
  const _MucHopDong({
    required this.hopDong,
    required this.kho,
    required this.khiNhan,
  });
  final HopDong hopDong;
  final KhoHopDongMau kho;
  final VoidCallback khiNhan;
  Widget _dong(IconData icon, String chu) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15),
        const SizedBox(width: 8),
        Expanded(child: Text(chu, style: KieuChu.chuPhu)),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final h = hopDong;
    final ngayCon = h.ngayKetThuc
        .difference(DateUtils.dateOnly(DateTime.now()))
        .inDays;
    return Material(
      color: BangMau.nenThe,
      child: InkWell(
        key: ValueKey(h.id),
        onTap: khiNhan,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    color: BangMau.chinh,
                    size: 23,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(h.maHopDong, style: KieuChu.noiDungDam)),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * .34,
                    ),
                    child: NhanHopDong(trangThai: h.trangThai),
                  ),
                ],
              ),
              _dong(Icons.person_outline, kho.nguoi(h.nguoiThueId).hoTen),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Phòng ${kho.phong(h.phongId).maPhong}',
                      style: KieuChu.chuPhu,
                    ),
                    Text(
                      '${dinhDangVND(h.giaThue)}/tháng',
                      style: KieuChu.chuPhu,
                    ),
                  ],
                ),
              ),
              _dong(
                Icons.calendar_today_outlined,
                '${dinhDangNgay(h.ngayBatDau)} – ${dinhDangNgay(h.ngayKetThuc)}',
              ),
              if (h.trangThai == TrangThaiHopDong.dangHieuLuc && ngayCon >= 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Còn $ngayCon ngày',
                      style: KieuChu.chuPhu.copyWith(color: BangMau.chinh),
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
