import 'package:flutter/material.dart';

import '../../tien_ich/dinh_dang_ngay.dart';

class ChonNgay extends StatelessWidget {
  const ChonNgay({
    super.key,
    required this.nhan,
    this.giaTri,
    this.ngayNhoNhat,
    this.ngayLonNhat,
    this.khiThayDoi,
  });
  final String nhan;
  final DateTime? giaTri, ngayNhoNhat, ngayLonNhat;
  final ValueChanged<DateTime>? khiThayDoi;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: khiThayDoi == null
        ? null
        : () async {
            final first = DateUtils.dateOnly(ngayNhoNhat ?? DateTime(1900));
            final last = DateUtils.dateOnly(ngayLonNhat ?? DateTime(2100));
            assert(!first.isAfter(last));
            final current = DateUtils.dateOnly(giaTri ?? DateTime.now());
            final initial = current.isBefore(first)
                ? first
                : current.isAfter(last)
                ? last
                : current;
            final date = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: first,
              lastDate: last,
              helpText: 'Chọn ngày',
              cancelText: 'Hủy',
              confirmText: 'Chọn',
            );
            if (date != null) khiThayDoi?.call(date);
          },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: nhan,
        enabled: khiThayDoi != null,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(giaTri == null ? 'Chọn ngày' : dinhDangNgay(giaTri!)),
    ),
  );
}
