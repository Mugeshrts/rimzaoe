import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:rimza1/presentation/Screens/modeselection.dart';
import 'package:rimza1/presentation/Screens/splash.dart';
import 'package:rimza1/service/mqtt.dart'; 


void main()async{
  WidgetsFlutterBinding.ensureInitialized();
   await GetStorage.init(); // Initialize GetStorage before app starts
  //  await dotenv.load(fileName: ".env");
  await MqttService.initMqtt();
  await dotenv.load(); // ✅ Load .env
  runApp(MyApp());

  // await MqttService.initMqtt();
  // MqttService.initMqtt();
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: SplashScreen(),
    );
  }
}
