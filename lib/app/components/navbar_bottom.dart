import 'package:althea/app/dashboard/dashboard.dart';
import 'package:althea/app/homepage.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return const BottomNavBar();
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);


  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndexPage = 1;

  Widget getPage(int index){
    switch(index){
      case 0:
        return const Homepage();
      case 1:
        return Dashboard();
        // return FormAbsen(user : user);
      default:
        return Dashboard();
        // return Profile(user : user);
    }
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndexPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 164, 255),
      body: getPage(_selectedIndexPage),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            activeIcon: Icon(Icons.view_list_outlined),
            label : "Petunjuk",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label : "Dashboard"
          ),
        ],
        currentIndex: _selectedIndexPage,
        onTap: _onItemTap,
        ),
    );
  }
}
