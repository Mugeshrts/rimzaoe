import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:rimza1/data/user.dart';
import 'package:rimza1/presentation/Screens/tabs/friday.dart';
import 'package:rimza1/presentation/Screens/tabs/monday.dart';
import 'package:rimza1/presentation/Screens/tabs/saturday.dart';
import 'package:rimza1/presentation/Screens/tabs/sunday.dart';
import 'package:rimza1/presentation/Screens/tabs/thursday.dart';
import 'package:rimza1/presentation/Screens/tabs/tuesday.dart';
import 'package:rimza1/presentation/Screens/tabs/wednesday.dart';
import 'package:rimza1/service/mqtt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamModeNew extends StatefulWidget {
  final String mode;
  final String imei;
  final Exam data;
  const ExamModeNew({super.key, required this.mode, required this.imei,required this.data});

  @override
  State<ExamModeNew> createState() => _ExamModeNewState();
}
List copy_list=[];
class _ExamModeNewState extends State<ExamModeNew> with SingleTickerProviderStateMixin {
  late String mode;
  late String imei;
  late Exam data;
  String day="";
  late TabController _tabController;

  void data_get()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString("day", widget.day);
    day = prefs.getString("day")??"MON";
    // log("day :: $day");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        print('Current active tab: ${_tabController.index}');
      }
    });
    setState(() {
      data=widget.data;
      imei=widget.imei;
      mode=widget.mode;
      // data_get();
    });
    // log(" data : ${data.sun.runtimeType}");
    // log("exam imei : ${widget.imei}");
    // log("exam mode : ${widget.mode}");
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // log("tabbar control index : ${_tabController.index}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam"),
        bottom:  TabBar(
          isScrollable: true,
          tabs: const [
            Tab(text: 'MON'),
            Tab(text: 'TUE'),
            Tab(text: 'WED'),
            Tab(text: 'THU'),
            Tab(text: 'FRI'),
            Tab(text: 'SAT'),
            Tab(text: 'SUN'),
          ],
          controller: _tabController,
        ),
        actions: [
          IconButton(onPressed: ()async{
            // data_get();
            // log("tabbar control index : ${_tabController.index}");
            if(_tabController.index==0){
              copy_list=widget.data.mon;
              // log("selected day : MON");
            }
            else if(_tabController.index==1){
              // log("selected day : TUE");
              copy_list=widget.data.tue;
            }
            else if(_tabController.index==2){
              // log("selected day : WED");
              copy_list=widget.data.wed;

            }
            else if(_tabController.index==3){
              // log("selected day : THU");
              copy_list=widget.data.thu;
            }
            else if(_tabController.index==4){
              // log("selected day : FRI");
              copy_list=widget.data.fri;
            }
            else if(_tabController.index==5){
              // log("selected day : SAT");
              copy_list=widget.data.sat;
            }
            else if(_tabController.index==6){
              // log("selected day : SUN");
              copy_list=widget.data.sun;
            }
            else{
              // log("selected day : no  day");
            }
            String copy=jsonEncode(copy_list).toString();
            // log("copy string : $copy");
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString("copy", copy);
            // log("copy data : ${copy_list}");
            setState(() {

            });
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied'),backgroundColor: Colors.green,));
          }, icon: Icon(Icons.copy)),
          IconButton(onPressed: ()async{
            // data_get();
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            // log("tabbar control index : ${_tabController.index}");
            String _day="";
            if(_tabController.index==0){
              await prefs.setString("select_index", "MON");
              // past_value=copy_list;
              // copy_list=widget.data.mon;
              day="MON";
              // log("selected day : MON");
            }
            else if(_tabController.index==1){
              log("selected day : TUE");
              await prefs.setString("select_index", "TUE");
              // copy_list=widget.data.tue;
              day="TUE";
            }
            else if(_tabController.index==2){
              log("selected day : WED");
              await prefs.setString("select_index", "WED");
              // copy_list=widget.data.wed;
              day="WED";
            }
            else if(_tabController.index==3){
              log("selected day : THU");
              await prefs.setString("select_index", "THU");
              // copy_list=widget.data.thu;
              day="THU";
            }
            else if(_tabController.index==4){
              log("selected day : FRI");
              await prefs.setString("select_index", "FRI");
              // copy_list=widget.data.fri;
              day="FRI";
            }
            else if(_tabController.index==5){
              log("selected day : SAT");
              await prefs.setString("select_index", "SAT");
              // copy_list=widget.data.sat;
              day="SAT";
            }
            else if(_tabController.index==6){
              log("selected day : SUN");
              await prefs.setString("select_index", "SUN");
              // copy_list=widget.data.sun;
              day="SUN";
            }else{
              log("selected day : no  day");
            }
            log("copy data : ${copy_list}");
            setState(() {

            });
            SharedPreferences tr= await  SharedPreferences.getInstance();
            String mobileno= tr.getString("mobile")??"";
            String uri ="http://api.iautobells.com/api/autobell_device.php";
            Map<String,dynamic> update_data={"mode":mode,"day":day,"data":copy_list};
            Map<String,dynamic> ody_data ={"action":"bulk_add","device_id":imei,"data":jsonEncode(update_data)};
            http.Response response=await http.post(Uri.parse(uri),body:ody_data);
            log("response data : "+response.body);
            log("response code : "+response.statusCode.toString());
            // var data= jsonDecode(response.body);
            if(response.statusCode==200){
              log("Bulk Add");
            }else{
              log(" not Bulk Add");
            }

          }, icon: Icon(Icons.paste)),
          IconButton(onPressed: ()async{
            String _dayDelete='';
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            try{
              // await MqttService.initMqtt();
              if(_tabController.index==0){
                _dayDelete="MON";
                data.mon=[];
              }
              else if(_tabController.index==1){
                _dayDelete="TUE";
                data.tue=[];
              }
              else if(_tabController.index==2){
                _dayDelete="WED";
                data.wed=[];

              }
              else if(_tabController.index==3){
                _dayDelete="THU";
                data.thu=[];
              }
              else if(_tabController.index==4){
                _dayDelete="FRI";
                data.fri=[];
              }
              else if(_tabController.index==5){
                _dayDelete="SAT";
                data.sat=[];
              }
              else if(_tabController.index==6){
                _dayDelete="SUN";
                data.sun=[];
              }
              SharedPreferences tr= await  SharedPreferences.getInstance();
              String mobileno= tr.getString("mobile")??"";
              String uri ="http://api.iautobells.com/api/autobell_device.php";
              Map<String,dynamic> update_data={"mode":mode,"day":_dayDelete,"data":copy_list};
              Map<String,dynamic> ody_data ={"action":"bulk_delete","device_id":imei,"data":jsonEncode(update_data)};
              http.Response response=await http.post(Uri.parse(uri),body:ody_data);
              log("response data : "+response.body);
              log("response code : "+response.statusCode.toString());
              // var _rsdata= jsonDecode(response.body);
              if(response.statusCode==200){
                log("Bulk delete");
              }else{
                log(" not bulk_delete");
              }
              if(widget.mode=="normal"){
                Map<String, String> ms={"day":_dayDelete,"mode":"normal","delete":"ALL"};
                // print("delete all : $ms");
                MqttService.publish("$imei/schedule", jsonEncode(ms).toString());
              }else if(widget.mode=="exam"){
                Map<String, String> ms={"day":_dayDelete,"mode":"exam","delete":"ALL"};
                // print("delete all : $ms");
                MqttService.publish("$imei/schedule", jsonEncode(ms).toString());
                // MqttService.publish("$imei/exam_schedule", jsonEncode(ms).toString());
              }
              await prefs.setString("delete_index", _dayDelete);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleted'),backgroundColor: Colors.green,));
            }catch(e){
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error'),backgroundColor: Colors.green,));
            }
            setState(() {

            });

          }, icon: Icon(Icons.delete)),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MondayPage(mode:widget.mode,imei:widget.imei,data:data.mon,day: 'MON'),
          TuesdayPage(mode:widget.mode,imei:widget.imei,data:data.tue,day: 'TUE'),
          WednesdayPage(mode:widget.mode,imei:widget.imei,data:data.wed,day: 'WED'),
          FridayPage(mode:widget.mode,imei:widget.imei,data:data.fri,day: 'FRI'),
          SaturdayPage(mode:widget.mode,imei:widget.imei,data:data.sat,day: 'SAT'),
          SundayPage(mode:widget.mode,imei:widget.imei,data:data.sun,day: 'SUN'),
        ],
      ),
    );
  }
}

