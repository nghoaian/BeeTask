import 'package:bee_task/screen/home_screen.dart';
import 'package:bee_task/screen/setting_screen.dart'; // Giả sử bạn có màn SettingScreen
import 'package:flutter/material.dart';

class NavUIScreen extends StatefulWidget {
  @override
  _NavUIScreen createState() => _NavUIScreen();
}

class _NavUIScreen extends State<NavUIScreen> {
  int _selectedIndex = 0;
  bool _showAppBar = true;

  // Chỉ bao gồm HomeScreen và SettingScreen
  late final List<Widget> _widgetOptions = <Widget>[
    // HomeScreen(
    //   onTabTapped: _onItemTapped,
    // ),
    HomeScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showAppBar = (index == 0); // Chỉ hiển thị AppBar khi chọn Home tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              title: Text('App Bar'),
            )
          : null, // AppBar sẽ không hiển thị khi chọn Setting
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF4254FE),
          ),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                backgroundColor: Color(0xFF4254FE),
                label: 'Trang Chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                backgroundColor: Color(0xFF4254FE),
                label: 'Cài Đặt',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color.fromARGB(255, 255, 255, 255),
            unselectedItemColor: Colors.white,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
