import 'dart:async';
import 'dart:math';
import 'package:FlutterBluetooth/screens/mainPage.dart';
import 'package:flutter/foundation.dart';

import 'package:page_transition/page_transition.dart';
 
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';

 
///Class to hold data for itembuilder in Intro app.
class ItemData {
  final Color color;
  final Color modalColor;
  final String image;
  final String text1;
  final String text2;
  final String text3;

  ItemData(this.color, this.modalColor, this.image, this.text1, this.text2,
      this.text3);
}

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  _Intro createState() => _Intro();
}

class _Intro extends State<Intro> with TickerProviderStateMixin {
  int page = 0;
  late LiquidController liquidController;

  late Animation<double> animation;
  late AnimationController controller;

  double radius = 0;
  late Animation<double> circleAnimation;
  late AnimationController circleController;

  late UpdateType updateType;

  List<AndroidBluetoothLack> _blueLack = [];

  List<ItemData> data = [
    ItemData(const Color(0xFF83BCFF), Colors.white, "./assets/earbuds.png",
        "Let's Get Started", "Find your missing device with this app", ""),
    ItemData(const Color(0xFF007EA7), Colors.white, "./assets/headphone.png",
        "Turn on Bluetooth and Location Permission", "Bluetooth", "Location"),
    ItemData(
        const Color(0xFF80CED7),
        Colors.white,
        "./assets/speakers.png",
        "All Set!",
        "Remember to turn off other bluetooth devices which aren't required",
        ""),
  ];

