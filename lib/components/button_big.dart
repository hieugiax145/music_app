import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {

  final String buttonText;
  final void Function()? ontap;
  const BigButton({super.key, required this.buttonText, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: ontap,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    buttonText,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
            ),
          );
  }
}