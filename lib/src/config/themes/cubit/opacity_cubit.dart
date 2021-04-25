import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'opacity_state.dart';

class OpacityCubit extends Cubit<OpacityState> {
  OpacityCubit() : super(OpacityInitial());

  void setOpacitySemi() => emit(OpacitySemi());

  void opacityReset() => emit(OpacityInitial());
}
