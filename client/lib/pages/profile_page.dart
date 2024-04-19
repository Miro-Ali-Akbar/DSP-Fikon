import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const double? dropDownWidth = 500;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isExpanded = false;
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
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'image here:',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 30.0,
                    ),
                  ),
                  //Container(
                  //decoration: BoxDecoration(
                  //image: DecorationImage(
                  //image: AssetImage("image/null"),
                  //),
                  //),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text("Username",
                          style: Theme.of(context).textTheme.bodyLarge),
                      Text("Level 1",
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
            // Dropdown video
            // https://www.youtube.com/watch?v=giV9AbM2gd8
            DropdownMenu(
              width: ProfilePage.dropDownWidth,
              enableFilter: true,
              label: Text("Friends"),
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
            Container(
              width: ProfilePage.dropDownWidth,
              padding: EdgeInsets.all(5.0),
              child: OutlinedButton(
                child: Row(
                  children: [
                    Text('Friends',
                        style: Theme.of(context).textTheme.bodyLarge),
                    Spacer(),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
            ),
            if (isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    title: Text('Button 3'),
                    onTap: () {
                      // Do something when Button 3 is pressed
                    },
                  ),
                  ListTile(
                    title: Text('Button 4'),
                    onTap: () {
                      // Do something when Button 4 is pressed
                    },
                  ),
                  // Add more buttons as needed
                ],
              ),
            Text("data"),
            // add firebase api
            // const SignOutButton(),
          ],
        ),
      ),
    );
  }
}