  static final style = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  static final substyle = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.grey[800],
  );
  static final substyle1 = GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    circleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    Tween<double> _linearTween = Tween(begin: 5, end: 15);

    animation = _linearTween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    controller.forward();
    Timer.periodic(const Duration(milliseconds: 2000), androidGetBlueLack);

    Tween<double> _circleTween = Tween(begin: 0, end: 500);

    circleAnimation = _circleTween.animate(circleController);
  }

  void androidGetBlueLack(timer) {
    FlutterBlueElves.instance.androidCheckBlueLackWhat().then((values) {
      setState(() {
        _blueLack = values;
      });
    });
  }

  @override
  void dispose() {
    circleController.dispose();
    controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page) - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return SizedBox(
      width: 25.0,
      child: Center(
        child: Material(
          color: Colors.black,
          type: MaterialType.circle,
          child: SizedBox(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  bool val = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CustomPaint(
          foregroundPainter: ShapePainter(circleAnimation.value),
          child: Stack(
            children: <Widget>[
              LiquidSwipe.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  if (index == 2) {
                    if (_blueLack
                            .contains(AndroidBluetoothLack.bluetoothFunction) ||
                        (_blueLack
                            .contains(AndroidBluetoothLack.locationFunction) || _blueLack.contains(AndroidBluetoothLack.locationPermission))) {
                      index = 1;
                    }
                  }
                  return Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        color: data[index].color,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Stack(
                              children: [
                                Positioned(
                                  left: 20,
                                  top: 0,
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width * 0.7,
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(500),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  top: 60,
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.width * 0.6,
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(500),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  data[index].image,
                                  width: MediaQuery.of(context).size.width,
                                  height: 400,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.4,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(70.0),
                                topLeft: Radius.circular(70.0)),
                            color: data[index].modalColor,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20.0,
                                      left: 20,
                                      right: 20,
                                      bottom: 10),
                                  child: Text(
                                    data[index].text1,
                                    style: substyle,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: index == 1
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1.5),
                                            borderRadius: const BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                data[index].text2,
                                                style: substyle,
                                              ),
                                              Switch(
                                                  value: _blueLack.contains(
                                                          AndroidBluetoothLack
                                                              .bluetoothFunction)
                                                      ? false
                                                      : true,
                                                  onChanged: (value) {
                                                    if (_blueLack.contains(
                                                        AndroidBluetoothLack
                                                            .bluetoothFunction)) {
                                                      FlutterBlueElves.instance
                                                          .androidOpenBluetoothService(
                                                              (isOk) {
                                                        if (kDebugMode) {
                                                          print(isOk
                                                            ? "User agrees to grant location permission"
                                                            : "User does not agree to grant location permission");
                                                        }
                                                      });
                                                    }
                                                  }),
                                            ],
                                          ),
                                        )
                                      : Text(
                                          data[index].text2,
                                          style: substyle,
                                        ),
                                ),
                                index == 0
                                    ? Center(
                                        child: Container(
                                            margin: const EdgeInsets.only(top: 20),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.13,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: const Color(0xFF83BCFF)),
                                            child: Center(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                    Icons.arrow_back_ios),
                                                SizedBox(
                                                    width: animation.value),
                                                const Text(
                                                  "Swipe",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ))))
                                    : index == 2
                                        ? Container()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            child: index == 1
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 10),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color:
                                                              Colors.grey[300]!,
                                                          width: 1.5),
                                                      borderRadius:
                                                          const BorderRadius.all(
                                                              Radius.circular(
                                                                  8)),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          data[index].text3,
                                                          style:substyle,
                                                        ),
                                                        Switch(
                                                            value: (_blueLack.contains(
                                                                    AndroidBluetoothLack
                                                                        .locationFunction)||_blueLack.contains(
                                                                    AndroidBluetoothLack
                                                                        .locationPermission))
                                                                ? false
                                                                : true,
                                                            onChanged: (value) {
                                                              if (_blueLack.contains(
                                                                  AndroidBluetoothLack
                                                                      .locationPermission)) {
                                                                FlutterBlueElves
                                                                    .instance
                                                                    .androidOpenLocationService(
                                                                        (isOk) {
                                                                  if (kDebugMode) {
                                                                    print(isOk
                                                                      ? "User agrees to grant location permission"
                                                                      : "User does not agree to grant location permission");
                                                                  }
                                                                });
                                                              }
                                                            }),
                                                      ],
                                                    ),
                                                  )
                                                : Text(
                                                    data[index].text3,
                                                    style: substyle,
                                                  ),
                                          ),
                                index==1?Center(child: Text('( Settings > Location > App Permissions )',style: GoogleFonts.roboto(fontSize:15,fontWeight: FontWeight.w500),)):Container(),
                                index == 2
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 18.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              val = true;
                                              circleController =
                                                  AnimationController(
                                                      vsync: this,
                                                      duration: const Duration(
                                                          milliseconds:500));
                                              Tween<double> _circleTween =
                                                  Tween(
                                                      begin: 0,
                                                      end:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height);
                                              circleAnimation = _circleTween
                                                  .animate(circleController)
                                                ..addListener(() {
                                                  setState(() {});
                                                })
                                                ..addStatusListener((status) {
                                                  if (status ==
                                                      AnimationStatus
                                                          .completed) {
                                                    Navigator.pushReplacement(
                                                        context,
                                                        PageTransition(type:PageTransitionType.fade,duration: const Duration(milliseconds: 1000),child: const MainPage()));
                                                  }
                                                });
                                              circleController.forward();
                                            });
                                          },
                                          child: Center(
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.13,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: const Color(0xFF80CED7)),
                                              child: const Center(
                                                  child: Text(
                                                'Search Bluetooth Devices',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const Text(""),
                                index == 1
                                    ? const SizedBox(
                                        height: 10,
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                positionSlideIcon: 0.7,
                slideIconWidget: page==2?null:const Icon(Icons.arrow_back_ios),
                onPageChangeCallback: pageChangeCallback,
                waveType: WaveType.liquidReveal,
                liquidController: liquidController,
                fullTransitionValue: 880,
                enableSideReveal: false,
                enableLoop: false,
                ignoreUserGestureWhileAnimating: true,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    const Expanded(child: SizedBox()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(data.length, _buildDot),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  pageChangeCallback(int lpage) {
    if ((_blueLack.contains(AndroidBluetoothLack.bluetoothFunction) ||
            _blueLack.contains(AndroidBluetoothLack.locationFunction) || _blueLack.contains(AndroidBluetoothLack.locationPermission)) &&
        lpage == 2) {
      return;
    }
    setState(() {
      page = lpage;
    });
  }
}

class ShapePainter extends CustomPainter {
  final double radius;
  ShapePainter(this.radius);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFF80CED7)
      ..strokeWidth = 5
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 1.1);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
