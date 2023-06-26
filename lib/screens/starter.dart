import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

import 'registration.dart';
import 'intro.dart';

class Starter extends StatefulWidget {
  const Starter({Key? key}) : super(key: key);

  @override
  State<Starter> createState() => _StarterState();
}

class _StarterState extends State<Starter> with TickerProviderStateMixin {
  late SharedPreferences prefs;
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    _sharedStarter();
    super.initState();
  } 
  
  _sharedStarter() async {
    prefs = await SharedPreferences.getInstance();

    //Already Registered User
    if (prefs.containsKey('email')) {
      controller = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));

      Tween<double> _linearTween = Tween(begin: 0, end: 1000);

       animation = _linearTween.animate(controller)
        ..addListener(() {
          setState(() {});
        })
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    duration: const Duration(milliseconds: 1300),
                    child: Intro()));
          }
        });
      controller.forward();

    } else {
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 1300),
              child: const Registration()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF83BCCC),
      body: CustomPaint(
        foregroundPainter: ShapePainter(animation.value),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final double radius;
  ShapePainter(this.radius);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF83BCFF)
      ..strokeWidth = 5
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width, size.height);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
