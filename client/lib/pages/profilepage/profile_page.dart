import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  User user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
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
                profileRow(snapshot.data?.displayName),
                friendButton(),
                statisticsDropdown(),
                preferencesDropdown(),
                signOutButton(),

                /// TODO: only for debugging remove when everything is done
                ElevatedButton(
                  onPressed: () {
                    print(FirebaseAuth.instance.currentUser);
                    print(FirebaseAuth.instance.currentUser!.displayName);
                    user.reload();
                  },
                  // tooltip: 'Increment',
                  child: const Text("print user in debug"),
                ),
                deleteUserAccount(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Displays the firendbutton
  ///
  /// Return the friendbutton
  GestureDetector friendButton() => ContainerButton((), "Friends");

  /// Displays the statistics dropdown menu
  ///
  /// Returns the dropdown menu
  Container statisticsDropdown() {
    return DropdownTile(
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
    );
  }

  /// Displays the preferences dropdown menu
  ///
  /// Returns the dropdown menu
  Container preferencesDropdown() {
    return DropdownTile(
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
    );
  }

  /// Displays the signOut button
  ///
  /// Loggs out the current user
  GestureDetector signOutButton() => ContainerButton(
      () => {
            FirebaseAuth.instance.signOut(),
            GoogleSignIn().signOut(), // To be able to swithch google accounts
          },
      "Signout");

  /// Displays the delete account button
  ///
  /// Deletes the user account on pressing
  ElevatedButton deleteUserAccount() {
    return ElevatedButton(
      // TODO: Add confirmation button
      onPressed: () async {
        // TODO: Add reauthentication to make sure the user can actually delete their account
        // String webClientID = FlutterConfig.get('WEB_CLIENT_ID');
        // await user
        //     .reauthenticateWithProvider(GoogleProvider(clientId: webClientID));
        FirebaseAuth.instance.currentUser!.delete();
      },
      child: Text(
        "Remove account",
        style: TextStyle(color: Colors.red),
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
  Row profileRow(String? name) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: //Container(
              CircleAvatar(
            radius: 48, // Image radius
            backgroundImage: AssetImage('assets/images/default_profilepicture.png'),
            foregroundImage: NetworkImage(user
                .photoURL!), // Display user's profile picture if user is not null
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(children: [
            Text(
                (name == null)
                    ? ""
                    : name, // Needs nullchecker incase a new name is selected to prevent it being null and causing a red screen for one millisec
                style: Theme.of(context).textTheme.bodyLarge),
            Text("Level 1", style: Theme.of(context).textTheme.bodyLarge),
          ]),
        ),
      ],
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
