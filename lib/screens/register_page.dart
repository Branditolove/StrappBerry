import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  RegisterPage({super.key});

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
                          name: 'name',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F1F5),
                            hintText: 'Nombre',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                        const SizedBox(height: 15),
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
                        const SizedBox(height: 15),
                        FormBuilderTextField(
                          name: 'confirm_password',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF0F1F5),
                            hintText: 'Confirmar contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            (val) {
                              if (val !=
                                  _formKey.currentState?.fields['password']
                                      ?.value) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            }
                          ]),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.saveAndValidate() ??
                                false) {
                              final name =
                                  _formKey.currentState?.fields['name']?.value;
                              final email =
                                  _formKey.currentState?.fields['email']?.value;
                              final password = _formKey
                                  .currentState?.fields['password']?.value;

                              final prefs =
                                  await SharedPreferences.getInstance();
                              final users = prefs.getStringList('users') ?? [];
                              const isAdmin =
                                  false; // Cambia esta lógica según tu aplicación
                              // ignore: dead_code
                              const rolePrefix = isAdmin ? 'admin|' : '';

                              users.add('$rolePrefix$name|$email|$password');
                              await prefs.setStringList('users', users);

                              // ignore: use_build_context_synchronously
                              Navigator.pushNamed(context, '/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF353C59),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Registrarse',
                              style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            '¿Ya tienes cuenta?\nInicia sesión',
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
