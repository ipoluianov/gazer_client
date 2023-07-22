import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:gazer_client/core/protocol/cloud/cloud_account_info.dart';
import 'package:gazer_client/core/protocol/cloud/cloud_add_node.dart';
import 'package:gazer_client/core/protocol/cloud/cloud_login.dart';
import 'package:gazer_client/core/protocol/cloud/cloud_logout.dart';
import 'package:gazer_client/core/protocol/cloud/cloud_registered_nodes.dart';
import 'package:gazer_client/core/protocol/cloud/cloud_set_current_node_id.dart';
import 'package:gazer_client/core/protocol/cloud/cloud_state.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_list.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_prop_get.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_prop_set.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_remove.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_write.dart';
import 'package:gazer_client/core/protocol/resource/resource_add.dart';
import 'package:gazer_client/core/protocol/resource/resource_get.dart';
import 'package:gazer_client/core/protocol/resource/resource_get_by_path.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/protocol/resource/resource_remove.dart';
import 'package:gazer_client/core/protocol/resource/resource_rename.dart';
import 'package:gazer_client/core/protocol/resource/resource_set.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/protocol/service/service_lookup.dart';
import 'package:gazer_client/core/protocol/service/service_set_node_name.dart';
import 'package:gazer_client/core/protocol/unit/unit_add.dart';
import 'package:gazer_client/core/protocol/unit/unit_get_config.dart';
import 'package:gazer_client/core/protocol/unit/unit_items_values.dart';
import 'package:gazer_client/core/protocol/unit/unit_list.dart';
import 'package:gazer_client/core/protocol/unit/unit_prop_get.dart';
import 'package:gazer_client/core/protocol/unit/unit_prop_set.dart';
import 'package:gazer_client/core/protocol/unit/unit_remove.dart';
import 'package:gazer_client/core/protocol/unit/unit_set_config.dart';
import 'package:gazer_client/core/protocol/unit/unit_start.dart';
import 'package:gazer_client/core/protocol/unit/unit_state.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/protocol/unit/unit_stop.dart';
import 'package:gazer_client/core/protocol/unit_type/unit_type_categories.dart';
import 'package:gazer_client/core/protocol/unit_type/unit_type_config_meta.dart';
import 'package:gazer_client/core/protocol/unit_type/unit_type_list.dart';
import 'package:gazer_client/core/protocol/user/session_list.dart';
import 'package:gazer_client/core/protocol/user/session_open.dart';
import 'package:gazer_client/core/protocol/user/session_remove.dart';
import 'package:gazer_client/core/protocol/user/user_add.dart';
import 'package:gazer_client/core/protocol/user/user_list.dart';
import 'package:gazer_client/core/protocol/user/user_prop_get.dart';
import 'package:gazer_client/core/protocol/user/user_prop_set.dart';
import 'package:gazer_client/core/protocol/user/user_remove.dart';
import 'package:gazer_client/core/protocol/user/user_set_password.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/xchg/billing_for_address.dart';
import 'package:gazer_client/xchg/peer.dart';

typedef FromJsonFunc = dynamic Function(Map<String, dynamic> json);

class GazerLocalClient {
  String id;
  String transport;
  String address;
  String accessKey;
  String repeater = "";
  bool active = false;
  bool isValid = false;
  bool infoReceived = false;
  String nodeName = "";
  String nodeVersion = "";
  String nodeBuildTime = "";
  String lastError = "";
  GazerLocalClient(this.id, this.transport, this.address, this.accessKey);

  String localAddress() {
    return Repository().peer.address();
  }

  BillingSummary billingInfo() {
    BillingSummary result = Repository().peer.billingInfoForAddress(address);
    return result;
  }

  BillingDB billingDB() {
    BillingDB result = Repository().peer.billingDB;
    return result;
  }

  bool usingLocalRouter() {
    return Repository().peer.usingLocalRouter(address);
  }

  ////////////////////////////////////////////////////////
  //// Units
  ////////////////////////////////////////////////////////

  Future<UnitAddResponse> unitsAdd(
      String unitType, String unitName, String config) async {
    return fetch<UnitAddRequest, UnitAddResponse>(
      'unit_add',
      UnitAddRequest(unitType, unitName, config),
      (Map<String, dynamic> json) => UnitAddResponse.fromJson(json),
    );
  }

