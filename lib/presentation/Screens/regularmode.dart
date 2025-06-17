import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rimza1/service/mqtt.dart';

class WeekTabPage extends StatefulWidget {
  final String imei;
  final String mode;
  final Map<String, dynamic> data;

  const WeekTabPage({super.key, required this.imei, required this.mode, required this.data});

  @override
  _WeekTabPageState createState() => _WeekTabPageState();
}

class _WeekTabPageState extends State<WeekTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  late Map<String, List<Map<String, String>>> dayItems = {};
  List<Map<String, String>> copiedList = [];
  List<String> musicList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this);
    for (String day in days) {
      dayItems[day] = [];
      if (widget.data[day] != null) {
        for (var item in widget.data[day]) {
          dayItems[day]!.add({
            "id": UniqueKey().toString(),
            "time": item['time'],
            "file": item['sound'],
          });
        }
      }
    }
    _fetchMusicList();
  }

  void _fetchMusicList() async {
    final url = Uri.parse("http://api.iautobells.com/ftp_fileread.php");
    final res = await http.post(url);
    if (res.statusCode == 200) {
      final List raw = jsonDecode(res.body);
      setState(() {
        musicList = raw.map((e) => e.toString()).toList();
      });
    }
  }

  void _editItem(String day, String id) {
    final item = dayItems[day]!.firstWhere((item) => item["id"] == id);
    _showAddEditDialog(day: day, editItem: item);
  }

  void _deleteItem(String day, String id) {
    final timeToDelete = dayItems[day]!.firstWhere((item) => item["id"] == id)["time"];
    setState(() {
      dayItems[day]!.removeWhere((item) => item["id"] == id);
    });
    Map<String, String> payload = {"day": day, "delete": timeToDelete ?? ""};
    if (widget.mode == "normal") {
      MqttService.publish("${widget.imei}/schedule", jsonEncode(payload));
    } else {
      MqttService.publish("${widget.imei}/exam_schedule", jsonEncode(payload));
    }
  }

  void _showAddEditDialog({required String day, Map<String, String>? editItem}) async {
  String? selectedMusic = editItem?["file"];
  String? selectedTime = editItem?["time"];

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(editItem != null ? "Edit Alarm" : "Add Alarm"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    final formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                    setDialogState(() => selectedTime = formatted);
                  }
                },
                child: Text(
                  selectedTime != null ? "Time: $selectedTime" : "Pick Time",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: musicList.contains(selectedMusic) ? selectedMusic : null,
                hint: Text("Select Music"),
                items: musicList.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setDialogState(() => selectedMusic = val),
              ),
              if (selectedMusic != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Selected: $selectedMusic", style: TextStyle(color: Colors.blueGrey)),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (selectedTime != null && selectedMusic != null) {
                  final newItem = {
                    "id": UniqueKey().toString(),
                    "time": selectedTime!,
                    "file": selectedMusic!,
                  };

                  if (mounted) {
                    setState(() {
                      if (editItem != null) {
                        dayItems[day]!.remove(editItem);
                      }
                      dayItems[day]!.add(newItem);
                      dayItems[day]!.sort((a, b) => a['time']!.compareTo(b['time']!));
                    });
                  }

                  final payload = {
                    "day": day,
                    "mode": widget.mode,
                    "alarms": [
                      {"time": selectedTime, "sound": selectedMusic}
                    ]
                  };

                  // Correct MQTT topic logic
                  final topic = widget.mode == "normal"
                      ? "${widget.imei}/schedule"
                      : "${widget.imei}/exam_schedule";

                  MqttService.publish(topic, jsonEncode(payload));
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select time and music"), backgroundColor: Colors.orange),
                  );
                }
              },
              child: Text("Save"),
            ),
          ],
        ),
      );
    },
  );
}

  void _copyItems() {
    final currentDay = days[_tabController.index];
    copiedList = [...?dayItems[currentDay]];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied from $currentDay"), backgroundColor: Colors.green));
  }

  void _pasteItems() {
    final currentDay = days[_tabController.index];
    if (copiedList.isNotEmpty) {
      setState(() {
        dayItems[currentDay] = copiedList.map((e) => {
          "id": UniqueKey().toString(),
          "time": e["time"]!,
          "file": e["file"]!,
        }).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pasted to $currentDay"), backgroundColor: Colors.green));
    }
  }

  void _deleteAll() {
    final currentDay = days[_tabController.index];
    setState(() => dayItems[currentDay] = []);
    Map<String, String> payload = {"day": currentDay, "delete": "ALL"};
    MqttService.publish("${widget.imei}/${widget.mode}_schedule", jsonEncode(payload));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(widget.mode == "normal" ? 'Regular Mode' : 'Exam Mode', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: Icon(Icons.copy, color: Colors.white), onPressed: _copyItems),
          IconButton(icon: Icon(Icons.content_paste, color: Colors.white), onPressed: _pasteItems),
          IconButton(icon: Icon(Icons.delete, color: Colors.white), onPressed: _deleteAll),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: days.map((day) {
          final items = dayItems[day]!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final itemId = item["id"]!;
              return Slidable(
                key: Key(itemId),
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  extentRatio: 0.45,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _deleteItem(day, itemId),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                      borderRadius: BorderRadius.circular(12),
                    ),
                    SlidableAction(
                      onPressed: (_) => _editItem(day, itemId),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(19),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade900,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text('${index + 1}', style: TextStyle(color: Colors.blue.shade900)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['time']!, style: TextStyle(fontSize: 16)),
                              SizedBox(height: 4),
                              Text(
                                item['file']!,
                                style: TextStyle(color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Icon(Icons.check_circle_outline_sharp, color: Colors.blue),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                      SizedBox(width: 12),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: () {
          final currentDay = days[_tabController.index];
          _showAddEditDialog(day: currentDay);
        },
      ),
    );
  }
}