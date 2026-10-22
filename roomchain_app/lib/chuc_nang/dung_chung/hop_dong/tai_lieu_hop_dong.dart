import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/du_lieu_mau/kho_hop_dong_mau.dart';
import 'thanh_phan_hop_dong.dart';

class TaiLieuHopDongDemo {
  const TaiLieuHopDongDemo();

  static bool hopLe(TaiLieuHopDong t) =>
      t.noiDung.length >= 5 &&
      String.fromCharCodes(t.noiDung.take(5)) == '%PDF-' &&
      sha256.convert(t.noiDung).toString() == t.sha256;

  Future<TaiLieuHopDong> lay(KhoHopDongMau kho, String id) async {
    final h = kho.theoId(id);
    if (h == null) throw StateError('Không tìm thấy hợp đồng.');
    if (h.taiLieu != null) {
      final t = h.taiLieu!;
      if (!hopLe(t)) {
        throw StateError(
          'File PDF hoặc mã băm không hợp lệ. Cần cung cấp tài liệu gốc.',
        );
      }
      return t;
    }
    if (h.daCoChuKy) {
      throw StateError(
        'Thiếu tài liệu gốc của hợp đồng đã có xác nhận ký. Không tạo lại PDF.',
      );
    }
    final phong = kho.phong(h.phongId);
    final nguoi = kho.nguoi(h.nguoiThueId);
    final chu = pdf.Font.ttf(
      await rootBundle.load('assets/phong_chu/Roboto-Regular.ttf'),
    );
    final doc = pdf.Document(
      title: 'Hợp đồng ${h.maHopDong}',
      author: 'RoomChain AI · Demo',
      creator: 'RoomChain AI Frontend',
      compress: true,
    );
    pdf.Widget dong(String nhan, String giaTri) => pdf.Padding(
      padding: const pdf.EdgeInsets.symmetric(vertical: 4),
      child: pdf.Row(
        crossAxisAlignment: pdf.CrossAxisAlignment.start,
        children: [
          pdf.SizedBox(width: 135, child: pdf.Text(nhan)),
          pdf.Expanded(child: pdf.Text(giaTri)),
        ],
      ),
    );
    pdf.Widget muc(String nhan) => pdf.Padding(
      padding: const pdf.EdgeInsets.only(top: 18, bottom: 8),
      child: pdf.Text(nhan, style: const pdf.TextStyle(fontSize: 14)),
    );
    final c = h.cauHinh;
    doc.addPage(
      pdf.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pdf.EdgeInsets.all(36),
        theme: pdf.ThemeData.withFont(
          base: chu,
          bold: chu,
          italic: chu,
          boldItalic: chu,
        ),
        footer: (context) => pdf.Padding(
          padding: const pdf.EdgeInsets.only(top: 12),
          child: pdf.Text(
            'BẢN DEMO · ${h.maHopDong} · Trang ${context.pageNumber}/${context.pagesCount}',
            style: const pdf.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ),
        build: (_) => [
          pdf.Center(
            child: pdf.Text(
              'HỢP ĐỒNG THUÊ PHÒNG',
              style: const pdf.TextStyle(fontSize: 19),
            ),
          ),
          pdf.SizedBox(height: 12),
          pdf.Center(child: pdf.Text('Mã hợp đồng: ${h.maHopDong}')),
          pdf.SizedBox(height: 14),
          pdf.Text(
            'Tài liệu mẫu phục vụ trình diễn Frontend. Không có chữ ký điện tử hoặc xác nhận Blockchain, không phải bản hợp đồng đã được ký.',
          ),
          muc('1. Thông tin các bên và phòng thuê'),
          dong(
            'Bên cho thuê',
            '${DuLieuGia.chuTro.hoTen} · ${DuLieuGia.chuTro.soDienThoai}',
          ),
          dong('Bên thuê', '${nguoi.hoTen} · ${nguoi.soDienThoai}'),
          dong('Khu trọ', phong.tenKhuTro),
          dong('Địa chỉ', phong.diaChi),
          dong(
            'Phòng / Diện tích',
            '${phong.maPhong} / ${phong.dienTich.toStringAsFixed(0)}m²',
          ),
          dong(
            'Thời hạn',
            '${dinhDangNgay(h.ngayBatDau)} – ${dinhDangNgay(h.ngayKetThuc)}',
          ),
          muc('2. Giá thuê và các khoản thu (VND)'),
          dong('Giá thuê / tháng', dinhDangVND(h.giaThue)),
          dong('Tiền cọc', dinhDangVND(h.tienCoc)),
          dong('Dịch vụ cố định / tháng', dinhDangVND(c.phiDichVu)),
          dong('Đơn giá điện / kWh', dinhDangVND(c.donGiaDien)),
          dong('Đơn giá nước / m³', dinhDangVND(c.donGiaNuoc)),
          dong('Internet / tháng', dinhDangVND(c.internet)),
          dong('Khoản khác / tháng', dinhDangVND(c.khoanKhac)),
          pdf.Text(
            'Điện, nước tính theo chỉ số tiêu thụ thực tế, tách riêng phí dịch vụ và Internet. Tiền cọc VND là giá trị thỏa thuận, không phải bằng chứng giao dịch token.',
          ),
          muc('3. Thanh toán và ghi số'),
          pdf.Text(
            'Thời hạn thanh toán từ ngày ${c.thanhToanTu} đến hết ngày ${c.thanhToanDen} hàng tháng. Ghi số điện nước ngày ${c.ngayGhiSo} hàng tháng.',
          ),
          pdf.SizedBox(height: 8),
          pdf.Text(
            'Phụ thu trả chậm dự kiến: ${dinhDangVND(c.phuThuCham)}/ngày. $luuYPhuThu',
          ),
          muc('4. Kết thúc hợp đồng và hoàn cọc'),
          pdf.Text(c.ketThucSom),
          pdf.SizedBox(height: 8),
          pdf.Text(dieuKhoanHoanCoc),
          muc('5. Nội quy bổ sung'),
          pdf.Text(
            c.noiQuy.isEmpty
                ? 'Không bổ sung nội quy trong bản demo.'
                : c.noiQuy,
          ),
          muc('6. Xác nhận các bên'),
          pdf.Text(
            'Các bên kiểm tra nội dung, chi phí và thời hạn trước khi ký. Mọi chữ ký, nạp cọc và quyết toán thực tế chờ hệ thống Backend/Blockchain tích hợp.',
          ),
          pdf.SizedBox(height: 24),
          pdf.Row(
            mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
            children: [
              pdf.Text('BÊN CHO THUÊ\nChưa ký'),
              pdf.Text('BÊN THUÊ\nChưa ký'),
            ],
          ),
        ],
      ),
    );
    final bytes = await doc.save();
    return kho.luuTaiLieu(
      id,
      TaiLieuHopDong(
        noiDung: bytes,
        tenTep: '${h.maHopDong}.pdf',
        sha256: sha256.convert(bytes).toString(),
        ngayTao: DateTime.now(),
      ),
    );
  }

  Future<bool> tai(TaiLieuHopDong taiLieu) =>
      Printing.sharePdf(bytes: taiLieu.noiDung, filename: taiLieu.tenTep);
}
