import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/viewrequest.dart';
import 'dart:ui';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Notifications'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF457a8b)),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications yet'));
          } else {
            return FutureBuilder<List<Widget>>(
              future: _buildListTiles(snapshot.data!, context),
              builder: (context, listSnapshot) {
                if (listSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF457a8b)),
                  ));
                } else if (listSnapshot.hasError) {
                  return Center(child: Text('Error: ${listSnapshot.error}'));
                } else {
                  return ListView(children: listSnapshot.data!);
                }
              },
            );
          }
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchNotifications() async {
    try {
      List<String> userPostIds = await _fetchUserPostIds();
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('postId', whereIn: userPostIds)
          .get();
      return snapshot.docs;
    } catch (error) {
      print("Error fetching notifications: $error");
      return [];
    }
  }

  Future<List<String>> _fetchUserPostIds() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();
      List<String> postIds = [];
      for (DocumentSnapshot post in postsSnapshot.docs) {
        postIds.add(post['postId']);
      }
      return postIds;
    } catch (error) {
      print("Error fetching user post IDs: $error");
      return [];
    }
  }

  Future<String> _fetchUsername(String userId) async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userData['userName'] ?? 'Unknown User';
    } catch (error) {
      print("Error fetching username: $error");
      return 'Unknown User';
    }
  }

  Future<String> _fetchCity(String userId) async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userData['city'] ?? 'Unknown City';
    } catch (error) {
      print("Error fetching city: $error");
      return 'Unknown City';
    }
  }

  Future<String> _fetchBookName(String postId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot postDoc = querySnapshot.docs.first;
        if (postDoc.exists && postDoc.data() != null) {
          String bookName = postDoc['bookName'];
          return bookName ?? 'Unknown Book';
        } else {
          print('Document does not have bookName field');
          return 'Unknown Book';
        }
      } else {
        print('No document found with postId: $postId');
        return 'Unknown Book';
      }
    } catch (error) {
      print("Error fetching book name: $error");
      return 'Unknown Book';
    }
  }

  Future<List<Widget>> _buildListTiles(List<DocumentSnapshot> documents, BuildContext context) async {
    List<Widget> listTiles = [];
    for (var document in documents) {
      try {
        String bookName = await _fetchBookName(document['postId']);
        String userName = await _fetchUsername(document['userId']);
        String city =await _fetchCity(document['userId']);
        listTiles.add(
          ListTile(
            title: Text('$userName from $city sent Swap Request'),
            subtitle: Text('for $bookName'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewProfilePage(userId: document['userId'], notificationId: document['notificationId'],bookName: bookName,postId:document['postId']),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF457a8b),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
              ),
              child: Text(
                'View',
                style: TextStyle(fontSize: 16),
              ),

            ),
          ),
        );
      } catch (error) {
        print("Error building list tile: $error");
      }
    }
    return listTiles;
  }
}
