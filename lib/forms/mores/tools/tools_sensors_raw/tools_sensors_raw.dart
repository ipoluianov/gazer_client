import 'dart:async';
import 'dart:convert';

import 'package:environment_sensors/environment_sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/repository.dart';
import '../../more_form/more_button.dart';

class ToolsSensorsRawForm extends StatefulWidget {
  final ToolsFormArgument arg;
  const ToolsSensorsRawForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ToolsSensorsRawFormSt();
  }
}

class ToolsSensorsRawFormSt extends State<ToolsSensorsRawForm> {
  final ScrollController _scrollController = ScrollController();

  late Timer timerUpdate;

  bool _tempAvailable = false;
  bool _humidityAvailable = false;
  bool _lightAvailable = false;
  bool _pressureAvailable = false;
  final environmentSensors = EnvironmentSensors();

  bool _axelAvailable = false;
  bool _gyroAvailable = false;
  bool _magAvailable = false;

  double lastTemperature = 0.0;
  double lastHumidity = 0.0;
  double lastLight = 0.0;
  double lastPressure = 0.0;

  double lastAccelerometerX = 0.0;
  double lastAccelerometerY = 0.0;
  double lastAccelerometerZ = 0.0;

  double lastGyroX = 0.0;
  double lastGyroY = 0.0;
  double lastGyroZ = 0.0;

  double lastMagX = 0.0;
  double lastMagY = 0.0;
  double lastMagZ = 0.0;

  @override
  void initState() {
    super.initState();

    timerUpdate = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      update();
    });

    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool tempAvailable;
    bool humidityAvailable;
    bool lightAvailable;
    bool pressureAvailable;

    tempAvailable = await environmentSensors
        .getSensorAvailable(SensorType.AmbientTemperature);
    humidityAvailable =
        await environmentSensors.getSensorAvailable(SensorType.Humidity);
    lightAvailable =
        await environmentSensors.getSensorAvailable(SensorType.Light);
    pressureAvailable =
        await environmentSensors.getSensorAvailable(SensorType.Pressure);

    environmentSensors.temperature.listen((event) {
      setState(() {
        lastPressure = event;
      });
    });
    environmentSensors.humidity.listen((event) {
      setState(() {
        lastPressure = event;
      });
    });
    environmentSensors.light.listen((event) {
      setState(() {
        lastPressure = event;
      });
    });
    environmentSensors.pressure.listen((event) {
      setState(() {
        lastPressure = event;
      });
    });

    accelerometerEvents.listen(
      (AccelerometerEvent event) {
        setState(() {
          lastAccelerometerX = event.x;
          lastAccelerometerY = event.y;
          lastAccelerometerZ = event.z;
          _axelAvailable = true;
        });
      },
      onError: (error) {
        _axelAvailable = false;
      },
      cancelOnError: true,
    );

    gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        lastGyroX = event.x;
        lastGyroY = event.y;
        lastGyroZ = event.z;
        _gyroAvailable = true;
      },
      onError: (error) {
        _gyroAvailable = false;
      },
      cancelOnError: true,
    );

    magnetometerEvents.listen(
      (MagnetometerEvent event) {
        lastMagX = event.x;
        lastMagY = event.y;
        lastMagZ = event.z;
        _magAvailable = true;
      },
      onError: (error) {
        _magAvailable = false;
      },
      cancelOnError: true,
    );

    setState(() {
      _tempAvailable = tempAvailable;
      _humidityAvailable = humidityAvailable;
      _lightAvailable = lightAvailable;
      _pressureAvailable = pressureAvailable;
    });
  }

  @override
  void dispose() {
    timerUpdate.cancel();
    super.dispose();
  }

  void update() {
    incrementTitleKey();
  }

  Widget buildSensors(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Temperature: ${lastTemperature.toStringAsFixed(2)}"),
          Text("Humidity: ${lastHumidity.toStringAsFixed(2)}"),
          Text("Light: ${lastLight.toStringAsFixed(2)}"),
          Text("Pressure: ${lastPressure.toStringAsFixed(2)}"),
          Text("AccelerometerX: ${lastAccelerometerX.toStringAsFixed(2)}"),
          Text("AccelerometerY: ${lastAccelerometerY.toStringAsFixed(2)}"),
          Text("AccelerometerZ: ${lastAccelerometerZ.toStringAsFixed(2)}"),
          Text("GyroX: ${lastGyroX.toStringAsFixed(2)}"),
          Text("GyroY: ${lastGyroY.toStringAsFixed(2)}"),
          Text("GyroZ: ${lastGyroZ.toStringAsFixed(2)}"),
          Text("MagX: ${lastMagX.toStringAsFixed(2)}"),
          Text("MagY: ${lastMagY.toStringAsFixed(2)}"),
          Text("MagZ: ${lastMagZ.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context, String header) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.green,
                width: 3,
              ),
            ),
          ),
          child: Text(
            header,
            style: TextStyle(
              fontSize: 24,
              color: DesignColors.fore(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildRepository(BuildContext context) {
    List<Widget> result = [
      Text("Sensor Temperature: $_tempAvailable"),
      Text("Sensor Humidity: $_humidityAvailable"),
      Text("Sensor Light: $_lightAvailable"),
      Text("Sensor Pressure: $_pressureAvailable"),
      Text("Sensor Axel: $_axelAvailable"),
      Text("Sensor Gyro: $_gyroAvailable"),
      Text("Sensor Mag: $_magAvailable"),
      Text("Update Time: ${DateTime.now()}"),
    ];
    return [
      buildHeader(context, "Sensors"),
      Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: result,
        ),
      ),
    ];
  }

  List<Widget> buildContent(BuildContext context) {
    List<Widget> result = [];
    result.addAll(buildRepository(context));
    result.add(buildSensors(context));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: TitleBar(
            null,
            "ToolsSensorsRawForm",
            actions: <Widget>[
              buildHomeButton(context),
            ],
            key: Key(getCurrentTitleKey()),
          ),
          body: Container(
            color: DesignColors.mainBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LeftNavigator(showLeft),
                      Expanded(
                        child: DesignColors.buildScrollBar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: buildContent(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BottomNavigator(showBottom),
              ],
            ),
          ),
        );
      },
    );
  }

  String txtNodeName = "";
  final TextEditingController _textFieldController = TextEditingController();

  int currentTitleKey = 0;
  void incrementTitleKey() {
    setState(() {
      currentTitleKey++;
    });
  }

  String getCurrentTitleKey() {
    return "tools_" + currentTitleKey.toString();
  }
}
