import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/back_button.dart';
// import 'generated_map_page.dart';
import 'package:trailquest/pages/challenges/challenge_template.dart';


class GenerateTrail extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column( 
          children: [
            Row(
              children: [
                GoBackButton().build(context),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [PageCenter()]
                )
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: CreateNewTrail(),
            ), 
          ],
        )  
      ),
    );
  }
}

class CreateNewTrail extends StatelessWidget {
  const CreateNewTrail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const GeneratedMap()),
          );
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

class PageCenter extends StatefulWidget {
  PageCenter({super.key});

  @override 
  State<PageCenter> createState() => _PageCenterState(); 
}

class _PageCenterState extends State<PageCenter> {

  bool checkedvalue = false; 

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('What activity do you want to do?', style: TextStyle(fontSize: 15)),
          ), 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ActivityOptions(),
          ), 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('How long do you want the trail to be?', style: TextStyle(fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              child: InputField(),
              width: 300,
              height: 70,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Do you want the end point to be the same as the start point?', 
              style: TextStyle(fontSize: 15), 
              textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TrailType(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Do you want to start from your current position?', 
              style: TextStyle(fontSize: 15), 
              textAlign: TextAlign.center,),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: StartPointOptions(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text('What kind of enviornment do you want?', style: TextStyle(fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: EnviornmentOptions(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Checkbox(
                  value: checkedvalue,
                  onChanged: (newValue) {
                    setState(() {
                      checkedvalue = newValue ?? false;
                    });
                  },
                ),
                Text('Avoid staircases'),
              ],
            ),
          ),
        ],
      ), 
    ); 
  }
}

const List<String> Activities = <String>[
  'Walking', 'Running', 'Cycling'
];

final List<bool> _selectedStatusActivities = <bool>[false, false, false];

class ActivityOptions extends StatefulWidget {
  ActivityOptions({super.key});

  @override 
  State<ActivityOptions> createState() => _ActivityOptionsState(); 
}

class _ActivityOptionsState extends State<ActivityOptions> {

  @override
  Widget build(context) {
    return ToggleButtons(
      renderBorder: false,
      fillColor: Colors.white, 
      direction: Axis.horizontal,
      isSelected: _selectedStatusActivities,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedStatusActivities.length; i++) {
            _selectedStatusActivities[i] = i == index;
          }
        });
      },
      children: List<Widget>.generate(
        3, (index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(), 
              borderRadius: BorderRadius.all(Radius.circular(10)), 
              color: _selectedStatusActivities[index] ? Colors.black : Colors.white
              ),
            padding: const EdgeInsets.all(5), 
            width: 90,
            height: 30,
            alignment: Alignment.center, 
            child: Text(
              Activities[index], 
              style: TextStyle(
                color: _selectedStatusActivities[index] ? Colors.white : Colors.black))
          )
        )
      ),      
    );
  } 
}

const List<String> TrailTypes = <String>[
  'assets/images/img_circular_arrow.svg', 'assets/images/img_route.svg'
];

final List<bool> _selectedStatusTrailTypes = <bool>[false, false];

class TrailType extends StatefulWidget {
  TrailType({super.key});

  @override 
  State<TrailType> createState() => _TrailTypeState(); 
}

class _TrailTypeState extends State<TrailType> {

  @override
  Widget build(context) {
    return ToggleButtons(
      renderBorder: false,
      fillColor: Colors.white, 
      direction: Axis.horizontal,
      isSelected: _selectedStatusTrailTypes,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedStatusTrailTypes.length; i++) {
            _selectedStatusTrailTypes[i] = i == index;
          }
        });
      },
      children: List<Widget>.generate(
        2, (index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(), 
              borderRadius: BorderRadius.all(Radius.circular(10)), 
              color: _selectedStatusTrailTypes[index] ? Colors.black : Colors.white
              ),
            padding: const EdgeInsets.all(5), 
            width: 160,
            height: 70,
            alignment: Alignment.center, 
            child: Column(
              children: [
                SvgPicture.asset(
                  TrailTypes[index], 
                  colorFilter: _selectedStatusTrailTypes[index] ?
                    ColorFilter.mode(Colors.white, BlendMode.srcIn) :
                    ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  height: 35,
                  width: 35,
                ),
                Text(
                  index == 0 ? 'Yes' : 'No', 
                  style: TextStyle(
                    color: _selectedStatusTrailTypes[index] ? Colors.white : Colors.black))
              ],
            ),
          )
        )
      ),      
    );
  } 
}

