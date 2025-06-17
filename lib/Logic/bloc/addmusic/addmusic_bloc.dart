import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rimza1/Logic/bloc/addmusic/addmusic_event.dart';
import 'package:rimza1/Logic/bloc/addmusic/addmusic_state.dart';


class MusicUploadBloc extends Bloc<MusicUploadEvent, MusicUploadState> {
  MusicUploadBloc() : super(MusicUploadInitial()) {
    on<FetchMusicList>(_onFetchMusicList);
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<StartPlayback>(_onStartPlayback);
    on<StopPlayback>(_onStopPlayback);
    // on<UploadFile>(_onUploadFile);
    on<DownloadAndPlay>(_onDownloadAndPlay);
    on<DeleteFile>(_onDeleteFile);
     on<LoadAudios>(_onLoadAudios);
    on<UploadAudio>(_onUploadAudio);
     on<PickFileEvent>(_onPickFile);
     on<UploadFileEvent>(_onUploadFile);
  }

Future<void> _onPickFile(
      PickFileEvent event, Emitter<MusicUploadState> emit) async {
    emit(MusicUploadPicking());
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result != null && result.files.single.path != null) {
      emit(MusicUploadPicked(result.files.single.path!));
    } else {
      emit(MusicUploadInitial());
    }
  }

Future<void> _onUploadFile(
      UploadFileEvent event, Emitter<MusicUploadState> emit) async {
    emit(MusicUploadUploading(0.0));
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      emit(MusicUploadUploading(i / 10));
    }
    emit(MusicUploadSuccess());
  }



  Future<void> _onFetchMusicList(
      FetchMusicList event, Emitter<MusicUploadState> emit) async {
    emit(MusicListLoading());
    try {
      // Implement your logic to fetch music list
      final List<String> musicList = []; // Replace with actual data
      emit(MusicListLoaded(musicList: musicList));
    } catch (e) {
      emit(UploadFailure(error: e.toString()));
    }
  }

   

  void _onUploadAudio(UploadAudio event, Emitter<MusicUploadState> emit) async {
    emit(MusicUploadLoading());
    try {
      // Implement your upload logic here
      // For demonstration, we'll simulate a delay
      await Future.delayed(Duration(seconds: 2));
      emit(MusicUploadSuccess());
    } catch (e) {
      emit(MusicUploadFailure(e.toString()));
    }
  }

  Future<void> _onStartRecording(
      StartRecording event, Emitter<MusicUploadState> emit) async {
    // Implement your logic to start recording
    emit(RecordingInProgress(duration: Duration.zero));
  }

void _onLoadAudios(LoadAudios event, Emitter<MusicUploadState> emit) {
    // Implement logic to load existing audios
    // For demonstration, we'll emit a success state directly
    emit(MusicUploadSuccess());
  }

  Future<void> _onStopRecording(
      StopRecording event, Emitter<MusicUploadState> emit) async {
    // Implement your logic to stop recording
    emit(RecordingStopped());
  }

  Future<void> _onStartPlayback(
      StartPlayback event, Emitter<MusicUploadState> emit) async {
    // Implement your logic to start playback
    emit(PlaybackInProgress(duration: Duration.zero));
  }

  Future<void> _onStopPlayback(
      StopPlayback event, Emitter<MusicUploadState> emit) async {
    // Implement your logic to stop playback
    emit(PlaybackStopped());
  }

  // Future<void> _onUploadFile(
  //     UploadFile event, Emitter<MusicUploadState> emit) async {
  //   emit(UploadInProgress(progress: 0.0));
  //   try {
  //     // Implement your logic to upload file
  //     emit(UploadSuccess());
  //   } catch (e) {
  //     emit(UploadFailure(error: e.toString()));
  //   }
  // }

  Future<void> _onDownloadAndPlay(
      DownloadAndPlay event, Emitter<MusicUploadState> emit) async {
    emit(DownloadInProgress());
    try {
      // Implement your logic to download and play file
      emit(DownloadSuccess());
    } catch (e) {
      emit(DownloadFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteFile(
      DeleteFile event, Emitter<MusicUploadState> emit) async {
    try {
      // Implement your logic to delete file
      emit(DeletionSuccess());
    } catch (e) {
      emit(DeletionFailure(error: e.toString()));
    }
  }
}
