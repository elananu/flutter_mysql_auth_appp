import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final email = TextEditingController();
  bool loading = false;

  Future<void> resetPassword() async {
    setState(() => loading = true);
    final url = "http://192.168.56.1/mysql_auth_backend/forgot_password.php"; // replace IP
    final response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email.text}));
    final data = jsonDecode(response.body);
    setState(() => loading = false);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data["message"])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        width: 380,
        padding: EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Forgot Password",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(controller: email, decoration: InputDecoration(labelText: "Email")),
          SizedBox(height: 20),
          loading
              ? CircularProgressIndicator()
              : ElevatedButton(onPressed: resetPassword, child: Text("Send Reset Link")),
        ]),
      ),
    ));
  }
}
