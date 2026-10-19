import 'package:flutter/material.dart';

import '../../giao_dien/bang_mau.dart';
import '../../giao_dien/kich_thuoc.dart';

enum KieuNut { chinh, phu, nhat, nguyHiem, vanBan }

class NutBam extends StatelessWidget {
  const NutBam({
    super.key,
    required this.nhan,
    this.khiNhan,
    this.kieu = KieuNut.chinh,
    this.dangTai = false,
    this.voHieuHoa = false,
    this.bieuTuong,
    this.rongHet = true,
    this.chieuCao,
    this.khoangTrong,
  });
  final String nhan;
  final VoidCallback? khiNhan;
  final KieuNut kieu;
  final bool dangTai, voHieuHoa, rongHet;
  final IconData? bieuTuong;
  final double? chieuCao;
  final EdgeInsetsGeometry? khoangTrong;

  @override
  Widget build(BuildContext context) {
    final foreground = switch (kieu) {
      KieuNut.chinh => BangMau.nenThe,
      KieuNut.nguyHiem => BangMau.loi,
      _ => BangMau.chinh,
    };
    final background = switch (kieu) {
      KieuNut.chinh => BangMau.chinh,
      KieuNut.nhat => BangMau.chinhNhat,
      KieuNut.nguyHiem => BangMau.loiNhat,
      KieuNut.phu => BangMau.nenThe,
      KieuNut.vanBan => Colors.transparent,
    };
    return SizedBox(
      width: rongHet ? double.infinity : null,
      child: TextButton(
        onPressed: dangTai || voHieuHoa ? null : khiNhan,
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          disabledForegroundColor: BangMau.chuMo,
          disabledBackgroundColor: BangMau.vien,
          minimumSize: Size(KichThuoc.vungCham, chieuCao ?? KichThuoc.caoNut),
          padding:
              khoangTrong ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KichThuoc.boNut),
            side: kieu == KieuNut.phu
                ? const BorderSide(color: BangMau.chinh)
                : BorderSide.none,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: dangTai ? 0 : 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (bieuTuong != null) ...[
                    Icon(bieuTuong, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(child: Text(nhan, textAlign: TextAlign.center)),
                ],
              ),
            ),
            if (dangTai)
              Semantics(
                label: 'Đang xử lý',
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
