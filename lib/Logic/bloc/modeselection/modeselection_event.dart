abstract class ModeSelectionEvent {}

class UpdateMode extends ModeSelectionEvent {
  final String mode;
  UpdateMode(this.mode);
}

class ToggleExamMode extends ModeSelectionEvent {}

class UpdateTimeDate extends ModeSelectionEvent {}
