import 'package:flutter/material.dart';
import 'package:music_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class NeuBox extends StatelessWidget {
  // const NeuBox({super.key});
  final child;
  final Color color;
  const NeuBox({super.key, this.child, required this.color});
  @override
  Widget build(BuildContext context) {
    bool isDarkMode=Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
        boxShadow:[
          const BoxShadow(

            blurRadius: 15,
            offset: Offset(5, 5),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.secondary,
            // color: isDarkMode?Color(0xffa1b2g3):Colors.white,
            blurRadius: 15,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}