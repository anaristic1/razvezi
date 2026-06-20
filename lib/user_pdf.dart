import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:razvezi/cookie.dart';
import 'package:razvezi/custom_logger.dart';
import 'package:razvezi/storage.dart';

Future<String?> downloadRoutesPDF() async {

  final cookie = await getCookieFromStorage();

  final url = Uri.parse('${Connection.adress}last_month_report/'); 

  final response = await http.get(
    url,
    headers: {
      'Cookie': cookie,
    },
  );

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;

    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/routes.pdf');

    await file.writeAsBytes(bytes);

    return file.path; 
  } else {
    CustomLogger.error("Failed to download PDF");
    return null;
  }
}