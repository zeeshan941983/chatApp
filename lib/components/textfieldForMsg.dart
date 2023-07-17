import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class msgTextfield extends StatefulWidget {
  final TextEditingController? controller;

  msgTextfield({
    Key? key, // Add the Key parameter here
    this.controller,
  }) : super(key: key);

  @override
  State<msgTextfield> createState() => _msgTextfieldState();
}

class _msgTextfieldState extends State<msgTextfield> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        enableSuggestions: true,
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: 'Aa',
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
          )),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(20)),
          fillColor: Colors.grey[100],
          filled: true,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 20, height: 2.7),
        ),
      ),
    );
  }
}

class shight extends StatelessWidget {
  const shight({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.02,
    );
  }
}
