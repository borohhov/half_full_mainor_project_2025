import 'package:flutter/material.dart';

class ConsumptionScreen extends StatelessWidget {
  const ConsumptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Half Full"),),
      body: Center(
        child: Column(children: [
          Text("0"),
          ElevatedButton(onPressed: null, child: Text("Add 250 ml"))
        ],),
      ),
    );
  }
}
