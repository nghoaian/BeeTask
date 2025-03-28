import 'package:bee_task/screen/browse/browse_screen.dart';
import 'package:bee_task/screen/setting/setting_screen.dart';
import 'package:bee_task/screen/upcoming/home_screen.dart';
import 'package:bee_task/screen/search/search_screen.dart';
import 'package:bee_task/util/colors.dart';
import 'package:flutter/material.dart';

class NavUIScreen extends StatefulWidget {
  @override
  _NavUIScreen createState() => _NavUIScreen();
}

class _NavUIScreen extends State<NavUIScreen> {
  int _selectedIndex = 0;
  bool _showAppBar = true;

  late final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    BrowseScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      //_showAppBar = (index == 0); // Chỉ hiển thị AppBar khi chọn Home tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                backgroundColor: Color(0xFF4254FE),
                label: 'Upcoming',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                backgroundColor: Color(0xFF4254FE),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded),
                backgroundColor: Color(0xFF4254FE),
                label: 'Browse',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined),
                backgroundColor: Color(0xFF4254FE),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color.fromARGB(255, 255, 255, 255),
            unselectedItemColor: Colors.white,
            onTap: _onItemTapped,
            backgroundColor: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
