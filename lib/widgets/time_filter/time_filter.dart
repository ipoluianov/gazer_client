import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';
import 'package:intl/intl.dart' as international;

class TimeFilter extends StatefulWidget {
  final DateTime dtBeginInit;
  final DateTime dtEndInit;

  final Function(DateTime dtBegin, DateTime dtEnd) onChanged;
  const TimeFilter(this.dtBeginInit, this.dtEndInit, this.onChanged, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TimeFilterSt();
  }
}

class TimeFilterSt extends State<TimeFilter> {
  international.DateFormat timeFormat = international.DateFormat("yyyy-MM-dd HH:mm:ss");

  TextEditingController textEditingControllerDtBegin = TextEditingController();
  TextEditingController textEditingControllerDtEnd = TextEditingController();

  late DateTime dtBegin;
  late DateTime dtEnd;
  String dtBeginError = "";
  String dtEndError = "";

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loading = true;
    dtBegin = widget.dtBeginInit;
    dtEnd = widget.dtEndInit;
    updateTextFields();
    loading = false;
  }

  void updateTextFields() {
    textEditingControllerDtBegin.text = timeFormat.format(dtBegin);
    textEditingControllerDtEnd.text = timeFormat.format(dtEnd);
    changed();
  }

  Widget statusText() {
    var diff = dtEnd.difference(dtBegin);
    if (dtBeginError != "") {
      return const Text("wrong [from] field");
    }
    if (dtEndError != "") {
      return const Text("wrong [to] field");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("In Seconds: ${diff.inSeconds}"),
        Text("In Minutes: ${diff.inMinutes}"),
        Text("In Hours: ${diff.inHours}"),
      ],
    );
  }

  void changed() {
    if (loading) {
      return;
    }
    widget.onChanged(dtBegin, dtEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.black45,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Time Filter",
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          Container(
            height: 10,
          ),
          const Text("From:"),
          SizedBox(
            width: 200,
            child: TextField(
              controller: textEditingControllerDtBegin,
              decoration: textInputDecoration(),
              onChanged: (value) {
                setState(() {
                  try {
                    dtBegin = timeFormat.parse(value);
                    dtBeginError = "";
                    changed();
                  } catch (err) {
                    dtBeginError = "Error";
                  }
                });
              },
            ),
          ),
          const Text("To:"),
          SizedBox(
            width: 200,
            child: TextField(
              decoration: textInputDecoration(),
              controller: textEditingControllerDtEnd,
              onChanged: (value) {
                setState(() {
                  try {
                    dtEnd = timeFormat.parse(value);
                    dtEndError = "";
                    changed();
                  } catch (err) {
                    dtEndError = "Error";
                  }
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  var dt = DateTime.now();
                  dtBegin = dt.subtract(const Duration(hours: 1));
                  dtEnd = dt;
                  updateTextFields();
                });
              },
              child: const SizedBox(
                width: 155,
                child: Text(
                  "Last Hour",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  var dt = DateTime.now();
                  dtBegin = dt.subtract(const Duration(hours: 24));
                  dtEnd = dt;
                  updateTextFields();
                });
              },
              child: const SizedBox(
                width: 155,
                child: Text(
                  "Last 24 Hours",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  var dt = DateTime.now();
                  dtBegin = DateTime(dt.year, dt.month, dt.day, 0, 0, 0);
                  dtEnd = dtBegin.add(
                    const Duration(days: 1),
                  );
                  updateTextFields();
                });
              },
              child: const SizedBox(
                width: 155,
                child: Text(
                  "Current Day",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            child: statusText(),
          ),
        ],
      ),
    );
  }
}
