import 'package:rimza1/data/audiofile.dart';

abstract class AudioState {}

class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {}

class AudioLoaded extends AudioState {
  final List<AudioFile> audioFiles;
  final AudioFile? currentlyPlaying;
  final bool isPlaying;
  final bool isRecording;
  final int recordDuration;

  AudioLoaded({
    required this.audioFiles,
    this.currentlyPlaying,
    this.isPlaying = false,
    this.isRecording = false,
    this.recordDuration = 0,
  });
}

class AudioError extends AudioState {
  final String message;
  AudioError(this.message);
}
