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
  late final List<NavigationDestination> destinations;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    switch (Session.role) {
      case 'driver':
        pages = [
          const DriverRoutesScreen(),
          const UserRoutesToday(),
          const AccountPage(),
        ];
        destinations = const [
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
        ];    
        break;
      case 'store': 
        pages = [
          const UserRoutesScreen(),
          const AccountPage(),
        ];
        destinations = const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Početna',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Nalog',
          ),
        ];  
        break;
      default:
        throw Exception('Unknown role: ${Session.role}');
    
    }    
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
        destinations: destinations,
      ),
    );
  }
}