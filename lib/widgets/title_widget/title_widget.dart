import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

class TitleWidget extends StatefulWidget {
  final Connection connection;
  final String title;
  const TitleWidget(this.connection, this.title, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return TitleWidgetSt();
  }
}

class TitleWidgetSt extends State<TitleWidget> {
  bool serviceInfoLoaded = false;
  late ServiceInfoResponse serviceInfo;
  void loadNodeInfo() {
    Repository().client(widget.connection).serviceInfo().then((value) {
      if (mounted) {
        setState(() {
          serviceInfo = value;
          serviceInfoLoaded = true;
        });
      }
    });
  }

  String nodeName() {
    if (serviceInfoLoaded) {
      return serviceInfo.nodeName;
    }
    return widget.connection.address;
  }

  @override
  void initState() {
    super.initState();
    loadNodeInfo();
  }

  String addressLine() {
    if (widget.connection.transport == "https/cloud") {
      return "Node " + widget.connection.address + " (via Cloud)";
    }
    return widget.connection.address + " (direct connection)";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nodeName() + " - " + widget.title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
            overflow: TextOverflow.fade,
          ),
          Text(
            addressLine(),
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 12,
            ),
            overflow: TextOverflow.fade,
          )
        ],
      ),
    );
  }
}
