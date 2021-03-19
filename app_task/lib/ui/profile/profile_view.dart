import 'package:app_task/repository/auth_repository.dart';
import 'package:app_task/ui/login/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final repository = AuthRepository();
  User profile;

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  Future<void> getProfile() async {
    await repository.getCurrentUser().then((value) =>
        setState(() {
          profile = value;
        })
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Are You Sure'),
                    content: Text('Do you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('No'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text('Yes'),
                        onPressed: () {
                          repository.signOut().then(
                                (value) => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        LoginView(),
                                  ),
                                ),
                              );
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(18.0),
          child: Column(
            children: [
              Container(
                child: profile == null && profile?.photoURL == null
                    ? Image.asset('images/profile.png')
                    : Image.network(profile.photoURL),
                height: 200,
                width: 200,
              ),
              SizedBox(height: 8),
              Text(
                'Email',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Text('${profile?.email}'),
              SizedBox(height: 8),
              Text(
                'Name',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              Text('${profile?.displayName}'),
            ],
          ),
        ),
      ),
    );
  }
}
