import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../components/my_textfield.dart';
import '../../components/mybutton.dart';
import '../../services/auth/auth_services.dart';

class signupPage extends StatefulWidget {
  final void Function()? ontap;
  const signupPage({super.key, required this.ontap});

  @override
  State<signupPage> createState() => _signupPageState();
}

class _signupPageState extends State<signupPage> {
  final emialcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final passwordconformcontroller = TextEditingController();
  final namecontroller = TextEditingController();
  final storage = FirebaseStorage.instance;
  bool isloading = false;

  ////////pic
  File? _image;

  final picker = ImagePicker();
  Future getimageGellary() async {
    final PickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      if (PickedFile != null) {
        _image = File(PickedFile.path);
      } else {
        print('Picture didt get');
      }
    });
  }

  Future getimageCamera() async {
    final PickedFile = await picker.pickImage(
      imageQuality: 50,
      source: ImageSource.camera,
    );
    setState(() {
      if (PickedFile != null) {
        _image = File(PickedFile.path);
      } else {
        print('Picture didt get');
      }
    });
  }

/////
  void signup() async {
    if (passwordcontroller.text != passwordconformcontroller.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Password do not match')));

      return;
    }
    final authservices = Provider.of<Authservices>(context, listen: false);
    try {
      setState(() {
        isloading = true;
      });

      final ref = storage
          .ref('/images/' + DateTime.now().microsecondsSinceEpoch.toString());
      final ploadTask = ref.putFile(_image!.absolute);
      await Future.value(ploadTask);
      var newurl = await ref.getDownloadURL();
      await authservices.SignupwithEmailandPassword(emialcontroller.text,
          passwordcontroller.text, namecontroller.text, newurl.toString());
    } catch (e) {
      setState(() {
        isloading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    Exception(FirebaseException) {
      setState(() {
        isloading == false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(FirebaseException.toString())));
    }

    ;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return isloading == true
        ? Center(
            child: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
                child: Lottie.asset('images/loading.json',
                    height: 200, width: 200)),
          ))
        : Scaffold(
            body: SafeArea(
                child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 100,
                              backgroundImage: FileImage(_image!.absolute),
                            )
                          : CircleAvatar(
                              radius: 100,
                              child: Icon(
                                Icons.person,
                                size: 100,
                              )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                getimageGellary();
                              },
                              icon: Icon(
                                Icons.image,
                                color: Colors.deepPurple,
                              )),
                          IconButton(
                              onPressed: () {
                                getimageCamera();
                              },
                              icon: Icon(
                                Icons.camera,
                                color: Colors.deepPurple,
                              ))
                        ],
                      ),
                      shight(size: size),
                      Text(
                        " Let's create acount",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      shight(size: size),
                      myText_field(
                        controller: namecontroller,
                        hint: 'Enter Name',
                        icon: Icons.person_2_outlined,
                        obsecuretext: false,
                      ),
                      shight(size: size),
                      myText_field(
                        controller: emialcontroller,
                        hint: 'Enter Email',
                        icon: Icons.email,
                        obsecuretext: false,
                      ),
                      shight(size: size),
                      myText_field(
                        controller: passwordcontroller,
                        hint: 'Enter Passwoord',
                        icon: Icons.lock,
                        obsecuretext: true,
                      ),
                      shight(size: size),
                      myText_field(
                        controller: passwordconformcontroller,
                        hint: 'Conform Passwoord',
                        icon: Icons.lock,
                        obsecuretext: true,
                      ),
                      shight(size: size),
                      Mybutton(ontap: signup, text: 'Sign Up'),
                      shight(size: size),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already member?'),
                          SizedBox(
                            width: size.width / 30,
                          ),
                          GestureDetector(
                            onTap: widget.ontap,
                            child: Text(
                              'Login Now',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )),
          );
  }
}
