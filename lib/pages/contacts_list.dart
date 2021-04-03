import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  Firestore fireStoreDataBase = Firestore.instance;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  List<DocumentSnapshot> documents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fireStoreDataBase.collection("contacts").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            documents = snapshot.data.documents;
            return buildContactList();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addEditContactDialog(context, null);
        },
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildContactList()
  {
    return ListView(
      children: documents.map((doc) {
        return Dismissible(
          key: Key(doc['mobileNo']),
          onDismissed: (direction) {
            deleteContact(doc.documentID);
          },
          child: InkWell(
            onTap: () {
              /// open contact to edit
              addEditContactDialog(context, doc);
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.cyan, width: 3.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            doc['firstName'][0]
                                .toString()
                                .toUpperCase() +
                                doc['lastName'][0]
                                    .toString()
                                    .toUpperCase(),
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                        ),
                        // decoration: BoxDecoration(color: Colors.white,shape: BoxShape.circle),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${doc['firstName']} ${doc['lastName']}',
                                style: (TextStyle(
                                  fontSize: 18,
                                ))),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(Icons.call,
                                    size: 15, color: Colors.green),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(doc['mobileNo']),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(Icons.email,
                                    size: 15, color: Colors.cyan),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(doc['email']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void createContact(
      String firstName, String lastName, String mobileNo, String email) async {
    await fireStoreDataBase
        .collection("contacts")
        .add({
      'firstName': firstName,
      'lastName': lastName,
      'mobileNo': mobileNo,
      'email': email
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Contact Created..!!")));
  }

  void updateContact(String documentId, String firstName, String lastName,
      String mobileNo, String email) {
    try {
      fireStoreDataBase.collection('contacts').document(documentId).updateData({
        'firstName': firstName,
        'lastName': lastName,
        'mobileNo': mobileNo,
        'email': email
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Contact Updated..!!")));
    } catch (e) {
      print(e.toString());
    }
  }

  void deleteContact(String documentId) {
    try {
      fireStoreDataBase.collection('contacts').document(documentId).delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Contact Deleted..!!")));
    } catch (e) {
      print(e.toString());
    }
  }

  addEditContactDialog(BuildContext context, DocumentSnapshot doc) async {
    if (doc != null) {
      /// extract text to update contact
      firstNameController.text = doc['firstName'];
      lastNameController.text = doc['lastName'];
      mobileNoController.text = doc['mobileNo'];
      emailController.text = doc['email'];
    } else {
      /// refresh texts add contact
      firstNameController.text = "";
      lastNameController.text = "";
      mobileNoController.text = "";
      emailController.text = "";
    }
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(doc != null ? 'Edit Contact' : 'Add Contact'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: firstNameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: "First Name"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: lastNameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: "Last Name"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: mobileNoController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(labelText: "Mobile Number"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: emailController,
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: "Email Address"),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
            actions: <Widget>[
              new TextButton(
                child: new Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text('Save'),
                onPressed: () {
                  if (doc != null) {
                    /// update existing contact

                    updateContact(
                        doc.documentID,
                        firstNameController.text,
                        lastNameController.text,
                        mobileNoController.text,
                        emailController.text);
                  } else {
                    /// create new contact

                    createContact(
                        firstNameController.text,
                        lastNameController.text,
                        mobileNoController.text,
                        emailController.text);
                  }

                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
