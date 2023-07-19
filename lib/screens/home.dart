import 'package:flutter/material.dart';
import 'package:whatsapp_web_clone/resources/responsive.dart';

import 'home_mobile.dart';
import 'home_web.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: HomeMobile(),
      web: const HomeWeb(),
      tablet: const HomeWeb(),
    );
  }
}
