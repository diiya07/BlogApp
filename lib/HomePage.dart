import 'package:flutter/material.dart';
import 'Authentication.dart';
import 'PhotoUpload.dart';
import 'Posts.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  HomePage({
    required this.auth,
    required this.onSignedOut,
  });

  final AuthImplementation auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  List<Posts> postsList = [];

  @override
  void initState() {
    super.initState();
    DatabaseReference postsRef = FirebaseDatabase.instance.ref().child('Posts');
    postsRef.get().then((snapshot) {
      if (snapshot.exists) {
        var KEYS = snapshot.children.map((e) => e.key).toList();
        var DATA = snapshot.value as Map<dynamic, dynamic>;
        postsList.clear();
        for (var individualKey in KEYS) {
          var postData = DATA[individualKey] as Map<dynamic, dynamic>?;
          if (postData != null) {
            Posts posts = Posts(
              postData['image'] ?? '',
              postData['description'] ?? '',
              postData['date'] ?? '',
              postData['time'] ?? '',
            );
            postsList.add(posts);
          }
        }
        setState(() {
          print('Length : ${postsList.length}');
        });
      } else {
        print('No data available');
      }
    }).catchError((error) {
      print('Error fetching data: $error');
    });
  }

  void _logoutUser() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: postsList.isEmpty
          ? Center(child: Text('No posts'))
          : ListView.builder(
              itemCount: postsList.length,
              itemBuilder: (_, index) {
                return PostsUI(
                  postsList[index].image,
                  postsList[index].description,
                  postsList[index].date,
                  postsList[index].time,
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.pink[100],
        child: Container(
          margin: const EdgeInsets.only(left: 70.0, right: 70.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add_a_photo),
                iconSize: 30,
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return UploadPhotoPage(
                          auth: widget.auth,
                          onSignedOut: widget.onSignedOut,
                        );
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.logout_outlined),
                iconSize: 30,
                color: Colors.white,
                onPressed: _logoutUser,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget PostsUI(String image, String description, String date, String time) {
    return Card(
      elevation: 10.0,
      margin: EdgeInsets.all(15.0),
      child: Container(
        padding: EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall, // Updated to titleSmall
                  textAlign: TextAlign.center,
                ),
                Text(
                  time,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall, // Updated to titleSmall
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 10),
            Image.network(image, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium, // Updated to bodyMedium
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
