import 'package:flutter/material.dart';

import 'package:razvezi/cookie.dart';
import 'package:razvezi/account.dart';
import 'package:razvezi/driver_routes.dart';
import 'package:razvezi/user_routes.dart';
import 'package:razvezi/storage.dart';
import 'package:razvezi/todays_rides.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final List<Widget> pages;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    pages = [
    routeScreenForRole(),
    const UserRoutesToday(),
    const AccountPage(),
  ];
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        indicatorColor: AppColors.primaryColor,
        selectedIndex: selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Početna',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car),
            label: 'Današnje rute',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Nalog',
          ),
        ],
      ),
    );
  }
}

Widget routeScreenForRole() => switch (Session.role) {
  'driver' => const DriverRoutesScreen(),
  'store' => const UserRoutesScreen(),
  _ => throw Exception('Unknown role: ${Session.role}'),
};
