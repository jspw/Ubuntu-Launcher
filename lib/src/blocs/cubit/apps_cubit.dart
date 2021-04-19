import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'apps_state.dart';

class AppsCubit extends Cubit<AppsState> {
  AppsCubit() : super(AppsInitial());
}
