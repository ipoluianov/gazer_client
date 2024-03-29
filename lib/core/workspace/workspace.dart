import 'dart:convert';

import 'package:gazer_client/core/design.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../xchg/rsa.dart';

class Connection {
  String id;
  String transport;
  String address;
  String sessionKey;
  String networkId;
  String lastName;

  Connection(this.id, this.transport, this.address, this.sessionKey,
      this.networkId, this.lastName);

  Map<String, dynamic> toJson() => {
        'id': id,
        'transport': transport,
        'address': address,
        'session_key': sessionKey,
        'network_id': networkId,
        'last_name': lastName,
      };

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      json['id'],
      json['transport'],
      json['address'],
      json['session_key'],
      json.containsKey('network_id') ? json['network_id'] : "",
      json.containsKey('last_name') ? json['last_name'] : "",
    );
  }

  factory Connection.makeDefault() {
    return Connection("", "", "", "", "", "");
  }
}

class CloudAccount {
  String userName;
  String sessionKey;
  CloudAccount(this.userName, this.sessionKey);
  Map<String, dynamic> toJson() => {
        'address': userName,
        'session_key': sessionKey,
      };
  factory CloudAccount.fromJson(Map<String, dynamic> json) {
    return CloudAccount(json['address'], json['session_key']);
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Workspace {
  List<Connection> connections;
  Workspace(this.connections);
  Map<String, dynamic> toJson() => {'connections': connections};
  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      List<Connection>.from(
        json['connections'].map((model) => Connection.fromJson(model)),
      ),
    );
  }
}

Future<Workspace> readWorkspace() async {
  final prefs = await SharedPreferences.getInstance();
  var wsContent = prefs.getString("ws") ?? "{}";
  late Workspace ws;

  try {
    ws = Workspace.fromJson(jsonDecode(wsContent));
    return ws;
  } catch (ex) {
    ws = Workspace([]);
  }

  return ws;
}

Future<void> saveWorkspace(Workspace ws) async {
  final contents = jsonEncode(ws.toJson());
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("ws", contents);
  print("saveWorkspace $contents");
}

Future<void> wsSetConnection(List<Connection> connections) async {
  var ws = await readWorkspace();
  ws.connections = connections;
  saveWorkspace(ws);
}

Future<void> wsAddConnection(Connection connection) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool("node_client_added_connection", true);
  var ws = await readWorkspace();
  ws.connections.add(connection);
  saveWorkspace(ws);
}

Future<void> wsEditConnection(Connection connection) async {
  print("Edit connection ${connection.address} '${connection.lastName}'");
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool("node_client_added_connection", true);
  var ws = await readWorkspace();
  for (var conn in ws.connections) {
    if (conn.id == connection.id) {
      conn.address = connection.address;
      conn.sessionKey = connection.sessionKey;
      conn.networkId = connection.networkId;
      conn.lastName = connection.lastName;
    }
  }
  saveWorkspace(ws);
}

Future<AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>> getKeyPair() async {
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> result = generateRSAkeyPair();
  final prefs = await SharedPreferences.getInstance();
  String privateKeyString = prefs.getString("private_key_p") ?? "";
  bool loaded = false;
  if (privateKeyString != "") {
    try {
      var privateP = prefs.getString("private_key_p");
      var privateQ = prefs.getString("private_key_q");
      var privateModulus = prefs.getString("private_key_mod");
      var privateExponent = prefs.getString("private_key_exp");

      var publicModulus = prefs.getString("public_key_mod");
      var publicExponent = prefs.getString("public_key_exp");

      if (privateP != null &&
          privateQ != null &&
          privateModulus != null &&
          privateExponent != null &&
          publicModulus != null &&
          publicExponent != null) {
        RSAPrivateKey privateKey = RSAPrivateKey(
            BigInt.parse(privateModulus),
            BigInt.parse(privateExponent),
            BigInt.parse(privateP),
            BigInt.parse(privateQ));

        RSAPublicKey publicKey = RSAPublicKey(
            BigInt.parse(publicModulus), BigInt.parse(publicExponent));

        result = AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
            publicKey, privateKey);
        loaded = true;
      }
    } catch (ex) {
      print(ex);
    }
  }

  if (!loaded) {
    var privateP = result.privateKey.p!.toString();
    prefs.setString("private_key_p", privateP);
    var privateQ = result.privateKey.q!.toString();
    prefs.setString("private_key_q", privateQ);
    var privateModulus = result.privateKey.modulus!.toString();
    prefs.setString("private_key_mod", privateModulus);
    var privateExponent = result.privateKey.privateExponent!.toString();
    prefs.setString("private_key_exp", privateExponent);

    var publicExponent = result.publicKey.exponent!.toString();
    prefs.setString("public_key_exp", publicExponent);

    var publicModulus = result.publicKey.modulus!.toString();
    prefs.setString("public_key_mod", publicModulus);
  }

  return result;
}

Future<void> saveAppearance() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("palette", DesignColors.palette());
}

Future<void> loadAppearance() async {
  final prefs = await SharedPreferences.getInstance();
  String? paletteName = prefs.getString("palette");
  if (paletteName != null) {
    DesignColors.setPalette(paletteName);
  }
}

Future<void> wsRemoveConnection(String id) async {
  var ws = await readWorkspace();
  ws.connections.removeWhere((element) => element.id == id);
  saveWorkspace(ws);
}

Future<List<Connection>> wsGetConnections() async {
  var ws = await readWorkspace();
  return ws.connections;
}
