import 'package:equatable/equatable.dart';
import 'package:rimza1/Logic/bloc/addmusic/addmusic_state.dart';

abstract class MusicUploadEvent extends Equatable {
  const MusicUploadEvent();

  @override
  List<Object> get props => [];
}

class FetchMusicList extends MusicUploadEvent {}

class StartRecording extends MusicUploadEvent {}

class StopRecording extends MusicUploadEvent {}

class StartPlayback extends MusicUploadEvent {}

class StopPlayback extends MusicUploadEvent {}

class UploadFile extends MusicUploadEvent {
  final String filePath;
  final String fileName;

  const UploadFile({required this.filePath, required this.fileName});

  @override
  List<Object> get props => [filePath, fileName];
}

class DownloadAndPlay extends MusicUploadEvent {
  final String fileName;

  const DownloadAndPlay({required this.fileName});

  @override
  List<Object> get props => [fileName];
}

class DeleteFile extends MusicUploadEvent {
  final String fileName;

  const DeleteFile({required this.fileName});

  @override
  List<Object> get props => [fileName];
}

class LoadAudios extends MusicUploadEvent {}

class UploadAudio extends MusicUploadEvent {
  final String filePath;

  const UploadAudio(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class PickFileEvent extends MusicUploadEvent {}

class UploadFileEvent extends MusicUploadEvent {
  final String filePath;

  UploadFileEvent(this.filePath);

  @override
  List<Object> get props => [filePath];
}

class MusicUploadPicked extends MusicUploadState {
  final String filePath;

  MusicUploadPicked(this.filePath);

  @override
  List<Object> get props => [filePath];
}

