import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rimza1/Core/network.dart';
import 'package:rimza1/Logic/bloc/home/bloc/home_bloc.dart';
import 'package:rimza1/Logic/bloc/home/bloc/home_event.dart';
import 'package:rimza1/Logic/bloc/home/bloc/home_state.dart';
import 'package:rimza1/presentation/Screens/modeselection.dart';
import 'package:rimza1/presentation/Screens/login.dart';
import 'package:rimza1/service/mqtt.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DeviceBloc _deviceBloc;
  final TextEditingController _searchController = TextEditingController();
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _deviceBloc = DeviceBloc(apiUrl: Dashboard_url, storage: box);
    _deviceBloc.add(FetchDevices());
    _initMqttAndRefresh();
  }

  Future<void> _initMqttAndRefresh() async {
    try {
      await MqttService.initMqtt();
      _deviceBloc.add(RefreshMQTTData());
    } catch (_) {}
  }

  void handleLogout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textCancel: "Cancel",
      textConfirm: "Logout",
      confirmTextColor: Colors.white,
      onConfirm: () {
        box.erase();
        Get.offAll(() => LoginScreen());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _deviceBloc,
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: Colors.blue.shade50,
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue.shade900),
                child: Center(
                  child: Text("Welcome 👋", style: TextStyle(color: Colors.white, fontSize: 20)),
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
          title: Text("Devices", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue.shade900,
          actions: [
            Center(child: Text("v1.8", style: TextStyle(fontSize: 16))),
            BlocBuilder<DeviceBloc, DeviceState>(
              builder: (context, state) {
                if (state is DeviceLoaded) {
                  return IconButton(
                    onPressed: () async {
                      await MqttService.initMqtt();
                      _deviceBloc.add(RefreshMQTTData());
                    },
                    icon: Lottie.asset(
                      state.faulty == "yes"
                          ? 'assets/lotties/red.json'
                          : state.mqttCheck
                              ? 'assets/lotties/green.json'
                              : 'assets/lotties/red.json',
                      width: 60,
                      height: 60,
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
          leading: Builder(
            builder: (context) => IconButton(
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
                onChanged: (query) => _deviceBloc.add(SearchDevices(query)),
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
        body: BlocBuilder<DeviceBloc, DeviceState>(
          builder: (context, state) {
            if (state is DeviceLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is DeviceLoaded) {
              if (state.devices.isEmpty) {
                return Center(child: Text("No device available", style: TextStyle(fontSize: 18)));
              }

              return ListView.builder(
                itemCount: state.devices.length,
                itemBuilder: (context, index) {
                  final device = state.devices[index];
                  final isActive = device.status.toLowerCase() == 'active';
                  final hasMqtt = state.mqttReceivedDeviceIds.contains(device.imei);

                  return GestureDetector(
                    onTap: () {
                      if (isActive) {
                        // Get.to(() => ModeSelectionScreen(device: device));
                        Get.to(() => ModeSelectionScreen(
      imei: device.imei,
      dbdata: device.data ?? '', 
      device: device,
      // device: device.deviceName,
    ));
                      } else {
                        Get.snackbar("Notice", "There is no data available for this device.",
                            backgroundColor: Colors.redAccent, colorText: Colors.white);
                      }
                    },
                    child: Card(
                      color: hasMqtt ? Colors.white : Colors.red.shade300,
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: Image.asset('assets/images/Bell_Ring.png'),
                        title: Text(device.deviceName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("SW Version: ${device.swVersion.isNotEmpty ? device.swVersion : 'N/A'}"),
                            Text("Release Date: ${device.releaseDate.isNotEmpty ? device.releaseDate : 'N/A'}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is DeviceError) {
              return Center(child: Text(state.message));
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
