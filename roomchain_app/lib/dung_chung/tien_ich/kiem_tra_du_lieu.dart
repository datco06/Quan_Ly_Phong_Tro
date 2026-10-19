abstract final class KiemTraDuLieu {
  static bool rong(String? value) => value == null || value.trim().isEmpty;
  static String? batBuoc(String? value) =>
      rong(value) ? 'Vui lòng nhập thông tin' : null;
  static String? email(String? value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
      ? null
      : 'Email không hợp lệ';
  static String? soDienThoai(String? value) =>
      RegExp(r'^(0[35789]\d{8}|\+84[35789]\d{8})$')
          .hasMatch((value ?? '').replaceAll(' ', ''))
      ? null
      : 'Số điện thoại không hợp lệ';
  static String? tienKhongAm(String? value) {
    final so = int.tryParse(value?.trim() ?? '');
    return so != null && so >= 0 ? null : 'Nhập số tiền nguyên không âm';
  }
}