final List<bool> _selectedStatusStartPoint = <bool>[false, false];

class StartPointOptions extends StatefulWidget {
  StartPointOptions({super.key});

  @override 
  State<StartPointOptions> createState() => _StartPointOptionsState(); 
}

class _StartPointOptionsState extends State<StartPointOptions> {

  @override
  Widget build(context) {
    return ToggleButtons(
      renderBorder: false,
      fillColor: Colors.white, 
      direction: Axis.horizontal,
      isSelected: _selectedStatusStartPoint,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedStatusStartPoint.length; i++) {
            _selectedStatusStartPoint[i] = i == index;
          }
        });
        if (_selectedStatusStartPoint[1]) {
          //TODO: When this button is pressed a map should open to allow the user to choose a starting point. 
          // Uncomment the following code and add the destination after the arrow. The code is tested and should work :)
          //Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
          //  pageBuilder: (context, x, xx) => ,
          //  transitionDuration: Duration.zero,
          //  reverseTransitionDuration: Duration.zero,
          //));
        }
      },
      children: List<Widget>.generate(
        2, (index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(), 
              borderRadius: BorderRadius.all(Radius.circular(10)), 
              color: _selectedStatusStartPoint[index] ? Colors.black : Colors.white
              ),
            padding: const EdgeInsets.all(5), 
            width: 160,
            height: 30,
            alignment: Alignment.center, 
            child: Text(
              index == 0 ? 'Yes' : 'No (choose from map)',
              style: TextStyle(
                color: _selectedStatusStartPoint[index] ? Colors.white : Colors.black))
          )
        )
      ),      
    );
  } 
}

const List<String> EnviornmentIcons = <String>[
  'assets/images/img_trees.svg',
  'assets/images/img_city.svg',
  'assets/images/img_park.svg',
];

const List<String> Enviornments = <String>[
  'Nature', 'City', 'Both'
];

final List<bool> _selectedStatusEnviornment = <bool>[false, false, false];

class EnviornmentOptions extends StatefulWidget {
  EnviornmentOptions({super.key});

  @override 
  State<EnviornmentOptions> createState() => _EnvironmentOptionsState(); 
}

class _EnvironmentOptionsState extends State<EnviornmentOptions> {

  @override
  Widget build(context) {
    return ToggleButtons(
      renderBorder: false,
      fillColor: Colors.white, 
      direction: Axis.horizontal,
      isSelected: _selectedStatusEnviornment,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _selectedStatusEnviornment.length; i++) {
            _selectedStatusEnviornment[i] = i == index;
          }
        });
      },
      children: List<Widget>.generate(
        3, (index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(), 
              borderRadius: BorderRadius.all(Radius.circular(10)), 
              color: _selectedStatusEnviornment[index] ? Colors.black : Colors.white
              ),
            padding: const EdgeInsets.all(5), 
            width: 90,
            height: 70,
            alignment: Alignment.center, 
            child: Column(
              children: [
                SvgPicture.asset(
                  EnviornmentIcons[index],
                  colorFilter: _selectedStatusEnviornment[index] ?
                    ColorFilter.mode(Colors.white, BlendMode.srcIn) :
                    ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  height: 35,
                  width: 35,
                ),
                Text(
                  Enviornments[index],
                  style: TextStyle(
                    color: _selectedStatusEnviornment[index] ? Colors.white : Colors.black
                  ), 
                ),
              ],
            ),
          )
        )
      ),      
    );
  } 
}

class InputField extends StatefulWidget {
  InputField({super.key}); 

  @override 
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
         ),),
         UnitToggleButton(),
       ], // Only numbers can be entered
    );
  }
}

class UnitToggleButton extends StatefulWidget {
  UnitToggleButton({super.key}); 
  
  @override
  _UnitToggleButtonState createState() => _UnitToggleButtonState();
}

class _UnitToggleButtonState extends State<UnitToggleButton> {
  bool isMeters = true;

  void toggleUnit() {
    setState(() {
      isMeters = !isMeters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: toggleUnit,
      child: Text(
        isMeters ? 'Meters' : 'Minutes',
        style: TextStyle(color: Colors.black),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: Colors.black,
        )
      ),
    );
  }
}