  Future<UnitRemoveResponse> unitsRemove(List<String> unitsIDs) async {
    return fetch<UnitRemoveRequest, UnitRemoveResponse>(
      'unit_remove',
      UnitRemoveRequest(unitsIDs),
      (Map<String, dynamic> json) => UnitRemoveResponse.fromJson(json),
    );
  }

  Future<UnitStateResponse> unitsState(String unitId) async {
    return fetch<UnitStateRequest, UnitStateResponse>(
      'unit_state',
      UnitStateRequest(unitId),
      (Map<String, dynamic> json) => UnitStateResponse.fromJson(json),
    );
  }

  Future<UnitStateAllResponse> unitsStateAll() async {
    return fetch<UnitStateAllRequest, UnitStateAllResponse>(
      'unit_state_all',
      UnitStateAllRequest(),
      (Map<String, dynamic> json) => UnitStateAllResponse.fromJson(json),
    );
  }

  Future<UnitItemsValuesResponse> unitItemsValues(String unitName) async {
    return fetch<UnitItemsValuesRequest, UnitItemsValuesResponse>(
      'unit_items_values',
      UnitItemsValuesRequest(unitName),
      (Map<String, dynamic> json) =>
          UnitItemsValuesResponse.fromJson(json, false),
    );
  }

  Future<UnitItemsValuesResponse> unitItemsValuesWithoutServiceItems(
      String unitName) async {
    return fetch<UnitItemsValuesRequest, UnitItemsValuesResponse>(
      'unit_items_values',
      UnitItemsValuesRequest(unitName),
      (Map<String, dynamic> json) =>
          UnitItemsValuesResponse.fromJson(json, true),
    );
  }

  Future<UnitListResponse> unitsList() async {
    return fetch<UnitListRequest, UnitListResponse>(
      'unit_list',
      UnitListRequest(),
      (Map<String, dynamic> json) => UnitListResponse.fromJson(json),
    );
  }

  Future<UnitStartResponse> unitsStart(List<String> unitIDs) async {
    return fetch<UnitStartRequest, UnitStartResponse>(
      'unit_start',
      UnitStartRequest(unitIDs),
      (Map<String, dynamic> json) => UnitStartResponse.fromJson(json),
    );
  }

  Future<UnitStopResponse> unitsStop(List<String> unitIDs) async {
    return fetch<UnitStopRequest, UnitStopResponse>(
      'unit_stop',
      UnitStopRequest(unitIDs),
      (Map<String, dynamic> json) => UnitStopResponse.fromJson(json),
    );
  }

  Future<UnitSetConfigResponse> unitsSetConfig(
      String unitId, String unitName, String config) async {
    return fetch<UnitSetConfigRequest, UnitSetConfigResponse>(
      'unit_set_config',
      UnitSetConfigRequest(unitId, unitName, config),
      (Map<String, dynamic> json) => UnitSetConfigResponse.fromJson(json),
    );
  }

  Future<UnitGetConfigResponse> unitsGetConfig(String unitId) async {
    return fetch<UnitGetConfigRequest, UnitGetConfigResponse>(
      'unit_get_config',
      UnitGetConfigRequest(unitId),
      (Map<String, dynamic> json) => UnitGetConfigResponse.fromJson(json),
    );
  }

  Future<UnitPropSetResponse> unitPropSet(
      String unitId, Map<String, String> props) async {
    List<UnitPropSetItemRequest> propItems = [];
    for (var key in props.keys) {
      var value = props[key];
      propItems.add(UnitPropSetItemRequest(key, value!));
    }

    return fetch<UnitPropSetRequest, UnitPropSetResponse>(
      'unit_prop_set',
      UnitPropSetRequest(unitId, propItems),
      (Map<String, dynamic> json) => UnitPropSetResponse.fromJson(json),
    );
  }

  Future<UnitPropGetResponse> unitPropGet(String unitId) async {
    return fetch<UnitPropGetRequest, UnitPropGetResponse>(
      'unit_prop_get',
      UnitPropGetRequest(unitId),
      (Map<String, dynamic> json) => UnitPropGetResponse.fromJson(json),
    );
  }

  ////////////////////////////////////////////////////////
  //// Unit Types
  ////////////////////////////////////////////////////////

