// Biên nhận trong bộ nhớ phục vụ demo, chưa phải dữ liệu từ RPC.
enum BuocDatCocDemo {
  choApprove,
  daApprove,
  dangGuiCoc,
  choXacNhan,
  daKhoa,
  thatBai,
}

enum LoiDatCocDemo { approve, deposit, xacNhan }

abstract interface class ViGiaoDichDemo {
  String? get diaChi;
  int get phienKetNoi;
  int get chainId;
  int get soDuToken;
  bool get dangDatCoc;
  bool phienHopLe(int phien);
  void batDauDatCoc(int soToken, int phien);
  void ghiNhanApprove(int soToken, int phien);
  void ghiNhanChiCoc(int soToken, int phien);
  void ketThucDatCoc();
}

class GiaoDichBlockchain {
  const GiaoDichBlockchain({
    required this.hopDongId,
    required this.diaChiVi,
    required this.soToken,
    required this.chainId,
    this.diaChiEscrow,
    this.buoc = BuocDatCocDemo.choApprove,
    this.viXacNhanLuc,
    this.approveGuiLuc,
    this.approveXacNhanLuc,
    this.datCocGuiLuc,
    this.blockXacNhanLuc,
    this.khoaCocLuc,
    this.maApprove,
    this.transactionHash,
    this.loi,
    this.buocThatBai,
  });
  final String hopDongId, diaChiVi;
  // Đơn vị: số nguyên MockVNDC; không dùng double hoặc VND để trừ số dư.
  final int soToken, chainId;
  final String? diaChiEscrow, maApprove, transactionHash, loi;
  final BuocDatCocDemo buoc;
  final LoiDatCocDemo? buocThatBai;
  final DateTime? viXacNhanLuc,
      approveGuiLuc,
      approveXacNhanLuc,
      datCocGuiLuc,
      blockXacNhanLuc,
      khoaCocLuc;
  bool get laMoPhong => true;
  static bool hashHopLe(String? ma) =>
      ma != null && RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(ma);
  static bool diaChiHopLe(String? diaChi) =>
      diaChi != null && RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(diaChi);
  bool get daKhoa =>
      buoc == BuocDatCocDemo.daKhoa &&
      loi == null &&
      soToken > 0 &&
      chainId > 0 &&
      diaChiHopLe(diaChiVi) &&
      hashHopLe(maApprove) &&
      hashHopLe(transactionHash) &&
      maApprove != transactionHash &&
      viXacNhanLuc != null &&
      approveGuiLuc != null &&
      approveXacNhanLuc != null &&
      datCocGuiLuc != null &&
      blockXacNhanLuc != null &&
      khoaCocLuc != null &&
      !approveGuiLuc!.isBefore(viXacNhanLuc!) &&
      !approveXacNhanLuc!.isBefore(approveGuiLuc!) &&
      !datCocGuiLuc!.isBefore(approveXacNhanLuc!) &&
      !blockXacNhanLuc!.isBefore(datCocGuiLuc!) &&
      !khoaCocLuc!.isBefore(blockXacNhanLuc!);

  GiaoDichBlockchain copyWith({
    BuocDatCocDemo? buoc,
    DateTime? viXacNhanLuc,
    DateTime? approveGuiLuc,
    DateTime? approveXacNhanLuc,
    DateTime? datCocGuiLuc,
    DateTime? blockXacNhanLuc,
    DateTime? khoaCocLuc,
    String? maApprove,
    String? transactionHash,
    String? loi,
    LoiDatCocDemo? buocThatBai,
  }) => GiaoDichBlockchain(
    hopDongId: hopDongId,
    diaChiVi: diaChiVi,
    soToken: soToken,
    chainId: chainId,
    diaChiEscrow: diaChiEscrow,
    buoc: buoc ?? this.buoc,
    viXacNhanLuc: viXacNhanLuc ?? this.viXacNhanLuc,
    approveGuiLuc: approveGuiLuc ?? this.approveGuiLuc,
    approveXacNhanLuc: approveXacNhanLuc ?? this.approveXacNhanLuc,
    datCocGuiLuc: datCocGuiLuc ?? this.datCocGuiLuc,
    blockXacNhanLuc: blockXacNhanLuc ?? this.blockXacNhanLuc,
    khoaCocLuc: khoaCocLuc ?? this.khoaCocLuc,
    maApprove: maApprove ?? this.maApprove,
    transactionHash: transactionHash ?? this.transactionHash,
    loi: loi ?? this.loi,
    buocThatBai: buocThatBai ?? this.buocThatBai,
  );
}
