import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/protocol/unit/unit_items_values.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

abstract class NodeFormState {
}

class NodeFormStateLoaded extends NodeFormState {
  final UnitStateAllResponse response;
  NodeFormStateLoaded(this.response);
}

class NodeFormStateLoading extends NodeFormState {
}

class NodeFormCubit extends Cubit<NodeFormState> {
  Map<String, UnitStateAllResponse> lastResponses = {};
  //UnitStateAllResponse? lastResponse;
  String lastConnectionAddress = "";

  NodeFormCubit(NodeFormState initialState) : super(initialState);
  void load(Connection conn) async {
    if (lastResponses.containsKey(conn.address)) {
      var lastResponse = lastResponses[conn.address];
      emit(NodeFormStateLoaded(lastResponse!));
    } else {
      emit(NodeFormStateLoading());
    }

    lastConnectionAddress = conn.address;

    GazerLocalClient client = Repository().client(conn);
    var result = await client.unitsStateAll();
    NodeFormState state = NodeFormStateLoaded(result);
    emit(state);
    lastResponses[conn.address] = result;
  }
}
