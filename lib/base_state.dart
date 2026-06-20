import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:razvezi/storage.dart';

abstract class BaseRoutesState<T extends StatefulWidget> extends State<T> {
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();

    connectSocket();
    fetchRoutes();
  }

  void connectSocket() {
    final uri = Uri.parse("${Connection.webSocket}ws/routes/");
    channel = WebSocketChannel.connect(uri);

    channel.stream.listen((message) {
      final data = jsonDecode(message);

      if (data["type"] == "route_update") {
        onRouteUpdate(data);
      }
    });
  }

  Future<void> fetchRoutes();

  void onRouteUpdate(Map<String, dynamic> data) {
    fetchRoutes();
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}