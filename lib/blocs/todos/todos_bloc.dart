import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ft_bloc_todos/blocs/todos/todos.dart';
import 'package:ft_bloc_todos/models/models.dart';
import 'package:todos_repository_simple/todos_repository_simple.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepositoryFlutter todosRepository;

  TodosBloc({@required this.todosRepository}) : super(TodosLoadInProgress());

  @override
  Stream<TodosState> mapEventToState(
    TodosEvent event,
  ) async* {
    if(event is TodosLoaded) {
      yield* _mapTodosLoadedToState();
    } else if(event is TodoAdded) {
      yield* _mapTodosAddedToState(event);
    } else if(event is TodoUpdated) {
      yield* _mapTodosUpdatedToState(event);
    } if(event is TodoDeleted) {
      yield* _mapTodosDeletedToState(event);
    } if(event is ToggleAll) {
      yield* _mapToggleAllToState();
    } if(event is ClearCompleted) {
      yield* _mapClearCompletedToState();
    }

  }

  Stream<TodosState> _mapTodosLoadedToState() async* {
    try {
      final todos = await this.todosRepository.loadTodos();
      yield TodosLoadSuccess(
        todos.map(Todo.fromEntity).toList(),
      );

    } catch(_) {
      yield TodosLoadFailure();
    }
  }

  Stream<TodosState> _mapTodosAddedToState(TodoAdded event) async* {
    if(state is TodosLoadSuccess) {
      final List<Todo> updatedTodos =
          List.from((state as TodosLoadSuccess).todos)..add(event.todo);
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Future _saveTodos(List<Todo> todos) {
    return todosRepository.saveTodos(
      todos.map((todo) => todo.todoEntity()).toList(),
    );
  }

  Stream<TodosState> _mapTodosUpdatedToState(TodoUpdated event) async* {
    if(state is TodosLoadSuccess) {
      final List<Todo> updatedTodos =
      (state as TodosLoadSuccess).todos.map((todo) {
        return todo.id == event.todo.id ? event.todo : todo;
      }).toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapTodosDeletedToState(TodoDeleted event) async* {
    if(state is TodosLoadSuccess) {
      final updatedTodos =
      (state as TodosLoadSuccess).todos
        .where((todo) => todo.id != event.todo.id)
        .toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapToggleAllToState() async* {
    if(state is TodosLoadSuccess) {
      final allComplete = (state as TodosLoadSuccess)
        .todos.every((todo) => todo.complete);

      final List<Todo> updatedTodos = (state as TodosLoadSuccess)
          .todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapClearCompletedToState() async* {
    if(state is TodosLoadSuccess) {
      final List<Todo> updatedTodos = (state as TodosLoadSuccess)
          .todos
          .where((todo) => !todo.complete)
          .toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }
}
