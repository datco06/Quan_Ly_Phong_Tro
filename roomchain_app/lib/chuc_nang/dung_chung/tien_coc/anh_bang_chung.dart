import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../../dung_chung/roomchain_ui.dart';
import '../../../../dung_chung/mo_hinh/quyet_toan_tien_coc.dart';

class DichVuAnhBangChung {
  const DichVuAnhBangChung({this.khiMoTep});
  final Future<List<XFile>> Function()? khiMoTep;
  Future<List<BangChungKhauTru>> chon() async {
    final tep = await (khiMoTep != null
        ? khiMoTep!()
        : openFiles(
            acceptedTypeGroups: const [
              XTypeGroup(
                label: 'Ảnh bằng chứng',
                extensions: ['jpg', 'jpeg', 'png', 'webp'],
                mimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
                uniformTypeIdentifiers: [
                  'public.jpeg',
                  'public.png',
                  'org.webmproject.webp',
                ],
              ),
            ],
          ));
    if (tep.length > 5) {
      throw const FormatException('Chỉ chọn tối đa 5 ảnh mỗi lần.');
    }
    final ketQua = <BangChungKhauTru>[];
    for (final f in tep) {
      if (await f.length() > 5 * 1024 * 1024) {
        throw const FormatException('Mỗi ảnh không được vượt quá 5 MB.');
      }
      final bytes = await f.readAsBytes();
      try {
        final codec = await ui.instantiateImageCodec(bytes, targetWidth: 300);
        final khung = await codec.getNextFrame();
        khung.image.dispose();
        codec.dispose();
      } catch (_) {
        throw const FormatException(
          'Không đọc được ảnh. Vui lòng chọn JPEG, PNG hoặc WebP hợp lệ.',
        );
      }
      ketQua.add(
        BangChungKhauTru(
          id: sha256.convert(bytes).toString(),
          tenTep: f.name,
          noiDung: bytes,
        ),
      );
    }
    return ketQua;
  }
}

class AnhBangChung extends StatelessWidget {
  const AnhBangChung({super.key, required this.anh, required this.khiXoa});
  final BangChungKhauTru anh;
  final VoidCallback? khiXoa;

  Future<void> _xemAnh(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(anh.tenTep, overflow: TextOverflow.ellipsis),
                  ),
                ),
                NutBieuTuong(
                  bieuTuong: Icons.close,
                  goiY: 'Đóng ảnh',
                  khiNhan: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.memory(
                  anh.noiDung,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Center(child: Text('Không đọc được ảnh.')),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Semantics(
        label: 'Xem ảnh ${anh.tenTep}',
        button: true,
        child: InkWell(
          onTap: () => _xemAnh(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.memory(
              anh.noiDung,
              fit: BoxFit.cover,
              cacheWidth: 300,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
      ),
      if (khiXoa != null)
        Positioned(
          top: 0,
          right: 0,
          child: IconButton.filledTonal(
            tooltip: 'Xóa ảnh ${anh.tenTep}',
            onPressed: khiXoa,
            icon: const Icon(Icons.close, size: 18),
          ),
        ),
    ],
  );
}
