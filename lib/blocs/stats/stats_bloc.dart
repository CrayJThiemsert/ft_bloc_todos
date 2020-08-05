import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ft_bloc_todos/models/models.dart';
import 'package:ft_bloc_todos/blocs/blocs.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final TodosBloc todosBloc;
  StreamSubscription todosSubscription;

  StatsBloc({@required this.todosBloc}) : super(StatsLoadInProgress()) {
    todosSubscription = todosBloc.listen((state) {
      if(state is TodosLoadSuccess) {
        add(StatsUpdated(state.todos));
      }
    });
  }

  @override
  Stream<StatsState> mapEventToState(
    StatsEvent event,
  ) async* {
    if(event is StatsUpdated) {
      int numActive =
          event.todos
            .where((todo) => !todo.complete)
            .toList().length;
      int numCompleted =
          event.todos
              .where((todo) => todo.complete)
              .toList().length;
      yield StatsLoadSuccess(numActive, numCompleted);
    }
  }

  @override
  Future<Function> close() {
    todosSubscription.cancel();
    return super.close();
  }
}
