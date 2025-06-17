// // import 'dart:async';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:flutter_sound/public/flutter_sound_recorder.dart'show FlutterSoundRecorder;
// // import 'package:get/get_core/src/get_main.dart';
// // import 'package:get/get_navigation/get_navigation.dart';
// // import 'package:just_audio/just_audio.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:intl/intl.dart';

// // class AudioFile {
// //   final String path;
// //   final String name;
// //   final int size;
// //   final DateTime addedAt;

// //   AudioFile({
// //     required this.path,
// //     required this.name,
// //     required this.size,
// //     required this.addedAt,
// //   });
// // }

// // class AudioListPage extends StatefulWidget {
// //   const AudioListPage({Key? key}) : super(key: key);

// //   @override
// //   _AudioListPageState createState() => _AudioListPageState();
// // }

// // class _AudioListPageState extends State<AudioListPage> with TickerProviderStateMixin{
// //   final AudioPlayer _player = AudioPlayer();
// //   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
// //   final List<AudioFile> _audioFiles = [];
// //   AudioFile? _currentlyPlaying;
// //   bool _isPlaying = false;
// //   bool _isRecording = false;
// //   String? _recordedPath;
// //   int _recordDuration = 0;
// //   Timer? _recordTimer;
// //   bool isOpen = false;
// //   late AnimationController _animationController;

  

// //   @override
// //   void initState() {
// //      _animationController =
// //         AnimationController(vsync: this, duration: Duration(milliseconds: 100));
// //     super.initState();
// //     _requestPermissions();
// //   }

// //   void _toggle() {
// //     setState(() {
// //       isOpen = !isOpen;
// //       isOpen ? _animationController.forward() : _animationController.reverse();
// //     });
// //   }



// //   Future<void> _requestPermissions() async {
// //     await [
// //       Permission.audio,
// //       Permission.storage,
// //       Permission.microphone,
// //     ].request();
// //   }

// //   Future<void> _pickMultipleAudios() async {
// //     await _requestPermissions();

// //     final result = await FilePicker.platform.pickFiles(
// //       type: FileType.audio,
// //       allowMultiple: true,
// //     );

// //     if (result != null) {
// //       final files =
// //           result.files
// //               .where((f) => f.path != null)
// //               .map((f) => File(f.path!))
// //               .where((file) => file.existsSync())
// //               .map(
// //                 (file) => AudioFile(
// //                   path: file.path,
// //                   name: file.uri.pathSegments.last,
// //                   size: file.lengthSync(),
// //                   addedAt: DateTime.now(),
// //                 ),
// //               )
// //               .toList();

// //       setState(() {
// //         _audioFiles.addAll(files);
// //       });
// //     }
// //   }

// //   Future<void> _startRecording() async {
// //     final dir = await getApplicationDocumentsDirectory();
// //     final path =
// //         '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
// //     _recordedPath = path;

// //     await _recorder.openRecorder();
// //     await _recorder.startRecorder(toFile: path);

// //     setState(() {
// //       _isRecording = true;
// //       _recordDuration = 0;
// //     });
// //     _recordTimer = Timer.periodic(Duration(seconds: 1), (timer) {
// //       setState(() {
// //         _recordDuration++;
// //       });
// //     });
// //   }

// //   Future<void> _stopRecording() async {
// //     await _recorder.stopRecorder();
// //     await _recorder.closeRecorder();
// //     _recordTimer?.cancel();

// //     final file = File(_recordedPath!);
// //     if (await file.exists()) {
// //       final audio = AudioFile(
// //         path: file.path,
// //         name: file.uri.pathSegments.last,
// //         size: file.lengthSync(),
// //         addedAt: DateTime.now(),
// //       );

// //       setState(() {
// //         _audioFiles.add(audio);
// //         _isRecording = false;
// //       });
// //     }
// //   }

// //   Future<void> _playOrPauseAudio(AudioFile file) async {
// //     if (_currentlyPlaying?.path != file.path) {
// //       await _player.setFilePath(file.path);
// //       await _player.play();
// //       setState(() {
// //         _currentlyPlaying = file;
// //         _isPlaying = true;
// //       });
// //     } else {
// //       if (_isPlaying) {
// //         await _player.pause();
// //       } else {
// //         await _player.play();
// //       }
// //       setState(() {
// //         _isPlaying = !_isPlaying;
// //       });
// //     }
// //   }

