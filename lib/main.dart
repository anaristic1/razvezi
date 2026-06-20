import 'package:flutter/material.dart';
import 'package:razvezi/login.dart';
import 'package:razvezi/custom_logger.dart';

void main() {
  CustomLogger.initialize();
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    )
  );
}
