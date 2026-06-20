import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razvezi/get_data.dart';
import 'package:razvezi/cookie.dart';

// driver ima dva dugmeta
// admin ima otkazi porudzbinu, mozda zovi vozaca?
// status history 


Widget createButton(String text, void Function() func){
  return ElevatedButton(
    onPressed: func,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow,
      foregroundColor: Colors.black,
    ),
    child: Text(text),
  );
}

Widget getButtonsBasedOnRole(routeId, VoidCallback onRefresh){
  switch (Session.role) {
    case "driver":
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createButton("Preuzeta roba", 
          () async {
            bool success = await changeRouteStatus(routeId, 'take_product');

            if (success){
              onRefresh();
            }else{
            }
          }),
          const SizedBox(width: 10),
          createButton("Zavrseno", 
          () async { 
            bool success = await changeRouteStatus(routeId, 'finish');
            if (success){
              onRefresh();
            }else{
            }

          }),
        ],
      );
    case "dispatcher":
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createButton("Otkaži", 
          () async { 
            bool success = await changeRouteStatus(routeId, 'cancel');
            if (success){
              onRefresh();
            }
          }),
        ],
      );
    default: 
      return const Text('');
  }
}

class RouteDetailScreen extends StatefulWidget {
  final dynamic route;

  const RouteDetailScreen({super.key, required this.route});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {

  void refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var route = widget.route;
    var start = route['start_location'];
    var end = route['end_location'];
    var status = route['status'];

    DateTime date_created = DateTime.parse(route['date_created']).toLocal();
    String formatted_date = DateFormat('dd.MM.yyyy HH:mm').format(date_created);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ruta"), 
        backgroundColor: const Color.fromARGB(219, 251, 236, 95),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Od: $start"),
          Text("Do: $end"),
          Text("Vreme kreiranja rute: $formatted_date"),
          getButtonsBasedOnRole(
            route['id'],
            refreshPage,
          ),
          const Text("Statusi rute:"),
          Expanded(
            child: StatusHistory(routeId: route['id']),
          ),
        ],
      ),
    );
  }
}

class StatusHistory extends StatefulWidget {
  final dynamic routeId;

  const StatusHistory({super.key, required this.routeId});

  @override
  State<StatefulWidget> createState() {
    return _StatusHistory();
  }
}


class _StatusHistory extends State<StatusHistory> {

  String getText(status, time, user){
    switch (status) {
      case 1:
        return "$time Korisnik $user je napravio novu rutu.";
      case 2:
        return "$time Korisnik $user je prihvatio rutu.";
      case 3:
        return "$time Korisnik $user je preuzeo paket.";
      case 4:
        return "$time Korisnik $user je zavrsio voznju.";
      case 5:
        return "$time Korisnik $user je otkazao voznju.";
      default:
        return "Nepoznat status";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRouteStatusHistory(widget.routeId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Nema statusa za ovu rutu.');
        }
  
        final history = snapshot.data as List;
  
        return ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            
            DateTime time_of_creation = DateTime.parse(item['changed_at']).toLocal();
            String formatted_creation = DateFormat('HH:mm').format(time_of_creation);

            return ListTile(
              title: Text(getText(item['status'], formatted_creation, item['changed_by'])),
              //subtitle: Text(formatted_creation),
            );
          },
        );
      },
    );
  }
}