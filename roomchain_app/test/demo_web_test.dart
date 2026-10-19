import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomchain_app/dung_chung/demo/khung_dien_thoai_demo.dart';
import 'package:roomchain_app/dung_chung/roomchain_ui.dart';

void main() {
  for (final size in [
    const Size(1280, 900),
    const Size(390, 844),
    const Size(800, 400),
  ]) {
    testWidgets('Viewport web $size và dialog nằm trong khung demo', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Size? viewport;
      await tester.pumpWidget(
        MaterialApp(
          theme: ChuDeUngDung.sang,
          builder: (_, child) => KhungDienThoaiDemo(child: child!),
          home: Builder(
            builder: (context) {
              viewport = MediaQuery.sizeOf(context);
              return Scaffold(
                body: Center(
                  child: NutBam(
                    nhan: 'Mở',
                    khiNhan: () {
                      HopThoaiXacNhan.hienThi(
                        context,
                        tieuDe: 'Xác nhận',
                        noiDung: 'Nội dung mẫu',
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
      final desktop = size.width >= 480 && size.height >= 480;
      expect(viewport!.width, desktop ? 390 : size.width);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Mở'));
      await tester.pumpAndSettle();
      final bounds = tester.getRect(find.byType(AlertDialog));
      expect(
        bounds.left,
        greaterThanOrEqualTo((size.width - viewport!.width) / 2),
      );
      expect(
        bounds.right,
        lessThanOrEqualTo((size.width + viewport!.width) / 2),
      );
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
