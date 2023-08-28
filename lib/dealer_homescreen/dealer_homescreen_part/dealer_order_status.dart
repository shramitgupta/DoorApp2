import 'package:flutter/material.dart';

class DealerOrderStatus extends StatefulWidget {
  const DealerOrderStatus({super.key});

  @override
  State<DealerOrderStatus> createState() => _DealerOrderStatusState();
}

class _DealerOrderStatusState extends State<DealerOrderStatus> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown.shade900,
        title: const Text(
          'Order Status',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stepper(
        currentStep: _index,
        onStepCancel: () {},
        onStepContinue: () {},
        onStepTapped: (int index) {},
        steps: <Step>[
          Step(
            title: const Text('Step 1 title'),
            content: Container(
                alignment: Alignment.centerLeft,
                child: const Text('Content for Step 1')),
          ),
          const Step(
            title: Text('Step 2 title'),
            content: Text('Content for Step 2'),
          ),
        ],
      ),
    );
  }
}
