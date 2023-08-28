import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/error_dialog/error_dialog.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/xchg/network_container.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/design.dart';
import '../../../core/navigation/route_generator.dart';
import '../../../core/workspace/add_local_connection.dart';

class NodeAddForm extends StatefulWidget {
  final NodeAddFormArgument arg;
  const NodeAddForm({Key? key, required this.arg}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NodeAddFormSt();
  }
}

class NodeAddFormSt extends State<NodeAddForm> {
  bool firstAccountLoaded = false;

  final TextEditingController _txtControllerAccessData =
      TextEditingController();
  //final TextEditingController _txtControllerHost = TextEditingController();
  //final TextEditingController _txtControllerUser = TextEditingController();
  //final TextEditingController _txtControllerPassword = TextEditingController();

  String connectionError = "";

  @override
  void initState() {
    super.initState();

    requestVersion();
  }

  PackageInfo? packageInfo;

  void requestVersion() {
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        packageInfo = value;
      });
    }).catchError((err) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void tryToAddNode(String accessData) {
    List<String> parts = accessData.split("_");
    if (parts.length == 2) {
      addNode(parts[0], parts[1]).then((conn) {
        if (conn != null) {
          Navigator.pop(context, conn);
          return;
        }
        showErrorDialog(context, "Wrong Access Data (1)");
      }).catchError((err) {
        showErrorDialog(context, "$err");
      });
    } else {
      showErrorDialog(context, "Wrong Access Data (2)");
    }
  }

  Widget buildAddNodeButton() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: 130,
          height: 36,
          child: ElevatedButton(
            onPressed: () {
              tryToAddNode(_txtControllerAccessData.text);
            },
            child: const Text("Add node"),
          ),
        ),
      ),
    );
  }

  Widget buildScanButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              usingScanner = true;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                color: DesignColors.fore(),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Icon(
              Icons.qr_code,
              size: 72,
              color: DesignColors.fore(),
            ),
          ),
        ),
      ],
    );
  }

  int mode = 0;

  Widget buildMode0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: TextField(
            autofocus: true,
            controller: _txtControllerAccessData,
            decoration: const InputDecoration(
              labelText: "Access Data",
            ),
          ),
        ),
        buildAddNodeButton(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildAddLocal(),
            buildAddDemo(),
          ],
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.only(top: 30),
            child: const Text("Scan QR Code"),
          ),
        ),
        buildScanButton(),
      ],
    );
  }

  Widget buildMode1() {
    return Column(
      children: [
        TextField(
          autofocus: true,
          controller: _txtControllerAccessData,
          decoration: const InputDecoration(
            labelText: "Access Data",
          ),
        ),
        MobileScanner(
          // fit: BoxFit.contain,
          controller: cameraController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            final Uint8List? image = capture.image;
            for (final barcode in barcodes) {
              debugPrint('Barcode found! ${barcode.rawValue}');
            }
          },
        ),
      ],
    );
  }

  /*Widget buildMode2() {
    return Container(
      padding: const EdgeInsets.all(10),
      //constraints: BoxConstraints(minWidth: 250, minHeight: 300),
      child: Column(
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              autofocus: true,
              controller: _txtControllerHost,
              decoration: const InputDecoration(
                labelText: "Address",
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _txtControllerUser,
              decoration: const InputDecoration(
                labelText: "AccessKey",
              ),
            ),
          ),
        ],
      ),
    );
  }*/

  Widget buildMode() {
    if (mode == 0) {
      return buildMode0();
    }
    if (mode == 1) {
      return buildMode1();
    }
    /*if (mode == 2) {
      return buildMode2();
    }*/
    return buildMode0();
  }

  Widget buildAddLocal() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: OutlinedButton(
        onPressed: () {
          loadLocalAdminPassword().then((result) {
            String accessData = "${result[0]}_${result[1]}";
            _txtControllerAccessData.text = accessData;
            tryToAddNode(accessData);
          });
        },
        child: Text("ADD LOCAL NODE"),
      ),
    );
  }

  Widget buildAddDemo() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: OutlinedButton(
        onPressed: () {
          httpGet("https://gazer.cloud/demo/demo.txt", 1000).then((value) {
            setState(() {
              _txtControllerAccessData.text = value;
            });
            tryToAddNode(value);
          }).catchError((err) {
            showErrorDialog(context, "$err");
          });
        },
        child: const Text("ADD DEMO NODE"),
      ),
    );
  }

  Widget buildContent() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: buildMode(),
      ),
    );
  }

  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget buildQRCodeScanner(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        Connection.makeDefault(),
        "Connect To Node",
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        // fit: BoxFit.contain,
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;
          for (final barcode in barcodes) {
            //debugPrint('Barcode found! ${barcode.rawValue}');
            if (barcode.rawValue != null) {
              setState(() {
                _txtControllerAccessData.text = barcode.rawValue!;
                usingScanner = false;
              });
              tryToAddNode(_txtControllerAccessData.text);
            }
          }
        },
      ),
    );
  }

  bool usingScanner = false;

  @override
  Widget build(BuildContext context) {
    if (usingScanner) {
      return buildQRCodeScanner(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < 600;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        String version = "";

        if (packageInfo != null) {
          version = packageInfo!.version;
        }

        return Scaffold(
          appBar: TitleBar(
            null,
            "Add Node",
            version: version,
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
                      buildContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String homeDirectory() {
    String os = Platform.operatingSystem;
    String? home = "";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }
    if (home == null) {
      return "/";
    }
    return home;
  }
}
