import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  void tryToAddNode() {
    List<String> parts = _txtControllerAccessData.text.split("_");
    if (parts.length == 2) {
      addNode(parts[0], parts[1]).then((conn) {
        if (conn != null) {
          Navigator.pop(context, conn);
        }
      });
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
              tryToAddNode();
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
        OutlinedButton(
          onPressed: () {
            setState(() {
              usingScanner = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: const Icon(
              Icons.qr_code,
              size: 72,
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
        buildAddLocal(),
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
        )
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
    return Center(
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.only(top: 20),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              //_txtControllerHost.text = "localhost";
              //_txtControllerUser.text = "admin";
              loadLocalAdminPassword().then((result) {
                _txtControllerAccessData.text = "${result[0]}_${result[1]}";
                /*_txtControllerHost.text = result[0];
                _txtControllerUser.text = result[1];*/
              });
            },
            child: const Text(
              "Load local node default credentials",
              style: TextStyle(
                  decoration: TextDecoration.underline, color: Colors.blue),
            ),
          ),
        ),
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
              tryToAddNode();
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

        return Scaffold(
          appBar: TitleBar(
            Connection.makeDefault(),
            "Connect To Node",
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
