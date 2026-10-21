import '../../../../dung_chung/mo_hinh/thong_bao.dart';

// Dữ liệu demo riêng cho S01, không phải dữ liệu từ Backend hoặc Firebase.
List<ThongBao> taoThongBaoMau({DateTime? bayGio}) {
  final moc = bayGio ?? DateTime.now();
  return [
    ThongBao(
      id: 'TB001',
      tieuDe: 'Nguyễn Văn Minh',
      noiDung: 'Đã phản hồi tin nhắn của bạn',
      loai: NhomThongBao.tinNhan,
      suKien: SuKienThongBao.tinNhan,
      thoiGian: moc.subtract(const Duration(minutes: 5)),
      anhDaiDien: 'assets/hinh_anh/gioi_thieu/chu_tro.png',
    ),
    ThongBao(
      id: 'TB002',
      tieuDe: 'Phòng P201',
      noiDung: 'Có lịch xem phòng vào 15:00 hôm nay',
      loai: NhomThongBao.heThong,
      suKien: SuKienThongBao.lichXemPhong,
      thoiGian: moc.subtract(const Duration(minutes: 30)),
      doiTuongId: 'P201',
    ),
    ThongBao(
      id: 'TB003',
      tieuDe: 'Ưu đãi mới',
      noiDung: 'Có 3 phòng mới phù hợp với nhu cầu của bạn',
      loai: NhomThongBao.heThong,
      suKien: SuKienThongBao.goiYPhong,
      thoiGian: moc.subtract(const Duration(hours: 2)),
    ),
    ThongBao(
      id: 'TB004',
      tieuDe: 'Hợp đồng',
      noiDung: 'Hợp đồng của bạn sắp hết hạn',
      loai: NhomThongBao.heThong,
      suKien: SuKienThongBao.hopDong,
      thoiGian: moc.subtract(const Duration(days: 3)),
    ),
    ThongBao(
      id: 'TB005',
      tieuDe: 'Hệ thống',
      noiDung: 'Cập nhật tính năng mới',
      loai: NhomThongBao.heThong,
      suKien: SuKienThongBao.heThong,
      thoiGian: moc.subtract(const Duration(days: 7)),
    ),
  ];
}
