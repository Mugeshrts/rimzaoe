import 'package:equatable/equatable.dart';

abstract class MusicUploadState extends Equatable {
  const MusicUploadState();

  @override
  List<Object> get props => [];
}

class MusicUploadInitial extends MusicUploadState {}

class MusicListLoading extends MusicUploadState {}
class MusicUploadLoading extends MusicUploadState {}
class MusicUploadSuccess extends MusicUploadState {}

class MusicListLoaded extends MusicUploadState {
  final List<String> musicList;

  const MusicListLoaded({required this.musicList});

  @override
  List<Object> get props => [musicList];
}

class RecordingInProgress extends MusicUploadState {
  final Duration duration;

  const RecordingInProgress({required this.duration});

  @override
  List<Object> get props => [duration];
}

class RecordingStopped extends MusicUploadState {}

class PlaybackInProgress extends MusicUploadState {
  final Duration duration;

  const PlaybackInProgress({required this.duration});

  @override
  List<Object> get props => [duration];
}

class PlaybackStopped extends MusicUploadState {}

class UploadInProgress extends MusicUploadState {
  final double progress;

  const UploadInProgress({required this.progress});

  @override
  List<Object> get props => [progress];
}

class UploadSuccess extends MusicUploadState {}

class UploadFailure extends MusicUploadState {
  final String error;

  const UploadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class DownloadInProgress extends MusicUploadState {}

class DownloadSuccess extends MusicUploadState {}

class DownloadFailure extends MusicUploadState {
  final String error;

  const DownloadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class DeletionSuccess extends MusicUploadState {}

class DeletionFailure extends MusicUploadState {
  final String error;

  const DeletionFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class MusicUploadFailure extends MusicUploadState {
  final String error;

  const MusicUploadFailure(this.error);

  @override
  List<Object> get props => [error];
}

class MusicUploadUploading extends MusicUploadState {
  final double progress;

  MusicUploadUploading(this.progress);

  @override
  List<Object> get props => [progress];
}

class MusicUploadPicking extends MusicUploadState {}


