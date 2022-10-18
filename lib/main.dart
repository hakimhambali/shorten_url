import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shorten_url/screens/home_body.dart';
import 'screens/history.dart';
import 'screens/feedback.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int myIndex = 0;
  List<Widget> widgetList = [
    const HomeBody(),
    const History(),
    const Improvement(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widgetList[myIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
              backgroundColor: Colors.black,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade800,
              gap: 8,
              onTabChange: (index) {
                setState(() {
                  myIndex = index;
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: ((context) => widgetList[myIndex])));
                });
              },
              padding: const EdgeInsets.all(16),
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.history,
                  text: 'History',
                ),
                GButton(
                  icon: Icons.feedback,
                  text: 'Feedback',
                ),
              ]),
        ),
      ),
    );
  }
}
