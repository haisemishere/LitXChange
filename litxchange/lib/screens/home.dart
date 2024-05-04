import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:litxchange/screens/master.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo.png', // Path to your logo image
          height: 120, // Adjust height as needed
          width: 200, // Adjust width as needed
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isNotEqualTo: currentUserUid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final posts = snapshot.data!.docs;
          return ListView.builder(// Set the background color
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              var date = post['date'].toDate();
              String bookCondition = post['condition'] ?? 'Unknown Condition';
              var formattedDate = DateFormat.yMMMMd().format(date);
              return FutureBuilder(
                future: _fetchUsername(post['userId']),
                builder: (context, AsyncSnapshot<String> usernameSnapshot) {
                  if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (usernameSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${usernameSnapshot.error}'),
                    );
                  } else {
                    String username = usernameSnapshot.data ?? 'Unknown User';
                    String authorName = post['authorName'] ?? 'Unknown Author';

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                formattedDate,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                '${post['bookName']} by $authorName',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Condition: $bookCondition'),
                                  Text(post['genre']),
                                ],
                              ),
                            ),
                            post['imageUrl'] != null
                                ? Image.network(
                              post['imageUrl'],
                              fit: BoxFit.cover,
                            )
                                : SizedBox.shrink(),
                            SizedBox(height: 16.0),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    username,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  FutureBuilder(
                                    future: _isSwap(post['postId']),
                                    builder: (context, AsyncSnapshot<bool> snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Offstage();
                                      }
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      if (!snapshot.data!) {
                                        return IconButton(
                                          icon: Icon(Icons.swap_horiz,
                                              color: Color(0xFF457a8b)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Swap Request'),
                                                content: Text('Are you sure you want to send a swap request?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Cancel",
                                                      style: TextStyle(color: Color(0xFF457a8b)),),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      sendReq(context, post['postId']);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => Home(userId: (FirebaseAuth.instance.currentUser)!.uid, idx: 0,),
                                                        ),
                                                      );
                                                    },
                                                    child: Text('Send',
                                                      style: TextStyle(color: Color(0xFF457a8b)),),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }
                                      return Offstage();
                                    },
                                  ),
                                ],

                              ),
                            ),
                            SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _isSwap(String postId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('postId', isEqualTo: postId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }
      else
      {
        return false;
      }
    } catch (error) {
      print("Error fetching username: $error");
      return false;
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

  void sendReq(BuildContext context,
      String postId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String notificationId =
          FirebaseFirestore.instance.collection('notifications').doc().id;
      // Generate unique ID for notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'postId': postId,
        'notificationId': notificationId,
        'timestamp': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request sent successfully'),
        ),
      );
    } catch (error) {
      print('Error saving notification: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to send request'),
        ),
      );
    }
  }
}
