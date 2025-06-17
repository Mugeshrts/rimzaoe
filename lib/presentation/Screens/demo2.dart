import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rimza1/data/user.dart';
import 'package:rimza1/presentation/Screens/demo.dart';
import 'package:rimza1/presentation/Screens/holidaypage.dart';
import 'package:rimza1/presentation/Screens/regularmode.dart';
import 'package:rimza1/presentation/widget/widgets.dart';
import 'package:rimza1/service/mqtt.dart';


class ModeSelectionScreen extends StatefulWidget {
  final DeviceModel device;
  final String imei;
  final dynamic dbdata;

  const ModeSelectionScreen({
    Key? key,
    required this.imei,
    required this.dbdata,
    required this.device,
  }) : super(key: key);

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  late String currentTime;
  late String currentDate;
  late String today;
  bool isExamMode = true;
  bool mqttConnected = false;
  Timer? _timer;
  final box = GetStorage();
  late DateTime now;
  Map<String, dynamic> info = {};
  late Allday all_day;
  late Allday dball_day;
  String mode = "";
  String log_arr = "";

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    today = box.read('isholiday') ?? "Working day";

    all_day = Allday.fromJson({
      "normal": {"MON": [], "TUE": [], "WED": [], "THU": [], "FRI": [], "SAT": [], "SUN": []},
      "exam": {"MON": [], "TUE": [], "WED": [], "THU": [], "FRI": [], "SAT": [], "SUN": []},
    });

    dball_day = widget.dbdata is String
        ? Allday.fromJson(jsonDecode(widget.dbdata))
        : Allday.fromJson(widget.dbdata);

    currentTime = DateFormat('hh:mm:ss a').format(now);
    currentDate = DateFormat('EEE, dd-MM-yyyy').format(now);

