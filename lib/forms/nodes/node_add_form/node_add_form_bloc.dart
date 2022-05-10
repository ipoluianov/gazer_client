import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

abstract class NodeAddFormState {
}

class NodeAddFormStateLoaded extends NodeAddFormState {
}

class NodeAddFormStateLoading extends NodeAddFormState {
}

class NodeAddFormCubit extends Cubit<NodeAddFormState> {

  NodeAddFormCubit(NodeAddFormState initialState) : super(initialState);
  void load() async {
    emit(NodeAddFormStateLoading());
  }
}
