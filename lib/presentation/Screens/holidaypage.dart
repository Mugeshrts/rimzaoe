import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rimza1/service/mqtt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Holidaypage extends StatefulWidget {
  final String imei;
  const Holidaypage({super.key, required this.imei});

  @override
  State<Holidaypage> createState() => _HolidaypageState();
}

class _HolidaypageState extends State<Holidaypage> {
  DateTime select1 = DateTime.now();
  DateTime select2 = DateTime.now();
  String date = "";
  String imei = "";
  String log_arr = "";
  List all_day = [];

  @override
  void initState() {
    super.initState();
    imei = widget.imei;
    get_mqtt_data();
  }

  void get_mqtt_data() async {
    if (MqttService.client.connectionStatus?.state.toString() != "MqttConnectionState.connected") {
      // handle reconnect if needed
    }

    MqttService.client.updates!.listen((dynamic t) {
      String _topic = t[0].topic;
      MqttPublishMessage recMessage = t[0].payload;
      var payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

      if (_topic == '$imei/holidayslist') {
        final DateFormat formatter = DateFormat('dd.MM.yyyy');
        final DateTime now = DateTime.now().subtract(Duration(days: 1));
        all_day = jsonDecode(payload);
        DateFormat format = DateFormat("dd.MM.yyyy");

        all_day.sort((a, b) {
          DateTime dateA = format.parse(a);
          DateTime dateB = format.parse(b);
          return dateA.compareTo(dateB);
        });
        all_day = all_day.where((date) => !formatter.parse(date).isBefore(now)).toList();

        setState(() {});
      } else if (_topic == '$imei/log') {
        log_arr = payload;
      }
    });

    MqttService.subscribeTopic("$imei/holidayslist");
    MqttService.subscribeTopic("$imei/log");
    MqttService.publish("$imei/get_holidays", jsonEncode({}));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) {
      setState(() {
        if (date == "one") {
          select1 = picked;
        } else if (date == "two") {
          select2 = picked;
        }
        date = "";
      });
    }
  }

  String dayOfWeekAsString(int value) {
    switch (value) {
      case DateTime.monday:
        return 'MON';
      case DateTime.tuesday:
        return 'TUE';
      case DateTime.wednesday:
        return 'WED';
      case DateTime.thursday:
        return 'THU';
      case DateTime.friday:
        return 'FRI';
      case DateTime.saturday:
        return 'SAT';
      case DateTime.sunday:
        return 'SUN';
      default:
        return '';
    }
  }

  Widget _buildDatePicker(String label, DateTime date, VoidCallback onTap) {
    return Flexible(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(DateFormat('dd:MM:yyyy').format(date)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade50,
              foregroundColor: Colors.black,
              minimumSize: const Size(100, 40),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("Holiday Manager", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => get_mqtt_data(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child:  Row(
                  children: [
                    _buildDatePicker("From", select1, () {
                      date = "one";
                      _selectDate(context);
                    }),
                    const SizedBox(width: 12),
                    _buildDatePicker("To", select2, () {
                      date = "two";
                      _selectDate(context);
                    }),
                    const Spacer(),
                    Tooltip(
                      message: "Upload Holiday",
                      child: ElevatedButton(
                        onPressed: () async {
                          if (select1.isBefore(select2) || select1.isAtSameMomentAs(select2)) {
                            final today = DateTime.now();
                            if ((today.isAfter(select1) || today.isAtSameMomentAs(select1)) &&
                                (today.isBefore(select2) || today.isAtSameMomentAs(select2))) {
                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setString('isholiday', 'Holiday');
                            }

                            Map<String, dynamic> ms = {
                              "holiday_sets": [
                                {
                                  "start_date": DateFormat('dd.MM.yyyy').format(select1),
                                  "end_date": DateFormat('dd.MM.yyyy').format(select2),
                                }
                              ]
                            };

                            MqttService.publish("$imei/holidays", jsonEncode(ms));
                            get_mqtt_data();

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Successfully Updated'),
                              backgroundColor: Colors.green,
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Please Select Valid Date'),
                              backgroundColor: Colors.orange,
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.upload, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Upcoming Holidays',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: all_day.isEmpty
                  ? const Center(child: Text("No Holidays Found"))
                  : ListView.builder(
                      itemCount: all_day.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 3,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(all_day[index], style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text("Holiday"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                Map<String, dynamic> ms = {"dates": [all_day[index]]};
                                MqttService.publish("$imei/deleteHoliday", jsonEncode(ms));
                                setState(() {
                                  all_day.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('Deleted successfully'),
                                  backgroundColor: Colors.green,
                                ));
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
