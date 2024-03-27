import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/viewrequest.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications yet'));
          } else {
            return ListView(
              children: snapshot.data!.map((document) {
                return FutureBuilder<String>(
                  future: _fetchBookName(document['postId']),
                  builder: (context, bookSnapshot) {
                    if (bookSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: Text('Notification for post: ${document['postId']}'),
                        subtitle: Text('Fetching book name...'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewProfilePage(userId: document['userId'], notificationId: document['notificationId']),
                              ),
                            );
                          },
                          child: Text('View'),
                        ),
                      );
                    } else if (bookSnapshot.hasError) {
                      return ListTile(
                        title: Text('Notification for post: ${document['postId']}'),
                        subtitle: Text('Error fetching book name: ${bookSnapshot.error}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewProfilePage(userId: document['userId'], notificationId: document['notificationId']),
                              ),
                            );
                          },
                          child: Text('View'),
                        ),
                      );
                    } else {
                      return ListTile(
                        title: Text('Notification for book: ${bookSnapshot.data}'),
                        subtitle: FutureBuilder<String>(
                          future: _fetchUsername(document['userId']),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return Text('User ID: ${document['userId']}');
                            } else if (userSnapshot.hasError) {
                              return Text('Error: ${userSnapshot.error}');
                            } else {
                              return Text('Username: ${userSnapshot.data}');
                            }
                          },
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewProfilePage(userId: document['userId'], notificationId: document['notificationId']),
                              ),
                            );
                          },
                          child: Text('View'),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchNotifications() async {
    try {
      List<String> userPostIds = await _fetchUserPostIds(); // Fetch user's post IDs
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('postId', whereIn: userPostIds) // Filter notifications for user's posts
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

}
