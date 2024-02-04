import 'package:flutter/material.dart';
import 'team_page.dart';

class TeamsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الفِرَق'),
          centerTitle: true,
        ),
        body: const TeamPage(),
      ),
    );
  }
}
