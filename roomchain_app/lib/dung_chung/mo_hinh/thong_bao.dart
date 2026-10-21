enum NhomThongBao { tinNhan, heThong }

enum SuKienThongBao { tinNhan, lichXemPhong, goiYPhong, hopDong, heThong }

class ThongBao {
  const ThongBao({
    required this.id,
    required this.tieuDe,
    required this.noiDung,
    required this.loai,
    required this.suKien,
    required this.thoiGian,
    this.daDoc = false,
    this.anhDaiDien,
    this.duongDanDich,
    this.doiTuongId,
  });

  final String id, tieuDe, noiDung;
  final NhomThongBao loai;
  final SuKienThongBao suKien;
  final DateTime thoiGian;
  final bool daDoc;
  final String? anhDaiDien, duongDanDich, doiTuongId;

  ThongBao copyWith({bool? daDoc}) => ThongBao(
    id: id,
    tieuDe: tieuDe,
    noiDung: noiDung,
    loai: loai,
    suKien: suKien,
    thoiGian: thoiGian,
    daDoc: daDoc ?? this.daDoc,
    anhDaiDien: anhDaiDien,
    duongDanDich: duongDanDich,
    doiTuongId: doiTuongId,
  );
}
