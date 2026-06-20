import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razvezi/cookie.dart';
import 'package:razvezi/custom_logger.dart';
import 'package:razvezi/storage.dart';

var allRoutes = '${Connection.adress}routes/';
var driverRoutes = '${Connection.adress}driver_routes/';


Future getResponse(String URL) async {
  final cookie = await getCookieFromStorage();
  final response = await http.get(
    Uri.parse(URL),
    headers:  {
      'Cookie': cookie,
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Unsucessfull');
  }
}

Future getAllRoutes() async {
  return getResponse(allRoutes);
}

Future getAcceptedRoutesByDriver() async {
  return getResponse(driverRoutes);
}

Future getRouteStatusHistory(int route_id) async {
  String url_route_hist = "${Connection.adress}routes/$route_id/history";
  return getResponse(url_route_hist);
}

Future<bool> takeRoute(int routeId, int userId) async {
  final url = Uri.parse('$allRoutes$routeId/');
  final cookie = await getCookieFromStorage();

  final response = await http.patch(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'X-CSRFToken': await getCSRF(),
    },
    body: jsonEncode({
      'status': 2, //prihvacena 
    }),
  );

  if (response.statusCode == 200) {
    CustomLogger.info("Driver $userId takes $routeId");
    return true;
  } else {
    CustomLogger.error("Error while trying to take route");
    return false;
  }
}

Future<bool> changeRouteStatus(int routeId, String path) async {
  // path cancel finish take_product

  final url = Uri.parse("${Connection.adress}routes/$routeId/$path/");
  final cookie = await getCookieFromStorage();

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'X-CSRFToken': await getCSRF(),
    },
  );

  if (response.statusCode == 200) {
    CustomLogger.debug("Sucess for changing route $routeId status to: $path");
    return true;
  } else {
    CustomLogger.debug("Error while trying to change route $routeId status to: $path");
    return false;
  }
}