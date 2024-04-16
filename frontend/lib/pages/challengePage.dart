import 'package:flutter/material.dart';
import 'package:trailquest/main.dart';


class ChallengePage extends StatelessWidget{ 

 var jsonString = '''
  [
    {"msgID": intres},
    {"data": {"username": emmisen}}
  ]
  ''';

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
                try{
                  channel?.sink.add(jsonString);
                  channel?.stream.listen((jsonString) {
                    print(jsonString);
                    channel?.sink.close();
                  });
                } catch (error) {
                  print(error);
                }
  
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