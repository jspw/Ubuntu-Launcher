part of 'opacity_cubit.dart';

abstract class OpacityState extends Equatable {
  const OpacityState();

  @override
  List<Object> get props => [];
}

class OpacityInitial extends OpacityState {}

class OpacitySemi extends OpacityState {}

