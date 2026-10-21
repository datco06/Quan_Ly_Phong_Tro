import 'package:flutter/material.dart';

import '../../../../dung_chung/mo_hinh/thong_bao.dart';
import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../ung_dung/dieu_huong.dart';
import 'du_lieu_thong_bao_mau.dart';

// Chạy riêng S01 để xem thử, không thay đổi main.dart của ứng dụng.
void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ChuDeUngDung.sang,
    onGenerateRoute: DieuHuong.taoRoute,
    home: const DanhSachThongBao(vaiTro: VaiTro.tenant),
  ),
);

String dinhDangThoiGianThongBao(DateTime thoiGian, {DateTime? bayGio}) {
  final cach = (bayGio ?? DateTime.now()).difference(thoiGian);
  if (cach.inSeconds < 60) return 'Vừa xong';
  if (cach.inMinutes < 60) return '${cach.inMinutes} phút trước';
  if (cach.inHours < 24) return '${cach.inHours} giờ trước';
  if (cach.inDays < 7) return '${cach.inDays} ngày trước';
  if (cach.inDays < 28) return '${cach.inDays ~/ 7} tuần trước';
  return dinhDangNgay(thoiGian);
}

class DanhSachThongBao extends StatefulWidget {
  const DanhSachThongBao({
    super.key,
    required this.vaiTro,
    this.trongTab = false,
    this.duLieuBanDau,
    this.khiLamMoi,
    this.khiMoThongBao,
    this.khiVeTrangChinh,
  });

  final VaiTro vaiTro;
  final bool trongTab;
  final List<ThongBao>? duLieuBanDau;
  final Future<List<ThongBao>> Function()? khiLamMoi;
  final Future<void> Function(ThongBao thongBao)? khiMoThongBao;
  final ValueChanged<VaiTro>? khiVeTrangChinh;

  @override
  State<DanhSachThongBao> createState() => _DanhSachThongBaoState();
}

class _DanhSachThongBaoState extends State<DanhSachThongBao> {
  late List<ThongBao> _danhSach;
  late DateTime _mocThoiGian;
  int _tab = 0;
  bool _dangLamMoi = false;

  @override
  void initState() {
    super.initState();
    _mocThoiGian = DateTime.now();
    _danhSach = _sapXep(
      widget.duLieuBanDau ?? taoThongBaoMau(bayGio: _mocThoiGian),
    );
  }

  List<ThongBao> _sapXep(List<ThongBao> duLieu) =>
      List.of(duLieu)..sort((a, b) => b.thoiGian.compareTo(a.thoiGian));

  List<ThongBao> get _daLoc => _danhSach.where((muc) {
    return _tab == 0 ||
        (_tab == 1
            ? muc.loai == NhomThongBao.tinNhan
            : muc.loai == NhomThongBao.heThong);
  }).toList();

  void _quayLai() {
    final dieuHuong = Navigator.of(context);
    if (dieuHuong.canPop()) {
      dieuHuong.pop();
    } else if (widget.khiVeTrangChinh != null) {
      widget.khiVeTrangChinh!(widget.vaiTro);
    } else {
      // Trang chủ hai vai trò chưa có route; dùng trang đăng nhập đã tồn tại.
      dieuHuong.pushReplacementNamed(DieuHuong.dangNhap);
    }
  }

