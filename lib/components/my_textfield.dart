import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class myText_field extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData? icon;
  final bool obsecuretext;
  final VoidCallback? ontap;
  final bool? read;

  myText_field(
      {Key? key, // Add the Key parameter here
      this.controller,
      required this.hint,
      required this.obsecuretext,
      this.icon,
      this.read,
      this.ontap})
      : super(key: key);

  @override
  State<myText_field> createState() => _myText_fieldState();
}

class _myText_fieldState extends State<myText_field> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: widget.obsecuretext,
      onTap: widget.ontap,
      readOnly: widget.read == true,
      controller: widget.controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(20)),
        hintText: widget.hint,
        fillColor: Colors.grey[150],
        filled: true,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(
          widget.icon,
          color: Colors.grey,
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
