import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainFormState {
  List<Connection> connections;
  MainFormState(this.connections);
}

class MainFormBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    //print("MainFormBloc - onChange ${change.currentState}");
  }
}

class MainFormCubit extends Cubit<MainFormState> {
  MainFormCubit(MainFormState initialState) : super(initialState);

  void load() async {
    final prefs = await SharedPreferences.getInstance();
    var wsContent = prefs.getString("ws") ?? "{}";
    MainFormState state = MainFormState([]);
    try {
      late Workspace ws;
      ws = Workspace.fromJson(jsonDecode(wsContent));
      for (var conn in ws.connections) {
          state.connections.add(conn);
      }
    } catch (ex) {
    }

    emit(state);
  }

  void save() {
    // TODO: save
    load();
  }

  void add(Connection conn) async {
    save();
  }

  void remove(String id) async {
    await wsRemoveConnection(id);
    load();
  }
}
