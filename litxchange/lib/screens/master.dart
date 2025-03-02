import 'package:flutter/material.dart';
import 'add.dart';
import 'home.dart';
import 'profile.dart';
import 'search.dart';
import 'notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  final String userId;
  final int idx;
  const Home({Key? key, required this.userId, required this.idx}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  late String _profilePictureUrl = "";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(),
      SearchPage(),
      AddPage(),
      NotificationsPage(),
      ProfilePage(userId: widget.userId),
    ];

    // Check if an index is passed and set the selected index accordingly
    if (widget.idx != null && widget.idx >= 0 && widget.idx < _widgetOptions.length) {
      _selectedIndex = widget.idx;
    }

    _fetchProfilePictureUrl();
  }

  Future<void> _fetchProfilePictureUrl() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        DocumentSnapshot userData = await _firestore.collection('users').doc(userId).get();
        setState(() {
          _profilePictureUrl = userData['profilePictureUrl'] ?? "https://via.placeholder.com/150";
        });
      }
    } catch (error) {
      print("Error fetching profile picture URL: $error");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: <Widget>[
                  Icon(Icons.notifications),

                ],
              ),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: _profilePictureUrl.isNotEmpty
                  ? CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(_profilePictureUrl),
              )
                  : Icon(Icons.person), // Fallback to default icon if profile picture URL is empty
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF457a8b),
          unselectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
