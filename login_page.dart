import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  bool isPatient = true;

  Future<void> login() async {
    setState(() => loading = true);

    final url = "http://192.168.56.1/mysql_auth_backend/login.php";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email.text,
        "password": pass.text
      }),
    );

    setState(() => loading = false);

    if (response.body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server did not return any data")));
      return;
    }

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data["message"])));

    if (data["status"] == "success") {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => Dashboard(email: email.text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDEFF5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 400,
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medication, color: Colors.blue, size: 40),
                    SizedBox(width: 10),
                    Text(
                      "MediCare",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Welcome Back",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Login to manage your medications",
                      style: TextStyle(color: Colors.grey)),
                ),

                SizedBox(height: 20),

                // I am a
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("I am a",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPatient = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isPatient ? Colors.black : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Patient",
                              style: TextStyle(
                                  color: isPatient
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isPatient = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isPatient
                                ? Colors.black
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "Caregiver",
                              style: TextStyle(
                                  color: !isPatient
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Email
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Email")),
                SizedBox(height: 8),
                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    prefixIcon: Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),

                SizedBox(height: 15),

                // Password
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Password")),
                SizedBox(height: 8),
                TextField(
                  controller: pass,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    prefixIcon: Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Color(0xFFF2F2F2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),

                SizedBox(height: 25),

                // Login Button
                loading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(15),
                            ),
                          ),
                          child: Text("Login",
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),

                SizedBox(height: 15),

                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ForgotPasswordPage()));
                    },
                    child: Text("Forgot Password?",
                        style: TextStyle(color: Colors.blue))),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    RegisterPage()));
                      },
                      child: Text("Sign Up",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight:
                                  FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