  Future<UnitTypeListResponse> unitTypeList(
      String category, String filter, int offset, int maxCount) async {
    return fetch<UnitTypeListRequest, UnitTypeListResponse>(
      'unit_type_list',
      UnitTypeListRequest(category, filter, offset, maxCount),
      (Map<String, dynamic> json) => UnitTypeListResponse.fromJson(json),
    );
  }

  Future<UnitTypeCategoriesResponse> unitTypeCategories() async {
    return fetch<UnitTypeCategoriesRequest, UnitTypeCategoriesResponse>(
      'unit_type_categories',
      UnitTypeCategoriesRequest(),
      (Map<String, dynamic> json) => UnitTypeCategoriesResponse.fromJson(json),
    );
  }

  Future<UnitTypeConfigMetaResponse> unitTypeConfigMeta(String unitType) async {
    return fetch<UnitTypeConfigMetaRequest, UnitTypeConfigMetaResponse>(
      'unit_type_config_meta',
      UnitTypeConfigMetaRequest(unitType),
      (Map<String, dynamic> json) => UnitTypeConfigMetaResponse.fromJson(json),
    );
  }

  ////////////////////////////////////////////////////////
  //// Service
  ////////////////////////////////////////////////////////

  Future<ServiceLookupResponse> serviceLookup(
      String entity, String parameters) async {
    return fetch<ServiceLookupRequest, ServiceLookupResponse>(
      'service_lookup',
      ServiceLookupRequest(entity, parameters),
      (Map<String, dynamic> json) => ServiceLookupResponse.fromJson(json),
    );
  }

  Future<ServiceSetNodeNameResponse> serviceSetNodeName(String name) async {
    return fetch<ServiceSetNodeNameRequest, ServiceSetNodeNameResponse>(
      'service_set_node_name',
      ServiceSetNodeNameRequest(name),
      (Map<String, dynamic> json) => ServiceSetNodeNameResponse.fromJson(json),
    );
  }

  Future<ServiceInfoResponse> serviceInfo() async {
    return fetch<ServiceInfoRequest, ServiceInfoResponse>(
      'service_info',
      ServiceInfoRequest(),
      (Map<String, dynamic> json) => ServiceInfoResponse.fromJson(json),
    );
  }

  void requestServiceInfo() {
    fetch<ServiceInfoRequest, ServiceInfoResponse>(
      'service_info',
      ServiceInfoRequest(),
      (Map<String, dynamic> json) => ServiceInfoResponse.fromJson(json),
    ).then((value) {
      nodeName = value.nodeName;
      nodeVersion = value.version;
      nodeBuildTime = value.buildTime;
    });
  }

  ////////////////////////////////////////////////////////
  //// Users
  ////////////////////////////////////////////////////////

  Future<SessionListResponse> sessionList(String userName) async {
    return fetch<SessionListRequest, SessionListResponse>(
      'session_list',
      SessionListRequest(userName),
      (Map<String, dynamic> json) => SessionListResponse.fromJson(json),
    );
  }

  Future<SessionRemoveResponse> sessionRemove(String sessionToken) async {
    return fetch<SessionRemoveRequest, SessionRemoveResponse>(
      'session_remove',
      SessionRemoveRequest(sessionToken),
      (Map<String, dynamic> json) => SessionRemoveResponse.fromJson(json),
    );
  }

  Future<UserAddResponse> userAdd(String userName, String password) async {
    return fetch<UserAddRequest, UserAddResponse>(
      'user_add',
      UserAddRequest(userName, password),
      (Map<String, dynamic> json) => UserAddResponse.fromJson(json),
    );
  }

  Future<UserListResponse> userList() async {
    return fetch<UserListRequest, UserListResponse>(
      'user_list',
      UserListRequest(),
      (Map<String, dynamic> json) => UserListResponse.fromJson(json),
    );
  }

  Future<UserRemoveResponse> userRemove(String userName) async {
    return fetch<UserRemoveRequest, UserRemoveResponse>(
      'user_remove',
      UserRemoveRequest(userName),
      (Map<String, dynamic> json) => UserRemoveResponse.fromJson(json),
    );
  }

