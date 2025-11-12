import 'package:chat_app/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Generic BaseBloc class
abstract class BaseBloc<E, S> extends Bloc<E, S> {
  BaseBloc(S initialState) : super(initialState);
  late Either<Failure, dynamic> result;
  static T get<T extends Bloc>(BuildContext context) =>
      BlocProvider.of<T>(context);

  void emitDone(Function(dynamic) value) {
    result.fold((l) => null, (r) => value(r));
  }
}
