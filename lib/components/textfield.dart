import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController input;
  final bool obscure;
  final String hint;

  const MyTextField({super.key, required this.input, required this.obscure, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        obscureText: obscure,
        controller: input,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          ),
          hintText: hint,
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
        ),
      ),
    );
  }
}
