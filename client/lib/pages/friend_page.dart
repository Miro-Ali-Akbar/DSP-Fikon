import 'package:flutter/material.dart';
import 'package:trailquest/main.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trailquest/widgets/challenge_cards.dart';


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
        ),
        body: Expanded(child: 
              ListView.builder(
                  itemCount: friendsList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(friendsList[index].name),
                    );
                  }
                ),
        )
      )
    );

  }

}//end class


void showFriendRequest(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return friendRequest(
        content: Container(
          width: MediaQuery.of(context).size.width / 1.3,
          height: MediaQuery.of(context).size.height / 2.5,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFFFFF),
            borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
          ),
          child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height/12,
                  padding: EdgeInsets.all(15.0),
                  child: Material(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontFamily: 'helvetica_neue_light',
                            ),
                            textAlign: TextAlign.center,
                
                          ),
                        ],
                      )
                  ),
                ),
        ), 
      );
    },
  );
}
class friendRequest extends StatelessWidget{
  final Widget content;
  friendRequest({required this.content});
  Widget build(BuildContext context) {
    return AlertDialog(
      content: content,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      //add preferences
    );
  }
}
