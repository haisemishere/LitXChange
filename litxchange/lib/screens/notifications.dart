import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<DocumentSnapshot>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
  }

  Future<List<DocumentSnapshot>> _fetchNotifications() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      return querySnapshot.docs;
    } catch (error) {
      print("Error fetching notifications: $error");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: FutureBuilder(
        future: _notificationsFuture,
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
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
          List<DocumentSnapshot> notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Text('No notifications available'),
            );
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              DocumentSnapshot notification = notifications[index];
              return ListTile(
                title: Text('You received a request'),
                subtitle: Text('On post ID: ${notification['postId']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Handle view button press
                  },
                  child: Text('View'),
                ),
                onTap: () {
                  // Handle notification tap if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