  Future<void> _moThongBao(ThongBao muc) async {
    setState(() {
      _danhSach = _danhSach
          .map((tb) => tb.id == muc.id ? tb.copyWith(daDoc: true) : tb)
          .toList();
    });
    final daDoc = muc.copyWith(daDoc: true);
    if (widget.khiMoThongBao != null) {
      try {
        await widget.khiMoThongBao!(daDoc);
        return;
      } catch (_) {
        if (!mounted) return;
      }
    }
    if (!mounted) return;
    // Mở nội dung đầy đủ khi chưa có màn hình chi tiết hoặc chat.
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(muc.tieuDe),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(muc.noiDung),
              const SizedBox(height: 12),
              Text(
                dinhDangNgayGio(muc.thoiGian),
                style: KieuChu.chuPhu.copyWith(color: BangMau.chuPhu),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _thongTin() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về thông báo'),
        content: const SingleChildScrollView(
          child: Text(
            'Chấm đỏ cho biết thông báo chưa đọc. Nhấn vào thông báo để xem nội dung và đánh dấu đã đọc.\n\nTin nhắn gồm phản hồi từ người dùng. Hệ thống gồm lịch xem phòng, gợi ý, hợp đồng và các cập nhật khác.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(
                () => _danhSach = _danhSach
                    .map((muc) => muc.copyWith(daDoc: true))
                    .toList(),
              );
              Navigator.pop(context);
            },
            child: const Text('Đánh dấu tất cả đã đọc'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Làm mới dữ liệu demo nhưng giữ các thông báo đã đọc theo ID.
  Future<void> _lamMoi() async {
    if (_dangLamMoi) return;
    _dangLamMoi = true;
    final bayGio = DateTime.now();
    try {
      final duLieu =
          await (widget.khiLamMoi?.call() ??
              Future.value(
                widget.duLieuBanDau ?? taoThongBaoMau(bayGio: bayGio),
              ));
      if (!mounted) return;
      final daDoc = _danhSach
          .where((muc) => muc.daDoc)
          .map((muc) => muc.id)
          .toSet();
      setState(() {
        _mocThoiGian = bayGio;
        _danhSach = _sapXep(
          duLieu
              .map(
                (muc) =>
                    muc.copyWith(daDoc: muc.daDoc || daDoc.contains(muc.id)),
              )
              .toList(),
        );
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Chưa thể làm mới thông báo. Vui lòng thử lại.'),
            ),
          );
      }
    } finally {
      _dangLamMoi = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final danhSach = _daLoc;
    final noiDung = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phần nút quay lại và thông tin.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (!widget.trongTab)
                NutBieuTuong(
                  bieuTuong: Icons.arrow_back,
                  goiY: 'Quay lại',
                  khiNhan: _quayLai,
                ),
              const Spacer(),
              NutBieuTuong(
                bieuTuong: Icons.info_outline,
                goiY: 'Thông tin thông báo',
                khiNhan: _thongTin,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Thông báo',
            style: KieuChu.tieuDeTrang.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Phần lọc; dùng ChoiceChip để có nền teal và không có dấu check như mẫu.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(3, (chiSo) {
              final daChon = _tab == chiSo;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(const ['Tất cả', 'Tin nhắn', 'Hệ thống'][chiSo]),
                  selected: daChon,
                  onSelected: (_) => setState(() => _tab = chiSo),
                  showCheckmark: false,
                  selectedColor: BangMau.chinh,
                  backgroundColor: BangMau.nenThe,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: KieuChu.nhan.copyWith(
                    color: daChon ? BangMau.nenThe : BangMau.chuChinh,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        // Phần danh sách thông báo và trạng thái rỗng.
        Expanded(
          child: RefreshIndicator(
            onRefresh: _lamMoi,
            child: danhSach.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 36),
                      TrangThaiRong(
                        tieuDe: 'Chưa có thông báo',
                        moTa: 'Các thông báo mới sẽ xuất hiện tại đây',
                        bieuTuong: Icons.notifications_none,
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: danhSach.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, thickness: 0.5),
                    itemBuilder: (context, chiSo) {
                      final muc = danhSach[chiSo];
                      return _MucThongBao(
                        key: ValueKey(muc.id),
                        thongBao: muc,
                        thoiGian: dinhDangThoiGianThongBao(
                          muc.thoiGian,
                          bayGio: _mocThoiGian,
                        ),
                        khiNhan: () => _moThongBao(muc),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
    // Khi nhúng vào tab, sử dụng Scaffold/SafeArea của layout cha.
    return widget.trongTab
        ? noiDung
        : Scaffold(
            backgroundColor: BangMau.nen,
            body: SafeArea(child: noiDung),
          );
  }
}

class _MucThongBao extends StatelessWidget {
  const _MucThongBao({
    super.key,
    required this.thongBao,
    required this.thoiGian,
    required this.khiNhan,
  });
  final ThongBao thongBao;
  final String thoiGian;
  final VoidCallback khiNhan;

  @override
  Widget build(BuildContext context) {
    final (bieuTuong, nen, mau) = switch (thongBao.suKien) {
      SuKienThongBao.tinNhan => (
        Icons.person_outline,
        BangMau.vien,
        BangMau.chuPhu,
      ),
      SuKienThongBao.lichXemPhong => (
        Icons.event_outlined,
        BangMau.loiNhat,
        BangMau.loi,
      ),
      SuKienThongBao.goiYPhong => (
        Icons.auto_awesome_outlined,
        BangMau.canhBaoNhat,
        BangMau.canhBao,
      ),
      SuKienThongBao.hopDong => (
        Icons.description_outlined,
        BangMau.thongTinNhat,
        BangMau.thongTin,
      ),
      SuKienThongBao.heThong => (
        Icons.settings_outlined,
        BangMau.chinhNhat,
        BangMau.chinh,
      ),
    };
    final avatar = ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: ColoredBox(
          color: nen,
          child: thongBao.anhDaiDien == null
              ? Icon(bieuTuong, color: mau, size: 23)
              : Image.asset(
                  thongBao.anhDaiDien!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.person_outline, color: mau),
                ),
        ),
      ),
    );
    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: khiNhan,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(child: avatar),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thongBao.tieuDe,
                        style: KieuChu.noiDungDam.copyWith(
                          fontSize: 14.5,
                          fontWeight: thongBao.daDoc
                              ? FontWeight.w500
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        thongBao.noiDung,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: KieuChu.chuPhu.copyWith(
                          fontSize: 13,
                          color: BangMau.chuPhu,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        thoiGian,
                        style: KieuChu.chuPhu.copyWith(color: BangMau.chuMo),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (!thongBao.daDoc)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Semantics(
                      label: 'Chưa đọc',
                      child: Container(
                        key: ValueKey('chua_doc_${thongBao.id}'),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: BangMau.loi,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
