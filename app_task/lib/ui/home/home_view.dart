import 'package:app_task/model/receipt.dart';
import 'package:app_task/repository/auth_repository.dart';
import 'package:app_task/ui/detail_receipt/detail_receipt_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final authRepository = AuthRepository();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Reference storage = FirebaseStorage.instance.ref().child('receipt');
  Stream receiptList;
  User profile;

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  Future<void> getProfile() async {
    var user = await authRepository.getCurrentUser();
    if (user != null) {
      setState(() {
        receiptList = FirebaseFirestore.instance
            .collection('receipt')
            .orderBy('updatedAt', descending: true)
            .snapshots();
        profile = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: receiptList,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return snapshot.data.docs.isEmpty
                      ? Center(child: Text('Empty Receipt'))
                      : ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          itemCount: snapshot.data.size,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot document =
                                snapshot.data.docs[index];
                            Receipt receipt =
                                Receipt.fromMap(document, document.id);
                            return Card(
                              child: ListTile(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return DetailReceiptView(
                                      receipt: receipt,
                                      isFavorite: false,
                                      user: profile,
                                    );
                                  }),
                                ),
                                leading: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: 64,
                                    minHeight: 64,
                                    maxWidth: 128,
                                    maxHeight: 128,
                                  ),
                                  child: receipt.photoUrl == '' ||
                                          receipt.photoUrl == null
                                      ? Image.asset('images/icon.png')
                                      : Image.network(receipt.photoUrl,
                                          fit: BoxFit.cover),
                                ),
                                title: Text(receipt.name),
                                subtitle: Text(
                                  DateFormat("dd MMM yyyy hh:mm:ss")
                                      .format(receipt.updatedAt),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                isThreeLine: false,
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
