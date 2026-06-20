import 'package:flutter/material.dart';
import 'package:razvezi/login.dart';
import 'package:razvezi/user_pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:razvezi/cookie.dart';
import 'package:razvezi/storage.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "${Session.username}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final path = await downloadRoutesPDF();
                if (path != null) {
                  OpenFile.open(path);
                }
              },
              icon: const Icon(Icons.download),
              label: const Text("Izvod za prošli mesec"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Izlogujte se"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Statistics extends StatelessWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("This");
  }
}
