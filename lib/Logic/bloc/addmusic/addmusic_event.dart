

import 'package:rimza1/data/audiofile.dart';

abstract class AudioEvent {}

class LoadAudios extends AudioEvent {}

class AddAudio extends AudioEvent {
  final AudioFile audioFile;
  AddAudio(this.audioFile);
}

class DeleteAudio extends AudioEvent {
  final AudioFile audioFile;
  DeleteAudio(this.audioFile);
}

class StartRecording extends AudioEvent {}

class StopRecording extends AudioEvent {}

class PlayAudio extends AudioEvent {
  final AudioFile audioFile;
  PlayAudio(this.audioFile);
}

class PauseAudio extends AudioEvent {}

class PickAudios extends AudioEvent {}
