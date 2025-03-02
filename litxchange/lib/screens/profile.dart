import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:LitXChange/screens/login.dart';
import 'package:LitXChange/screens/editprofile.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: ProfilePage(userId: 'placeholder_user_id'),
  ));
}

class ProfilePage extends StatefulWidget {
  final String userId; // Add userId parameter

  const ProfilePage({Key? key, required this.userId}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late FirebaseFirestore _firestore;
  late String _userId;
  String _username = "";
  String _bio = "";
  String _city = "";
  String _profilePictureUrl = "https://via.placeholder.com/150";
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _fetchUserData();
    _fetchUserEmail();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
        DocumentSnapshot userData =
        await _firestore.collection('users').doc(_userId).get();
        setState(() {
          _username = userData['userName'] ?? '';
          _bio = userData['bio'] ?? '';
          _city = userData['city'] ?? '';
          _profilePictureUrl =
              userData['profilePictureUrl'] ?? "https://via.placeholder.com/150";
        });
      }
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Color(0xFF457a8b)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    currentUsername: _username,
                    currentBio: _bio,
                    currentCity: _city,
                    profilePictureUrl: _profilePictureUrl,
                    userEmail: _userEmail, // Pass user email to EditProfilePage
                  ),
                ),
              );
              // Fetch updated user data after returning from edit profile page
              _fetchUserData();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFF457a8b)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Logout"),
                    content: Text("Are you sure you want Logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFF457a8b)), // Change highlight color
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Color(0xFF457a8b)),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFF457a8b)), // Change highlight color
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(color: Color(0xFF457a8b)),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_profilePictureUrl),
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(width: 20),
                  Text(
                    _username,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _bio,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _city,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 20),
            Divider( color: Color(0xFF457a8b)), // Add a divider to separate profile info from posts
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
            SizedBox(height: 10),
            _buildUserPostsList(),
          ],
        ),
      ),
    );
  }

  Future<int> getPostCount() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: _userId)
          .get();
      return snapshot.size;
    } catch (error) {
      print("Error fetching post count: $error");
      return 0; // Return 0 if there's an error
    }
  }

  Widget _buildUserPostsList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: _userId) // Filter posts by current user's ID
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Color(0xFF457a8b)),
            ),
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
            child: Text('No posts available'),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            var date = post['date'].toDate();
            var formattedDate = DateFormat.yMMMMd().format(date);
            String authorName = post['authorName'] ?? 'Unknown Author';
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
                            icon: Icon(Icons.delete,
                                color: Color(0xFF457a8b)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Delete Post"),
                                    content: Text(
                                        "Are you sure you want to delete this post?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Close the dialog
                                        },
                                        style: ButtonStyle(
                                          foregroundColor: MaterialStateProperty
                                              .all<Color>(
                                              Color(0xFF457a8b)), // Change highlight color
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                              color: Color(0xFF457a8b)),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Delete the post from Firestore
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .doc(post.id) // Use the document's ID
                                              .delete();
                                          Navigator.pop(
                                              context); // Close the dialog
                                        },
                                        style: ButtonStyle(
                                          foregroundColor: MaterialStateProperty
                                              .all<Color>(
                                              Color(0xFF457a8b)), // Change highlight color
                                        ),
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                              color: Color(0xFF457a8b)),
                                        ),
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
