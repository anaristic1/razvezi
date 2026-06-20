import 'package:flutter/material.dart';
import 'package:razvezi/custom_logger.dart';
import 'package:razvezi/cookie.dart';
import 'package:razvezi/navigation_bar.dart';
import 'package:razvezi/storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : null,
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Korisničko ime'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Unesi korisničko ime";
                  }
                  return null;
                },
                onSaved: (value) => username = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Lozinka'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Unesi lozinku";
                  }
                  return null;
                },
                onSaved: (value) => password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Prijava'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String result = await serverLogin(username, password);

      if (!mounted) return;

      if (result.isNotEmpty) {
        CustomLogger.warning("Unsuccessfull logging: $result.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
        return;
      }
      CustomLogger.info("Successfull login for user $username.");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
    }
  }
}