// //   void _deleteAudio(AudioFile file) {
// //     setState(() {
// //       _audioFiles.remove(file);
// //       if (_currentlyPlaying?.path == file.path) {
// //         _player.stop();
// //         _currentlyPlaying = null;
// //         _isPlaying = false;
// //       }
// //     });
// //   }

// //   void _showAddOptions() {
// //     showModalBottomSheet(
// //       context: context,
// //       builder: (_) {
// //         return Wrap(
// //           children: [
// //             ListTile(
// //               leading: Icon(Icons.library_music),
// //               title: Text("Pick Music"),
// //               onTap: () {
// //                 Navigator.pop(context);
// //                 _pickMultipleAudios();
// //               },
// //             ),
// //             ListTile(
// //               leading: Icon(Icons.mic),
// //               title: Text(_isRecording ? "Stop Recording" : "Record Audio"),
// //               onTap: () {
// //                 Navigator.pop(context);
// //                 _isRecording ? _stopRecording() : _startRecording();
// //               },
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   String _formatSize(int bytes) {
// //     if (bytes >= 1024 * 1024) {
// //       return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
// //     } else {
// //       return "${(bytes / 1024).toStringAsFixed(1)} KB";
// //     }
// //   }

// //   String _formatDuration(int seconds) {
// //     final mins = (seconds ~/ 60).toString().padLeft(2, '0');
// //     final secs = (seconds % 60).toString().padLeft(2, '0');
// //     return '$mins:$secs';
// //   }

// //   @override
// //   void dispose() {
// //     _player.dispose();
// //     _recorder.closeRecorder();
// //     _recordTimer?.cancel();
// //     _animationController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final df = DateFormat('yyyy-MM-dd HH:mm:ss');

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(
// //           "Upload Music",
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             color: Colors.blue.shade900,
// //           ),
// //         ),
// //         leading: Builder(
// //           builder:
// //               (context) => IconButton(
// //                 icon: Icon(
// //                   Icons.arrow_back_sharp,
// //                   color: Colors.blue.shade900,
// //                   size: 30,
// //                 ),
// //                 onPressed: () {
// //                   Get.back();
// //                 },
// //               ),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(8.0),
// //         child: Column(
// //           children: [
// //             if (_isRecording)
// //               Card(
// //                 color: Colors.red.shade50,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 elevation: 4,
// //                 child: ListTile(
// //                   leading: Icon(Icons.mic, color: Colors.redAccent, size: 36),
// //                   title: Text(
// //                     "Recording...",
// //                     style: TextStyle(color: Colors.redAccent),
// //                   ),
// //                   subtitle: Text(
// //                     _formatDuration(_recordDuration),
// //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                   ),
                
// //                   trailing: IconButton(
// //                     icon: Icon(
// //                       Icons.stop_circle,
// //                       size: 36,
// //                       color: Colors.redAccent,
// //                     ),
// //                     onPressed: _stopRecording,
// //                   ),
// //                 ),
// //               ),
// //             Expanded(
// //               child:
// //                   _audioFiles.isEmpty
// //                       ? Center(child: Text("No audio files added."))
// //                       : ListView.builder(
// //                         itemCount: _audioFiles.length,
// //                         itemBuilder: (context, index) {
// //                           final file = _audioFiles[index];
// //                           final isPlayingThis =
// //                               _currentlyPlaying?.path == file.path &&
// //                               _isPlaying;
// //                           return Card(
// //                             elevation: 3,
// //                             margin: EdgeInsets.symmetric(vertical: 6),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: ListTile(
// //                               contentPadding: EdgeInsets.all(12),
// //                               leading: Icon(
// //                                 Icons.music_note,
// //                                 color: Colors.blue.shade900,
// //                               ),
// //                               title: Text(
// //                                 file.name,
// //                                 style: TextStyle(fontWeight: FontWeight.bold),
// //                               ),
// //                               subtitle: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text("Size: ${_formatSize(file.size)}"),
// //                                   Text("Added: ${df.format(file.addedAt)}"),
// //                                 ],
// //                               ),
// //                               trailing: Row(
// //                                 mainAxisSize: MainAxisSize.min,
// //                                 children: [
// //                                   IconButton(
// //                                     icon: Icon(
// //                                       isPlayingThis
// //                                           ? Icons.pause_circle_filled
// //                                           : Icons.play_circle_fill,
// //                                       size: 32,
// //                                       color: Colors.blueAccent,
// //                                     ),
// //                                     onPressed: () => _playOrPauseAudio(file),
// //                                   ),
// //                                   IconButton(
// //                                     icon: Icon(
// //                                       Icons.delete,
// //                                       color: Colors.redAccent,
// //                                     ),
// //                                     onPressed: () => _deleteAudio(file),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //             ),
// //           ],
// //         ),
// //       ),

// //     floatingActionButton: SizedBox(
// //   width: 200,
// //   height: 200,
// //   child: Stack(
// //     alignment: Alignment.bottomRight,
// //     children: [
// //       // Mic Button - Top
// //       Positioned(
// //         bottom: 80,
// //         right: 0,
// //         child: ScaleTransition(
// //           scale: Tween<double>(begin: 0, end: 1).animate(
// //             CurvedAnimation(
// //               parent: _animationController,
// //               curve: Curves.easeOut,
// //             ),
// //           ),
// //           child: FloatingActionButton(
// //             heroTag: "mic",
// //             mini: true,
// //             backgroundColor: Colors.redAccent,
// //             onPressed: () {
// //               isOpen ? (_isRecording ? _stopRecording() : _startRecording()) : null;
// //               _toggle();
// //             },
// //             child: Icon(_isRecording ? Icons.stop : Icons.mic,color: Colors.white,),
// //           ),
// //         ),
// //       ),

// //       // Music Button - Left
// //       Positioned(
// //         bottom: 0,
// //         right: 80,
// //         child: ScaleTransition(
// //           scale: Tween<double>(begin: 0, end: 1).animate(
// //             CurvedAnimation(
// //               parent: _animationController,
// //               curve: Curves.easeOut,
// //             ),
// //           ),
// //           child: FloatingActionButton(
// //             heroTag: "music",
// //             mini: true,
// //             backgroundColor: Colors.green,
// //             onPressed: () {
// //               _pickMultipleAudios();
// //               _toggle();
// //             },
// //             child: Icon(Icons.library_music,color: Colors.white,),
// //           ),
// //         ),
// //       ),

// //       // Main FAB - Center
// //       FloatingActionButton(
// //         heroTag: "main",
// //         backgroundColor: Colors.blue.shade900,
// //         onPressed: _toggle,
// //         child: AnimatedBuilder(
// //           animation: _animationController,
// //           builder: (context, child) {
// //             return Transform.rotate(
// //               angle: _animationController.value * 0.5 * 3.14,
// //               child: Icon(Icons.add,color: Colors.white,),
// //             );
// //           },
// //         ),
// //       ),
// //     ],
// //   ),
// // ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:rimza1/Logic/bloc/addmusic/addmusic_bloc.dart';
// import 'package:rimza1/Logic/bloc/addmusic/addmusic_event.dart';
// import 'package:rimza1/Logic/bloc/addmusic/addmusic_state.dart';



// class AudioListPage extends StatefulWidget {
//   const AudioListPage({super.key});

//   @override
//   State<AudioListPage> createState() => _AudioListPageState();
// }

// class _AudioListPageState extends State<AudioListPage> with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   bool isOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
//   }

//   void _toggle() {
//     setState(() {
//       isOpen = !isOpen;
//       isOpen ? _animationController.forward() : _animationController.reverse();
//     });
//   }

//   String _formatSize(int bytes) {
//     if (bytes >= 1024 * 1024) {
//       return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
//     } else {
//       return "${(bytes / 1024).toStringAsFixed(1)} KB";
//     }
//   }

//   String _formatDuration(int seconds) {
//     final mins = (seconds ~/ 60).toString().padLeft(2, '0');
//     final secs = (seconds % 60).toString().padLeft(2, '0');
//     return '$mins:$secs';
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final df = DateFormat('yyyy-MM-dd HH:mm:ss');

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Upload Music",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.blue.shade900,
//           ),
//         ),
//         leading: BackButton(color: Colors.blue.shade900),
//       ),
//       body: BlocBuilder<AudioBloc, AudioState>(
//         builder: (context, state) {
//           if (state is AudioLoaded) {
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   if (state.isRecording)
//                     Card(
//                       color: Colors.red.shade50,
//                       child: ListTile(
//                         leading: Icon(Icons.mic, color: Colors.redAccent, size: 36),
//                         title: Text("Recording...", style: TextStyle(color: Colors.redAccent)),
//                         subtitle: Text(_formatDuration(state.recordDuration)),
//                         trailing: IconButton(
//                           icon: Icon(Icons.stop, color: Colors.redAccent),
//                           onPressed: () => context.read<AudioBloc>().add(StopRecording()),
//                         ),
//                       ),
//                     ),
//                   Expanded(
//                     child: state.audioFiles.isEmpty
//                         ? Center(child: Text("No audio files added."))
//                         : ListView.builder(
//                             itemCount: state.audioFiles.length,
//                             itemBuilder: (context, index) {
//                               final file = state.audioFiles[index];
//                               final isPlaying = state.currentlyPlaying?.path == file.path && state.isPlaying;
//                               return Card(
//                                 child: ListTile(
//                                   leading: Icon(Icons.music_note, color: Colors.blue.shade900),
//                                   title: Text(file.name),
//                                   subtitle: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text("Size: ${_formatSize(file.size)}"),
//                                       Text("Added: ${df.format(file.addedAt)}"),
//                                     ],
//                                   ),
//                                   trailing: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       IconButton(
//                                         icon: Icon(
//                                           isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
//                                           color: Colors.blue,
//                                         ),
//                                         onPressed: () {
//                                           context.read<AudioBloc>().add(PlayAudio(file));
//                                         },
//                                       ),
//                                       IconButton(
//                                         icon: Icon(Icons.delete, color: Colors.red),
//                                         onPressed: () {
//                                           context.read<AudioBloc>().add(DeleteAudio(file));
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             );
//           } else if (state is AudioError) {
//             return Center(child: Text(state.message));
//           } else {
//             return Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: SizedBox(
//         width: 200,
//         height: 200,
//         child: BlocBuilder<AudioBloc, AudioState>(
//           builder: (context, state) {
//             final isRecording = state is AudioLoaded && state.isRecording;

//             return Stack(
//               alignment: Alignment.bottomRight,
//               children: [
//                 // Mic Button
//                 Positioned(
//                   bottom: 80,
//                   right: 0,
//                   child: ScaleTransition(
//                     scale: Tween<double>(begin: 0, end: 1).animate(
//                       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//                     ),
//                     child: FloatingActionButton(
//                       heroTag: "mic",
//                       mini: true,
//                       backgroundColor: Colors.redAccent,
//                       onPressed: () {
//                         if (isOpen) {
//                           context.read<AudioBloc>().add(isRecording ? StopRecording() : StartRecording());
//                           _toggle();
//                         }
//                       },
//                       child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 // Music Button
//                 Positioned(
//                   bottom: 0,
//                   right: 80,
//                   child: ScaleTransition(
//                     scale: Tween<double>(begin: 0, end: 1).animate(
//                       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//                     ),
//                     child: FloatingActionButton(
//                       heroTag: "music",
//                       mini: true,
//                       backgroundColor: Colors.green,
//                       onPressed: () {
//                         context.read<AudioBloc>().add(PickAudios());
//                         _toggle();
//                       },
//                       child: Icon(Icons.library_music, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 // Main FAB
//                 FloatingActionButton(
//                   heroTag: "main",
//                   backgroundColor: Colors.blue.shade900,
//                   onPressed: _toggle,
//                   child: AnimatedBuilder(
//                     animation: _animationController,
//                     builder: (context, child) {
//                       return Transform.rotate(
//                         angle: _animationController.value * 0.5 * 3.14,
//                         child: Icon(Icons.add, color: Colors.white),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
