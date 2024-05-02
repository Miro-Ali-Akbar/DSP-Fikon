import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';


class Friendpage extends StatelessWidget {

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: Text("Friends",
            style: TextStyle(
              color: Colors.green, 
              fontSize: 30.0
            )
          
          ),
           actions: <Widget>[
            TextButton.icon(
                onPressed: () {
  
                  
                },
                label: Text(
                  'Add Friend +',
                  style: TextStyle(color: Colors.white),
                ),
                icon: SvgPicture.asset('assets/images/img_group.svg'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 30),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                )
              ),
           ]
        )
      )
    );

  }

}