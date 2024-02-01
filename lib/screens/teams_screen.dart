import 'package:flutter/material.dart';
import 'team_page.dart';

class TeamsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
      ),
      body: TeamPage(),
    );
  }
}
