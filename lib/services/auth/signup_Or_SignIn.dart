import 'package:flutter/material.dart';

import '../../screens/Auth_pages/SigninPage.dart';
import '../../screens/Auth_pages/SignupPage.dart';

class signupOrSignIn extends StatefulWidget {
  const signupOrSignIn({super.key});

  @override
  State<signupOrSignIn> createState() => _signupOrSignInState();
}

class _signupOrSignInState extends State<signupOrSignIn> {
  bool showSignupPage = true;
  void togglePages() {
    setState(() {
      showSignupPage = !showSignupPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignupPage) {
      return signinPage(ontap: togglePages);
    } else {
      return signupPage(ontap: togglePages);
    }
  }
}
