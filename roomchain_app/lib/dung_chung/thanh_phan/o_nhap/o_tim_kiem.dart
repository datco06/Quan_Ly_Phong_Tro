import 'package:flutter/material.dart';

class OTimKiem extends StatefulWidget {
  const OTimKiem({
    super.key,
    this.controller,
    this.goiY = 'Tìm khu vực, giá thuê, tiện ích...',
    this.khiTimKiem,
    this.tuDongFocus = false,
  });
  final TextEditingController? controller;
  final String goiY;
  final ValueChanged<String>? khiTimKiem;
  final bool tuDongFocus;
  @override
  State<OTimKiem> createState() => _OTimKiemState();
}

class _OTimKiemState extends State<OTimKiem> {
  TextEditingController? _noiBo;
  TextEditingController get _controller =>
      widget.controller ?? (_noiBo ??= TextEditingController());
  @override
  void dispose() {
    _noiBo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) => TextField(
          controller: _controller,
          autofocus: widget.tuDongFocus,
          textInputAction: TextInputAction.search,
          onChanged: widget.khiTimKiem,
          onSubmitted: widget.khiTimKiem,
          decoration: InputDecoration(
            hintText: widget.goiY,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Xóa tìm kiếm',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      widget.khiTimKiem?.call('');
                    },
                  ),
          ),
        ),
      );
}
