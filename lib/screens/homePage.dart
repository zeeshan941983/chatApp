import 'package:chat/screens/searchpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../components/my_textfield.dart';
import '../services/chat/chat_service.dart';

import 'Chatpagee.dart';

class HomePage extends StatefulWidget {
  final List<String>? user;

  HomePage({Key? key, this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String name = '';
  String currentUserProfilePicUrl = '';
  String formattedTime = '';
  bool font = false;
  TextEditingController search = TextEditingController();

  Future<void> getCurrentUserProfilePicUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();

    final profilePicUrl = userDoc.data()!['image'];
    final fname = userDoc.data()!['name'];
    setState(() {
      currentUserProfilePicUrl = profilePicUrl;
      name = fname;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserProfilePicUrl();
  }

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    setState(() {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });

    return SafeArea(
      child: Scaffold(
        key: _globalKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Selected users')
                  .doc(_auth.currentUser!.uid)
                  .collection('Users')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Text('Error');
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final selectedUsers = snap.data!.docs;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedUsers.length,
                  itemBuilder: (context, index) {
                    final user =
                        selectedUsers[index].data() as Map<String, dynamic>;

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user['selected Id'])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Error');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        final isOnline = userData['isOnline'];

                        return StreamBuilder<QuerySnapshot>(
                          stream: ChatService().getMessages(
                            _auth.currentUser!.uid,
                            user['selected Id'],
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Error');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return Column(
                              children: [
                                SizedBox(
                                  height: 110,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 20, top: 10),
                                  child: Stack(children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage:
                                          NetworkImage(userData['image']),
                                    ),
                                    Positioned(
                                      right: size.aspectRatio,
                                      top: 60,
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Icon(
                                          Icons.circle_sharp,
                                          size: 15,
                                          color: isOnline == 'offline'
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Center(
                                    child: Text(
                                  userData['name'],
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                )),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 240),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Selected users')
                    .doc(_auth.currentUser!.uid)
                    .collection('Users')
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Text('Error');
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final selectedUsers = snap.data!.docs;

                  return ListView.builder(
                    itemCount: selectedUsers.length,
                    itemBuilder: (context, index) {
                      final user =
                          selectedUsers[index].data() as Map<String, dynamic>;

                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(user['selected Id'])
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Error');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          // final isOnline = userData['isOnline'];

                          return StreamBuilder<QuerySnapshot>(
                            stream: ChatService().getMessages(
                              _auth.currentUser!.uid,
                              user['selected Id'],
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Text('Error');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final messages = snapshot.data!.docs;

                              String lastMessage = '';

                              if (messages.isNotEmpty) {
                                final lastMsg = messages.last.data()
                                    as Map<String, dynamic>;
                                if (lastMsg.containsKey('timestamp')) {
                                  final timestamp = lastMsg['timestamp'];
                                  if (timestamp is Timestamp) {
                                    final dateTime = timestamp.toDate();
                                    lastMessage = lastMsg['message'];
                                    formattedTime = DateFormat.jm().format(
                                        dateTime); // Format time as HH:MM AM/PM
                                  }
                                }
                              }

                              return Card(
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  height: 80,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          NetworkImage(userData['image']),
                                    ),
                                    title: Text(
                                      userData['name'],
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    trailing: Text(
                                      formattedTime,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      lastMessage,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    onLongPress: () {
                                      String selectedEmail = userData["Email"];
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shadowColor: Colors.black,
                                            backgroundColor: Colors.deepPurple,
                                            contentTextStyle:
                                                TextStyle(color: Colors.white),
                                            titleTextStyle:
                                                TextStyle(color: Colors.white),
                                            title: Text("Delete User"),
                                            content: Text(
                                                "Are you sure you want to delete this user?"),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          "Selected users")
                                                      .doc(_auth
                                                          .currentUser!.uid)
                                                      .collection('Users')
                                                      .where("Email",
                                                          isEqualTo:
                                                              selectedEmail)
                                                      .get()
                                                      .then((QuerySnapshot
                                                          querySnapshot) {
                                                    querySnapshot.docs
                                                        .forEach((doc) {
                                                      doc.reference.delete();
                                                    });
                                                  });

                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return Chatpage(
                                          reciverName: selectedUsers[index]
                                              ['name'],
                                          reciveuserEmail: selectedUsers[index]
                                              ["Email"],
                                          reciveuserID: selectedUsers[index]
                                              ["selected Id"],
                                          reciverimage: selectedUsers[index]
                                              ["image"],
                                        );
                                      }));
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            ////top side

            Container(
              width: size.width / 1,
              height: size.height * 0.06,
              margin: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 55,
              ),
              child: myText_field(
                hint: 'Search',
                controller: search,
                obsecuretext: false,
                read: true,
                ontap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return searchUser();
                  }));
                },
                icon: Icons.search,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Messages",
                      style: GoogleFonts.palanquinDark(fontSize: 30)),
                  GestureDetector(
                    onTap: () => _globalKey.currentState?.openEndDrawer(),
                    child: currentUserProfilePicUrl == ''
                        ? Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(100)),
                          )
                        : CircleAvatar(
                            backgroundImage:
                                NetworkImage(currentUserProfilePicUrl)),
                  )
                ],
              ),
            ),
            ////top side ends
          ],
        ),
      ),
    );
  }
}
