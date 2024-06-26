import 'package:flutter/material.dart';
import 'package:polar/polar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String identifier = 'C0680226';
  final Polar polar = Polar();
  String heartRateText = 'Waiting for data...';
  String ecgText = 'Waiting for data...';
  String accText = 'Waiting for data...';

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  void connectToDevice() {
    polar.connectToDevice(identifier);
    streamWhenReady();
  }

  void streamWhenReady() async {
    await polar.sdkFeatureReady.firstWhere(
          (e) => e.identifier == identifier && e.feature == PolarSdkFeature.onlineStreaming,
    );

    polar.startHrStreaming(identifier).listen((hrData) {
      final hr = hrData.samples[0];
      final rrRhs = hrData.samples[1];
      setState(() {
        heartRateText = 'Heart Rate: $hr, rrRHS: $rrRhs';
      });
    });

    polar.startEcgStreaming(identifier).listen((ecgData) {
      final ecgValue = ecgData.samples; // ECG data as a list of integers
      setState(() {
        ecgText = 'ECG Data: $ecgValue';
      });
    });

    polar.startAccStreaming(identifier).listen((accData) {
      final accX = accData.samples[0];
      final accY = accData.samples[1];
      final accZ = accData.samples[2];
      setState(() {
        accText = 'Accelerometer Data: X=${int.parse(accX.toString()) * 1000}, Y=${int.parse(accY.toString()) * 1000}, Z=${int.parse(accZ.toString()) * 1000}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Polar H10 Data Monitor')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(heartRateText),
              Text(ecgText),
              Text(accText),
            ],
          ),
        ),
      ),
    );
  }
}
