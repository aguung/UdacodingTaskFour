import 'dart:io';

import 'package:app_task/model/receipt.dart';
import 'package:app_task/repository/auth_repository.dart';
import 'package:app_task/repository/receipt_repository.dart';
import 'package:app_task/ui/create_receipt/create_receipt_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class CreateReceiptView extends StatefulWidget {
  final bool isEdit;
  final Receipt receipt;

  CreateReceiptView({
    @required this.isEdit,
    this.receipt,
  });

  @override
  _CreateReceiptViewState createState() => _CreateReceiptViewState();
}

class _CreateReceiptViewState extends State<CreateReceiptView> {
  final formState = GlobalKey<FormState>();
  final authRepository = AuthRepository();
  final createReceiptCubit =
      CreateReceiptCubit(repository: ReceiptRepository());
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();

  User profile;
  File _image;

  @override
  void initState() {
    getProfile();
    if (widget.isEdit) {
      controllerName.text = widget.receipt.name;
      controllerDescription.text = widget.receipt.description;
    }
    super.initState();
  }

  Future<void> getProfile() async {
    var user = await authRepository.getCurrentUser();
    if (user != null) {
      setState(() {
        profile = user;
      });
    }
  }

  Future _getImage() async {
    var selectedImage =
        await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _image = File(selectedImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Update Receipt' : 'Create Receipt'),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              if (formState.currentState.validate() &&
                  (widget.isEdit || _image != null)) {
                var name = controllerName.text.trim();
                var description = controllerDescription.text.trim();
                if (widget.isEdit) {
                  createReceiptCubit.updateReceipt(
                      widget.receipt.key, name, description, _image);
                } else {
                  createReceiptCubit.addReceipt(name, description, _image,
                      profile.uid, profile.displayName);
                }
              } else if (_image == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Image not attach"),
                  ),
                );
              }
            },
            icon: Icon(Icons.done),
          ),
        ],
      ),
      body: BlocProvider<CreateReceiptCubit>(
        create: (context) => createReceiptCubit,
        child: BlocListener<CreateReceiptCubit, CreateReceiptState>(
          listener: (context, state) async {
            if (state is FailureCreateReceiptState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                ),
              );
            } else if (state is SuccessCreateReceiptState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints.tightFor(
                  height: MediaQuery.of(context).size.height),
              child: Stack(
                children: [
                  Form(
                    key: formState,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: controllerName,
                            decoration: InputDecoration(
                              hintText: 'Name',
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              return value.isEmpty ? 'Name is empty' : null;
                            },
                          ),
                          SizedBox(height: 8),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: controllerDescription,
                            keyboardType: TextInputType.multiline,
                            minLines: 5,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Description',
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value.isEmpty ? 'Description is empty' : null,
                          ),
                          SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _getImage,
                            child: Text('Choose Image'),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          _image == null
                              ? widget.isEdit
                                  ? Image.network(
                                      widget.receipt.photoUrl,
                                      fit: BoxFit.fill,
                                      height: 300,
                                    )
                                  : Icon(Icons.image)
                              : Image.file(
                                  _image,
                                  fit: BoxFit.fill,
                                  height: 300,
                                ),
                          SizedBox(
                            height: 8,
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<CreateReceiptCubit, CreateReceiptState>(
                    builder: (context, state) {
                      if (state is LoadingCreateReceiptState) {
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
