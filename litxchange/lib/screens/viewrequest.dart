import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:litxchange/screens/master.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthApi
{
  static final _googleSignIn=GoogleSignIn(scopes: ['https://mail.google.com/']);
  static  Future<GoogleSignInAccount?> signIn() async {
    if (await _googleSignIn.isSignedIn()) {
      _googleSignIn.signOut();
    }
      return await _googleSignIn.signIn();

  }

  static Future signOut()=>_googleSignIn.signOut();
}

class ViewProfilePage extends StatefulWidget {
  final String userId;
  final String notificationId;
  final String postId;
  final String bookName;

  const ViewProfilePage({required this.userId, required this.notificationId, required this.bookName, required this.postId});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Swap Request for '${widget.bookName}'",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  QuerySnapshot notificationsSnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('notifications')
                                      .where('notificationId',
                                      isEqualTo: widget.notificationId)
                                      .get();

                                  for (DocumentSnapshot doc
                                  in notificationsSnapshot.docs) {
                                    await doc.reference.delete();
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Home(userId: (FirebaseAuth.instance
                                              .currentUser)!
                                              .uid,
                                              idx: 3),
                                    ),
                                  );
                                } catch (error) {
                                  print(
                                      "Error deleting notification: $error");
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
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF457a8b),
                    padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Reject',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
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
                            icon: Icon(Icons.check_circle),
                            // Use the check_box_outline_blank icon
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Accept Swap Request"),
                                    content: Text(
                                        "Are you sure you want to select '${post['bookName']}' for swapping?"),
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

                                          await sendemail(widget.userId,widget.bookName,post['bookName']);

                                          QuerySnapshot notificationsSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('notifications')
                                              .where('notificationId',
                                              isEqualTo: widget.notificationId)
                                              .get();

                                          for (DocumentSnapshot doc
                                          in notificationsSnapshot.docs) {
                                            await doc.reference.delete();
                                          }

                                          QuerySnapshot recievedSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .where('postId',
                                              isEqualTo: widget.postId)
                                              .get();

                                          for (DocumentSnapshot doc
                                          in recievedSnapshot.docs) {
                                            await doc.reference.delete();
                                          }

                                          QuerySnapshot sentSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('posts')
                                              .where('postId',
                                              isEqualTo: post['postId'])
                                              .get();

                                          for (DocumentSnapshot doc
                                          in sentSnapshot.docs) {
                                            await doc.reference.delete();
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Home(userId: (FirebaseAuth.instance.currentUser)!.uid, idx: 3,),
                                            ),
                                          );

                                          // Close the dialog
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

  Future<String> _fetchUserEmail(String userId) async {
    try {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userData['email'] ?? 'Unknown email';
    } catch (error) {
      print("Error fetching email: $error");
      return 'Unknown email';
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

  Future sendemail(String reciverid,String bookName,String selectedbook) async {
    String userName = await _fetchUsername(
        (FirebaseAuth.instance.currentUser)!.uid);
    String reciverName=await _fetchUsername(reciverid);
    String reciever_email=await _fetchUserEmail(reciverid);
    final user1 = FirebaseAuth.instance.currentUser;
    String sender_email=user1!.email ?? '';
    GoogleSignInAccount? user = await GoogleAuthApi.signIn();
    while (user!.email!=sender_email)
    {
        GoogleAuthApi.signOut();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Invalid email selected'),
            content: Text('Please select the email account you used to register to LitXChange'),
            actions: [
              TextButton(
                onPressed: () async{
                  Navigator.of(context).pop();
                  user = await GoogleAuthApi.signIn();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );

    }
    final auth = await user!.authentication;
    final token = auth.accessToken!;
    print('Authenticated: $sender_email');
    final smtpServer = gmailSaslXoauth2(sender_email, token);
    final message = Message()
      ..from = Address(sender_email, userName)
      ..recipients = [reciever_email]
      ..subject = 'Swap Request Accepted'
      ..text = 'Dear $reciverName,\n\nTeam LitXChange is pleased to inform you that your swap request for book, \'$bookName\' has been accepted by $userName in return of your book, \'$selectedbook\'.\n\nTo establish further contact with $userName, please reply to this email.\n\nHappy Swapping!\n\nRegards,\nTeam LitXChange\n\nPlease note that this is a computer-generated email.';

    try {
      await send(message,smtpServer);
      print('email sent');

    }
    on MailerException catch (e) {
      print(e);
    }
  }
}

