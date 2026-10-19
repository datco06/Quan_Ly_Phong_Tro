import 'package:flutter/material.dart';

class KhungThe extends StatelessWidget {
  const KhungThe({super.key, required this.child, this.khiNhan});
  final Widget child;
  final VoidCallback? khiNhan;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: khiNhan,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}
