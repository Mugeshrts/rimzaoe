import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rimza1/Logic/bloc/modeselection/modeselection_state.dart';
import 'package:rimza1/Logic/bloc/modeselection/modeselection_event.dart';


class ModeSelectionBloc extends Bloc<ModeSelectionEvent, ModeSelectionState> {
  Timer? _timer;

  ModeSelectionBloc()
      : super(
          ModeSelectionState(
            currentTime: DateFormat('hh:mm:ss a').format(DateTime.now()),
            currentDate: DateFormat('EEE, dd-MM-yyyy').format(DateTime.now()),
            selectedMode: "Exam Mode",
            isExamMode: true,
          ),
        ) {
    on<UpdateMode>((event, emit) {
      emit(state.copyWith(selectedMode: event.mode));
    });

    on<ToggleExamMode>((event, emit) {
      emit(state.copyWith(isExamMode: !state.isExamMode));
    });

    on<UpdateTimeDate>((event, emit) {
      final now = DateTime.now();
      emit(state.copyWith(
        currentTime: DateFormat('hh:mm:ss a').format(now),
        currentDate: DateFormat('EEE, dd-MM-yyyy').format(now),
      ));
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      add(UpdateTimeDate());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
