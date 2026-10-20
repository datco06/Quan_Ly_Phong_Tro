import 'package:flutter/material.dart';

class ONhapLieu extends StatelessWidget {
  const ONhapLieu({
    super.key,
    required this.nhan,
    this.goiY,
    this.controller,
    this.kieuBanPhim,
    this.kiemTra,
    this.choPhep = true,
    this.chiDoc = false,
    this.bieuTuongDau,
    this.bieuTuongCuoi,
    this.khiThayDoi,
    this.soDong = 1,
    this.anNoiDung = false,
    this.loi,
    this.batBuoc = false,
    this.nutTapTrung,
    this.hanhDongBanPhim,
    this.khiGui,
  });
  final String nhan;
  final String? goiY, loi;
  final TextEditingController? controller;
  final TextInputType? kieuBanPhim;
  final FormFieldValidator<String>? kiemTra;
  final bool choPhep, chiDoc, anNoiDung, batBuoc;
  final Widget? bieuTuongDau, bieuTuongCuoi;
  final ValueChanged<String>? khiThayDoi;
  final int soDong;
  final FocusNode? nutTapTrung;
  final TextInputAction? hanhDongBanPhim;
  final ValueChanged<String>? khiGui;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    focusNode: nutTapTrung,
    textInputAction: hanhDongBanPhim,
    onFieldSubmitted: khiGui,
    keyboardType: kieuBanPhim,
    validator: kiemTra,
    enabled: choPhep,
    readOnly: chiDoc,
    onChanged: khiThayDoi,
    maxLines: anNoiDung ? 1 : soDong,
    obscureText: anNoiDung,
    decoration: InputDecoration(
      labelText: '$nhan${batBuoc ? ' *' : ''}',
      hintText: goiY,
      errorText: loi,
      prefixIcon: bieuTuongDau,
      suffixIcon: bieuTuongCuoi,
    ),
  );
}
