import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class Congrats extends StatefulWidget {
  const Congrats({super.key});

  @override
  State<Congrats> createState() => _CongratsState();
}

class _CongratsState extends State<Congrats> {
  bool isPlaying = false;
  final controller = ConfettiController();

  @override
  void initState() {
    super.initState();

    controller.play();
  }

  @override
  Widget build(BuildContext context) =>
      Stack(alignment: Alignment.center, children: [
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            // title: const Text('Congratulations'),
          ),
        ),
        ConfettiWidget(
          confettiController: controller,
          shouldLoop: true,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.2,
          numberOfParticles: 20,
          minBlastForce: 1,
          maxBlastForce: 100,
        ),
      ]);
}
