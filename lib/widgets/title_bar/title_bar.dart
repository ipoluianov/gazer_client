import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/borders/border_02_titlebar.dart';

class TitleBar extends StatefulWidget implements PreferredSizeWidget {
  final Connection? connection;
  final String title;
  final List<Widget>? actions;
  const TitleBar(this.connection, this.title, {Key? key, this.actions})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TitleBarSt();
  }

  @override
  Size get preferredSize {
    return const Size(0, 62);
  }
}

class TitleBarSt extends State<TitleBar> {
  bool serviceInfoLoaded = false;
  late ServiceInfoResponse serviceInfo;
  void loadNodeInfo() {
    if (widget.connection != null) {
      Repository().client(widget.connection!).serviceInfo().then((value) {
        if (mounted) {
          setState(() {
            serviceInfo = value;
            serviceInfoLoaded = true;
          });
        }
      }).catchError((err) {});
    }
  }

  String nodeName() {
    if (widget.connection == null) {
      return "1werwer";
    }
    if (serviceInfoLoaded) {
      return "${widget.connection!.address} - ${serviceInfo.nodeName}";
    }
    return widget.connection!.address;
  }

  String titleLine() {
    if (widget.connection != null) {
      return "${nodeName()} - ${widget.title}";
    }
    return widget.title;
  }

  @override
  void initState() {
    super.initState();
    loadNodeInfo();
  }

  String addressLine() {
    if (widget.connection != null) {
      var billingInfos = Repository().client(widget.connection!).billibInfos();
      String result = "";
      for (var bi in billingInfos) {
        result += bi.router;
        result += "=";
        result += "${bi.receivedFrames} ${bi.counter}/${bi.limit}";
        result += " | ";
      }
      return result;
    }
    return "";
  }

  List<Widget> getActions() {
    if (widget.actions == null) {
      return [];
    }
    return widget.actions!;
  }

  Widget buildBackButton() {
    if (Navigator.of(context).canPop()) {
      return buildActionButton(context, Icons.arrow_back_ios, "Back", () {
        Navigator.of(context).pop();
      });
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: DesignColors.mainBackgroundColor,
        child: Stack(
          children: [
            Border02Painter.build(false),
            Container(
              padding: const EdgeInsets.only(left: 3, top: 3, right: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBackButton(),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      //color: Colors.yellow,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              //color: Colors.cyan,
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                titleLine(),
                                style: TextStyle(
                                    color: DesignColors.fore(),
                                    overflow: TextOverflow.ellipsis),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              //color: Colors.cyan,
                              alignment: Alignment.topLeft,
                              child: Text(
                                addressLine(),
                                style: TextStyle(
                                    color: DesignColors.fore1(),
                                    overflow: TextOverflow.ellipsis),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: getActions(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
