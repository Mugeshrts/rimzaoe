import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Scheduletask extends StatefulWidget {
  const Scheduletask({super.key});

  @override
  State<Scheduletask> createState() => _ScheduletaskState();
}

class _ScheduletaskState extends State<Scheduletask> {
  Widget buildAudioModal() {
    return Container(
      padding: EdgeInsets.all(16),
      height: 250,
      child: Column(
        children: [
          Text(
            'Audio Recorder',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                onPressed: _isRecording ? _stopRecording : _startRecording,
                iconSize: 40,
                color: Colors.red,
              ),
              SizedBox(width: 20),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _isPlaying ? _pausePlayback : _startPlayback,
                iconSize: 40,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  String? _filePath;
  Timer? _timer;
  int _recordDuration = 0;
  String? selectedSubject;
  List<String> subjects = ['0007_Long_Bell_1_mp3'];

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initialize();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/flutter_sound.aac';
    await _recorder!.startRecorder(toFile: _filePath);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _startPlayback() async {
    if (_filePath != null && await File(_filePath!).exists()) {
      await _player!.startPlayer(
        fromURI: _filePath,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    } else {
      print('Audio file not found or recording failed');
    }
  }

  Future<void> _pausePlayback() async {
    await _player!.pausePlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _initialize() async {
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    await Permission.microphone.request();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    super.dispose();
  }

  List<bool> isSelected = [true, false];
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final formattedTime = selectedTime.format(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Schedule Task",
          style: TextStyle(color: Colors.blue.shade900),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade900),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              // color: const Color.fromARGB(255, 0, 0, 0),
              isSelected: isSelected,
              selectedColor: Colors.white,
              // color: Colors.grey,
              fillColor: Colors.amber.shade400,

              onPressed: (index) {
                setState(() {
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = i == index;
                  }
                });
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.mic, color: isSelected[0] ? Colors.white : Colors.blue.shade900,),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.file_copy, color: isSelected[0] ? Colors.blue.shade900 : Colors.white,),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            _buildLabeledRow(
              "Selected Date",
              formattedDate,
              Icons.calendar_today,
              _pickDate,
            ),
            _buildLabeledRow(
              "Selected Time:",
              formattedTime,
              Icons.access_time,
              _pickTime,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (_) => buildAudioModal(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Record Audio file",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                focusColor: Colors.blue.shade900,
                labelText: "Select Music",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              value: selectedSubject,
              items:
                  subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                });
              },
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                print("button clicked");
              },
              child: Container(
              
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.blue.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Schedule Task",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLabeledRow(
  String label,
  String value,
  IconData icon,
  VoidCallback onTap,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Text(value, style: TextStyle(color: Colors.black, fontSize: 15)),
              SizedBox(width: 120),
              Icon(icon, color: Colors.blue.shade900),
            ],
          ),
        ),
      ],
    ),
  );
}
