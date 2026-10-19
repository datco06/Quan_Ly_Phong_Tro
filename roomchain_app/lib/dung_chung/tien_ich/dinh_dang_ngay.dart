String _haiSo(int n) => n.toString().padLeft(2, '0');
String dinhDangNgay(DateTime ngay) =>
    '${_haiSo(ngay.day)}/${_haiSo(ngay.month)}/${ngay.year.toString().padLeft(4, '0')}';
String dinhDangKy(DateTime ngay) =>
    '${_haiSo(ngay.month)}/${ngay.year.toString().padLeft(4, '0')}';
String dinhDangNgayGio(DateTime ngay) =>
    '${dinhDangNgay(ngay)} ${_haiSo(ngay.hour)}:${_haiSo(ngay.minute)}';
