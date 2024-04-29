import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trailquest/pages/generate_trail_page.dart';
import 'package:trailquest/my_trail_list.dart';
import 'package:trailquest/widgets/trail_cards.dart';

bool browsing = false;

class TrailPage extends StatefulWidget {
  @override
  _TrailPageState createState() => _TrailPageState();
}

class _TrailPageState extends State<TrailPage> {

  final List<TrailCard> myTrails = MyTrailList;
  final List<TrailCard> friendsTrails = FriendTrailList;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(height: 40),
              CreateNewTrail(),
              Row(
                children: <Widget>[
                  AnimatedButtons(onBrowsingChanged: (value) {
                    setState(() {
                      browsing = value;
                    });
                  }),
                  FilterButton(),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
              Expanded(
                child: Trails(savedTrails: MyTrailList, friendTrails: FriendTrailList,),
                //child: Trails(trails: MyTrailList),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedButtons extends StatelessWidget {
  final ValueChanged<bool> onBrowsingChanged;

  AnimatedButtons({required this.onBrowsingChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        TextButton(
          onPressed: () {
            onBrowsingChanged(!browsing);
          },
          child: Container(
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 50,
            width: 160,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('My Trails', style: TextStyle(color: Colors.black), textAlign: TextAlign.center),
                  Text('Friends', style: TextStyle(color: Colors.black), textAlign: TextAlign.center)
                ],
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          left: browsing ? 92 : 12,
          top: 8,
          child: Container(
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: !browsing ? Text('My Trails', style: TextStyle(color: Colors.white)) : Text('Friends', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}

class FilterButton extends StatelessWidget {
  const FilterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextButton.icon(
        onPressed: () => showDialog(context: context, builder: (BuildContext context) {
          return AlertDialog(
            content: FilterPopUp(),
          );
        }),
        style: TextButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        label: const Text('Filter', style: TextStyle(color: Colors.white, fontSize: 15)),
        icon: SvgPicture.asset('assets/icons/img_filter.svg'),
      ),
    );
  }
}

class CreateNewTrail extends StatelessWidget {
  const CreateNewTrail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
          pageBuilder: (context, x, xx) => GenerateTrail(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ));
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: const Text('Generate new trail +', style: TextStyle(color: Colors.white, fontSize: 30)),
    );
  }
}

class Trails extends StatelessWidget {
  List<TrailCard> savedTrails;
  List<TrailCard> friendTrails; 
  
  Trails({Key? key, required this.savedTrails, required this.friendTrails}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<TrailCard> allTrails = new List.from(savedTrails)..addAll(friendTrails); 
    
    List<TrailCard> filteredTrails = browsing ? 
      friendTrails : 
      allTrails.where((trail) {
        return trail.isSaved; 
      }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: filteredTrails.length,
      itemBuilder: (BuildContext context, int index) {
        return filteredTrails[index]; 
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

class FilterPopUp extends StatefulWidget {
  FilterPopUp({super.key}); 

  @override 
  State<FilterPopUp> createState() => _FilterPopUpState();
}

class _FilterPopUpState extends State<FilterPopUp> {

  bool value1 = false; 
  bool value2 = false; 
  bool value3 = false; 

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  onChanged: (newValue) {
                    setState(() {
                      value1 = newValue ?? false;
                    });
                  }, 
                  value: value1
                ),
                Text('Test'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  onChanged: (newValue) {
                    setState(() {
                      value2 = newValue ?? false;
                    });
                  }, 
                  value: value2
                ),
                Text('Test'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  onChanged: (newValue) {
                    setState(() {
                      value3 = newValue ?? false;
                    });
                  }, 
                  value: value3
                ),
                Text('Test'),
              ],
            ),
          ],
        ),
        width: 40,
        height: 150
    );
  }
}
