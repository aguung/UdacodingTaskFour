import 'dart:io';

import 'package:app_task/model/receipt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReceiptRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference ref;

  ReceiptRepository() {
    ref = _firestore.collection('receipt');
  }

  Future<Either<String, String>> addReceipt(String name, String description,
      File file, String createdKey, String createdName) async {
    try {
      DocumentReference result = await ref.add(
        Receipt(
          name: name,
          description: description,
          createdKey: createdKey,
          createdName: createdName,
          photoUrl: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ).toCreate(),
      );
      if (result.id != null) {
        Reference reference =
            FirebaseStorage.instance.ref().child('receipt').child(result.id);
        await reference.putFile(file);
        String url = await reference.getDownloadURL();
        await ref.doc(result.id).update({'photoUrl': url});
        return Right("Succesfully add receipt");
      } else {
        return Left("Failure add receipt");
      }
    } on FirebaseException catch (e) {
      return Left(e.message);
    }
  }

  Future<Either<String, String>> updateReceipt(
      String key, String name, String description, File file) async {
    DocumentReference receiptDoc = _firestore.doc('receipt/$key');
    try {
      if (file != null) {
        Reference reference =
            FirebaseStorage.instance.ref().child('receipt').child(key);
        reference.delete().then((_) async {
          await reference.putFile(file);
          String url = await reference.getDownloadURL();
          await ref.doc(key).update({'photoUrl': url});
        });
      }
      _firestore.runTransaction((transaction) async {
        DocumentSnapshot taskReceipt = await transaction.get(receiptDoc);
        if (taskReceipt.exists) {
          transaction.update(
            receiptDoc,
            Receipt(
              name: name,
              description: description,
              updatedAt: DateTime.now(),
            ).toUpdate(),
          );
        }
      });
      return Right("Succesfully update receipt");
    } on FirebaseException catch (e) {
      return Left(e.message);
    }
  }

  Future<Either<String, String>> addLike(String key, String user) async {
    try {
      DocumentReference receiptDoc = _firestore.doc('receipt/$key');
      _firestore.runTransaction((transaction) async {
        DocumentSnapshot taskReceipt = await transaction.get(receiptDoc);
        if (taskReceipt.exists) {;
          transaction.update(
            receiptDoc,
            {
              'likes': FieldValue.arrayUnion([user])
            },
          );
        }
      });
      return Right("Succesfully add like receipt");
    } on FirebaseException catch (e) {
      return Left(e.message);
    }
  }

  Future<Either<String, String>> removeLike(String key, String user) async {
    try {
      DocumentReference receiptDoc = _firestore.doc('receipt/$key');
      _firestore.runTransaction((transaction) async {
        DocumentSnapshot taskReceipt = await transaction.get(receiptDoc);
        if (taskReceipt.exists) {
          transaction.update(
            receiptDoc,
            {
              'likes': FieldValue.arrayRemove([user])
            },
          );
        }
      });
      return Right("Succesfully remove like receipt");
    } on FirebaseException catch (e) {
      return Left(e.message);
    }
  }
}
