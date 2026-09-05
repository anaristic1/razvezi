import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razvezi/get_data.dart';
import 'package:razvezi/cookie.dart';
import 'package:razvezi/utility.dart';

// driver ima dva dugmeta
// admin ima otkazi porudzbinu, mozda zovi vozaca?
// status history

Widget createButton(String text, void Function() func) {
  return ElevatedButton(
    onPressed: func,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow,
      foregroundColor: Colors.black,
    ),
    child: Text(text),
  );
}

Widget getButtonsBasedOnRole(routeId, routeStatus, StateSetter setState) {
  switch (Session.role) {
    case "driver":
      var shouldTakeProductBtn = routeStatus == 1 || routeStatus == 2;
      var shouldFinishBtn = routeStatus == 3;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (shouldTakeProductBtn) ...[
          createButton("Preuzeta roba", () async {
            bool success = await changeRouteStatus(routeId, 'take_product');
            if (success) {
              setState(() {
                shouldTakeProductBtn = false;
                shouldFinishBtn = true;
              });
            } else {}
          })],
          const SizedBox(width: 10),
          if (shouldFinishBtn) ...[
          createButton("Zavrseno", () async {
            bool success = await changeRouteStatus(routeId, 'finish');
            if (success) {
              setState(() {
                shouldFinishBtn = false;
              });
            } else {}
          })],
        ],
      );
    case "store":
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createButton("Otkaži", () async {
            bool success = await changeRouteStatus(routeId, 'cancel');
            if (success) {
              setState(() {});
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

  late int routeStatus;
  late int routeId;

  @override
  void initState() {
    super.initState();
    routeStatus = widget.route['status'];
    routeId = widget.route['id'];
  }

  Widget getButtons(){
    switch (Session.role) {
      case "driver":
        return buildButtonsForDrivers();
      case "store":
        return buildButtonsForStore();
      default:
        return const Text('');
    }
  }

  Widget buildButtonsForDrivers(){
    if (routeStatus==2){ //Prihvacen 
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createButton("Preuzeta roba", () async {
            bool success = await changeRouteStatus(routeId, 'take_product');
            if (success) {
              setState(() {
                routeStatus = 3;
              });
            }
          }),
        ],
      );
    }
    if (routeStatus==3){ // Preuzeta roba
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          createButton("Zavrseno", () async {
            bool success = await changeRouteStatus(routeId, 'finish');
            if (success) {
              setState(() {
                routeStatus = 4;
              });
            }
          }),
        ],
      );
    }
    return const Text('');
  }

  Widget buildButtonsForStore(){
    if (routeStatus==1 || routeStatus==2){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createButton("Otkaži", () async {
            bool success = await changeRouteStatus(routeId, 'cancel');
            if (success) {
              setState(() {});
              routeStatus = 5;
            }
          }),
        ],
      );
    }else{
      return const Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    var route = widget.route;
    var start = route['start_location'];
    var end = route['end_location'];

    DateTime dateCreated = DateTime.parse(route['date_created']).toLocal();
    String formattedDate = DateFormat('HH:mm dd.MM.').format(dateCreated);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ruta"),
        backgroundColor: Colors.white30,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container( // for info before buttons
            padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            decoration: getBoxDecoration(),
            child: Column(
              children: [
              _routeInfoRow(icon: Icons.arrow_upward, label: 'Od', value: start),
              _getDivider(),
              _routeInfoRow(icon: Icons.location_on_outlined, label: 'Do', value: end),
              _getDivider(),
              _routeInfoRow(icon: Icons.calendar_today_outlined, label: 'Kreirana u', value: formattedDate),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16.0), // Adds 16px margin on all sides
            child: getButtons(),
          ),

          Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: getBoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                      "Statusi rute:",
                      style: TextStyle(
                        fontSize:15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ),
                    const SizedBox(height: 12),
                    StatusHistory(routeId: route['id']),
                  ],
                ),
              ),
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
  String getText(status, user) {
    switch (status) {
      case 1:
        return "Korisnik $user je napravio novu rutu.";
      case 2:
        return "Korisnik $user je prihvatio rutu.";
      case 3:
        return "Korisnik $user je preuzeo paket.";
      case 4:
        return "Korisnik $user je zavrsio voznju.";
      case 5:
        return "Korisnik $user je otkazao voznju.";
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];

            DateTime timeOfCreation =
                DateTime.parse(item['changed_at']).toLocal();
            String formattedCreation =
                DateFormat('HH:mm').format(timeOfCreation);

            return _statusItem(
              time: formattedCreation, 
              text: getText(item['status'], item['changed_by']),
              isLast: index == history.length - 1);
          },
        );
      },
    );
  }
}

Widget _routeInfoRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: 
          BoxDecoration(
            color: Colors.yellow.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        child: Icon(
          icon,
          color: Colors.black,
        ),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
            ),  
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _getDivider(){
  return const Divider(
    color: Colors.grey,
    thickness: 1,
    indent: 10,
    endIndent: 10,
  );
}


Widget _statusItem({
    required String time,
    required String text,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Timeline
          SizedBox(
            width: 30,
            child: Column(
              children: [
                // Yellow dot
                Container(
                  width: 15,
                  height: 15,
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),

                // Line connecting statuses
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.black12,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Status content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
