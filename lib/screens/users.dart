import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Chatpagee.dart';

class users extends StatefulWidget {
  const users({
    super.key,
  });

  @override
  State<users> createState() => _usersState();
}

class _usersState extends State<users> with WidgetsBindingObserver {
  CollectionReference ref_chat_room =
      FirebaseFirestore.instance.collection('chat_rooms');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchf = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("online");
  }

  void setStatus(String status) async {
    // TODO: implement setState
    await _firestore
        .collection('Users')
        .doc(_auth.currentUser!.uid)
        .update({"isOnline": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ///online
      setStatus("online");
    } else {
      ///offline
      setStatus("offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(children: [
        // ignore: unnecessary_null_comparison
        searchf.text.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: _buildUserList())
            : Text(""),
        Padding(
            padding: EdgeInsets.symmetric(vertical: 50), child: _buildsearch())
      ]),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading..');
          }

          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildUserListItem(doc))
                .toList(),
          );
        });
  }

  ////build individual user list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data['Email']) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        height: 60,
        child: ListTile(
          subtitle: Text(data['isOnline']),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(data['image']),
          ),
          title: Text(
            data['Email'],
            style: TextStyle(color: Colors.black),
          ),
          onTap: () async {
            bool userExists = await FirebaseFirestore.instance
                .collection("Selected users")
                .doc(_auth.currentUser!.uid)
                .collection('Users')
                .where("Email", isEqualTo: data['Email'])
                .limit(1)
                .get()
                .then((QuerySnapshot querySnapshot) => querySnapshot.size > 0);

            if (!userExists) {
              // Add the user to the "Selected users" collection
              FirebaseFirestore.instance
                  .collection("Selected users")
                  .doc(_auth.currentUser!.uid)
                  .collection('Users')
                  .add({
                "Email": data['Email'],
                "selected Id": data["uid"],
                "name": data['name'],
                "image": data['image'],
                "isonline": ''
              });
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chatpage(
                  reciverName: data["name"],
                  reciveuserEmail: data['Email'],
                  reciveuserID: data['uid'],
                  reciverimage: data['image'],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildsearch() {
    var size = MediaQuery.of(context).size;
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('Users')
        .where(
          'Email',
          isEqualTo: searchf.text,
        )
        .snapshots();

    return Stack(
      children: [
        Row(
          children: [
            Container(
                height: size.height * 0.056,
                width: size.width,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: searchf,
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

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    if (_auth.currentUser!.email !=
                        snapshot.data!.docs[index]['Email']) {
                      return ListTile(
                        subtitle: Text(snapshot.data!.docs[index]['isOnline']),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data!.docs[index]['image']),
                        ),
                        title: Text(
                          snapshot.data!.docs[index]['Email'],
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () async {
                          bool userExists = await FirebaseFirestore.instance
                              .collection("Selected users")
                              .doc(_auth.currentUser!.uid)
                              .collection('Users')
                              .where("Email",
                                  isEqualTo: snapshot.data!.docs[index]
                                      ['Email'])
                              .limit(1)
                              .get()
                              .then((QuerySnapshot querySnapshot) =>
                                  querySnapshot.size > 0);

                          if (!userExists) {
                            // Add the user to the "Selected users" collection
                            FirebaseFirestore.instance
                                .collection("Selected users")
                                .doc(_auth.currentUser!.uid)
                                .collection('Users')
                                .add({
                              "Email": snapshot.data!.docs[index]['Email'],
                              "selected Id": snapshot.data!.docs[index]["uid"],
                              "name": snapshot.data!.docs[index]['name'],
                              "image": snapshot.data!.docs[index]['image'],
                              "isonline": ''
                            });
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chatpage(
                                reciverName: snapshot.data!.docs[index]["name"],
                                reciveuserEmail: snapshot.data!.docs[index]
                                    ['Email'],
                                reciveuserID: snapshot.data!.docs[index]['uid'],
                                reciverimage: snapshot.data!.docs[index]
                                    ['image'],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return null;
                  },
                );
              }),
        )
      ],
    );
  }
}
