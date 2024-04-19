import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trailquest/pages/generate_trail_page.dart';

bool browsing = false;

class TrailPage extends StatefulWidget {
  @override
  _TrailPageState createState() => _TrailPageState();
}

class _TrailPageState extends State<TrailPage> {

  final List<String> myTrails = ['Trail name', 'Different trail name', '3', '4', '5'];
  final List<String> friendsTrails = ['friend trail', '3', '4', '5'];

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
                child: Trails(trails: browsing ? friendsTrails : myTrails),
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
        onPressed: null,
        style: TextButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        label: const Text('Filter', style: TextStyle(color: Colors.white, fontSize: 15)),
        icon: SvgPicture.asset('assets/images/img_filter.svg'),
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
  final List<String> trails;

  const Trails({Key? key, required this.trails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: trails.length,
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
                  trails[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
