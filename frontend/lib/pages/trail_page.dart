import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trailquest/pages/generate_trail_page.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';



final List<String> entries = <String>['Trail name', 'Different trail name', '3', '4', '5']; 

class TrailPage extends StatelessWidget{
  const TrailPage({super.key});
 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 40),
              CreateNewTrail(),
              Row( 
                children: <Widget>[
                  MyTrailsButton(),
                  BrowseButton(),
                  FilterButton(),
                ],
              ),
              Expanded(
                child: Trails(context),
              ),
            ] 
          ),
        ),
      ),
    );
  }
}

class MyTrailsButton extends StatelessWidget {
  const MyTrailsButton({super.key}); 

  @override 
  Widget build(BuildContext context) {
    return AnimatedButton(
      transitionType: TransitionType.LEFT_TO_RIGHT,
      text: 'My trails', 
      width: 80,
      onPress: null,
      isReverse: true, 
      borderRadius: 10,
      backgroundColor: Colors.black,
      borderColor: Colors.black,
      selectedTextColor: Colors.black,
      textStyle: TextStyle(
        fontSize: 15, 
        color: Colors.white
      ),
    );
  }
}

class BrowseButton extends StatelessWidget {
  const BrowseButton({super.key}); 

  @override 
  Widget build(BuildContext context) {
    return AnimatedButton(
      transitionType: TransitionType.RIGHT_TO_LEFT,
      text: 'Browse', 
      width: 80,
      onPress: null,
      isReverse: true, 
      borderRadius: 10,
      backgroundColor: Colors.black,
      borderColor: Colors.black,
      selectedTextColor: Colors.black,
      textStyle: TextStyle(
        fontSize: 15, 
        color: Colors.white
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override 
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextButton.icon( 
        onPressed: null,
        style: TextButton.styleFrom(
          backgroundColor: Colors.green, 
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          )
        ),
        label: const Text('Filter', style: TextStyle(color: Colors.white, fontSize: 15)),
        icon: SvgPicture.asset('assets/images/img_filter.svg'),
      ),
    );
  }
}

class CreateNewTrail extends StatelessWidget {
  const CreateNewTrail({super.key});

  @override 
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
          pageBuilder: (context, x, xx) => GenerateTrail(),
          transitionDuration: Duration.zero, 
          reverseTransitionDuration: Duration.zero));
      }, 

      style: TextButton.styleFrom(
        backgroundColor: Colors.green, 
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        )
      ),

      child: const Text('Generate new trail +', style: TextStyle(color: Colors.white, fontSize: 30)), 
    ); 
  }
}

Widget Trails(BuildContext context) {
  return ListView.separated(
    padding: const EdgeInsets.all(10),
    itemCount: entries.length,
    itemBuilder: (BuildContext context, int index) {
      return Container(
        width: 350,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle, 
          borderRadius: BorderRadius.all(Radius.circular(10.0)), 
          color: Colors.green[400],
        ),
        child: Row(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${entries[index]}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30
                ), 
              ),
            ),
          ],
        )
      );
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
  );
}