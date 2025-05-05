import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:rimza1/Core/network.dart';
import 'package:rimza1/data/user.dart';
import 'package:rimza1/presentation/Screens/dummy.dart';
import 'package:rimza1/presentation/Screens/login.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rimza1/service/mqtt.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<DeviceModel> devices = [];
  List<DeviceModel> filteredDevices = [];
  bool isLoading = true;
  bool mqttConnected = true;
  final box = GetStorage();
  final String apiUrl = Dashboard_url;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDevicesAndConnectMQTT();
  }

  Future<void> fetchDevicesAndConnectMQTT() async {
    final String? mobile = box.read('mobile');
    print('[FETCH DEVICES] Mobile: $mobile');
    if (mobile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Mobile number not found")));
      return;
    }

    final url = Uri.parse(apiUrl);
    print('[FETCH DEVICES] API URL: $url');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {"action": "get_device", "mobile": mobile},
      );

      print('[FETCH DEVICES] Response Code: ${response.statusCode}');
      print('[GET DEVICE] Response: ${response.body}');

      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        final List<DeviceModel> loadedDevices = decoded.map((e) => DeviceModel.fromJson(e)).toList();
        print('[FETCH DEVICES] Parsed ${decoded.length} devices');
        setState(() {
         devices = loadedDevices;
         filteredDevices = loadedDevices;
         isLoading = false;
        });

        // 🔗 Connect to MQTT and subscribe to each device topic
        await MqttService.initMqtt();
        MqttService.client.onConnected = () {
          setState(() => mqttConnected = true);
          for (var device in devices) {
            MqttService.subscribeTopic('device/${device.imei}');
          }
        };
      } else {
        print('[FETCH DEVICES] Unexpected response structure');
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Unexpected response format")));
      }
    } catch (e) {
      print('[FETCH DEVICES] Exception: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load devices: $e")));
    }
  }

  void handleLogout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textCancel: "Cancel",
      textConfirm: "Logout",
      confirmTextColor: Colors.white,
      onConfirm: () {
        final box = GetStorage();
        box.erase(); // clears all storage
        Get.offAll(() => LoginScreen());
      },
    );
  }

   void filterSearch(String query) {
    if (query.isEmpty) {
      setState(() => filteredDevices = devices);
    } else {
      setState(() {
        filteredDevices = devices.where((device) =>
            device.deviceName.toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
    }
  } 
 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.blue.shade50,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade900),
              child: Center(
                child: Text(
                  "Welcome 👋",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout"),
              onTap: handleLogout,
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: Text(
          "Devices (${devices.length})",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade900,
        actions: [
          Center(
            child: Text(
              "v1.8",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Lottie.asset(
            mqttConnected
                ? 'assets/lotties/93167-sphere.json'
                : 'assets/lotties/91142-red-pulsing-dot.json',
            width: 50,
            height: 50,
          ),
        ],
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: 'Search Devices...',
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
     
       body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredDevices.isEmpty
              ? Center(
                  child: Text(
                    "No device available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final device = filteredDevices[index];
                    return GestureDetector(
                       onTap: () {
    final isDeviceAvailable = device.status.toLowerCase() == 'active';
    if (isDeviceAvailable) {
      Get.to(() => ModeSelectionScreen(device: device));
    } else {
      Get.snackbar(
        "Notice",
        "There is no data available for this device.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  },
                      child: Card(
                        margin: EdgeInsets.all(10),
                         shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                        child: ListTile(
                          leading: Image.asset('assets/images/Bell_Ring.png'),
                          title: Text(device.deviceName),
                          subtitle: Text("IMEI: ${device.imei}"),
                          trailing: Text(
                            device.status,
                            style: TextStyle(
                              color: device.status == "Active"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}