import 'package:flutter/material.dart';
import 'package:razvezi/base_state.dart';
import 'package:razvezi/driver_routes.dart';
import 'package:razvezi/get_data.dart';

import 'package:razvezi/create_new.dart';
import 'package:razvezi/storage.dart';
import 'package:razvezi/base_state.dart';

String userCreatedRoutes = "${Connection.adress}created_routes/";

class UserRoutesScreen extends StatefulWidget {
  const UserRoutesScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserRidesScreen();
  }
}

class _UserRidesScreen extends BaseRoutesState<UserRoutesScreen> {

  Future? _allRoutes;

  @override
  Future<void> fetchRoutes() async {
    setState(() {
      _allRoutes = getResponse(userCreatedRoutes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _allRoutes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            
            final routes = snapshot.data as List;

            return Column(
              children: [
                Expanded(
                  child: routes.isEmpty 
                  ? Container()
                  : Column(
                    children: [
                      const Text("Kreirane rute"),
                      Expanded(
                        child: RoutesList(routes: routes),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: createNewRouteButton(),
                ),
              ],
            );

          }
        ),
      ),
    );
  }

  Widget createNewRouteButton(){
    return FloatingActionButton.small(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewRouteFormScreen(),
          ),
        );
      },
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      child: const Icon(Icons.add),
    );
  }

}