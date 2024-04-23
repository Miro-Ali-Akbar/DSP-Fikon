import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const double? dropDownWidth = 500;
  static const edgeValue = 20.0;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: Colors.black,
            fontSize: 30.0,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileRow(),
            Friendlist(),
            DropdownTile(
              "Statistics",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      'Statistics 1',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Do something when Button
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Dosent have to be buttons',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            DropdownTile(
              "Preferences",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      'Button 1',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Do something when Button
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Button 2',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Do something when Button
                    },
                  ),
                  // Add more buttons as needed
                ],
              ),
            ),
            // TODO: add firebase api
            // const SignOutButton(),
          ],
        ),
      ),
    );
  }

  Row ProfileRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: //Container(
              CircleAvatar(
            radius: 48, // Image radius
            backgroundImage: AssetImage('assets/images/img_profile.svg'),
            // foregroundImage: , // TODO: Here is the actual profile picture
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text("Username", style: Theme.of(context).textTheme.bodyLarge),
              Text("Level 1", style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Container Friendlist() {
    // Check with others - I give up
    // Dropdown video
    // https://www.youtube.com/watch?v=giV9AbM2gd8
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(ProfilePage.edgeValue),
      height: 60.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(ProfilePage.edgeValue),
        ),
        color: Colors.green,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Row(
          children: [
            DropdownMenu(
              enableSearch: true,
              enableFilter: true,
              label:
                  Text("Friends", style: Theme.of(context).textTheme.bodyLarge),
              dropdownMenuEntries: <DropdownMenuEntry>[
                DropdownMenuEntry(value: 1, label: 'James'),
                DropdownMenuEntry(value: 2, label: 'Gordon'),
                DropdownMenuEntry(value: 3, label: 'Daisy'),
                DropdownMenuEntry(value: 4, label: 'Eve'),
                DropdownMenuEntry(value: 5, label: 'Molly'),
              ],
              onSelected: (friend) {
                // Do something when you click on a friend eg take them to friend page?
              },
            ),
            Spacer(),
            Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
    );
  }

  Container DropdownTile(String Name, Column Buttons) {
    // https://api.flutter.dev/flutter/material/ExpansionTile-class.html
    return Container(
      margin: EdgeInsets.all(ProfilePage.edgeValue),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(ProfilePage.edgeValue),
        ),
        color: Colors.green,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            Name,
            style: TextStyle(color: Colors.white),
          ),
          children: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(ProfilePage.edgeValue),
                      bottomRight: Radius.circular(ProfilePage.edgeValue),
                    ),
                  ),
                  // alignment: Alignment.center,
                  child: Buttons,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
