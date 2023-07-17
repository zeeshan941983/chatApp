import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'Chatpagee.dart';

class searchUser extends StatefulWidget {
  const searchUser({super.key});

  @override
  State<searchUser> createState() => _searchUserState();
}

class _searchUserState extends State<searchUser> {
  TextEditingController seachtf = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool istrue = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('Selected users')
        .doc(_auth.currentUser!.uid)
        .collection('Users')
        .where(
          'Email',
          isEqualTo: seachtf.text,
        )
        .snapshots();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                    height: size.height * 0.056,
                    width: size.width / 1.25,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 10,
                    ),
                    child: TextFormField(
                      controller: seachtf,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Search',
                        fillColor: Colors.grey[150],
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                      ),
                    )),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: StreamBuilder(
                stream: _usersStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text("something is wrong");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (_, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          height: 80,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  snapshot.data!.docs[index]['image']),
                            ),
                            title: Text(
                              snapshot.data!.docs[index]['name'],
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            onTap: () {
                              Get.to(Chatpage(
                                reciverName: snapshot.data!.docs[index]['name'],
                                reciveuserEmail: snapshot.data!.docs[index]
                                    ["Email"],
                                reciveuserID: snapshot.data!.docs[index]
                                    ["selected Id"],
                                reciverimage: snapshot.data!.docs[index]
                                    ["image"],
                              ));
                            },
                          ),
                        );
                      },
                    ),
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
