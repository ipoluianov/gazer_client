import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/nodes/node_add_form/node_add_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Connection?> addLocalConnection() async  {
  Connection? connection;
  final prefs = await SharedPreferences.getInstance();

  try {
    if (!(prefs.getBool("node_client_added_connection") ?? false)) {
      // Add default connection
      GazerLocalClient cl = GazerLocalClient("new", "", "", "");
      String localAdminPassword = await loadLocalAdminPassword();
      cl.transport = "http/local";
      cl.address = "localhost";
      var openSessionResult = await cl.sessionOpen("admin", localAdminPassword);
      cl.session = openSessionResult.sessionToken;
      cl.isValid = true;

      var connectionId = UniqueKey().toString();
      connection = Connection(connectionId, cl.transport, cl.address, cl.session);
      await wsAddConnection(connection);
      prefs.setBool("node_client_added_connection", true);
    }
  } catch(err) {
    connection = null;
  }

  return connection;
}

Future<String> loadLocalAdminPassword() async {
  String text = "";
  try {
    final File file = File('${NodeAddFormSt.gazerDataDirectory()}/default_admin_password.txt');
    text = await file.readAsString();
  } catch (e) {}
  return text;
}
