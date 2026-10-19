import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../giao_dien/bang_mau.dart';

/// Bao cả Navigator để dialog và trang mới cũng nằm trong viewport điện thoại.
class KhungDienThoaiDemo extends StatelessWidget {
  const KhungDienThoaiDemo({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 480 || constraints.maxHeight < 480) {
        return child;
      }
      final height = math.min(860.0, constraints.maxHeight - 32);
      return ColoredBox(
        color: BangMau.vien,
        child: Center(
          child: Container(
            width: 406,
            height: height,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BangMau.chuChinh,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: BangMau.chuChinh.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: ColoredBox(
                color: BangMau.nenThe,
                child: Column(
                  children: [
                    const ExcludeSemantics(
                      child: SizedBox(
                        height: 28,
                        child: Center(
                          child: SizedBox(
                            width: 80,
                            height: 14,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: BangMau.chuChinh,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, phone) => MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            size: Size(phone.maxWidth, phone.maxHeight),
                            padding: EdgeInsets.zero,
                            viewPadding: EdgeInsets.zero,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                    const ExcludeSemantics(
                      child: SizedBox(
                        height: 16,
                        child: Center(
                          child: SizedBox(
                            width: 100,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: BangMau.chuChinh,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
