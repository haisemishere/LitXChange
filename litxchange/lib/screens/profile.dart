import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:litxchange/screens/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
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
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    currentUsername: _username,
                    currentBio: _bio,
                    currentCity: _city,
                    profilePictureUrl: _profilePictureUrl,
                    onUpdate: (newUsername, newBio, newCity, newProfilePictureUrl) async {
                      setState(() {
                        _username = newUsername;
                        _bio = newBio;
                        _city = newCity;
                        _profilePictureUrl = newProfilePictureUrl;
                      });
                      await _saveUserData();
                      Navigator.pop(context); // Go back to profile page after saving
                    },
                    userEmail: _userEmail, // Pass user email to EditProfilePage
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_profilePictureUrl),
                backgroundColor: Colors.transparent
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                _username,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                _bio,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                _city,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(), // Add a divider to separate profile info from posts
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

  Widget _buildUserPostsList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: _userId) // Filter posts by current user's ID
          .snapshots(),
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
                            icon: Icon(Icons.delete),
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
                                        child: Text("Cancel"),
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
                                        child: Text("Delete"),
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

  Future<void> _updateUserData(String newUsername, String newBio, String newCity) async {
    setState(() {
      _username = newUsername;
      _bio = newBio;
      _city = newCity;
    });
    await _saveUserData();
  }

  Future<void> _saveUserData() async {
    try {
      await _firestore.collection('users').doc(_userId).set({
        'username': _username,
        'bio': _bio,
        'city': _city,
      });
      print('User data saved successfully');
    } catch (error) {
      print('Error saving user data: $error');
    }
  }
}

class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String currentBio;
  final String currentCity;
  final String profilePictureUrl;
  final Function(String, String, String, String) onUpdate;
  final String userEmail;

  const EditProfilePage({
    Key? key,
    required this.currentUsername,
    required this.currentBio,
    required this.currentCity,
    required this.onUpdate,
    required this.userEmail,
    required this.profilePictureUrl,// Pass user email to EditProfilePage
  }): super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  String _userEmail = '';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _fetchUserEmail();
    super.initState();
    _usernameController =
        TextEditingController(text: widget.currentUsername);
    _bioController = TextEditingController(text: widget.currentBio);
    _cityController = TextEditingController(text: widget.currentCity);
  }

  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage != null) {
      String fileName = 'profile_${widget.currentUsername}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final firebaseStorageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      await firebaseStorageRef.putFile(_profileImage!);
      final downloadUrl = await firebaseStorageRef.getDownloadURL();
      widget.onUpdate(_usernameController.text, _bioController.text, _cityController.text, downloadUrl);
    } else {
      widget.onUpdate(_usernameController.text, _bioController.text, _cityController.text, widget.profilePictureUrl);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_profileImage != null)
              CircleAvatar(
                backgroundImage: FileImage(_profileImage!),
                radius: 50,
              ),
            TextButton(
              onPressed: _pickImage,
              child: Text("Change Profile Picture"),
            ),
            Text(
              'Email: $_userEmail',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('Bio', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                hintText: 'Enter a short description about yourself',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter your city',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                await _uploadImage();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF457a8b), // Text color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Button border radius
                ),
                elevation: 3, // Button shadow
              ),
              child: Text(
                'Save',
                style: TextStyle(fontSize: 16), // Button text style
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}