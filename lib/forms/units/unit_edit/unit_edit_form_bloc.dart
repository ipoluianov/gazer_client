import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/protocol/unit_type/unit_type_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

abstract class UnitEditFormState {
}

class UnitEditFormStateLoaded extends UnitEditFormState {
  UnitTypeListResponse response;
  UnitEditFormStateLoaded(this.response);
}

class UnitEditFormStateLoading extends UnitEditFormState {
}

class UnitEditFormCubit extends Cubit<UnitEditFormState> {

  UnitEditFormCubit(UnitEditFormState initialState) : super(initialState);
  void load(Connection conn) async {
    emit(UnitEditFormStateLoading());

    var client = Repository().client(conn);
    var response = await client.unitTypeList("", "", 0, 1000);
    emit(UnitEditFormStateLoaded(response));
  }
}
