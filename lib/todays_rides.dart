import 'package:flutter/material.dart';
import 'package:razvezi/base_state.dart';
import 'package:razvezi/driver_routes.dart';
import 'package:razvezi/get_data.dart';

import 'package:razvezi/create_new.dart';
import 'package:razvezi/storage.dart';
import 'package:razvezi/base_state.dart';
import 'package:razvezi/utility.dart';

String todaysRoutes = "${Connection.adress}drivers_routes_today/";

class UserRoutesToday extends StatefulWidget {
  const UserRoutesToday({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserRoutesTodayScreen();
  }
}

class _UserRoutesTodayScreen extends BaseRoutesState<UserRoutesToday> {

  Future? _allRoutes;

  @override
  Future<void> fetchRoutes() async {
    setState(() {
      _allRoutes = getResponse(todaysRoutes);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: routes.isEmpty 
                  ? Container()
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Današnje rute: ${routes.length}"),
                      Expanded(
                        child: RoutesList(routes: routes),
                      ),
                    ],
                  ),
                ),
              ],
            );

          }
        ),
      ),
    );
  }

}