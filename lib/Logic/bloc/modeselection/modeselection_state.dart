class ModeSelectionState {
  final String currentTime;
  final String currentDate;
  final String selectedMode;
  final bool isExamMode;

  ModeSelectionState({
    required this.currentTime,
    required this.currentDate,
    required this.selectedMode,
    required this.isExamMode,
  });

  ModeSelectionState copyWith({
    String? currentTime,
    String? currentDate,
    String? selectedMode,
    bool? isExamMode,
  }) {
    return ModeSelectionState(
      currentTime: currentTime ?? this.currentTime,
      currentDate: currentDate ?? this.currentDate,
      selectedMode: selectedMode ?? this.selectedMode,
      isExamMode: isExamMode ?? this.isExamMode,
    );
  }
}
