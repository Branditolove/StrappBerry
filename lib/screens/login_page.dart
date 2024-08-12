import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF353C59),
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Image.asset('assets/logo.png', height: 80),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        FormBuilderTextField(
                          name: 'email',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F1F5),
                            hintText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.email(),
                          ]),
                        ),
                        const SizedBox(height: 15),
                        FormBuilderTextField(
                          name: 'password',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F1F5),
                            hintText: 'Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: FormBuilderValidators.required(),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final email =
                                  _formKey.currentState?.fields['email']?.value;
                              final password = _formKey
                                  .currentState?.fields['password']?.value;

                              final prefs =
                                  await SharedPreferences.getInstance();
                              final adminAccountsJson =
                                  prefs.getString('adminAccounts') ?? '[]';
                              final adminAccounts =
                                  List<Map<String, dynamic>>.from(
                                jsonDecode(adminAccountsJson),
                              );
                              final users = prefs.getStringList('users') ?? [];

                              final isAdmin = adminAccounts.any((account) =>
                                  account['email'] == email &&
                                  account['password'] == password);

                              final isUser = users.any((user) {
                                final parts = user.split('|');
                                final storedEmail = parts[1];
                                final storedPassword = parts[2];
                                return storedEmail == email &&
                                    storedPassword == password;
                              });

                              if (isAdmin) {
                                // ignore: use_build_context_synchronously
                                Navigator.pushNamed(context, '/admin');
                              } else if (isUser) {
                                // ignore: use_build_context_synchronously
                                Navigator.pushNamed(context, '/user');
                              } else {
                                showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'Email o contraseña incorrectos'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF353C59),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Iniciar sesión',
                              style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            '¿No tienes cuenta?\nRegístrate',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blueAccent,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Brandon Diaz | brandonvqz23@gmail.com',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF686B75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
