import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  final String email;
  Dashboard({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Text(
          "Welcome $email 👋",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