  Future<UserSetPasswordResponse> userSetPassword(
      String userName, String password) async {
    return fetch<UserSetPasswordRequest, UserSetPasswordResponse>(
      'user_set_password',
      UserSetPasswordRequest(userName, password),
      (Map<String, dynamic> json) => UserSetPasswordResponse.fromJson(json),
    );
  }

  Future<SessionOpenResponse> sessionOpen(
      String userName, String password) async {
    return fetch<SessionOpenRequest, SessionOpenResponse>(
      'session_open',
      SessionOpenRequest(userName, password),
      (Map<String, dynamic> json) => SessionOpenResponse.fromJson(json),
    );
  }

  Future<UserPropSetResponse> userPropSet(
      String userName, Map<String, String> props) async {
    List<UserPropSetItemRequest> propItems = [];
    for (var key in props.keys) {
      var value = props[key];
      propItems.add(UserPropSetItemRequest(key, value!));
    }

    return fetch<UserPropSetRequest, UserPropSetResponse>(
      'user_prop_set',
      UserPropSetRequest(userName, propItems),
      (Map<String, dynamic> json) => UserPropSetResponse.fromJson(json),
    );
  }

  Future<UserPropGetResponse> userPropGet(String unitId) async {
    return fetch<UserPropGetRequest, UserPropGetResponse>(
      'user_prop_get',
      UserPropGetRequest(unitId),
      (Map<String, dynamic> json) => UserPropGetResponse.fromJson(json),
    );
  }

  ////////////////////////////////////////////////////////
  //// Data Items
  ////////////////////////////////////////////////////////

  Future<DataItemHistoryChartResponse> dataItemHistoryChart(
      List<DataItemHistoryChartItemRequest> reqItems) async {
    //DataItemHistoryChartItemRequest reqItem = DataItemHistoryChartItemRequest(itemName, dtBegin, dtEnd, groupTimeRange, outFormat);
// String itemName, int dtBegin, int dtEnd, int groupTimeRange, String outFormat
    return fetch<DataItemHistoryChartRequest, DataItemHistoryChartResponse>(
      'data_item_history_chart',
      DataItemHistoryChartRequest(reqItems),
      (Map<String, dynamic> json) =>
          DataItemHistoryChartResponse.fromJson(json),
    );
  }

  Future<DataItemHistoryResponse> dataItemHistory(
      String itemName, int dtBegin, int dtEnd) async {
    return fetch<DataItemHistoryRequest, DataItemHistoryResponse>(
      'data_item_history',
      DataItemHistoryRequest(itemName, dtBegin, dtEnd),
      (Map<String, dynamic> json) => DataItemHistoryResponse.fromJson(json),
    );
  }

  Future<DataItemRemoveResponse> dataItemRemove(List<String> items) async {
    return fetch<DataItemRemoveRequest, DataItemRemoveResponse>(
      'data_item_remove',
      DataItemRemoveRequest(items),
      (Map<String, dynamic> json) => DataItemRemoveResponse.fromJson(json),
    );
  }

  Future<DataItemListResponse> dataItemList(List<String> items) async {
    return fetch<DataItemListRequest, DataItemListResponse>(
      'data_item_list',
      DataItemListRequest(items),
      (Map<String, dynamic> json) => DataItemListResponse.fromJson(json),
    );
  }

  Future<DataItemWriteResponse> dataItemWrite(
      String itemName, String value) async {
    return fetch<DataItemWriteRequest, DataItemWriteResponse>(
      'data_item_write',
      DataItemWriteRequest(itemName, value),
      (Map<String, dynamic> json) => DataItemWriteResponse.fromJson(json),
    );
  }

  Future<DataItemPropSetResponse> dataItemPropSet(
      String itemName, Map<String, String> props) async {
    List<DataItemPropSetItemRequest> propItems = [];
    for (var key in props.keys) {
      var value = props[key];
      propItems.add(DataItemPropSetItemRequest(key, value!));
    }

    return fetch<DataItemPropSetRequest, DataItemPropSetResponse>(
      'data_item_prop_set',
      DataItemPropSetRequest(itemName, propItems),
      (Map<String, dynamic> json) => DataItemPropSetResponse.fromJson(json),
    );
  }

