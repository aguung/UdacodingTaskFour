import 'package:app_task/model/receipt.dart';
import 'package:app_task/repository/auth_repository.dart';
import 'package:app_task/ui/create_receipt/create_receipt_view.dart';
import 'package:app_task/ui/detail_receipt/detail_receipt_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptView extends StatefulWidget {
  @override
  _ReceiptViewState createState() => _ReceiptViewState();
}

class _ReceiptViewState extends State<ReceiptView> {
  final authRepository = AuthRepository();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Reference storage = FirebaseStorage.instance.ref().child('receipt');
  Stream myReceiptList;
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
        myReceiptList = FirebaseFirestore.instance
            .collection('receipt')
            .where('createdKey', isEqualTo: user.uid)
            .orderBy('updatedAt',descending: true)
            .snapshots();
        profile = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Receipt"),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              String result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateReceiptView(
                    isEdit: false,
                  ),
                ),
              );
              if (result != null && result.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result),
                ));
                setState(() {});
              }
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: myReceiptList,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return snapshot.data.docs.isEmpty
                      ? Center(child: Text('Empty My Receipt'))
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
                                      receipt: receipt
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
                                trailing: PopupMenuButton(
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    )
                                  ],
                                  onSelected: (String value) async {
                                    if (value == 'edit') {
                                      String result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return CreateReceiptView(
                                            isEdit: true,
                                            receipt: receipt,
                                          );
                                        }),
                                      );
                                      if (result != null && result.isNotEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(result),
                                        ));
                                        setState(() {});
                                      }
                                    } else if (value == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Are You Sure'),
                                            content: Text(
                                                'Do you want to delete ${receipt.name}?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('No'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Delete'),
                                                onPressed: () {
                                                  storage
                                                      .child(receipt.key)
                                                      .delete()
                                                      .then((value) => document
                                                          .reference
                                                          .delete());
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Icon(Icons.more_vert),
                                ),
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
