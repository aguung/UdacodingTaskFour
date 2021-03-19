import 'package:app_task/model/receipt.dart';
import 'package:app_task/repository/receipt_repository.dart';
import 'package:app_task/ui/detail_receipt/detail_receipt_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DetailReceiptView extends StatefulWidget {
  final Receipt receipt;
  final bool isFavorite;
  final User user;

  DetailReceiptView({this.receipt, this.isFavorite, this.user});

  @override
  _DetailReceiptViewState createState() => _DetailReceiptViewState();
}

class _DetailReceiptViewState extends State<DetailReceiptView> {
  final detailReceiptCubit =
  DetailReceiptCubit(repository: ReceiptRepository());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Receipt'),
      ),
      body: BlocProvider<DetailReceiptCubit>(
        create: (context) => detailReceiptCubit,
        child: BlocListener<DetailReceiptCubit, DetailReceiptState>(
          listener: (context, state) async {
            if (state is FailureDetailReceiptState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                ),
              );
            } else
            if (state is SuccessDetailReceiptState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Image.network(widget.receipt.photoUrl),
                      ListTile(
                        title: Text('Receipt Name'),
                        subtitle: Text(widget.receipt.name),
                      ),
                      ListTile(
                        title: Text('Receipt Created By'),
                        subtitle: Text(widget.receipt.createdName),
                      ),
                      ListTile(
                        title: Text('Receipt Description'),
                        subtitle: Text(widget.receipt.description),
                      ),
                      ListTile(
                        title: Text('Receipt Date Created'),
                        subtitle: Text(
                          DateFormat("dd MMM yyyy hh:mm:ss")
                              .format(widget.receipt.createdAt),
                        ),
                      ),
                      ListTile(
                        title: Text('Receipt Last Updated'),
                        subtitle: Text(
                          DateFormat("dd MMM yyyy hh:mm:ss")
                              .format(widget.receipt.updatedAt),
                        ),
                      ),
                      widget.isFavorite != null && !widget.isFavorite
                          ? ElevatedButton(
                        child: Text('Add Favorite'),
                        onPressed: () {
                          detailReceiptCubit.addLikeReceipt(widget.receipt.key, widget.user.uid);
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<
                              RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.lightBlue),
                            ),
                          ),
                        ),
                      )
                          : SizedBox(
                        height: 16,
                      )
                    ],
                  ),
                  BlocBuilder<DetailReceiptCubit, DetailReceiptState>(
                    builder: (context, state) {
                      if (state is LoadingDetailReceiptState) {
                        return Container(
                          color: Colors.black.withOpacity(.5),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  )
                ],
              ),
            ),)
          ,
        )
        ,
      )
      ,
    );
  }
}
