import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ft_bloc_todos/models/models.dart';

part 'tab_event.dart';

class TabBloc extends Bloc<TabEvent, AppTab> {
  TabBloc() : super(AppTab.todos);

  @override
  Stream<AppTab> mapEventToState(
    TabEvent event,
  ) async* {
    if(event is TabUpdated) {
      yield event.tab;
    }
  }
}
