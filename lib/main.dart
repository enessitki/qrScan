import 'dart:async';
import 'dart:io';

import 'package:QRScan/theme/colors/light_colors.dart';
import 'package:QRScan/widgets/top_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _scanBarcode = 'Henüz bir şey taranmadı.';

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "İptal", true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(body: Builder(builder: (BuildContext context) {
      return Container(
          alignment: Alignment.center,
          child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TopContainer(
                  height: 200,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FloatingActionButton(
                              onPressed: () => exit(0),
                              tooltip: 'Çıkış',
                              backgroundColor: Colors.redAccent,
                              child: new Icon(Icons.close),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              CircularPercentIndicator(
                                radius: 90.0,
                                lineWidth: 5.0,
                                animation: true,
                                percent: 0.75,
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: LightColors.kRed,
                                backgroundColor: LightColors.kDarkYellow,
                                center: CircleAvatar(
                                    backgroundColor: LightColors.kBlue,
                                    radius: 35.0,
                                    backgroundImage:
                                        AssetImage('assets/images/avatar.png')),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      'Qr Kod',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        color: LightColors.kDarkBlue,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      'Developed by Enes',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                ),
                FloatingActionButton.extended(
                  icon: Icon(Icons.camera),
                  label: Text('Taramak İçin Tıkla!'),
                  elevation: 20.0,
                  backgroundColor: LightColors.kDarkYellow,
                  onPressed: () => scanQR(),
                ),
                Padding(
                  padding: EdgeInsets.all(7.0),
                ),
                FloatingActionButton.extended(
                  icon: Icon(Icons.navigate_next),
                  label: Text('Siteye Git!'),
                  elevation: 20.0,
                  backgroundColor: LightColors.kDarkYellow,
                  onPressed: () {
                    if (_scanBarcode == "-1") {
                      AlertDialog alertDialog = new AlertDialog(
                        title: Text("Hatalı Tarama"),
                        content: Text("Taradığınız kodda web uzantısı yok!"),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text("Tamam"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                      showDialog(context: context, builder: (_) => alertDialog);
                    } else {
                      String result = _scanBarcode.substring(0, 4);
                      if (result != "http") {
                        AlertDialog alertDialog = new AlertDialog(
                          title: Text("Hatalı Tarama"),
                          content: Text("Taradığınız kodda web uzantısı yok!"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("Tamam"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                        showDialog(
                            context: context, builder: (_) => alertDialog);
                      } else {
                        _launchURL(_scanBarcode);
                      }
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(40.0),
                ),
                Text('Taranan uzantı :\n',
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: "Agne",
                        color: LightColors.kDarkYellow)),
                SizedBox(
                  width: 300.0,
                  child: TypewriterAnimatedTextKit(
                    text: [
                      "$_scanBarcode",
                    ],
                    textStyle: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Agne",
                        color: LightColors.kDarkYellow),
                    textAlign: TextAlign.center,
                  ),
                )
              ]));
    })));
  }

  _launchURL(String barcode) async {
    String url = barcode;
    if (url != "Henüz bir şey taranmadı." || url != "-1") {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
}
