import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // Search Bar
            SearchBar(),
            // Recently Visited Section
            RecentlyVisitedSection(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: Colors.red,
      child: const Icon(
        Icons.add,
        color: Colors.white,
        size: 40,
      ),
      shape: const CircleBorder(),
      elevation: 6,
    );
  }
}

/// SearchBar Widget
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Xử lý sự kiện nhấn nút kính lúp
              print("Search button clicked!");
            },
          ),
          hintText: 'Tasks, projects, and more',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}

/// RecentlyVisitedSection Widget
class RecentlyVisitedSection extends StatelessWidget {
  const RecentlyVisitedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recently visited',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          // Grouped items with rounded corners
          buildSectionGroup([
            buildButtonItem(Icons.filter_alt_outlined, 'Filters & Labels'),
            buildDividerWithPadding(),
            buildButtonItem(Icons.calendar_today, 'Upcoming'),
            buildDividerWithPadding(),
            buildButtonItem(Icons.today, 'Today'),
            buildDividerWithPadding(),
            buildButtonItem(Icons.home, 'Home', emoji: '🏡'),
            buildDividerWithPadding(),
            buildButtonItem(Icons.tag, 'Testproject', isTeam: true),
            buildDividerWithPadding(),
            buildButtonItem(Icons.notifications, 'Notifications'),
          ]),
        ],
      ),
    );
  }

  Widget buildButtonItem(IconData icon, String title,
      {String? emoji, bool isTeam = false}) {
    return TextButton(
      onPressed: () {
        // Handle button tap
        print('Tapped on $title');
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(0),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Row(
          children: [
            Text(title),
            if (emoji != null) Text(' $emoji'),
            if (isTeam)
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(Icons.people, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildDividerWithPadding() {
    return Row(
      children: [
        const SizedBox(width: 55), // Indentation for divider
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget buildSectionGroup(List<Widget> sectionWidgets) {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: sectionWidgets,
      ),
    );
  }
}
