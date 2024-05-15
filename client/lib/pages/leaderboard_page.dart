import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:trailquest/widgets/back_button.dart';

class Leaderboard extends StatelessWidget {
  final List<String> myList;

  // Constructor to receive the list
  Leaderboard(this.myList);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              GoBackButton().build(context),
              Text('Leaderboard',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30.0,
                  )),
              SvgPicture.asset(
                'assets/icons/img_group.svg',
                colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Username', style: TextStyle(fontSize: 20)),
                Text('Score', style: TextStyle(fontSize: 20)),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 5),
                itemCount: myList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    tileColor:
                        index % 2 == 0 ? Colors.green[100] : Colors.white,
                    leading: SizedBox(
                      width: 40,
                      child: index == 0
                          ? SvgPicture.asset(
                              'assets/icons/gold_medal.svg',
                              width: 40,
                              height: 40,
                            )
                          : index == 1
                              ? SvgPicture.asset(
                                  'assets/icons/silver_medal.svg',
                                  width: 40,
                                  height: 40,
                                )
                              : index == 2
                                  ? SvgPicture.asset(
                                      'assets/icons/bronze_medal.svg',
                                      width: 40,
                                      height: 40,
                                    )
                                  : Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(myList[index].split(' ')[1]),
                        Text(myList[index].split(' ')[0]),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
