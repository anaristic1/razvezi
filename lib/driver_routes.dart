import 'package:flutter/material.dart';
import 'package:razvezi/base_state.dart';
import 'package:razvezi/get_data.dart';
import 'package:razvezi/route_detail.dart';


class DriverRoutesScreen extends StatefulWidget {
  const DriverRoutesScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DriverRoutesScreen();
  }
}


class _DriverRoutesScreen extends BaseRoutesState<DriverRoutesScreen> {

  Future? _allRoutes;
  Future? _acceptedRoutes;

  @override
  Future<void> fetchRoutes() async {
    setState(() {
      _allRoutes = getAllRoutes();
      _acceptedRoutes = getAcceptedRoutesByDriver();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
              children: [
                const Text("Dostupne rute"),
                Expanded(
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
      
                      return ListView.builder(
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          var route = routes[index];
                          var start = "${route['start_location']}";
                          var end = "${route['end_location']}";
      
                          return Dismissible(
                            key: Key("$start-$end"),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.check, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                await takeRoute(routes[index]['id'], 2);
                              }
                              return false;
                            },
                            child: Card(
                              color: const Color.fromARGB(255, 244, 222, 24),
                              child: ListTile(title: Text("$start - $end")),
                            )
                          );
                        },
                      );
                    },
                  ),
                ),
                const Text("Moje rute"),
                Expanded(
                  child: FutureBuilder(
                    future: _acceptedRoutes,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                
                      final routes = snapshot.data as List;
      
                      return RoutesList(routes: routes);
                    },
                  ),
                ),
            ],
        ),
      ),
    );
  }
}

class RoutesList extends StatelessWidget {
  final List routes;

  const RoutesList({
    required this.routes,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      itemCount: routes.length,
      itemBuilder: (context, index) {
        var route = routes[index];
        var start = "${route['start_location']}";
        var end = "${route['end_location']}";

        return Card(
          color: switch (route['status']) {
            1 => const Color.fromARGB(225, 200, 200, 200), // Nov
            2 => const Color.fromARGB(225, 95, 245, 123), //Prihvacen
            3 => const Color.fromARGB(225, 95, 245, 123),
            4 => const Color.fromARGB(225, 95, 245, 123),
            5 => const Color.fromARGB(224, 245, 53, 19), 
            _ => const Color.fromARGB(225, 200, 200, 200),
          },
          child: ListTile(
            title: Text("$start - $end"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RouteDetailScreen(route: route),
                ),
              );
            },
          ),
        );
      },
    );

  }
}