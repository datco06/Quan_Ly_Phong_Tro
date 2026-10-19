import 'package:flutter/material.dart';

class LuaChon<T> {
  const LuaChon({required this.giaTri, required this.nhan});
  final T giaTri;
  final String nhan;
}

class OChon<T> extends StatelessWidget {
  const OChon({
    super.key,
    required this.nhan,
    required this.luaChon,
    this.giaTri,
    this.khiThayDoi,
    this.kiemTra,
  });
  final String nhan;
  final List<LuaChon<T>> luaChon;
  final T? giaTri;
  final ValueChanged<T?>? khiThayDoi;
  final FormFieldValidator<T>? kiemTra;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    key: ValueKey(giaTri),
    initialValue: giaTri,
    isExpanded: true,
    decoration: InputDecoration(labelText: nhan),
    validator: kiemTra,
    items: luaChon
        .map(
          (e) => DropdownMenuItem(
            value: e.giaTri,
            child: Text(e.nhan, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: khiThayDoi,
  );
}
