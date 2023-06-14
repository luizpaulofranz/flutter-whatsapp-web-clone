import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget web;

  const Responsive({
    Key? key,
    required this.mobile,
    required this.web,
    this.tablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraits) {
        if (constraits.maxWidth >= 1200) {
          return web;
        } else if (constraits.maxWidth >= 800) {
          Widget? resTablet = tablet;
          if (resTablet != null) {
            return resTablet;
          } else {
            return web;
          }
        } else {
          return mobile;
        }
      },
    );
  }
}