  Future<DataItemPropGetResponse> dataItemPropGet(String itemName) async {
    return fetch<DataItemPropGetRequest, DataItemPropGetResponse>(
      'data_item_prop_get',
      DataItemPropGetRequest(itemName),
      (Map<String, dynamic> json) => DataItemPropGetResponse.fromJson(json),
    );
  }

  ////////////////////////////////////////////////////////
  //// Cloud
  ////////////////////////////////////////////////////////

  Future<CloudAccountInfoResponse> cloudAccountInfo() async {
    return fetch<CloudAccountInfoRequest, CloudAccountInfoResponse>(
      'cloud_account_info',
      CloudAccountInfoRequest(),
      (Map<String, dynamic> json) => CloudAccountInfoResponse.fromJson(json),
    );
  }

  Future<CloudAddNodeResponse> cloudAddNode(String name) async {
    return fetch<CloudAddNodeRequest, CloudAddNodeResponse>(
      'cloud_add_node',
      CloudAddNodeRequest(name),
      (Map<String, dynamic> json) => CloudAddNodeResponse.fromJson(json),
    );
  }

  Future<CloudLoginResponse> cloudLogin(
      String userName, String password) async {
    return fetch<CloudLoginRequest, CloudLoginResponse>(
      'cloud_login',
      CloudLoginRequest(userName, password),
      (Map<String, dynamic> json) => CloudLoginResponse.fromJson(json),
    );
  }

  Future<CloudLogoutResponse> cloudLogout() async {
    return fetch<CloudLogoutRequest, CloudLogoutResponse>(
      'cloud_logout',
      CloudLogoutRequest(),
      (Map<String, dynamic> json) => CloudLogoutResponse.fromJson(json),
    );
  }

  Future<CloudStateResponse> cloudState() async {
    return fetch<CloudStateRequest, CloudStateResponse>(
      'cloud_state',
      CloudStateRequest(),
      (Map<String, dynamic> json) => CloudStateResponse.fromJson(json),
    );
  }

  Future<CloudRegisteredNodesResponse> cloudRegisteredNode() async {
    if (accessKey.isEmpty) {
      throw GazerClientException("no session");
    }

    return fetch<CloudRegisteredNodesRequest, CloudRegisteredNodesResponse>(
      's-registered-nodes',
      CloudRegisteredNodesRequest(),
      (Map<String, dynamic> json) =>
          CloudRegisteredNodesResponse.fromJson(json),
    );
  }

  Future<CloudSetCurrentNodeIdResponse> cloudSetCurrentNodeId(
      String nodeId) async {
    return fetch<CloudSetCurrentNodeIdRequest, CloudSetCurrentNodeIdResponse>(
      'cloud_set_current_node_id',
      CloudSetCurrentNodeIdRequest(nodeId),
      (Map<String, dynamic> json) =>
          CloudSetCurrentNodeIdResponse.fromJson(json),
    );
  }

  ////////////////////////////////////////////////////////
  //// Resources
  ////////////////////////////////////////////////////////

  Future<ResAddResponse> resAdd(
      String name, String type, Uint8List content) async {
    var contentString = const Base64Encoder().convert(content);

    return fetch<ResAddRequest, ResAddResponse>(
      'resource_add',
      ResAddRequest(name, type, contentString),
      (Map<String, dynamic> json) => ResAddResponse.fromJson(json),
    );
  }

  Future<ResSetResponse> resSet(
      String id, String suffix, int offset, Uint8List content) async {
    var contentString = const Base64Encoder().convert(content);
    return fetch<ResSetRequest, ResSetResponse>(
      'resource_set',
      ResSetRequest(id, suffix, offset, contentString),
      (Map<String, dynamic> json) => ResSetResponse.fromJson(json),
    );
  }

  Future<ResGetResponse> resGetEntire(String id) async {
    int step = 1000;
    String name = "";
    String type = "";
    int resSize = 0;
    String resHash = "";
    List<int> result = [];

    for (int offset = 0; offset < 100 * 1000000; offset += step) {
      print("loading res offset $offset");
      var value = await fetch<ResGetRequest, ResGetResponse>(
        'resource_get',
        ResGetRequest(id, offset, step),
        (Map<String, dynamic> json) => ResGetResponse.fromJson(json),
      );
      name = value.name;
      type = value.type;
      resSize = value.size;
      resHash = value.hash;
      if (value.content.isEmpty) {
        break;
      }
      result.addAll(value.content.toList());
    }

    return ResGetResponse(
        id, name, type, Uint8List.fromList(result), resSize, resHash);
  }

