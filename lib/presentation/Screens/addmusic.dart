import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rimza1/Logic/bloc/addmusic/addmusic_bloc.dart';
import 'package:rimza1/Logic/bloc/addmusic/addmusic_event.dart';
import 'package:rimza1/Logic/bloc/addmusic/addmusic_state.dart';



class AudioListPage extends StatefulWidget {
  const AudioListPage({super.key});

  @override
  State<AudioListPage> createState() => _AudioListPageState();
}

class _AudioListPageState extends State<AudioListPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  void _toggle() {
    setState(() {
      isOpen = !isOpen;
      isOpen ? _animationController.forward() : _animationController.reverse();
    });
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    } else {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Upload Music",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
        leading: BackButton(color: Colors.blue.shade900),
      ),
      body: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          if (state is AudioLoaded) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (state.isRecording)
                    Card(
                      color: Colors.red.shade50,
                      child: ListTile(
                        leading: Icon(Icons.mic, color: Colors.redAccent, size: 36),
                        title: Text("Recording...", style: TextStyle(color: Colors.redAccent)),
                        subtitle: Text(_formatDuration(state.recordDuration)),
                        trailing: IconButton(
                          icon: Icon(Icons.stop, color: Colors.redAccent),
                          onPressed: () => context.read<AudioBloc>().add(StopRecording()),
                        ),
                      ),
                    ),
                  Expanded(
                    child: state.audioFiles.isEmpty
                        ? Center(child: Text("No audio files added."))
                        : ListView.builder(
                            itemCount: state.audioFiles.length,
                            itemBuilder: (context, index) {
                              final file = state.audioFiles[index];
                              final isPlaying = state.currentlyPlaying?.path == file.path && state.isPlaying;
                              return Card(
                                child: ListTile(
                                  leading: Icon(Icons.music_note, color: Colors.blue.shade900),
                                  title: Text(file.name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Size: ${_formatSize(file.size)}"),
                                      Text("Added: ${df.format(file.addedAt)}"),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          context.read<AudioBloc>().add(PlayAudio(file));
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          context.read<AudioBloc>().add(DeleteAudio(file));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          } else if (state is AudioError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: SizedBox(
        width: 200,
        height: 200,
        child: BlocBuilder<AudioBloc, AudioState>(
          builder: (context, state) {
            final isRecording = state is AudioLoaded && state.isRecording;

            return Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Mic Button
                Positioned(
                  bottom: 80,
                  right: 0,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                    ),
                    child: FloatingActionButton(
                      heroTag: "mic",
                      mini: true,
                      backgroundColor: Colors.redAccent,
                      onPressed: () {
                        if (isOpen) {
                          context.read<AudioBloc>().add(isRecording ? StopRecording() : StartRecording());
                          _toggle();
                        }
                      },
                      child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white),
                    ),
                  ),
                ),
                // Music Button
                Positioned(
                  bottom: 0,
                  right: 80,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                    ),
                    child: FloatingActionButton(
                      heroTag: "music",
                      mini: true,
                      backgroundColor: Colors.green,
                      onPressed: () {
                        context.read<AudioBloc>().add(PickAudios());
                        _toggle();
                      },
                      child: Icon(Icons.library_music, color: Colors.white),
                    ),
                  ),
                ),
                // Main FAB
                FloatingActionButton(
                  heroTag: "main",
                  backgroundColor: Colors.blue.shade900,
                  onPressed: _toggle,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animationController.value * 0.5 * 3.14,
                        child: Icon(Icons.add, color: Colors.white),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}