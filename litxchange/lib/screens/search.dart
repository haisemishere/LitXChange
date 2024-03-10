import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _searchStream = FirebaseFirestore.instance.collection('posts').snapshots();
  }

  Future<String> _fetchUserid(String userName) async {
    try {
      QuerySnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: userName)
          .limit(1) // Limit the result to 1 document
          .get();
      if (userData.docs.isNotEmpty) {
        // Check if any document is found
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
      if (fieldName == 'userId') {
        print(searchText);
        searchText = await _fetchUserid(searchText);
        print(searchText);// Await the result of _fetchUserid
      }
      _searchStream = FirebaseFirestore.instance
          .collection('posts')
          .where(fieldName, isEqualTo: searchText)
          .snapshots();
    } else {
      _searchStream = FirebaseFirestore.instance.collection('posts').snapshots();
    }
    setState(() {}); // Trigger rebuild to update search results
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
                    backgroundColor: Colors.blue,
                    // Text color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Button border radius
                    ),
                    elevation: 3, // Button shadow
                  ),
                  child: Text(
                    'Search',
                    style: TextStyle(fontSize: 16), // Button text style
                  ),
                ),
              ],
            ),
          ),
          Row(
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
          Expanded(
            child: _buildSearchResults(), // Display search results here
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
            var formattedDate = DateFormat.yMMMMd().format(date);
            return FutureBuilder(
              future: _fetchUsername(post['userId']), // Fetch username
              builder: (context, AsyncSnapshot<String> usernameSnapshot) {
                if (usernameSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (usernameSnapshot.hasError) {
                  return Text('Error: ${usernameSnapshot.error}');
                } else {
                  String username = usernameSnapshot.data ?? 'Unknown User';
                  String authorName = post['authorName'] ?? 'Unknown Author'; //

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
                            subtitle: Text(post['genre']),
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
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.swap_horiz),
                                  onPressed: () {
                                    // Handle more options button press for this post
                                  },
                                ),
                              ],
                            ),
                          ),
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
