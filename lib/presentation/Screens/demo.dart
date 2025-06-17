import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart'show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:path/path.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3_plus/record_mp3_plus.dart';
import 'package:rimza1/service/mqtt.dart';
import 'dart:typed_data';
class MusicUpload extends StatefulWidget {
  final String imei;
  const MusicUpload({super.key, required this.imei});

  @override
  State<MusicUpload> createState() => _MusicUploadState();
}

class _MusicUploadState extends State<MusicUpload>   with SingleTickerProviderStateMixin  {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  var mqtt_song =[];
bool status_u=false;
bool status_mq=false;
  String imei ="";
  List music_data=[];
  List<String> music_data1=[];
  String dropdownValue = 'select music';
  bool time_bool=false;
  List all_day=[];
  var log_arr;
  final record = AudioRecorder();
  String _filePath = '';
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  bool rec=false;
  Timer? _timer;
  bool buff=false;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String _recordingTime = "00:00:00";
  FlutterSoundPlayer? _audioPlayer;
  FlutterSoundRecorder? _audioRecorder;
  String _pathToSaveAudio = '';
  TextEditingController locatintiname= TextEditingController();
  bool pause=false;
  String filename='';
   bool isOpen = false;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
           
    imei =widget.imei;
    get_mqtt_data();
    get_music();
    _audioPlayer = FlutterSoundPlayer();
    _audioRecorder = FlutterSoundRecorder();
    initPlayerAndRecorder();
     super.initState();
  }

  void _toggle() {
    setState(() {
      isOpen = !isOpen;
      isOpen ? _animationController.forward() : _animationController.reverse();
    });
  }


    @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer!.stopPlayer();
     _animationController.dispose();
    super.dispose();
  }

  Widget _buildChildFab(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: FloatingActionButton(
        mini: true,
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }

  void get_music()async{
    String url="http://api.iautobells.com/ftp_fileread.php";
    http.Response response=await  http.post(Uri.parse(url));
    log("response :: ${response.body}");
    if(response.statusCode==200){
      setState(() {
        music_data = jsonDecode(response.body);
        music_data1=music_data.map((element) => element.toString()).toList();
        print('data type :: ${music_data1}');
      });
    }}
  void get_mqtt_data() async{
    imei=widget.imei;
    setState(() {
      status_mq=true;
      MqttService.client.updates!.listen((dynamic t) {
        String _topic = t[0].topic;
        MqttPublishMessage recMessage = t[0].payload;
        var payload = MqttPublishPayload.bytesToStringAsString(
            recMessage.payload.message);
        if(_topic=='$imei/audiolist'){
          setState(() {
            all_day=jsonDecode(payload);
            status_mq=false;
          });

          log("payload data type ${all_day.runtimeType}");
        }
        else if(_topic=='$imei/log'){
          log_arr=payload;
        }
      });
    });

 
    MqttService.subscribeTopic("$imei/audiolist");
    MqttService.subscribeTopic("$imei/log");
    Map<String, String> ms={};
    MqttService.publish("$imei/getAudiolist", jsonEncode(ms).toString());

  }

  // @override
  // void initState()async {
  //   super.initState();
  //   imei =widget.imei;
  //   get_mqtt_data();
  //   get_music();
  //   _audioPlayer = FlutterSoundPlayer();
  //   _audioRecorder = FlutterSoundRecorder();
  //   initPlayerAndRecorder();
  //    _animationController =
  //       AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  // }

  Future<void> initPlayerAndRecorder() async {
    await _audioPlayer!.openPlayer();
    await _audioRecorder!.openRecorder();
    await Permission.microphone.request();
  }

  void startRecording() async {
    Directory tempDirectory = await getTemporaryDirectory();
    setState(() {
      _pathToSaveAudio = '${tempDirectory.path}/${locatintiname.text!=""&& locatintiname.text!=null?locatintiname.text.trim():DateTime.now().millisecondsSinceEpoch}.mp3';
      log("path file get : ${_pathToSaveAudio}");
    });
    RecordMp3.instance.start(_pathToSaveAudio, (type) {
      log("see ....: $type");
    });
    setState(() {
      _isRecording = true;
      _recordingTime = "00:00:00";
      _currentDuration = Duration.zero;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _currentDuration = _currentDuration + const Duration(seconds: 1);
          _recordingTime = _currentDuration.toString().split('.').first.padLeft(8, "0");
        });
      });
      });
  }

  void stopRecording() async {
    RecordMp3.instance.stop();
    setState(() {
      _totalDuration = _currentDuration;
      _timer?.cancel();
      _isRecording = false;
    } );
  }

  void startPlaying() async {
    await _audioPlayer!.startPlayer(fromURI: _pathToSaveAudio);
    _recordingTime="00:00:00";
    log("path file : $_pathToSaveAudio");
    _currentDuration = Duration.zero;
    setState(() {
      _isPlaying=true;
      mockAudioPlayback();
    });

  }

  void stopPlaying() async {
    await _audioPlayer!.stopPlayer();
    setState(() => _isPlaying = false);
  }

  Future<void> _uploadFile1(BuildContext context) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    var dio = Dio();
    try {
      File file = File(_pathToSaveAudio);
      String fileName = locatintiname.text+".mp3";
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_pathToSaveAudio,filename: fileName),
      });
      Response response = await dio.post('http://api.iautobells.com/ftp_test.php', data: formData,
      onSendProgress: (int sent, int total) {
        setState(() {
            _uploadProgress = sent / total;


          log("upload progress :: $_uploadProgress");
        });
      },
      );
      if (response.statusCode == 200) {
        try{
          // await MqttService.initMqtt();
          Map<String, String> ms={"filename":"${_pathToSaveAudio.split('/').last.toString().replaceAll('"', "").replaceAll(" ", "_").trim()}",
          "hash": "${digest.toString()}"
          };
          print("sync all : $ms");
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(' Successfully Uploaded'),backgroundColor: Colors.green,));
          Future.delayed(const Duration(seconds: 1),(){
            MqttService.publish("${imei}/sync", jsonEncode(ms).toString());
            setState(() {
              print("Upload successful");
              status_u=true;
            });
          });
        }catch(e){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$e'),backgroundColor: Colors.orange,));
        }


      } else {
        print("Upload failed");
      }

      setState(() {
        get_music();
        _isUploading = false;
      });

    } catch (e) {
      print(e);
    }
  }

  void mockAudioPlayback() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDuration = _currentDuration + const Duration(seconds: 1);
        if (_currentDuration >= _totalDuration) {
          stopPlaying();
        }
      });
    });
  }
  Future<void> _uploadFile(BuildContext context) async {
    imei =widget.imei;
    status_u=false;
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result != null) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });
      var dio = Dio();
      File file = File(result.files.single.path!);
      String fileName = basename(file.path);
      int fileSize = file.lengthSync();
      fileName = "${fileName.toString().replaceAll('"', "").replaceAll(" ", "_").replaceAll(".", "_").replaceAll("mp3", "").trim()}.mp3";
      log("filename : $fileName");
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);

      print('Hash value of the MP3 file: $digest');
 
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path,filename: fileName),
      });
      print("Upload :${formData}");
      Response res = await dio.post('http://api.iautobells.com/ftp_test.php', data: formData,
        onSendProgress: (int sent, int total) {
          setState(() {
              _uploadProgress = sent / total;
            log("upload progress :: $_uploadProgress");
          });
        },
      );
      print("Upload :${res.statusCode}");
      print("Upload :${res.toString()}");

      if (res.statusCode == 200) {
        print("Upload :${jsonDecode(res.data)['file_name']}");
        String ftp_file=jsonDecode(res.data)['file_name'];
        try{
            Map<String,String> ch_map={
              "filename": "${ftp_file}",
              "device_id":imei
            };
          log("map : ${ch_map}");
          var check_file_size=await http.post(Uri.parse('http://api.iautobells.com/file_size.php'),body:ch_map );
          log("check_file_body : ${check_file_size.body}");
          
            if(check_file_size.statusCode==200){
              var file_check_json=jsonDecode(check_file_size.body);
              int up_file_size=file_check_json['file_size'];
              if(fileSize==up_file_size){
                Map<String, String> ms={"filename":"${ftp_file}",
                  "hash":"${digest.toString()}"
                };
                print("sync all : $ms");
                Future.delayed(const Duration(seconds: 1),(){
                  MqttService.publish("${imei}/sync", jsonEncode(ms).toString());
                  setState(() {
                    print("Upload successful");
                    status_u=true;
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(' Successfully Uploaded'),backgroundColor: Colors.green,));
              }else{
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('File Size Not Matched'),backgroundColor: Colors.orange,));
              }
            }


        }catch(e){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$e'),backgroundColor: Colors.orange,));
        }

      } else {
        print("Upload failed");
      }

      setState(() {
        get_music();
        _isUploading = false;
      });
    } else {
      print("User cancelled the picker");
    }
  }

  Future<String> calculateSha256(File file, int difference) async {
    List<int> fileBytes = await file.readAsBytes();
    List<int> adjustedBytes = fileBytes.sublist(0, fileBytes.length - difference);
    final digest = sha256.convert(adjustedBytes);
    return digest.toString();
  }
  Future<void> downloadAndPlay(String fileName) async {

    log("file name: $fileName");
    setState(() {
      filename=fileName;
      buff=true;
    });
    var tempDir = await getApplicationDocumentsDirectory();
    File file = File('${tempDir.path}/$fileName');
    String url = "http://api.iautobells.com/download_file.php?filename=$fileName";
    FormData.fromMap({'filename': fileName});
    var dio=Dio();
    var rsult=await dio.download(url,file.path,onReceiveProgress: (rec,to){
      print("downloading data : ${((rec / to) * 100).toStringAsFixed(0)}%");
    }).then((value) async{
    log("file downlodeed");
    });
    await _audioPlayer!.startPlayer(fromURI: file.path);
      setState(() {
        pause=true;
        buff=false;
      });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async{

     if(await _audioPlayer!.isStopped){
   pause=false;
        _timer?.cancel();
     }
     setState(() {

     });

    });}
  void audio_pass(){
    _audioPlayer!.stopPlayer();
    setState(() {
      pause=false;
    });
  }
  @override
  Widget build(BuildContext context) {

    Widget makeBody() {
      return Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: locatintiname,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp('[/.,]')),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'File Name',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1,color: Colors.green),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1,color: Colors.orange),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(width: 1,color: Colors.green),
                ),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    borderSide: BorderSide(width: 1,color: Colors.black)
                ),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    borderSide: BorderSide(width: 1,color: Colors.red)
                ),
              ),
              onChanged: (value) async{
                setState(() {
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Recording Time: $_recordingTime",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: locatintiname.text!=""&& locatintiname.text!=null?(_isRecording ? stopRecording : startRecording):(){
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Please Enter File Name '),backgroundColor: Colors.orange,));
                },
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed:  locatintiname.text!=""&& locatintiname.text!=null?(_isPlaying ? stopPlaying : startPlaying):(){
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please Enter File Name '),backgroundColor: Colors.orange,));
                    },
                              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                          label: Text(_isPlaying ? 'Stop Playing' : 'Start Playing'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: (){
                  setState(() {
                    rec=!rec;
                  });
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: ()async{
                  if(_pathToSaveAudio!=""&&locatintiname.text!=""&& locatintiname.text!=null){
                    _uploadFile1(context);
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Please check '),backgroundColor: Colors.orange,));
                  }
                  setState(() {

                  });

                },
                icon: const Icon(Icons.upload),
                label: const Text('Uplode'),
              ),
            ],
          ),
        ],
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Music"),
        actions: [
          IconButton(onPressed: (){
            get_mqtt_data();
            get_music();
          }, icon: const Icon(Icons.refresh))
        ],
        backgroundColor: Colors.blue.shade900,
      ),
      body: rec?(_isUploading?Center(child:  CircularPercentIndicator(
        radius: 110.0,
        animation: false,
        animationDuration: 1200,
        lineWidth: 25.0,
        percent: _uploadProgress,
        center:  Text(
          "${(_uploadProgress*100).toInt()}%",
          style:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
        circularStrokeCap: CircularStrokeCap.butt,
        backgroundColor: Colors.yellow,
        progressColor: Colors.red,
      ),):makeBody()):
      (_isUploading?Center(child:  CircularPercentIndicator(
        radius: 110.0,
        animation: false,
        animationDuration: 1200,
        lineWidth: 25.0,
        percent: _uploadProgress,
        center:  Text(
          "${(_uploadProgress*100).toInt()}%",
          style:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
        ),
        circularStrokeCap: CircularStrokeCap.butt,
        backgroundColor: Colors.yellow,
        progressColor: Colors.red,
      ),):
      ListView.builder(
          itemCount: music_data1.length,
          itemBuilder: (context,index){
        return ListTile(
          title: Text("${music_data1[index]}"),
          leading: status_mq?const IconButton(onPressed: null, icon: CircleAvatar(backgroundColor: Colors.white,
              child: Center(child: CircularProgressIndicator())
          )): all_day.contains(music_data1[index])?IconButton(onPressed: (){
            if(pause){
              audio_pass();
            }else{
              downloadAndPlay(music_data1[index]);
            }
          }, icon:
          CircleAvatar(
              child: buff&& filename==music_data1[index]?const Center(child: CircularProgressIndicator()):(pause && filename==music_data1[index]?const Icon(Icons.stop,color: Colors.white,):const Icon(Icons.play_arrow,color: Colors.white,))
          ))
              :IconButton(
              onPressed: ()async{
            try{
              var tempDir = await getApplicationDocumentsDirectory();
              File file = File('${tempDir.path}/${music_data1[index]}');
              String url = "http://api.iautobells.com/download_file.php?filename=${music_data1[index]}";
              FormData.fromMap({'filename': "${music_data1[index]}"});
              var dio=Dio();
              var rsult=await dio.download(url,file.path,onReceiveProgress: (rec,to){
                print("downloading data : ${((rec / to) * 100).toStringAsFixed(0)}%");
              }).then((value) async{
                log("file downlodeed");
              });
              print("file size : ${ await file.length()-30}");
              String digest = await calculateSha256(file, 30);
              print('Hash value of the MP3 file: $digest');
              Map<String, String> ms={"filename":music_data1[index], "hash": "${digest.toString()}"
                                  };
              print("sync all : $ms");
              MqttService.publish("${imei}/sync", jsonEncode(ms).toString());
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(' Successfully Uploaded'),backgroundColor: Colors.green,));
              get_mqtt_data();
              setState(() {
                print("Upload successful");
                status_u=true;
              });
            }catch(e){

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
              icon: const Icon(Icons.music_note,color: Colors.grey,)),
          trailing: IconButton(onPressed: ()async{
            String uri="http://api.iautobells.com/ftp_delete.php";
            Map<String, String> mess={"file":music_data1[index]};
            http.Response res= await http.post(Uri.parse(uri),body:mess);
            print("responce :: ${res.body}");
            if(res.statusCode==200 && res.body.contains("${music_data1[index]} deleted successful")){
              get_music();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(' Successfully Deleted'),backgroundColor: Colors.green,));
            }else{
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(' Not Deleted'),backgroundColor: Colors.orangeAccent,));
            }
          },icon: const Icon(Icons.delete),color: Colors.red,),
        );
      })),
      // floatingActionButton: FloatingActionButton(onPressed: (){},
      // backgroundColor: Colors.amber,
      // child: Icon(Icons.abc),),
       floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOpen) ...[
            _buildChildFab(Icons.message, () => print('Message tapped')),
            _buildChildFab(Icons.phone, () => print('Phone tapped')),
          ],
          FloatingActionButton(
            onPressed: _toggle,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Transform.rotate(
                angle: _animationController.value * 0.75 * 3.14,
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButtonLocation: ExpandableFab.location,
      // floatingActionButton: ExpandableFab(

      //   children: [
      //     rec? FloatingActionButton.small(
      //                 heroTag: null,
      //                   child: const Icon(Icons.list),
                       
      //                   onPressed: () {
      //                     setState(() {
      //                       rec=!rec;
      //                     });
      //                   },
      //                 )
      //         :FloatingActionButton.small(
      //       heroTag: null,
      //       child: const Icon(Icons.upload),
      //       onPressed: () {
      //           if(!_isUploading){
      //               _uploadFile(context);
      //               if(status_u){
      //               }
      //             }
      //       },
      //     ),
      //     FloatingActionButton.small(
      //       heroTag: null,
      //       child: const Icon(Icons.mic),
      //       onPressed: () {
      //        setState(() {
      //          rec=!rec;
      //        });
      //       },
      //     ),
      //   ],
      // ),
    );
  }
}




// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: AnimatedFABExample());
//   }
// }

// class AnimatedFABExample extends StatefulWidget {
//   @override
//   _AnimatedFABExampleState createState() => _AnimatedFABExampleState();
// }

// class _AnimatedFABExampleState extends State<AnimatedFABExample>
//     with SingleTickerProviderStateMixin {
//   bool isOpen = false;
//   late AnimationController _animationController;

//   @override
//   void initState() {
//     _animationController =
//         AnimationController(vsync: this, duration: Duration(milliseconds: 300));
//     super.initState();
//   }

//   void _toggle() {
//     setState(() {
//       isOpen = !isOpen;
//       isOpen ? _animationController.forward() : _animationController.reverse();
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Widget _buildChildFab(IconData icon, VoidCallback onPressed) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       child: FloatingActionButton(
//         mini: true,
//         onPressed: onPressed,
//         child: Icon(icon),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Animated FAB')),
//       body: Center(child: Text('Press the FAB!')),
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (isOpen) ...[
//             _buildChildFab(Icons.message, () => print('Message tapped')),
//             _buildChildFab(Icons.phone, () => print('Phone tapped')),
//           ],
//           FloatingActionButton(
//             onPressed: _toggle,
//             child: AnimatedBuilder(
//               animation: _animationController,
//               builder: (context, child) => Transform.rotate(
//                 angle: _animationController.value * 0.75 * 3.14,
//                 child: Icon(Icons.add),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }