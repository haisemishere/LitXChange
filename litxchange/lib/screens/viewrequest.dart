import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '/screens/notifications.dart';

class ViewProfilePage extends StatefulWidget {
  final String userId;
  final String notificationId;

  const ViewProfilePage({required this.userId, required this.notificationId});

  @override
  _ViewProfilePageState createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  late Stream<QuerySnapshot> _userPostsStream;

  @override
  void initState() {
    super.initState();
    _userPostsStream = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: widget.userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Profile'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Reject Request"),
                    content: Text(
                        "Are you sure you want to reject this request?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                              context); // Close the dialog
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            print(widget.notificationId);
                            QuerySnapshot notificationsSnapshot = await FirebaseFirestore.instance
                                .collection('notifications')
                                .where('notificationId', isEqualTo: widget.notificationId)
                                .get();

                            for (DocumentSnapshot doc in notificationsSnapshot.docs) {
                              await doc.reference.delete();
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationsPage(),
                              ),
                            );
                          } catch (error) {
                            print("Error deleting notification: $error");
                            // Handle error if needed
                          }
                        },

                        child: Text("Reject"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Reject'),
          ),
          Expanded(
            child: _buildUserPosts(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPosts() {
    return StreamBuilder(
      stream: _userPostsStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final posts = snapshot.data!.docs;
        if (posts.isEmpty) {
          return Center(
            child: Text('No posts found for this user.'),
          );
        }
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            var date = post['date'].toDate();
            var formattedDate = DateFormat.yMMMMd().format(date);
            String bookCondition =
                post['condition'] ?? 'Unknown Condition';
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
                    ),
                    ListTile(
                      title: Text(
                        '${post['bookName']} by ${post['authorName']}',
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
                    SizedBox(height: 8.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check_circle), // Use the check_box_outline_blank icon
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Accept Swap Request"),
                                    content: Text(
                                        "Are you sure you want to select this book for swapping?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Close the dialog
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(
                                              context); // Close the dialog
                                        },
                                        child: Text("Swap"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
