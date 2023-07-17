import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../components/my_textfield.dart';
import '../../components/mybutton.dart';
import '../../services/auth/auth_services.dart';

class signinPage extends StatefulWidget {
  final void Function()? ontap;
  const signinPage({super.key, required this.ontap});

  @override
  State<signinPage> createState() => _signinPageState();
}

class _signinPageState extends State<signinPage> {
  bool isloading = false;
  final emialcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  void sigin() async {
    final authservice = Provider.of<Authservices>(listen: false, context);
    try {
      setState(() {
        isloading = true;
      });
      await authservice.signInWithEmailandPassword(
          emialcontroller.text, passwordcontroller.text);
    } catch (e) {
      setState(() {
        isloading == false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return isloading == true
        ? Scaffold(
            backgroundColor: Colors.black,
            body: Center(
                child: Lottie.asset('images/loading.json',
                    height: 200, width: 200)),
          )
        : Scaffold(
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(children: [
                      Positioned(
                        left: 35,
                        top: 230,
                        child: Text('Welcome back',
                            style: GoogleFonts.aBeeZee(fontSize: 30)),
                      ),
                      Image.asset(
                        'images/1.png',
                        fit: BoxFit.fill,
                        width: 300,
                      ),
                    ]),
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
                    Mybutton(ontap: sigin, text: 'SignIn'),
                    shight(size: size),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Doesn't have account?"),
                        SizedBox(
                          width: size.width / 30,
                        ),
                        GestureDetector(
                          onTap: widget.ontap,
                          child: Text(
                            'Register Now',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )),
          );
  }
}
