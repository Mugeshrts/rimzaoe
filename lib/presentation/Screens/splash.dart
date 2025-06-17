import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rimza1/presentation/Screens/modeselection.dart';
import 'package:rimza1/presentation/Screens/home.dart';
import 'package:rimza1/presentation/Screens/login.dart';
import 'package:uuid/uuid.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GetStorage storage = GetStorage();

  @override
  void initState() {
    super.initState();
    navigateToNext();
  }

  void navigateToNext() async {
    // final connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult == ConnectivityResult.none) {
    //   // No internet connection
    //   Get.snackbar(
    //     'No Internet',
    //     'There is no internet, please check your connection',
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return; // Do not proceed
    // }
    // Check and store deviceId if not already stored
    String? deviceId = storage.read('deviceId');
    if (deviceId == null || deviceId.isEmpty) {
      var uuid = const Uuid();
      String newDeviceId = uuid.v1();
      storage.write('deviceId', newDeviceId);
    }

    // Wait 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // Check if mobile is stored
    String? username = storage.read('mobile');
    if (username != null && username.isNotEmpty) {
      Get.offAll(() =>  DashboardPage());
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.indigo,
      body: Center(
        child: Text("Rimza", style: TextStyle(fontSize: 32, color: Colors.white,fontWeight: FontWeight.bold),),
      ),
    );
  }
}