    _startClock();
    _initMqtt();
  }

  void _startClock() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
        currentDate = DateFormat('EEE, dd-MM-yyyy').format(DateTime.now());
      });
    });
  }

  Future<void> _initMqtt() async {
    try {
      log("Initializing MQTT...");
      await MqttService.initMqtt();
      log("MQTT initialized");

      final imei = widget.imei;
      MqttService.subscribeTopic("$imei/deviceInfo");
      MqttService.subscribeTopic("$imei/mode");
      MqttService.subscribeTopic("$imei/alarmlist");
      MqttService.subscribeTopic("$imei/log");

      MqttService.publish("$imei/getDeviceInfo", jsonEncode({}));
      MqttService.publish("$imei/getMode", jsonEncode({"day": _getDayOfWeek()}));
      MqttService.publish("$imei/getAlarmlist", jsonEncode({"day": _getDayOfWeek()}));
      MqttService.publish("$imei/getLog", jsonEncode({}));

      MqttService.client.updates!.listen((events) {
        final topic = events[0].topic;
        final MqttPublishMessage recMessage = events[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

        if (topic == "$imei/deviceInfo") {
          final parsed = safeJsonDecode(payload);
          if (parsed != null && parsed["System Time"] != null) {
            DateTime systemTime = DateFormat("dd-MM-yyyy HH:mm:ss").parse(parsed["System Time"]);
            setState(() {
              info = parsed;
              now = systemTime;
              mqttConnected = true;
            });
          }
        } else if (topic == "$imei/mode") {
          final modeData = safeJsonDecode(payload);
          if (modeData != null) {
            final dayKey = _getDayOfWeek();
            final currentMode = modeData[dayKey];
            setState(() {
              mode = currentMode;
              isExamMode = currentMode == "exam";
            });
          }
        } else if (topic == "$imei/alarmlist") {
          final jsonMap = safeJsonDecode(payload);
          if (jsonMap != null && jsonMap is Map<String, dynamic>) {
            all_day = Allday.fromJson(jsonMap);
          }
        } else if (topic == "$imei/log") {
          log_arr = payload;
        }
      });
    } catch (e, st) {
      log("MQTT init failed", error: e, stackTrace: st);
    }
  }

  String _getDayOfWeek() {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[DateTime.now().weekday - 1];
  }

  void _toggleMode() {
    setState(() {
      isExamMode = !isExamMode;
    });
    final newMode = isExamMode ? "exam" : "normal";
    MqttService.publish("${widget.imei}/exam_mode", jsonEncode({"mode": newMode}));
    MqttService.publish("${widget.imei}/getMode", jsonEncode({"day": _getDayOfWeek()}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text(
          widget.device.deviceName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Lottie.asset(
            mqttConnected ? 'assets/lotties/green.json' : 'assets/lotties/red.json',
            width: 60,
            height: 60,
          ),
          SizedBox(width: 10),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.device.deviceName),
              accountEmail: SizedBox.shrink(),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/images/Bell_Ring.png'),
              ),
              decoration: BoxDecoration(color: Colors.blue.shade900),
            ),
            ListTile(
              leading: Icon(Icons.bluetooth),
              title: Text('Connect with Bluetooth'),
              onTap: () {
                // Navigate to Bluetooth screen
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade900),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentTime, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: "Technology", color: Colors.black)),
                        SizedBox(height: 4),
                        Text(currentDate, style: TextStyle(fontSize: 15)),
                        SizedBox(height: 4),
                        Text("Today : $today", style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(height: 100, width: 1, color: Colors.black, margin: EdgeInsets.symmetric(horizontal: 35)),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade900),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleMode,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isExamMode ? Colors.amber : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.list_alt, color: isExamMode ? Colors.white : Colors.black54),
                              ),
                            ),
                            SizedBox(width: 4),
                            GestureDetector(
                              onTap: _toggleMode,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: !isExamMode ? Colors.amber : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.alarm, color: !isExamMode ? Colors.white : Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(isExamMode ? "Exam Mode" : "Regular Mode"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
           Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Column(
      children: [
        ModeCard(
          icon: Icons.alarm,
          text: "Regular Mode",
          onTap: () {
            try {
              final data = mqttConnected
                  ? all_day.toMapNormal()
                  : dball_day.toMapNormal();
              Get.to(() => WeekTabPage(
                mode: "normal",
                imei: widget.imei,
                data: data,
              ));
            } catch (e, st) {
              log("Regular Mode error", error: e, stackTrace: st);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to load Regular Mode"), backgroundColor: Colors.red),
              );
            }
          },
        ),
        ModeCard(
          icon: Icons.edit_document,
          text: "Exam Mode",
          onTap: () {
            try {
              final data = mqttConnected
                  ? all_day.toMapExam()
                  : dball_day.toMapExam();
              Get.to(() => WeekTabPage(
                mode: "exam",
                imei: widget.imei,
                data: data,
              ));
            } catch (e, st) {
              log("Exam Mode error", error: e, stackTrace: st);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to load Exam Mode"), backgroundColor: Colors.red),
              );
            }
          },
        ),
        ModeCard(
          icon: Icons.calendar_month_outlined,
          text: "Holiday",
          onTap: () {
            try {
              Get.to(() => Holidaypage(imei: widget.imei));
            } catch (e) {
              log("Holiday navigation error", error: e);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to open Holiday page"), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ],
    ),
    Column(
      children: [
        ModeCard(
          icon: Icons.music_note_sharp,
          text: "Music",
          onTap: () {
            try {
              Get.to(() => MusicUpload(imei: widget.imei));
            } catch (e) {
              log("Music upload navigation error", error: e);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to open Music page"), backgroundColor: Colors.red),
              );
            }
          },
        ),
        ModeCard(
          icon: Icons.timer,
          text: "SVM",
          onTap: () {
            try {
              // Get.to(() => Scheduletask(imei: widget.imei));
            } catch (e) {
              log("SVM navigation error", error: e);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to open SVM"), backgroundColor: Colors.red),
              );
            }
          },
        ),
        ModeCard(
          icon: Icons.speaker,
          text: "DVM",
          onTap: () {
            try {
              if (info['SW Version'] != null) {
                // Get.to(() => Dvmscreen(imei: widget.imei));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device is Offline'), backgroundColor: Colors.orange),
                );
              }
            } catch (e) {
              log("DVM navigation error", error: e);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to open DVM"), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ],
    ),
  ],
),

          ],
        ),
      ),
    );
  }

  dynamic safeJsonDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      log("Invalid JSON: $source", error: e);
      return null;
    }
  }
}
