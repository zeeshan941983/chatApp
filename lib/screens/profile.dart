import 'package:chat/components/mybutton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../components/my_textfield.dart';
import '../services/auth/auth_services.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  String currentUserProfilePicUrl = '';
  String name = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  // FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  void signOut() {
    final authservice = Provider.of<Authservices>(context, listen: false);
    authservice.signOut();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserProfilePicUrl();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                    color: Colors.deepPurple[200],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(180),
                    )),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 70, horizontal: 130),
                  child: Text(
                    'HI ' + name,
                    style:
                        GoogleFonts.aBeeZee(fontSize: 30, color: Colors.white),
                  )),
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 150),
                  child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(
                        currentUserProfilePicUrl,
                      )),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(CupertinoIcons.person),
                    title: Text(
                      name,
                      style: GoogleFonts.aBeeZee(fontSize: 20),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(CupertinoIcons.mail),
                    title: Text(
                      _auth.currentUser!.email.toString(),
                      style: GoogleFonts.aBeeZee(fontSize: 20),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: size.height / 10,
                // ),
                shight(size: size),
                Mybutton(ontap: signOut, text: 'signout')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
