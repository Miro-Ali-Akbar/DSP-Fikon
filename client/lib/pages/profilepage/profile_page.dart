import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trailquest/main.dart';
import 'package:trailquest/pages/friend_page.dart';

/// The profilepage of the user
/// Note: Use authGate instead of this as it guaranties that the user is logged in.
class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});
  static const double? dropDownWidth = 500;
  static const edgeValue = 20.0;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
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
        body: ListView(
          children: [
            ProfileRow(),
            ContainerButton(Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
              pageBuilder: (context, x, xx) => Friendpage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            )), "Friends"),
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
            ContainerButton(() => FirebaseAuth.instance.signOut(), "Signout"),
            ElevatedButton(
              onPressed: () {
                print(FirebaseAuth.instance.currentUser);
              },
              // tooltip: 'Increment',
              child: const Text("print user in debug"),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a button acording to our style
  ///
  /// [selectedFunction] a nullary function that does the prefered action
  /// [string] the text displayed on the button
  ///
  /// Returns a button acording to our style
  GestureDetector ContainerButton(selectedFunction, String string) {
    return GestureDetector(
      onTap: () {
        selectedFunction();
      },
      child: Container(
        padding: EdgeInsets.all(10 + 5), // +5 for some reason
        margin: EdgeInsets.all(ProfilePage.edgeValue),
        height: 60.0,
        width: ProfilePage.dropDownWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(ProfilePage.edgeValue),
          ),
          color: Colors.green,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            string,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// The header for the ProfilePage
  ///
  /// returns a avatar image from the logged in user along with thier name and level
  Row ProfileRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: //Container(
              CircleAvatar(
            radius: 48, // Image radius
            backgroundImage: AssetImage('assets/images/img_profile.svg'),
            foregroundImage: NetworkImage(user!
                .photoURL!), // Display user's profile picture if user is not null
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Text(user!.displayName!,
                  style: Theme.of(context).textTheme.bodyLarge),
              Text("Level 1", style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  // TODO: Remove as this is legacy
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

  /// Creates a dropdownmenu acording to our style
  ///
  /// [Name] The text displayed on the original button
  /// [Buttons] The buttons that can be expanded: Is a usually a Row or Column with ListTile as buttons
  ///
  /// Returns a container that is the complete dropdownmenu
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
