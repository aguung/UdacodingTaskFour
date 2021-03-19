import 'package:app_task/ui/favorite/favorite_view.dart';
import 'package:app_task/ui/home/home_view.dart';
import 'package:app_task/ui/profile/profile_view.dart';
import 'package:app_task/ui/receipt/receipt_view.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  MainView({Key key}) : super(key: key);

  @override
  MainViewState createState() => MainViewState();
}

class MainViewState extends State<MainView> {
  int selectedIndex = 0;
  final widgetOptions = [
    HomeView(),
    FavoriteView(),
    ReceiptView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt), label: 'My Receipt'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        fixedColor: Colors.deepPurple,
        onTap: onItemTapped,
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}
