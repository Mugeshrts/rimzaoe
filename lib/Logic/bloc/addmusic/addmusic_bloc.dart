import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rimza1/Logic/bloc/addmusic/addmusic_event.dart';
import 'package:rimza1/Logic/bloc/addmusic/addmusic_state.dart';
import 'package:rimza1/data/audiofile.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioPlayer _player = AudioPlayer();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  List<AudioFile> _audioFiles = [];
  AudioFile? _currentlyPlaying;
  bool _isPlaying = false;
  bool _isRecording = false;
  String? _recordedPath;
  int _recordDuration = 0;
  Timer? _recordTimer;

   AudioBloc() : super(AudioInitial()) {
    on<LoadAudios>(_onLoadAudios);
    on<AddAudio>(_onAddAudio);
    on<DeleteAudio>(_onDeleteAudio);
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<PickAudios>(_onPickAudios);
  }

  Future<void> _onLoadAudios(LoadAudios event, Emitter<AudioState> emit) async {
    emit(AudioLoaded(
      audioFiles: _audioFiles,
      currentlyPlaying: _currentlyPlaying,
      isPlaying: _isPlaying,
      isRecording: _isRecording,
      recordDuration: _recordDuration,
    ));
  }

   void _onAddAudio(AddAudio event, Emitter<AudioState> emit) {
    _audioFiles.add(event.audioFile);
    add(LoadAudios());
  }


  // Future<void> _onAddAudio(AddAudio event, Emitter<AudioState> emit) async {
  //   _audioFiles.add(event.audioFile);
  //   emit(AudioLoaded(
  //     audioFiles: _audioFiles,
  //     currentlyPlaying: _currentlyPlaying,
  //     isPlaying: _isPlaying,
  //     isRecording: _isRecording,
  //     recordDuration: _recordDuration,
  //   ));
  // }

  Future<void> _onDeleteAudio(DeleteAudio event, Emitter<AudioState> emit) async {
    _audioFiles.remove(event.audioFile);
    if (_currentlyPlaying?.path == event.audioFile.path) {
      await _player.stop();
      _currentlyPlaying = null;
      _isPlaying = false;
    }
    emit(AudioLoaded(
      audioFiles: _audioFiles,
      currentlyPlaying: _currentlyPlaying,
      isPlaying: _isPlaying,
      isRecording: _isRecording,
      recordDuration: _recordDuration,
    ));
  }

  Future<void> _onStartRecording(StartRecording event, Emitter<AudioState> emit) async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      emit(AudioError("Microphone permission not granted"));
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
    _recordedPath = path;

    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: path);

    _isRecording = true;
    _recordDuration = 0;

    _recordTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _recordDuration++;
      add(LoadAudios());
    });

    add(LoadAudios());
  }

  Future<void> _onStopRecording(StopRecording event, Emitter<AudioState> emit) async {
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    _recordTimer?.cancel();

    final file = File(_recordedPath!);
    if (await file.exists()) {
      final audio = AudioFile(
        path: file.path,
        name: file.uri.pathSegments.last,
        size: file.lengthSync(),
        addedAt: DateTime.now(),
      );

      _audioFiles.add(audio);
    }

    _isRecording = false;
    _recordDuration = 0;

    // emit(AudioLoaded(
    //   audioFiles: _audioFiles,
    //   currentlyPlaying: _currentlyPlaying,
    //   isPlaying: _isPlaying,
    //   isRecording: _isRecording,
    //   recordDuration: _recordDuration,
    // ));
    add(LoadAudios());
  }

  Future<void> _onPlayAudio(PlayAudio event, Emitter<AudioState> emit) async {
    if (_currentlyPlaying?.path != event.audioFile.path) {
      await _player.setFilePath(event.audioFile.path);
      await _player.play();
      _currentlyPlaying = event.audioFile;
      _isPlaying = true;
    } else {
      if (_isPlaying) {
        await _player.pause();
        _isPlaying = false;
      } else {
        await _player.play();
        _isPlaying = true;
      }
    }

    // emit(AudioLoaded(
    //   audioFiles: _audioFiles,
    //   currentlyPlaying: _currentlyPlaying,
    //   isPlaying: _isPlaying,
    //   isRecording: _isRecording,
    //   recordDuration: _recordDuration,
    // ));
    add(LoadAudios());
  }

  // Future<void> _onPauseAudio(PauseAudio event, Emitter<AudioState> emit) async {
  //   await _player.pause();
  //   _isPlaying = false;

  //   emit(AudioLoaded(
  //     audioFiles: _audioFiles,
  //     currentlyPlaying: _currentlyPlaying,
  //     isPlaying: _isPlaying,
  //     isRecording: _isRecording,
  //     recordDuration: _recordDuration,
  //   ));
  // }

 Future<void> _onPauseAudio(PauseAudio event, Emitter<AudioState> emit) async {
    await _player.pause();
    _isPlaying = false;
    add(LoadAudios());
  }

 Future<void> _onPickAudios(PickAudios event, Emitter<AudioState> emit) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      emit(AudioError("Storage permission not granted"));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      final files = result.files.where((f) => f.path != null).map((f) {
        final file = File(f.path!);
        return AudioFile(
          path: file.path,
          name: file.uri.pathSegments.last,
          size: file.lengthSync(),
          addedAt: DateTime.now(),
        );
      }).toList();

      _audioFiles.addAll(files);
      add(LoadAudios());
    }
  }

  @override
  Future<void> close() {
    _player.dispose();
    _recorder.closeRecorder();
    _recordTimer?.cancel();
    return super.close();
  }
}
