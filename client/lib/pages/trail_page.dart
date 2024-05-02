import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trailquest/pages/generate_trail_page.dart';
import 'package:trailquest/my_trail_list.dart';
import 'package:trailquest/widgets/trail_cards.dart';

bool browsing = false;

// Filters: 
// 0 = noStairs, 1 = onlyNature, 2 = circularRoutes, 3 = maxDistance, 4 = minDistance
List filters = [false, false, false, double.infinity, 0];

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
                  FilterButton(rebuildTrailPage: rebuildTrailPage),
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

  void rebuildTrailPage() {
    setState(() {}); // Triggers a rebuild of the entire widget tree
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
  final Function rebuildTrailPage; 

  const FilterButton({Key? key, required this.rebuildTrailPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextButton.icon(
        onPressed: () => showDialog(context: context, builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              child: FilterPopUp(rebuildTrailPage: rebuildTrailPage), 
              width: double.maxFinite, 
            ),
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
  List<TrailCard> savedTrails;
  List<TrailCard> friendTrails; 
  
  Trails({Key? key, required this.savedTrails, required this.friendTrails}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<TrailCard> allTrails = new List.from(savedTrails)..addAll(friendTrails); 
    
    // get either all saved trails or all friend trails, depending on the tab
    List<TrailCard> filteredTrails = browsing ? 
      friendTrails : 
      allTrails.where((trail) {
        return trail.isSaved; 
      }).toList();

    // filter trails according to the filters selected 
    filteredTrails = filterTrails(filteredTrails);

    return ListView.separated(
      padding: const EdgeInsets.all(10),
      itemCount: filteredTrails.length,
      itemBuilder: (BuildContext context, int index) {
        return filteredTrails[index]; 
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  List<TrailCard> filterTrails(List<TrailCard> list) {
    List<TrailCard> newList = list; 

    // Filter no stairs
    if (filters[0]) {
      newList = newList.where((trail) {
        return !trail.stairs; 
      }).toList();
    }

    // Filter only nature
    if (filters[1]) {
      newList = newList.where((trail) {
        return trail.natureStatus == "Nature"; 
      }).toList();
    }

    // Filter only circular routes
    if (filters[2]) {
      newList = newList.where((trail) {
        return trail.isCircular; 
      }).toList();
    }

    // Filter max distance
    newList = newList.where((trail) {
      return trail.lengthDistance <= filters[3]; 
    }).toList();

    // Filter min distance
    newList = newList.where((trail) {
      return trail.lengthDistance >= filters[4]; 
    }).toList();

    return newList; 
  }
}

class FilterPopUp extends StatefulWidget {
  final Function rebuildTrailPage; 

   const FilterPopUp({Key? key, required this.rebuildTrailPage}) : super(key: key);

  @override 
  State<FilterPopUp> createState() => _FilterPopUpState();
}

class _FilterPopUpState extends State<FilterPopUp> {

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                onChanged: (newValue) {
                  setState(() {
                    filters[0] = newValue ?? false;
                  });
                }, 
                value: filters[0]
              ),
              Flexible(
                child: Text('Exclude routes which could contain stairs'),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                onChanged: (newValue) {
                  setState(() {
                    filters[1] = newValue ?? false;
                  });
                }, 
                value: filters[1]
              ),
              Flexible(
                child: Text('Only include routes with a lot of nature'),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                onChanged: (newValue) {
                  setState(() {
                    filters[2] = newValue ?? false;
                  });
                }, 
                value: filters[2]
              ),
              Flexible(
                child: Text('Only include routes with the same start- and endpoint'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Max distance: '),
              Container(
                width: 80, // Specify the desired width
                height: 40, // Specify the desired height
                child: TextField(
                  
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onSubmitted: (value) {
                    setState(() {
                      filters[3] = double.parse(value);
                    });
                  },
                ),
              ),
              Text('meters'),
            ], // Only numbers can be entered
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Min distance: '),
              Container(
                width: 80,
                height: 40,
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (value) {
                    setState(() {
                      filters[4] = double.parse(value);
                    });
                  },
                ),
              ),
              Text('meters'),
            ], // Only numbers can be entered
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    widget.rebuildTrailPage(); 
                    Navigator.pop(context); 
                  }, 
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    side: BorderSide(color: Colors.black),
                  ),
                  child: Text("Apply", style: TextStyle(color: Colors.black),),
                ),
                TextButton(
                  onPressed: () {
                    filters = [false, false, false, double.infinity, 0];
                    rebuildFilter(); 
                    widget.rebuildTrailPage();
                  }, 
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    side: BorderSide(color: Colors.black),
                  ),
                  child: Text("Clear", style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void rebuildFilter() {
    setState(() {}); 
  }
}
