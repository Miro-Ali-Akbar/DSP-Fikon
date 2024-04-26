import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/back_button.dart'; 

class IndividualTrailPage extends StatefulWidget{

  @override
  State<IndividualTrailPage> createState() => _IndividualTrailPageState();
}

class _IndividualTrailPageState extends State<IndividualTrailPage> {

  bool saved = false; 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: Column( 
          children: [
            Row(
              children: [
                GoBackButton(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('Insert name of trail here', 
                    style: TextStyle(fontSize: 20)),
                ),
              ],
            ), 
            Expanded(
              child: Center(
                child: GoogleMap(
              //onMapCreated: (GoogleMapController controller) {
              //  _controller.complete(controller);
              //},
              zoomControlsEnabled: false,
              //myLocationEnabled: visiblePlayer,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(59.83972677529924, 17.6465716818546),
                  zoom: 15),
                ),
              ),
            ),
            TrailInfo(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SaveTrail(),
            ),
          ]
        )  
      ),
    );
  }
}

class SaveTrail extends StatefulWidget {
  const SaveTrail({Key? key}) : super(key: key);

  @override
  State<SaveTrail> createState() => _SaveTrailState();
}

class _SaveTrailState extends State<SaveTrail> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      
      onPressed: null,
      style: TextButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: const Text('Save Trail +', style: TextStyle(color: Colors.white, fontSize: 30)),
    );
  }
}
class TrailInfo extends StatefulWidget {
  TrailInfo({super.key});

  @override 
  State<TrailInfo> createState() => _TrailInfoState(); 
}

class _TrailInfoState extends State<TrailInfo> {

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
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/img_walking.svg', 
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    height: 35,
                    width: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('XX km', style: TextStyle(fontSize: 15),),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/img_clock.svg', 
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    height: 35,
                    width: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('XX min', style: TextStyle(fontSize: 15),),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/img_trees.svg', 
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    height: 35,
                    width: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Nature', style: TextStyle(fontSize: 15),),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/img_stairs.svg', 
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    height: 35,
                    width: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Stairs', style: TextStyle(fontSize: 15),),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/img_arrow_up.svg', 
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    height: 35,
                    width: 50,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('Height difference', style: TextStyle(fontSize: 15),),
                ),
              ],
            ),
          ),
        ],
      ), 
    ); 
  }
}

