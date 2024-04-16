import 'package:flutter/material.dart';
import 'package:trailquest/main.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class ChallengePage extends StatelessWidget{ 
  WebSocketChannel channel = WebSocketChannel.connect(Uri.parse("ws://130.243.229.232:3000"));
 var jsonString = '''
    {"msgID": "initRes",
    "data": {"username": "emmisen"}}
  ''';

  void _sendMessage(var message) {
    print(message);
    try {
      channel.sink.add(message);
      channel.stream.listen((message) {
        print(message);
        channel.sink.close();
      });
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Leaderboard'),
          // button
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                _sendMessage(jsonString);
  
              },
            ),
          ],
        ),
        body: Center(
          child: Text('Challenge!', 
            style: TextStyle(
              color: Colors.green, 
              fontSize: 30.0,
            )
          ), 
        ),
      ),
    );
  }
}