import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;

  Future<void> register() async {
    setState(() => loading = true);
    final url = "http://192.168.56.1/mysql_auth_backend/register.php"; // replace IP
    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.text, "password": pass.text}));
    final data = jsonDecode(response.body);
    setState(() => loading = false);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data["message"])));

    if (data["status"] == "success") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        width: 380,
        padding: EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Register", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(controller: email, decoration: InputDecoration(labelText: "Email")),
          SizedBox(height: 15),
          TextField(
            controller: pass,
            obscureText: true,
            decoration: InputDecoration(labelText: "Password"),
          ),
          SizedBox(height: 20),
          loading
              ? CircularProgressIndicator()
              : ElevatedButton(onPressed: register, child: Text("Register")),
        ]),
      ),
    ));
  }
}
