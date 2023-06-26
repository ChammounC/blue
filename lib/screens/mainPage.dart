import 'dart:async';
import 'dart:ui';
import 'dart:math';

import '../services/sendMail.dart';
import 'starter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../constants/colorConstant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {

  late SharedPreferences prefs;
  TextEditingController renameController = TextEditingController();

  List<AndroidBluetoothLack> _blueLack = [];
  final IosBluetoothState _iosBlueState = IosBluetoothState.unKnown;
  List<ScanResult> _scanResultList = [];
  List<HideConnectedDevice> _hideConnectedList = [];
  final List<_ConnectedItem> _connectedList = [];

  bool _isScanning = false;
  bool showScan = false;
  int randomNumber1 = 0;
  int randomNumber2 = 0;
  String text = "Tap Search";

  bool showRadar = true;
  bool feedbackActive = false;
  bool feedbackDone = false;
  bool off = false;
  bool showLoader = false;
  bool renameError=false;

  late double _radius;
  double rating1 = 0;
  double rating2 = 0;
  double rating3 = 0;

  int _current = 0;

  final List<String> imgList = [
    './assets/banner/banner1.png',
    './assets/banner/banner2.png',
    './assets/banner/banner3.png',
  ];

  final Uri _url = Uri.parse('https://github.com/ChammounC');

  late Animation<double> animation;
  late AnimationController controller;

  late Animation<double> circleAnimation;
  late AnimationController circleController;

  @override
  void initState() {
    _radius = (window.physicalSize.shortestSide / window.devicePixelRatio)/2;
    _sharedStarter();
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    Tween<double> _rotationTween = Tween(begin: -math.pi, end: math.pi);

    animation = _rotationTween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    controller.forward();
    Timer.periodic(const Duration(milliseconds: 2000), androidGetBlueLack);
    getHideConnectedDevice();

    //Uncover Screen
    circleController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    Tween<double> _circleTween = Tween(begin: 1000, end: 0);
    circleAnimation = _circleTween.animate(circleController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          showRadar = false;
        }
      });
    circleController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    renameController.dispose();
    super.dispose();
  }

  _sharedStarter() async {
    prefs = await SharedPreferences.getInstance();
  }

  void androidGetBlueLack(timer) {
    FlutterBlueElves.instance.androidCheckBlueLackWhat().then((values) {
      setState(() {
        _blueLack = values;
      });
    });
  }

  void getHideConnectedDevice() {
    FlutterBlueElves.instance.getHideConnectedDevices().then((values) {
      setState(() {
        _hideConnectedList = values;
      });
    });
  }

  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        body: showRadar
            ? CustomPaint(
            foregroundPainter: ShapePainter(circleAnimation.value),
            child: Container())
            :
        SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                        width: size.width,
                        height: size.height * 0.15,
                        decoration:const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.elliptical(100, 50),
                              bottomRight: Radius.elliptical(100, 50),
                              bottomLeft: Radius.elliptical(40, 20),
                              topRight: Radius.elliptical(40, 20)),
                        ),
                        child: Center(
                          child: SizedBox(
                            height: size.height * 0.15,
                            width: size.width,
                            child: Center(
                              child: GestureDetector(
                                  onTap: _launchUrl,
                                  child: CarouselSlider(
                                      items: imgList
                                          .map((item) => Center(
                                          child: Image.asset(
                                            item,
                                            fit: BoxFit.cover,
                                            width: size.width,
                                            height: size.height * 0.15,
                                          )))
                                          .toList(),
                                      options: CarouselOptions(
                                        height: size.height * 0.15,
                                        aspectRatio: 16 / 9,
                                        viewportFraction: 1,
                                        initialPage: 0,
                                        enableInfiniteScroll: true,
                                        reverse: false,
                                        autoPlay: true,
                                        autoPlayInterval: const Duration(seconds: 3),
                                        autoPlayAnimationDuration:
                                        const Duration(milliseconds: 800),
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                        enlargeCenterPage: false,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _current = index;
                                          });
                                        },
                                        scrollDirection: Axis.horizontal,
                                      ))),
                            ),
                          ),
                        )),
                  ],
                ),
                SizedBox(height: size.height*0.07),
                Text(
                  text,
                  style: GoogleFonts.roboto(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: size.height*0.07),
                SizedBox(
                  height: size.width,
                  width: size.width,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      CustomPaint(
                        foregroundPainter: _isScanning
                            ? PointPainter(_radius, animation.value)
                            : null,
                        painter: CirclePainter(_radius),
                        child: Container(),
                      ),
                      Positioned(
                        // top:10,
                        left: size.width / 3,
                        right: size.width / 3,
                        // bottom:10,
                        child: GestureDetector(
                          onTap: () {},
                          child: Column(
                            children: [
                              AnimatedContainer(
                                  duration: const Duration(seconds: 5),
                                  curve: Curves.bounceIn,
                                  height: 50,
                                  padding: const EdgeInsets.all(3),
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(50),
                                      color: Colors.white),
                                  child:
                                  Image.asset('assets/smartphone.png')),
                            ],
                          ),
                        ),
                      ),
                      _scanResultList.isEmpty
                          ? Container()
                          : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                        (_hideConnectedList.isNotEmpty
                            ? _hideConnectedList.length + 1
                            : 0) +
                            (_scanResultList.isNotEmpty
                                ? _scanResultList.length + 1
                                : 0),
                        itemBuilder:
                            (BuildContext context, int index) {
                          int scanStartIndex = 0+
                              (_hideConnectedList.isNotEmpty
                                  ? _hideConnectedList.length + 1
                                  : 0);
                          if (index == scanStartIndex) {
                            return Container();
                          } else {
                            ScanResult currentScan =
                            _scanResultList[index - 1];
                            return GestureDetector(
                              onTap: _blueLack.isNotEmpty
                                  ? null
                                  : _isScanning
                                  ? null
                                  : () {
                                Device toConnectDevice =
                                currentScan.connect(
                                    connectTimeout:
                                    10000);
                                setState(() {
                                  showScan = false;
                                  _connectedList.insert(
                                      0,
                                      _ConnectedItem(
                                          toConnectDevice,
                                          currentScan
                                              .macAddress,
                                          currentScan
                                              .name));
                                  _scanResultList.clear();
                                });
                                showModalBottomSheet(
                                    shape:
                                    const RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.only(
                                          topRight: Radius
                                              .circular(
                                              25),
                                          topLeft: Radius
                                              .circular(
                                              25)),
                                    ),
                                    isDismissible: false,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      _ConnectedItem
                                      currentConnected =
                                      _connectedList[
                                      index - 1];
                                      return WillPopScope(
                                        onWillPop:
                                            () async =>
                                        false,
                                        child: Container(
                                          decoration:
                                          const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius
                                                    .circular(
                                                    10),
                                                topRight: Radius
                                                    .circular(
                                                    10)),
                                          ),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .all(
                                                10),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceEvenly,
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .center,
                                              children: [
                                                GestureDetector(
                                                    onTap:
                                                        () {
                                                      if (_scanResultList
                                                          .isEmpty) {
                                                        text =
                                                        "Tap Search";
                                                      }
                                                      currentConnected
                                                          ._device
                                                          .disConnect();
                                                      currentConnected
                                                          ._device
                                                          .destroy();
                                                      if (!prefs
                                                          .containsKey('feedback')) {
                                                        feedbackActive =
                                                        true;
                                                      }
                                                      Navigator.pop(
                                                          context);
                                                      if (feedbackActive) {
                                                        feedbackForm(size:size);
                                                      }
                                                    },
                                                    child:
                                                    Container(
                                                      height:
                                                      MediaQuery.of(context).size.width * 0.15,
                                                      width:
                                                      MediaQuery.of(context).size.width * 0.4,
                                                      decoration: const BoxDecoration(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          color: AppColors.radarBackgroundOuter),
                                                      child:
                                                      Center(
                                                        child:
                                                        Text(
                                                          'Disconnect',
                                                          style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500),
                                                        ),
                                                      ),
                                                    )),
                                                SizedBox(
                                                    height: size.height *
                                                        0.12,
                                                    child: Image.asset(
                                                        './assets/headset.png')),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    Text(
                                                      prefs.getString(currentConnected._macAddress.toString()) ??
                                                          currentConnected._name ??
                                                          currentConnected._macAddress!,
                                                      style: GoogleFonts.roboto(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w500),
                                                    ),
                                                    const SizedBox(
                                                        width:
                                                        10),
                                                    GestureDetector(
                                                        onTap:
                                                            () {
                                                          // Navigator.push(context,MaterialPageRoute(builder: (_)=>DeviceControl(currentScan.name, currentScan.macAddress, toConnectDevice)));
                                                          showDialog<String>(
                                                            context: context,
                                                            builder: (BuildContext context) => StatefulBuilder(
                                                              builder: (context, setState) => SizedBox(
                                                                height: size.height * 0.07,
                                                                width: size.width * 0.7,
                                                                child: AlertDialog(
                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                                  insetPadding: const EdgeInsets.all(5),
                                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                                                                  title: Padding(
                                                                    padding: const EdgeInsets.only(left: 15, bottom: 25),
                                                                    child: Text(
                                                                      'Rename Device',
                                                                      style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
                                                                    ),
                                                                  ),
                                                                  content: Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                                                    child: SizedBox(
                                                                      height: size.height * 0.07,
                                                                      width: size.width * 0.7,
                                                                      child: Column(
                                                                        children: [
                                                                          Container(
                                                                            width: size.width * 0.6,
                                                                            height: 50,
                                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                            decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.all(Radius.circular(13.0)), border: Border.all(color: renameError?Colors.red:AppColors.radarBackgroundInner)),
                                                                            child: MediaQuery(
                                                                              data: MediaQuery.of(context).copyWith(
                                                                                textScaleFactor: 1.0,
                                                                              ),
                                                                              child: TextFormField(
                                                                                onTap: () {
                                                                                  // setState(
                                                                                  //     () {});
                                                                                },
                                                                                keyboardType: TextInputType.name,
                                                                                controller: renameController,
                                                                                style: GoogleFonts.roboto(
                                                                                  fontSize: 16,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                                decoration: InputDecoration(
                                                                                  border: InputBorder.none,
                                                                                  hintText: "Enter Here",
                                                                                  hintStyle: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[400], fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:() {
                                                                            setState(() {
                                                                              if(renameController.text.isEmpty){
                                                                                renameError=true;
                                                                              }else {
                                                                                prefs
                                                                                    .setString(
                                                                                    currentConnected
                                                                                        ._macAddress
                                                                                        .toString(),
                                                                                    renameController
                                                                                        .text);
                                                                                renameController
                                                                                    .clear();
                                                                                Navigator
                                                                                    .pop(
                                                                                    context);
                                                                              }
                                                                            });
                                                                          },
                                                                          child: Container(
                                                                            height: size.width * 0.1,
                                                                            width: size.width * 0.3,
                                                                            margin: const EdgeInsets.symmetric(vertical: 10),
                                                                            decoration: const BoxDecoration(color: AppColors.radarBackgroundOuter, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                                            child: Center(
                                                                              child: Text(
                                                                                "Rename",
                                                                                textScaleFactor: 1.0,
                                                                                style: GoogleFonts.roboto(
                                                                                  fontSize: 14,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.w400,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width: 25,
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap: () {
                                                                            setState(() {
                                                                              renameController.clear();
                                                                              Navigator.pop(context);
                                                                            });
                                                                          },
                                                                          child: Container(
                                                                            height: size.width * 0.1,
                                                                            width: size.width * 0.3,
                                                                            margin: const EdgeInsets.symmetric(vertical: 10),
                                                                            decoration: const BoxDecoration(color: AppColors.radarBackgroundOuter, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                                            child: Center(
                                                                              child: Text(
                                                                                "Cancel",
                                                                                textScaleFactor: 1.0,
                                                                                style: GoogleFonts.roboto(
                                                                                  fontSize: 14,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.w400,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child:
                                                        const Icon(
                                                          Icons.edit,
                                                          color: AppColors.radarBackgroundInner,
                                                        )),
                                                  ],
                                                ),
                                                StreamBuilder<
                                                    DeviceState>(
                                                    initialData:
                                                    DeviceState
                                                        .connected,
                                                    stream: currentConnected
                                                        ._device
                                                        .stateStream,
                                                    builder: (BuildContext
                                                    context,
                                                        AsyncSnapshot<DeviceState>
                                                        snapshot) {
                                                      DeviceState? currentState = snapshot.connectionState == ConnectionState.active
                                                          ? snapshot.data
                                                          : currentConnected._device.state;
                                                      if (currentState == DeviceState.connected &&
                                                          !currentConnected._device.isWatchingRssi) {
                                                        currentConnected._device.startWatchRssi();
                                                      }
                                                      return Text("Within " +
                                                          pow(10, (-69 - currentConnected._device.rssi) / 40).toStringAsFixed(1) +
                                                          " metres");
                                                    }),
                                                // Text(currentConnected._device.),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Column(
                                children: [
                                  index == 4
                                      ? SizedBox(height: size.height*0.05)
                                      : Container(),
                                  AnimatedContainer(
                                      duration: const Duration(seconds: 1),
                                      curve: Curves.elasticIn,
                                      height: 40,
                                      padding: const EdgeInsets.all(3),
                                      width: 40,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(
                                              50),
                                          color: Colors.white),
                                      child: Image.asset(
                                          'assets/headset.png')),
                                  Text(
                                    prefs.getString(currentScan
                                        .macAddress
                                        .toString()) ??
                                        currentScan.name ??
                                        currentScan.macAddress
                                            .toString(),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor:
          _isScanning ? Colors.red : AppColors.radarBackgroundInner,
          onPressed: () {
            if (_blueLack.contains(AndroidBluetoothLack.locationFunction)) {
              Fluttertoast.showToast(msg: "Looks like Location is OFF");
            } else if (_blueLack
                .contains(AndroidBluetoothLack.locationPermission)) {
              Fluttertoast.showToast(
                  msg:
                  "Looks like Location Permission for this app wasn't provided");
            } else if (_blueLack
                .contains(AndroidBluetoothLack.bluetoothFunction)) {
              Fluttertoast.showToast(msg: "Looks like Bluetooth is OFF");
            }

            if ((Platform.isAndroid && _blueLack.isEmpty) ||
                (Platform.isIOS &&
                    _iosBlueState == IosBluetoothState.poweredOn)) {
              if (_isScanning) {
                FlutterBlueElves.instance.stopScan();
              } else {
                _scanResultList = [];
                setState(() {
                  showScan = true;
                  text = "Searching Devices";
                  _isScanning = true;
                });
                FlutterBlueElves.instance.startScan(5000).listen((event) {
                  setState(() {
                    _scanResultList.insert(0, event);
                  });
                }).onDone(() {
                  setState(() {
                    text = "Search Complete";
                    _isScanning = false;
                  });
                });
              }
            }
          },
          tooltip: 'scan',
          child: Icon(
            _isScanning ? Icons.stop : Icons.find_replace,
            color: Colors.black,
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  feedbackForm({required Size size}){
    rating1 =
    3;
    rating2 =
    3;
    rating3 =
    3;
    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) => SizedBox(
          height: feedbackDone ? size.height * 0.1 : size.height * 0.4,
          width: size.width * 0.7,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.all(5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            title: Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 15),
              child: feedbackDone
                  ? null
                  : Text(
                'FeedBack Form',
                style: GoogleFonts.pacifico(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: SizedBox(
                height: feedbackDone ? size.height * 0.12 : size.height * 0.4,
                width: size.width * 0.7,
                child: feedbackDone
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      './assets/thankyou.png',
                      height: 50,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Thank you for your feedback!',
                      style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Your opinion is important to us. This way we can keep improving our app',
                        style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 15, bottom: 8),
                      child: Text(
                        'How Satisfied are you with the app design?',
                        style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                    RatingStars(
                      value: rating1,
                      onValueChanged: (v) {
                        //
                        setState(() {
                          rating1 = v;
                        });
                      },
                      starBuilder: (index, color) => Icon(
                        Icons.star,
                        color: color,
                      ),
                      starCount: 5,
                      starSize: 40,
                      valueLabelColor: const Color(0xff9b9b9b),
                      valueLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 12.0),
                      valueLabelRadius: 10,
                      maxValue: 5,
                      starSpacing: 2,
                      maxValueVisibility: true,
                      valueLabelVisibility: false,
                      animationDuration: const Duration(milliseconds: 500),
                      valueLabelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                      valueLabelMargin: const EdgeInsets.only(right: 8),
                      starOffColor: const Color(0xffe7e8ea),
                      starColor: AppColors.radarBackgroundInner,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 15, bottom: 8),
                      child: Text(
                        'How satisfied are you with the features of the app?',
                        style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                    RatingStars(
                      value: rating2,
                      onValueChanged: (v) {
                        //
                        setState(() {
                          rating2 = v;
                        });
                      },
                      starBuilder: (index, color) => Icon(
                        Icons.star,
                        color: color,
                      ),
                      starCount: 5,
                      starSize: 40,
                      valueLabelColor: const Color(0xff9b9b9b),
                      valueLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 12.0),
                      valueLabelRadius: 10,
                      maxValue: 5,
                      starSpacing: 2,
                      maxValueVisibility: true,
                      valueLabelVisibility: false,
                      animationDuration: const Duration(milliseconds: 500),
                      valueLabelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                      valueLabelMargin: const EdgeInsets.only(right: 8),
                      starOffColor: const Color(0xffe7e8ea),
                      starColor: AppColors.radarBackgroundInner,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 15, bottom: 8),
                      child: Text(
                        'How likely are you to recommend this app to your friends and families?',
                        style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                    RatingStars(
                      value: rating3,
                      onValueChanged: (v) {
                        //
                        setState(() {
                          rating3 = v;
                        });
                      },
                      starBuilder: (index, color) => Icon(
                        Icons.star,
                        color: color,
                      ),
                      starCount: 5,
                      starSize: 40,
                      valueLabelColor: const Color(0xff9b9b9b),
                      valueLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 12.0),
                      valueLabelRadius: 10,
                      maxValue: 5,
                      starSpacing: 2,
                      maxValueVisibility: true,
                      valueLabelVisibility: false,
                      animationDuration: const Duration(milliseconds: 500),
                      valueLabelPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                      valueLabelMargin: const EdgeInsets.only(right: 8),
                      starOffColor: const Color(0xffe7e8ea),
                      starColor: AppColors.radarBackgroundInner,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              feedbackDone
                  ? Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      feedbackActive = false;
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: size.width * 0.12,
                    width: size.width * 0.35,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(color: AppColors.radarBackgroundOuter, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: Center(
                      child: Text(
                        "Done",
                        textScaleFactor: 1.0,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  : Center(
                child: GestureDetector(
                  onTap: showLoader
                      ? null
                      : () async {
                    setState(() {
                      showLoader = true;
                    });
                    // await sendEmail(
                    //   email: " Email: ${prefs.getString('email')}",
                    //   message: 'FeedBack => How Satisfied are you with the app design? : $rating1, How satisfied are you with the features of the app? : $rating2, How likely are you to recommend this app to your friends and families? : $rating3',
                    //   name: "Name: ${prefs.getString('name')}",
                    //   number: "",
                    //   subject: 'Blue - New User Feedback',
                    // );
                    setState((){
                      prefs.setString('feedback', 'done');
                      feedbackDone = true;
                    });
                  },
                  child: Container(
                    height: size.width * 0.14,
                    width: size.width * 0.35,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(color: AppColors.radarBackgroundOuter, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    child: Center(
                      child: showLoader
                          ? const CircularProgressIndicator(
                        color: AppColors.radar,
                      )
                          : Text(
                        "SUBMIT",
                        textScaleFactor: 1.0,
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _ConnectedItem {
  final Device _device;
  final String? _macAddress;
  final String? _name;

  _ConnectedItem(this._device, this._macAddress, this._name);
}

class CirclePainter extends CustomPainter {
  final double radius;
  CirclePainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColors.radarBackgroundOuter
      ..strokeWidth = 3
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var paint1 = Paint()
      ..color = const Color(0xFFd2f0f7)
      ..strokeWidth = 2
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var paint2 = Paint()
      ..color = AppColors.radarBackgroundInner
      ..strokeWidth = 2
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    var path = Path();
    path.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    ));

    var path1 = Path();
    path1.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius * 0.7,
    ));

    var path2 = Path();
    path2.addOval(Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius * 0.35,
    ));

    canvas.drawPath(path, paint);
    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// FOR PAINTING THE TRACKING POINT
class PointPainter extends CustomPainter {
  final double radius;
  final double radians;

  PointPainter(this.radius, this.radians);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 8
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(colors: [
        AppColors.radarBackgroundInner.withOpacity(1.0),
        AppColors.radarBackgroundOuter.withOpacity(0.1)
      ]).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius))
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.colorBurn;

    Offset center = Offset(size.width / 2, size.height / 2);

    var path = Path();
    path.addOval(Rect.fromCircle(
      center: center,
      radius: radius,
    ));

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians * 2.5, //radians
        radians * 0.8, //radians
        true,
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
