import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/protocol/unit/unit_items_values.dart';
import 'package:gazer_client/core/protocol/unit/unit_state.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

abstract class UnitFormState {
}

class UnitFormStateLoaded extends UnitFormState {
  final UnitStateResponse response;
  UnitFormStateLoaded(this.response);
}

class UnitFormStateLoading extends UnitFormState {
}

class UnitFormCubit extends Cubit<UnitFormState> {
  Map<String, UnitStateResponse> lastResponses = {};
  String lastConnectionAddress = "";

  UnitFormCubit(UnitFormState initialState) : super(initialState);
  void load(Connection conn, String unitId) async {
    if (lastResponses.containsKey(conn.address)) {
      var lastResponse = lastResponses[conn.address];
      emit(UnitFormStateLoaded(lastResponse!));
    } else {
      emit(UnitFormStateLoading());
    }

    lastConnectionAddress = conn.address;

    GazerLocalClient client = Repository().client(conn);
    var result = await client.unitsState(unitId);
    UnitFormState state = UnitFormStateLoaded(result);
    emit(state);
    lastResponses[conn.address] = result;
  }
}
