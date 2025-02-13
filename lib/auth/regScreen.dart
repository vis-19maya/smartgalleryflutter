import 'package:flutter/material.dart';
import 'package:gallery/auth/loginScreen.dart';
import 'package:gallery/auth/registrationApi.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? _selectedGender;
  Map<String, dynamic> registrationData = {};

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(235, 245, 242, 242),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Form(
            key: formKey,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/Logo.png',
                        height: 100,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                       "Smart Gallery",
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      const SizedBox(height: 15),
                      const Text(
                        "Registration",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      // name
                      TextFormField(
                        validator: (value) => value == null || value.isEmpty ? "Field can't be empty" : null,
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Date of birth
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: "Date of Birth",
                          prefixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Phone number
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Phone number is required";
                          }
                          final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
                          return phoneRegex.hasMatch(value) ? null : "Enter a valid phone number";
                        },
                        controller: _phonenumberController,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Gender
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        validator: _validateGender,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                        ],
                        decoration: InputDecoration(
                          labelText: "Gender",
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email
                      TextFormField(
                        validator: (value) => value!.isEmpty || !value.contains('@') ? "Invalid email" : null,
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Username with minimum 4 characters validation
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field can't be empty";
                          }
                          if (value.length < 4) {
                            return "Username must be at least 4 characters";
                          }
                          return null;
                        },
                        controller: _userNameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: const Icon(Icons.account_circle),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Password with length validation (min 8 characters)
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Field can't be empty";
                          }
                          if (value.length < 8) {
                            return "Password must be at least 8 characters";
                          }
                          return null;
                        },
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              registrationData['name'] = _nameController.text;
                              registrationData['phonenumber'] = _phonenumberController.text;
                              registrationData['gender'] = _selectedGender;
                              registrationData['email'] = _emailController.text;
                              registrationData['username'] = _userNameController.text;
                              registrationData['password'] = _passwordController.text;
                              registrationData['dob'] = _dobController.text;

                              await regapi(registrationData);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Registered successfully")),
                              );
                            }
                          },
                          child: const Text("Submit"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
