import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:litxchange/screens/master.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

enum SearchOption {
  BookName,
  AuthorName,
  UserName,
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _searchStream;
  SearchOption _searchOption = SearchOption.BookName;
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _searchStream = FirebaseFirestore.instance.collection('posts').where('userId', isNotEqualTo: currentUserUid).snapshots();
  }

  Future<String> _fetchUserid(String userName) async {
    try {
      QuerySnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: userName)
          .limit(1)
          .get();
      if (userData.docs.isNotEmpty) {
        return userData.docs[0]['uid'] ?? 'Unknown User';
      } else {
        return 'Unknown User';
      }
    } catch (error) {
      print("Error fetching username: $error");
      return 'Unknown User';
    }
  }

  void _performSearch() async {
    String searchText = _searchController.text.trim();
    String fieldName;
    switch (_searchOption) {
      case SearchOption.AuthorName:
        fieldName = 'authorName';
        break;
      case SearchOption.UserName:
        fieldName = 'userId';
        break;
      case SearchOption.BookName:
      default:
        fieldName = 'bookName';
        break;
    }

    if (searchText.isNotEmpty) {
      if(fieldName=='userId'){
        _fetchUserid(searchText).then((String userId) {
          _searchStream = FirebaseFirestore.instance
              .collection('posts')
              .where('userId', isEqualTo: userId)
              .where('userId', isNotEqualTo: currentUserUid)
              .snapshots();
        });
      }
      else {
        _searchStream = FirebaseFirestore.instance
            .collection('posts')
            .where(fieldName, isEqualTo: searchText)
            .where('userId', isNotEqualTo: currentUserUid)
            .snapshots();
      }
    } else {
      _searchStream = FirebaseFirestore.instance.collection('posts').where('userId', isNotEqualTo: currentUserUid).snapshots();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by ${_searchOption.toString().split('.').last}',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _performSearch,
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
                    'Search',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  value: SearchOption.BookName,
                  groupValue: _searchOption,
                  onChanged: (SearchOption? value) {
                    setState(() {
                      _searchOption = value!;
                    });
                  },
                ),
                Text('Book Name'),
                Radio(
                  value: SearchOption.AuthorName,
                  groupValue: _searchOption,
                  onChanged: (SearchOption? value) {
                    setState(() {
                      _searchOption = value!;
                    });
                  },
                ),
                Text('Author Name'),
                Radio(
                  value: SearchOption.UserName,
                  groupValue: _searchOption,
                  onChanged: (SearchOption? value) {
                    setState(() {
                      _searchOption = value!;
                    });
                  },
                ),
                Text('User Name'),
              ],
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
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

  Widget _buildSearchResults() {
    return StreamBuilder(
      stream: _searchStream,
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
            child: Text('No posts found'),
          );
        }
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];
            var date = post['date'].toDate();
            String bookCondition =
                post['condition'] ?? 'Unknown Condition';
            var formattedDate = DateFormat.yMMMMd().format(date);
            return FutureBuilder(
              future: _fetchUsername(post['userId']),
              builder: (context, AsyncSnapshot<String> usernameSnapshot) {
                if (usernameSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (usernameSnapshot.hasError) {
                  return Text('Error: ${usernameSnapshot.error}');
                } else {
                  String username = usernameSnapshot.data ?? 'Unknown User';
                  String authorName = post['authorName'] ?? 'Unknown Author';

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
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
                          SizedBox(height: 8.0),
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
                                        icon: Icon(Icons.swap_horiz),
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
                                                  child: Text("Cancel"),
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
                                                  child: Text('Send'),
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
    );
  }
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Successful'),
        content: Text('Request sent successfully'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  } catch (error) {
    print('Error saving notification: $error');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request Failed'),
        content: Text('Unable to send request. Error: $error'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

