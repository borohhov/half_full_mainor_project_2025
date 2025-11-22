import 'package:flutter/material.dart';
import 'package:half_full/controllers/day_consumption_controller.dart';

class ConsumptionScreen extends StatefulWidget {
  const ConsumptionScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ConsumptionScreenState();
  }

}

class ConsumptionScreenState extends State<ConsumptionScreen> {
  DayConsumptionController controller = DayConsumptionController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Half Full"),),
      body: Center(
        child: Column(children: [
          Text(controller.getConsumption().consumption.toString()),
          Text("Remaining to drink for the day:"),
          Text(controller.remainingToDrink().toString()),
          ElevatedButton(onPressed: () {
            setState(() {
              controller.addConsumption();
            });
          }, child: Text("Add 250 ml"))
        ],),
      ),
    );
  }
}
