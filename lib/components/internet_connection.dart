import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Connectivity extends StatefulWidget {
  const Connectivity({super.key});

  @override
  State<Connectivity> createState() => _ConnectivityState();
}

class _ConnectivityState extends State<Connectivity> {
  bool _showWidget = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3)).then((value) {
      setState(() {
        _showWidget = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      decoration: BoxDecoration(color: Colors.amber),
      child: Center(
        child: _showWidget? Text('Internet'):Text('data'),
      ),
    );
  }
}
