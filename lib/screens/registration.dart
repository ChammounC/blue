import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'intro.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colorConstant.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> with TickerProviderStateMixin {
  late SharedPreferences prefs;
  late Animation<double> animation;
  late AnimationController controller;
  List<bool> val = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  final List<String> imgList = [
    './assets/banner/banner1.png',
    './assets/banner/banner2.png',
    './assets/banner/banner3.png',
  ];

  List<String> products = [];
  bool terms = false;
  bool formDone = false;
  bool emailValid = true;
  bool nameValid = true;
  bool numberValid = true;
  bool showLoader = false;

  int _current = 0;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  final Uri _url = Uri.parse('https://github.com/ChammounC');

  @override
  void initState() {
    _sharedStarter();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 5000));

    Tween<double> _linearTween = Tween(begin: 0, end: 1000);

    animation = _linearTween.animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _sharedStarter() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        setState(() {
          nameValid =
              nameController.text.length >2 ||
                  nameController.text.isEmpty;
          emailValid = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(emailController.text) || emailController.text.isEmpty;
          numberValid = numberController
              .text.length >
              7 ||
              numberController.text.isEmpty;
        });
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFF83BCCC),
        body: formDone
            ? CustomPaint(
                foregroundPainter: ShapePainter(animation.value),
              )
            : SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        width: size.width,
                        height: size.height * 0.15,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
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
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: SizedBox(
                        height: size.height * 0.7,
                        width: size.width * 0.8,
                        child: Material(
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                          elevation: 10,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Text(
                                          'Registration Form',
                                          style: GoogleFonts.pacifico(
                                              fontSize: 20,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        )),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: RichText(
                                          text: TextSpan(
                                              text: 'Full Name',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                              children: [
                                            TextSpan(
                                              text: " *",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ]))),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    // width: size.width * 0.6,
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(13.0)),
                                        border: Border.all(
                                            color: nameValid
                                                ? AppColors.radarBackgroundInner
                                                : Colors.red)),
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        textScaleFactor: 1.0,
                                      ),
                                      child: TextFormField(
                                        onTap: () {
                                          setState(() {
                                            numberValid = numberController
                                                        .text.length >
                                                    7 ||
                                                numberController.text.isEmpty;
                                            nameValid =
                                                nameController.text.length >2 ||
                                                    nameController.text.isEmpty;
                                            emailValid =
                                                RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                        .hasMatch(
                                                            emailController
                                                                .text) ||
                                                    emailController
                                                        .text.isEmpty;
                                          });
                                        },
                                        keyboardType: TextInputType.name,
                                        controller: nameController,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Enter Name",
                                          hintStyle: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: Colors.grey[400],
                                              fontWeight: FontWeight.w300,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: RichText(
                                          text: TextSpan(
                                              text: 'Email',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                              children: [
                                            TextSpan(
                                              text: " *",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ]))),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(13.0)),
                                        border: Border.all(
                                            color: emailValid
                                                ? AppColors.radarBackgroundInner
                                                : Colors.red)),
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        textScaleFactor: 1.0,
                                      ),
                                      child: TextFormField(
                                        onTap: () {
                                          setState(() {
                                            numberValid = numberController
                                                        .text.length >
                                                    7 ||
                                                numberController.text.isEmpty;
                                            nameValid =
                                                nameController.text.length >2 ||
                                                    nameController.text.isEmpty;
                                            emailValid =
                                                RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                        .hasMatch(
                                                            emailController
                                                                .text) ||
                                                    emailController
                                                        .text.isEmpty;
                                          });
                                        },
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        controller: emailController,
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Enter Email",
                                          hintStyle: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: Colors.grey[400],
                                              fontWeight: FontWeight.w300,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: RichText(
                                          text: TextSpan(
                                              text: 'Phone Number',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                              children: [
                                            TextSpan(
                                              text: " *",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ]))),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    // width: size.width * 0.6,
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(13.0)),
                                        border: Border.all(
                                            color: numberValid
                                                ? AppColors.radarBackgroundInner
                                                : Colors.red)),
                                    child: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        textScaleFactor: 1.0,
                                      ),
                                      child: TextFormField(
                                        onTap: () {
                                          setState(() {
                                            numberValid = numberController
                                                .text.length >
                                                7 ||
                                                numberController.text.isEmpty;
                                            nameValid =
                                                nameController.text.length >2 ||
                                                    nameController.text.isEmpty;
                                            emailValid =
                                                RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                    .hasMatch(
                                                    emailController
                                                        .text) ||
                                                    emailController
                                                        .text.isEmpty;
                                          });
                                        },
                                        keyboardType: TextInputType.number,
                                        controller: numberController,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(15),
                                        ],
                                        style: GoogleFonts.roboto(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Enter Number",
                                          hintStyle: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: Colors.grey[400],
                                              fontWeight: FontWeight.w300,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'Which Samsung products have you used before?',
                                        style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400),
                                      )),
                                  checkers(),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ExpansionTile(
                                      collapsedBackgroundColor:
                                          AppColors.radarBackgroundOuter,
                                      title: const Text("Terms and Conditions"),
                                      children: [
                                        Text(
                                          "The term 'us' or 'we' refers to the owner of the app. The term 'you' refers to the user or viewer of our app.The use of this app is subject to the following terms of use:",
                                          textAlign: TextAlign.justify,
                                          style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          "Your use of any information or materials on this app is entirely at your own risk, for which we shall not be liable. It shall be your own responsibility to ensure that any products, services, or information available through this app meet your specific requirements.",
                                          textAlign: TextAlign.justify,
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          "This app contains material which is owned by or licensed to us. This material includes, but is not limited to, the design, layout, look, appearance, and graphics.",
                                          textAlign: TextAlign.justify,
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ExpansionTile(
                                      collapsedBackgroundColor:
                                          AppColors.radarBackgroundOuter,
                                      title: const Text("Privacy Policy"),
                                      children: [
                                        Text(
                                            "We understand the power that the Internet holds for changing your life and making things easier for you. These benefits are at risk if people are concerned about their personal privacy. We are committed to providing you with an experience that respects and protects your personal privacy choices and concerns. In general, we gather information about all of our users collectively. We only use such information anonymously and in the aggregate. This information helps us determine what is most beneficial for our users, and how we can continually create a better overall experience for you.",
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.roboto(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400)),
                                        const SizedBox(height: 20),
                                        Text(
                                            "This app functionality requires/requests users to grant permission to use the bluetooth and location for the app to work. On the first run, the app would ask the user to give us contact information (such as their email address) and personal information (such as their name). The visitor's contact and personal information is primarily used to collect personal information necessary to effectively market and to sell the products of Samsung to clients and customers. We do not sell, trade, transfer, rent or exchange your personal information with anyone. We do not disclose information about your individual visits to this site, or personal information that you provide, which is your name and e-mail address., to any outside parties, except when we believe the law requires it.",
                                            textAlign: TextAlign.justify,
                                            style: GoogleFonts.roboto(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400)),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Transform.scale(
                                        scale: 1.5,
                                        child: Theme(
                                          data: ThemeData(
                                              unselectedWidgetColor:
                                                  const Color(0xFF83BCFF)),
                                          child: Checkbox(
                                              tristate: false,
                                              activeColor: const Color(0xFF83BCFF),
                                              shape: const CircleBorder(),
                                              value: terms,
                                              onChanged: (value) {
                                                setState(() {
                                                  terms = value!;
                                                });
                                              }),
                                        ),
                                      ),
                                      RichText(
                                          text: TextSpan(
                                              text:
                                                  'I agree to the terms and conditions',
                                              style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400),
                                              children: [
                                            TextSpan(
                                              text: " *",
                                              style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ])),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: GestureDetector(
                                      onTap:
    ()=>{
    Navigator.pushReplacement(
                                          context,
                                          PageTransition(
                                              type:
                                              PageTransitionType
                                                  .fade,
                                              duration: const Duration(
                                                  milliseconds:
                                                  1300),
                                              child:
                                              const Intro())),},
                                      child: Material(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10.0)),
                                        elevation: 5,
                                        child: Container(
                                          height: size.width * 0.1,
                                          width: size.width * 0.4,
                                          decoration: const BoxDecoration(
                                              color: AppColors
                                                  .radarBackgroundOuter,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0))),
                                          child: Center(
                                            child: showLoader
                                                ? const CircularProgressIndicator(
                                                    color: AppColors.radar,
                                                  )
                                                : Text(
                                                    "SUBMIT",
                                                    textScaleFactor: 1.0,
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
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

  Widget checkers() {
    return Column(
      children: [
        check('./assets/registration/c.png', 'CABLES', 0),
        check('./assets/registration/ch.png', 'CHARGER', 1),
        check('./assets/registration/hf.png', 'HANDSFREE', 2),
        check('./assets/registration/hp.png', 'HEADPHONES', 3),
        check('./assets/registration/nb.png', 'NECKBAND', 4),
        check('./assets/registration/eb.png', 'PODS', 5),
        check('./assets/registration/pb.png', 'POWERBANK', 6),
        check('./assets/registration/s.png', 'SPEAKER', 7),
        check('', 'NONE', 8),
      ],
    );
  }

  Widget check(String asset, String text, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
          // color: Colors.grey,
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            asset.isEmpty
                ? Container()
                : SizedBox(
                    height: 40,
                    child: Image.asset(
                      asset,
                      color: Colors.black,
                    )),
            const SizedBox(width: 5),
            Text(
              text,
              style:
                  GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Transform.scale(
              scale: 1.5,
              child: Theme(
                data: ThemeData(unselectedWidgetColor: const Color(0xFF83BCFF)),
                child: Checkbox(
                    tristate: false,
                    activeColor: const Color(0xFF83BCFF),
                    shape: const CircleBorder(),
                    value: val[index],
                    onChanged: (value) {
                      setState(() {
                        val[index] = value!;
                        if (index == 8 && val[index] == true) {
                          products.clear();
                          for (int i = 0; i < 8; i++) {
                            val[i] = false;
                          }
                        } else if (index != 8 && val[index] == true) {
                          products.add(text);
                          val[8] = false;
                        } else if (index != 8 && val[index] == false) {
                          products.remove(text);
                        }
                      });
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
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

