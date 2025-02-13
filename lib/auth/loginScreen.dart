
import 'package:flutter/material.dart';
import 'package:gallery/auth/loginApi.dart';
import 'package:gallery/auth/regScreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(text: "cvbvff");
  final TextEditingController _passwordController = TextEditingController(text: "dghgffg");
  // ignore: unused_field
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 242, 242),
      body: Padding(
        padding: const EdgeInsets.all(45.0),
        child: Center(
          child: Form(
            key: formKey,
            child: Container(            
              decoration: BoxDecoration(
                color: const Color.fromARGB(244, 232, 230, 229),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/Logo.png', // Image from assets
                      height: 80, // Adjust size as needed
                    ),
                    
                    const SizedBox(height: 10),
                    const Text(
                      "Smart Gallery",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Login",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    const SizedBox(height: 15),
                      TextFormField(
                      validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Username cannot be empty";
                      }
                      if (!RegExp(r'^[a-zA-Z0-9]{3,}$').hasMatch(value)) {
                     return "Username must be at least 3 characters and contain only letters and numbers.";
                     }
                     return null;
                      },
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        labelText: 'Username',
                        hintStyle: const TextStyle(color: Color.fromARGB(255, 19, 18, 18)),
                        fillColor: const Color.fromARGB(255, 235, 244, 244),
                        filled: true,
                        labelStyle: const TextStyle(color: Colors.blueGrey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 21.0),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password cannot be empty";
                        } else if (value.length <= 4) {
                          return "Password must be at least 4 characters";
                        }
                        return null;
                      },
                      controller: _passwordController,
                      decoration: InputDecoration(
                        suffixIcon: const Icon(Icons.lock),
                        hintStyle: const TextStyle(color: Colors.blueGrey),
                        fillColor: const Color.fromARGB(255, 238, 235, 235),
                        filled: true,
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.blueGrey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      width: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.black26,
                      ),
                    ),
                    const SizedBox(height: 21),
                    SizedBox(
                      width: 500,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await loginapi(_emailController.text, _passwordController.text, context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Logged in successfully")),
                            );
                            print("Username: ${_emailController.text}");
                            print("Password: ${_passwordController.text}");
                          }
                        },
                        child: const Text("Login"),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const SizedBox(
                      height: 50,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationPage()),
                        );
                      },
                      child: const Text("Create an account"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
