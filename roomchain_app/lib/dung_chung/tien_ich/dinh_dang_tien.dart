enum DonViTien { vnd, mockVNDC }

String dinhDangTien(int soTien, {DonViTien donVi = DonViTien.vnd}) {
  final chuoi = soTien.abs().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '${soTien < 0 ? '-' : ''}$chuoi${donVi == DonViTien.vnd ? 'đ' : ' MockVNDC'}';
}

String dinhDangVND(int soTien) => dinhDangTien(soTien);
String dinhDangMockVNDC(int soTien) =>
    dinhDangTien(soTien, donVi: DonViTien.mockVNDC);