  Future<ResGetResponse> resGet1(String id, int offset, int size) async {
    return fetch<ResGetRequest, ResGetResponse>(
      'resource_get',
      ResGetRequest(id, offset, size),
      (Map<String, dynamic> json) => ResGetResponse.fromJson(json),
    );
  }

  Future<ResGetByPathResponse> resGetByPath(
      String path, int offset, int size) async {
    return fetch<ResGetByPathRequest, ResGetByPathResponse>(
      'resource_get_by_path',
      ResGetByPathRequest(path, offset, size),
      (Map<String, dynamic> json) => ResGetByPathResponse.fromJson(json),
    );
  }

  Future<ResRemoveResponse> resRemove(String id) async {
    return fetch<ResRemoveRequest, ResRemoveResponse>(
      'resource_remove',
      ResRemoveRequest(id),
      (Map<String, dynamic> json) => ResRemoveResponse.fromJson(json),
    );
  }

  Future<ResPropSetResponse> resPropSet(
      String id, Map<String, String> props) async {
    List<ResPropSetItemRequest> propItems = [];
    for (var key in props.keys) {
      var value = props[key];
      propItems.add(ResPropSetItemRequest(key, value!));
    }

    return fetch<ResPropSetRequest, ResPropSetResponse>(
      'resource_prop_set',
      ResPropSetRequest(id, propItems),
      (Map<String, dynamic> json) => ResPropSetResponse.fromJson(json),
    );
  }

  Future<ResListResponse> resList(
      String type, String filter, int offset, int maxCount) async {
    return fetch<ResListRequest, ResListResponse>(
      'resource_list',
      ResListRequest(type, filter, offset, maxCount),
      (Map<String, dynamic> json) => ResListResponse.fromJson(json),
    );
  }

  ////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////
  //// COMMON
  ////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////

  Future<TResp> fetch<TReq, TResp>(
      String function, TReq request, FromJsonFunc fromJson) async {
    return fetchXchg(function, request, fromJson);

    /*if (transport == "https/cloud") {
      return fetchCloud(function, request, fromJson);
    }
    return fetchLocal(function, request, fromJson);*/
  }

  Uint8List int32bytes(int value) =>
      Uint8List(4)..buffer.asUint32List()[0] = value;

  Future<TResp> fetchXchg<TReq, TResp>(
      String function, TReq request, FromJsonFunc fromJson) async {
    //print("fetchXchg $function");

    // Gazer request body
    var reqString = jsonEncode(request);
    var res = await Repository().peer.call(address, accessKey, function,
        Uint8List.fromList(utf8.encode(reqString)));

    if (!res.isError()) {
      String s = utf8.decode(res.data);
      //print("RESULT: $s");
      //var fResp = Frame.fromJson(jsonDecode(s));
      return fromJson(jsonDecode(s));
    } else {
      lastError = res.error;
      //print("err: ${tr.error}");
      print("RESULT ERROR: ${res.error}");
      throw GazerClientException(res.error);
    }
  }

  String displayName() {
    if (transport == "https/cloud") {
      return "Cloud Node " + address;
    }
    return address;
  }

  String linkInformation() {
    return Repository().peer.remotePeerTransport(address);
  }

///////////////////////////////////////
  DateTime lastRefreshState = DateTime.now();
  ServiceInfoResponse? lastServiceInfo;
  void refreshState() {
    if (DateTime.now().difference(lastRefreshState).inSeconds.abs() < 3) return;
    lastRefreshState = DateTime.now();
    serviceInfo().then((value) {
      lastServiceInfo = value;
    });
  }
}

class GazerClientException implements Exception {
  final String message;
  GazerClientException(this.message);
  @override
  String toString() {
    return message;
  }
}

class GazerCloudWhereNodeResponse {
  final String nodeId;
  final String host;
  GazerCloudWhereNodeResponse(this.nodeId, this.host);
  factory GazerCloudWhereNodeResponse.fromJson(Map<String, dynamic> json) {
    return GazerCloudWhereNodeResponse(json['node_id'], json['host']);
  }
}
