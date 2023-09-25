import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Connection?> addNode(String address, String accessKey) async {
  final GazerLocalClient cl = GazerLocalClient("new", "", "", "", "");
  cl.transport = "http/local";
  cl.address = address;
  cl.accessKey = accessKey;

  if (cl.address.length != 49) {
    return null;
  }

  if (cl.address[0] != '#') {
    return null;
  }

  var conn = Connection(UniqueKey().toString(), cl.transport, cl.address,
      cl.accessKey, cl.networkId, "");

  await wsAddConnection(conn);
  return conn;
}

Future<Connection?> editNode(
    String id, String address, String accessKey, String networkId) async {
  final GazerLocalClient cl = GazerLocalClient(id, "", "", "", networkId);
  cl.transport = "http/local";
  cl.address = address;
  cl.accessKey = accessKey;
  cl.networkId = networkId;

  if (cl.address.length != 49) {
    return null;
  }

  if (cl.address[0] != '#') {
    return null;
  }

  var conn =
      Connection(id, cl.transport, cl.address, cl.accessKey, cl.networkId, "");

  await wsEditConnection(conn);
  return conn;
}

Future<Connection?> addLocalConnection() async {
  Connection? connection;
  final prefs = await SharedPreferences.getInstance();

  try {
    if (!(prefs.getBool("node_client_added_connection") ?? false)) {
      List<String> addressAndAccessKey = await loadLocalAdminPassword();
      if (addressAndAccessKey.length != 2) {
        throw "wrong access data";
      }
      connection =
          await addNode(addressAndAccessKey[0], addressAndAccessKey[1]);
      prefs.setBool("node_client_added_connection", true);
    }
  } catch (err) {
    connection = null;
  }

  return connection;
}

String gazerDataDirectory() {
  String result = "";

  String os = Platform.operatingSystem;
  String varDir = "";
  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS) {
    varDir = "/var";
  } else if (Platform.isLinux) {
    varDir = "/var";
  } else if (Platform.isWindows) {
    if (envVars['PROGRAMDATA'] != null) {
      varDir = envVars['PROGRAMDATA']!;
    }
  }
  result = "$varDir/gazer";
  return result;
}

Future<List<String>> loadLocalAdminPassword() async {
  String address = "";
  String masterKey = "";
  Permission.storage.request().then((value) {
    print("Granted");
  }).catchError((err) {
    print("errro");
  });
  try {
    final File file = File('${gazerDataDirectory()}/address.txt');
    var stream = file.openRead();
    address = await file.readAsString();
  } catch (e) {
    print("error: ${e.toString()}");
  }
  try {
    final File file = File('${gazerDataDirectory()}/masterkey.txt');
    var stream = file.openRead();
    masterKey = await file.readAsString();
  } catch (e) {
    print("error: ${e.toString()}");
  }
  return [address, masterKey];
}
