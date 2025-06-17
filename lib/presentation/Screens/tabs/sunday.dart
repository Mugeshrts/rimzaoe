import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rimza1/data/user.dart';
import 'package:rimza1/service/mqtt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
class SundayPage extends StatefulWidget {
  final String mode;
  final String imei;
  final dynamic data;
  final String day;
  const SundayPage({super.key, required this.mode, required this.day, required this.imei,required this.data});
  @override
  State<SundayPage> createState() => _SundayPageState();
}
List<String> times = [];
List<String> music = [];
late String mode;
late String imei;
late String day;
TimeOfDay _time = TimeOfDay.now();
// String dropdownValue = 'One';
String time = '';
String log_arr = '';
List music_data=[];
bool edit_bool=false;
bool mqtt_data_check=false;
List data =[];
List data_compar =[];
List<String> music_data1=[];
String? dropdownValue ;//= 'select music';
bool time_bool=false;
late int _index_data;
late Timer _timer;
late Allday all_day;
List<bool> vvv=[];
List<bool> aaa=[];
bool status_bool=false;
bool update_bool=false;
class _SundayPageState extends State<SundayPage> with AutomaticKeepAliveClientMixin<SundayPage>{
  String deleteDay="";
  String selectDay="";
  // String mode ="normal";
  bool slide=false;
  bool api=false;
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        // log("time:: $_time");
      });
    }
  }
  void showMyModalBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                  ),
                ),
                width: double.infinity,
                // color: Colors.red,
                child: Column(
                  children:  [
                    const SizedBox(height: 10,),
                    edit_bool?const Text("Edit Schedule",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),) :const Text("Add Schedule",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                  ],
                ),
              ),
              const Divider(color: Colors.blue,thickness: 3),
              // SizedBox(height: 20,),
              ElevatedButton.icon(
                onPressed: () {
                  _selectTime(context);
                  // Handle button press
                },
                icon: const Icon(Icons.access_time, size: 18.0),
                 label: Text("${_time.format(context)}"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  disabledForegroundColor: Colors.grey.withOpacity(0.38),
                  disabledBackgroundColor: Colors.grey.withOpacity(0.12), // Color when the button is disabled
                ),
              ),
              // TextButton(
              //   child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       const Icon(Icons.timer),
              //       const Text('Pick time'),
              //     ],
              //   ),
              //   onPressed: () async {
              //     final TimeOfDay? pickedTime = await showTimePicker(
              //       context: context,
              //       initialTime: TimeOfDay.now(),
              //       builder: (context, child) {
              //         return MediaQuery(
              //           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              //           child: child ?? Container(),
              //         );
              //       },
              //     );
              //
              //     if (pickedTime != null) {
              //       setState(() {
              //         time = "${(pickedTime.hour).toString().length==1?"0${pickedTime.hour}":pickedTime.hour}:${(pickedTime.minute).toString().length==1?"0${pickedTime.minute}":pickedTime.minute}";
              //         time_bool=true;
              //         // // print("time : $times");
              //         // time = 'Time selected: ${pickedTime.format(context)}';
              //       });
              //     }
              //   },
              // ),
              // time_bool?Text("Time : $time"):Text(time),
              Padding(
                padding: const EdgeInsets.all(8.0),
                // child: DropdownSearch<String>(
                //   popupProps:  const PopupProps.menu(
                //     showSelectedItems: true,
                //     showSearchBox: true,

                //     // disabledItemFn: (String s) => s.startsWith('I'),
                //   ),

                //   items: music_data1,
                //   dropdownDecoratorProps: const DropDownDecoratorProps(
                //     dropdownSearchDecoration: InputDecoration(
                //       labelText: "Select Music",
                //       border: OutlineInputBorder(),
                //       suffixIcon: Icon(Icons.arrow_drop_down),
                //       hintText: "Please select valid Music",
                //     ),
                //   ),
                //   onChanged:  (value) {
                //     setState(() {
                //       dropdownValue = value as String;
                //       // // print("music : $music");
                //     });
                //   },
                //   selectedItem: dropdownValue,
                // ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            edit_bool=false;
                            _time=TimeOfDay.now();
                            dropdownValue="";
                          });
                          Navigator.pop(context);
                          // _selectTime(context);
                          // Handle button press
                        },
                        icon: const Icon(Icons.access_time, size: 18.0),
                        label: const Text("Cancel"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          disabledForegroundColor: Colors.grey.withOpacity(0.38),
                          disabledBackgroundColor: Colors.grey.withOpacity(0.12), // Color when the button is disabled
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if(dropdownValue!=null&&dropdownValue!=""&&dropdownValue!.isNotEmpty){
                            time ="${_time.hour.toString().length==1?"0${_time.hour}":_time.hour}:${_time.minute.toString().length==1?"0${_time.minute}":_time.minute}";
                            Map<String,String> _shedule={"time": "$time", "sound": "$dropdownValue"};
                            // // log(" add data : ${jsonEncode(_shedule)}");
                            if(edit_bool){
                              data[_index_data]=_shedule;
                            }else{
                              data.add(_shedule);
                            }

                            setState(() {
                              edit_bool=false;
                              _time=TimeOfDay.now();
                              dropdownValue="";
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Successfully Inserted'),backgroundColor: Colors.green,));
                          }else{
                            // log("not");

                            setState(() {
                              edit_bool=false;
                              _time=TimeOfDay.now();
                              dropdownValue="";
                            });
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please Enter Valid Data'),backgroundColor: Colors.orange,));
                          }
                          // Handle button press
                        },
                        icon: const Icon(Icons.save, size: 18.0),
                        label: const Text("Save"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          disabledForegroundColor: Colors.grey.withOpacity(0.38),
                          disabledBackgroundColor: Colors.grey.withOpacity(0.12), // Color when the button is disabled
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        });
      },
    );
  }
  int co=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // setState(() {
    mqtt_data_check=false;
    data=widget.data;
    vvv=List<bool>.generate(data.length, (index) => true);
    aaa=List<bool>.generate(data.length, (index) => true);
    // log(" data length  : ${data.length}  , vv : ${vvv.length} , ad data vvv :: $vvv");
    // data_compar=data;
    imei=widget.imei;
    mode=widget.mode;
    day=widget.day;
    maintain_data();
    // });
    // log(" data : ${(widget.data.runtimeType)}");
    // log(" data : ${(widget.data)}");
    // log(" data : ${(data)}");
    // log("normal imei : ${widget.imei}");
    log("normal mode : ${widget.mode}");
    log("normal day : ${widget.day}");
  }
  void maintain_data()async{
    _timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) async{
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("day", widget.day);
      // bool repeat = prefs.getBool('status')??false;
      // api = prefs.getBool('apiupdate')??false;
      selectDay=prefs.getString("select_index")??"";
      deleteDay=prefs.getString("delete_index")??"";
      if (!mounted)
        return;
      log("selected date  :: $selectDay");
      log("repeat date  :: $status_bool");
      // log("api date  :: $api");
      log("mqtt_data_check  :: $mqtt_data_check");
      log("status_bool=true;  :: $status_bool");
      log("update_bool=true;  :: $update_bool");

      if(status_bool){
        // await prefs.setBool('status', false);
        // await prefs.setBool('apiupdate', false);
        status_bool=false;
        setState(() {
          vvv;
          // aaa;
        });
      }else{
        // log("status : $repeat");
      }
      if(update_bool){
        // await prefs.setBool('status', false);
        // await prefs.setBool('apiupdate', false);
        update_bool=false;
        update_bool=false;
        // if (!mounted)
        //   return;
        setState(() {
          // vvv;
          aaa;
        });
      }else{
        // log("status : $repeat");
      }

      if(selectDay==day) {
        String _copyeddata = prefs.getString("copy") ?? "";
        // log("coppppppppp:: $_copyeddata");
        List p = jsonDecode(_copyeddata);
        // log("ppppp data type : ${p.runtimeType} ");
        log("condition check ; ${data.where((element) => element['time'] == p[0]["time"]).isEmpty}");
        if (data.where((element) => element['time'] == p[0]["time"]).isEmpty) {
          if (data.isNotEmpty) {
            data.addAll(p);
            for (int i = 0; i < p.length; i++) {
              vvv.add(false);
              aaa.add(false);
            }
            log("*****************************");
            // await prefs.setString("day", widget.day);
          } else {
            log("----------------------");
            data = p;
            vvv = await List<bool>.generate(p.length, (index) => false);
            aaa = await List<bool>.generate(p.length, (index) => false);
          }

          try {
            // await MqttService.initMqtt();
            if (mode == 'normal') {
              // Map<String,String> data={"time":time,"sound":dropdownValue.toString()};
              var message = { 'day': day, 'mode': "normal", 'alarms': p};
              // print("data  : $data");
              // print("complete data : ${jsonEncode(message).toString()}");
              MqttService.publish(
                  "$imei/schedule", jsonEncode(message).toString());
            } else if (mode == "exam") {
              Map<String, String> data = {
                "time": time,
                "sound": dropdownValue.toString()
              };
              var message = { 'day': day, 'mode': "exam", 'alarms': p};
              // print("data  : $data");
              // print("complete data : ${jsonEncode(message).toString()}");
              MqttService.publish("$imei/schedule", jsonEncode(message).toString());
              // MqttService.publish("$imei/exam_schedule", jsonEncode(message).toString());
            }
            get_mqtt_data();
            await prefs.setString("select_index", "");
          } catch (e) {
            setState(() {
              flag = "Error";
            });
          }
          // get_mqtt_data();

          setState(() {

          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pasted'), backgroundColor: Colors.green,));
        }
      }

      if(deleteDay==day){
        data=[];
        vvv=[];
        aaa=[];
        // widget.data=[]
        await prefs.setString("delete_index", "");
        setState(() {

        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Deleted'),backgroundColor: Colors.green,));
      }

      // setState(() {
      //   edit_bool;
      //   if(!edit_bool){
      //     _time;
      //     dropdownValue;
      //     data;
      //     mqtt_data_check;
      //     // data_compar;
      //     log("mqtt_data_check : $mqtt_data_check");
      //     log("chekkkkkkkkkk : ${widget.data}");
      //     // log("mqtt_data_check : $data_compar");
      //   }
      // });
    });
  }
  void get_mqtt_data() async{
    // imei=widget.imei;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // String selectDay=prefs.getString("select_index")??"";
    // await MqttService.initMqtt();
    // setState(() {

    MqttService.client.updates!.listen((dynamic t) {
      String _topic = t[0].topic;
      MqttPublishMessage recMessage = t[0].payload;
      var payload = MqttPublishPayload.bytesToStringAsString(
          recMessage.payload.message);
      if(_topic=='$imei/alarmlist'){
        // all_day=payload;
        all_day=alldayFromJson(payload);

        log("payload data type ${all_day.runtimeType}");
        log("page : $mode");
        log("page : $day");
        // log("page : $selectDay");
        String _copyeddata =prefs.getString("copy")??"";
        // log("coppppppppp:: $_copyeddata");
        List p=jsonDecode(_copyeddata);
        if(mode=="normal"){
          Exam narmaldata=all_day.normal;

            if(day=="SUN"){
            List checkData=narmaldata.sun;
            for(int i=0;i<p.length;i++){
              String ttt=p[i]["time"];
              String sss=p[i]["sound"];
              log("check  message is present  :: ${checkData.where((element) => element['time'] == ttt && element['sound'] == sss).isNotEmpty}");
              if(checkData.where((element) => element['time'] == ttt && element['sound'] == sss).isNotEmpty){
                int pos=data.indexWhere((element) => element['time'] == ttt);
                setState(() {
                  vvv[pos]=true;
                });
              }

            }

            // prefs.setBool('status', true);
            status_bool=true;
            mqtt_data_check=true;


          }

          // normal_exam_data=all_day['normal'];
          // log(" normal data :  ${normal_exam_data.runtimeType}");
        }else if(mode=="exam"){
          Exam narmaldata=all_day.exam;
            if(day=="SUN"){
            List checkData=narmaldata.sun;
            for(int i=0;i<p.length;i++){
              String ttt=p[i]["time"];
              String sss=p[i]["sound"];
              log("check  message is present  :: ${checkData.where((element) => element['time'] == ttt && element['sound'] == sss).isNotEmpty}");
              if(checkData.where((element) => element['time'] == ttt && element['sound'] == sss).isNotEmpty){
                int pos=data.indexWhere((element) => element['time'] == ttt);
                setState(() {
                  vvv[pos]=true;
                });
              }

            }

            // prefs.setBool('status', true);
            status_bool=true;
            mqtt_data_check=true;


          }

          // normal_exam_data=all_day['exam'];
          // log(" exam data :  $normal_exam_data");
        }
      }
      else if(_topic=='$imei/log'){
        log_arr=payload;
      }
      // print("topic is $_topic Payload is $payload");
    });
    // });
    print("up up up");
    // List day=['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    MqttService.subscribeTopic("$imei/alarmlist");
    MqttService.subscribeTopic("$imei/log");
    Map<String, String> ms={"command":"all"};
    print("day data   : $ms");
    MqttService.publish("$imei/getAlarmlist", jsonEncode(ms).toString());
setState(() {

});
  }
  @override
  void dispose() {
    _timer.cancel();
    _timer;
    // TODO: implement dispose
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.teal,
      // body: times.isNotEmpty && music.isNotEmpty && times.length==music.length?
      body: data.isNotEmpty?
      ListView.builder(
          itemCount: data.length,
          itemBuilder: (context,index){
            // log("terrrrrrrrrr: $mqtt_data_check");
            if(mqtt_data_check){
              mqtt_data_check=false;
              maintain_data();
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Slidable(
                    // key: const ValueKey(0),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          autoClose: true,
                          flex: 1,
                          onPressed: (value) async{
                            try{
                              // await MqttService.initMqtt();
                              var tim= data[index]['time'];
                              SharedPreferences tr= await  SharedPreferences.getInstance();
                              var  mobileno= tr.getString("mobile")??"";
                              String uri ="http://api.iautobells.com/api/autobell_device.php";
                              Map<String,dynamic> update_data={"mode":mode,"day":day,"exidata":data[index]};
                              Map<String,dynamic> ody_data ={"action":"delete","device_id":imei,"data":jsonEncode(update_data)};
                              http.Response response=await http.post(Uri.parse(uri),body:ody_data);
                              log("response data : "+response.body);
                              log("response code : "+response.statusCode.toString());
                              // var u_data= jsonDecode(response.body);
                              if(response.statusCode==200){
                                log("delete");
                              }else{
                                log(" not delete");
                              }

                              if(widget.mode=="normal"){
                                Map<String,String> mess={"day":day,"mode":"normal","delete":tim.toString()};
                                MqttService.publish("$imei/schedule", jsonEncode(mess).toString());
                                print("delete map : $mess");
                              }else if(widget.mode=="exam"){
                                Map<String,String> mess={"day":day,"mode":"exam","delete":tim.toString()};
                                MqttService.publish("$imei/schedule", jsonEncode(mess).toString());
                                print("delete map : $mess");
                              }
                              data.removeAt(index);
                              log(" print : delete");
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Deleted '),backgroundColor: Colors.green,));
                              setState(() {

                              });

                            }catch(e){
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const   SnackBar(content: Text('Error'),backgroundColor: Colors.orange,));
                            }

                          },
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                        SlidableAction(
                          autoClose: true,
                          flex: 1,
                          onPressed: (value) async{
                            // SharedPreferences pref = await SharedPreferences.getInstance();
                            // pref.setString("time", times[index]);
                            // pref.setString("music", music[index]);
                            // pref.setInt("index", index);
                            log(" print : edit");
                            edit_bool=true;
                            time=data[index]['time'];
                            dropdownValue=data[index]['sound'];
                            DateTime tempDate = DateFormat('hh:mm').parse(time);
                            _index_data=index;
                            vvv[index]=false;
                            aaa[index]=false;
                            _time = TimeOfDay(hour: tempDate.hour, minute: tempDate.minute);
                            // showMyModalBottomSheet();
                            var chi =await  showModalBottomSheet(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                ),
                                context: context,
                                builder: ( BuildContext context ) {
                                  return MyBottomSheet();
                                });
                            log("chi : ${chi}");
                            setState(() {
                            });
                          },
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: Builder(
                        builder: (context) {
                          return InkWell(
                            onTap: (){
                              final controller = Slidable.of(context)!;
                              final isClosed = controller.actionPaneType.value == ActionPaneType.none; // you can use this to check if its closed
                              if (isClosed) {
                                print("isClosed if : $isClosed");
                                // use this to open it
                                setState(() {
                                  slide=true;
                                });
                                controller.openEndActionPane();
                              } else {
                                // if you want to close the ActionPane
                                controller.close();
                                setState(() {
                                  slide=false;
                                });
                                print("isClosed else : $isClosed");
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 70,
                                color: Colors.white,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      color: vvv[index] ?Colors.green:Colors.red,
                                      // color: mqtt_data_check && tt==data[index]['time'] && ss==data[index]['sound'] || widget.data[index]["time"]==data[index]['time'] ?Colors.green:Colors.red,
                                      width: 70,
                                      height: 70,
                                      // child: Icon(Icons.cake, color: Colors.white),
                                      child: Center(child: CircleAvatar(child: Text("${index + 1}"))),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          aaa[index] || vvv[index]?Row(
                                            children: [
                                              Text('${data[index]['time']}'), SizedBox(width: 20),
                                              vvv[index]  ? Image.asset('assets/read.png', color: Colors.blue, width: 20.0)  : aaa[index] ? Image.asset('assets/api.png', color: Colors.grey, width: 20.0): Container(),
                                              // vvv[index]  ? Icon(Icons.check, color: Colors.blue, size: 20.0) : aaa[index] ? Icon(Icons.check, color: Colors.grey, size: 20.0): Container(),
                                              // vvv[index]  ? Icon(Icons.check, color: Colors.blue, size: 20.0) : aaa[index] ? Icon(Icons.check, color: Colors.grey, size: 20.0): Container(),
                                            ],
                                          ):Row(
                                            children: [
                                              Text('${data[index]['time']}'),
                                              Icon(Icons.check, color: Colors.grey, size: 20.0)
                                              // vvv[index]  ? Icon(Icons.check, color: Colors.blue, size: 20.0) : aaa[index] ? Icon(Icons.check, color: Colors.grey, size: 20.0): Container(),
                                            ],
                                          ),
                                          Text('${data[index]['sound']}',
                                              style: const TextStyle(color: Colors.grey))
                                        ],
                                      ),
                                    ),
                                    Icon(slide?Icons.arrow_forward_ios :Icons.arrow_back_ios,
                                        color: Colors.blue),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                ),
                // const Divider(color: Colors.black38,)
              ],
            );
          }):const Center(
        child: Text("Your List is Empty",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton(onPressed: ()async{
        // showMyModalBottomSheet();
        var chi =await  showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            context: context,
            builder: ( BuildContext context ) {
              return MyBottomSheet();
            });
        log("chi : ${chi}");
        setState(() {

        });
      },child: const Icon(Icons.add),),
    );
  }
  @override
  bool get wantKeepAlive => true;
}
class MyBottomSheet extends StatefulWidget {
  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}
String flag="";
String tt="";
String ss="";
class _MyBottomSheetState extends State<MyBottomSheet> {

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time)
      setState(() {
        _time = picked;
      });
  }
  void get_music_ftp()async{
    // String url="http://devices.iautobells.com/ftp_fileread.php";
    String url="http://api.iautobells.com/ftp_fileread.php";
    http.Response response=await  http.post(Uri.parse(url));
    log("response :: ${response.statusCode}");
    if(response.statusCode==200){
      setState(() {
        music_data = jsonDecode(response.body);
        music_data1=music_data.map((element) => element.toString()).toList();
        // music_data1.insert(0, "select music");
        print('music_data type :: ${music_data.runtimeType}');
        print('music_data  :: ${music_data}');
        print('music_data1 type :: ${music_data1.runtimeType}');
        print('music_data1  :: $music_data1');
      });
    }}
  void get_music() async{
    // imei=widget.imei;
    // await MqttService.initMqtt();
    setState(() {
      MqttService.client.updates!.listen((dynamic t) {
        String _topic = t[0].topic;
        MqttPublishMessage recMessage = t[0].payload;
        var payload = MqttPublishPayload.bytesToStringAsString(
            recMessage.payload.message);
        if(_topic=='$imei/audiolist'){
          // all_day=payload;
          setState(() {
            // all_day=jsonDecode(payload);
            music_data = jsonDecode(payload);
            music_data1=music_data.map((element) => element.toString()).toList();
            print('music_data type :: ${music_data.runtimeType}');
            print('music_data  :: ${music_data}');
            print('music_data1 type :: ${music_data1.runtimeType}');
            print('music_data1  :: $music_data1');
          });

          // log("payload data type ${all_day.runtimeType}");
        }
        else if(_topic=='$imei/log'){
          log_arr=payload;
        }
        print("topic is $_topic Payload is $payload");
      });
    });

    print("up up up");
    // List day=['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    MqttService.subscribeTopic("$imei/audiolist");
    MqttService.subscribeTopic("$imei/log");
    Map<String, String> ms={};
    print("day data   : $ms");
    MqttService.publish("$imei/getAudiolist", jsonEncode(ms).toString());

  }
  void get_mqtt_data() async{
    // imei=widget.imei;
    // await MqttService.initMqtt();
    // setState(() {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    MqttService.client.updates!.listen((dynamic t) {
      String _topic = t[0].topic;
      MqttPublishMessage recMessage = t[0].payload;
      var payload = MqttPublishPayload.bytesToStringAsString(
          recMessage.payload.message);
      if(_topic=='$imei/alarmlist'){
        // all_day=payload;
        all_day=alldayFromJson(payload);

        log("payload data type ${all_day.runtimeType}");
        log("page : ${mode}");
        log("page : ${day}");
        if(mode=="normal"){
          Exam narmaldata=all_day.normal;
          if(day=="SUN"){
            log("day message : ${narmaldata.sun}");
            log("day message type : ${narmaldata.sun.runtimeType}");
            log("time: $tt  , sound :: $ss");
            List check_data=narmaldata.sun;
            log("check  message is present  :: ${check_data.where((element) => element['time'] == tt && element['sound'] == ss).isNotEmpty}");

            // log("check  message is present uu  :: ${check_data.contains(hhhhh)}");
            // if(check_data.where((element) => element['time'] == tt && element['sound'] == ss).isNotEmpty){
            if(check_data.where((element) => element['time'] == tt && element['sound'] == ss).isNotEmpty){
              if(flag=="Inserted"){
                vvv[vvv.length-1]=true;
              }else if(flag=="Updated"){
                vvv[_index_data]=true;
              }
              // setState(() {
              // prefs.setBool('status', true);
              status_bool=true;
              Map hhhhh={"time": tt, "sound": ss};
              // data_compar.add(hhhhh);
              mqtt_data_check=true;

              // });
            }

          }
          // normal_exam_data=all_day['normal'];
          // log(" normal data :  ${normal_exam_data.runtimeType}");
        }else if(mode=="exam"){
          Exam narmaldata=all_day.exam;

           if(day=="SUN"){
            log("day message : ${narmaldata.sun}");
            log("day message type : ${narmaldata.sun.runtimeType}");
            log("time: $tt  , sound :: $ss");
            List check_data=narmaldata.sun;
            log("check  message is present  :: ${check_data.where((element) => element['time'] == tt && element['sound'] == ss).isNotEmpty}");

            // log("check  message is present uu  :: ${check_data.contains(hhhhh)}");
            // if(check_data.where((element) => element['time'] == tt && element['sound'] == ss).isNotEmpty){
            if(check_data.where((element) => element['time'] == tt && element['sound'] == ss).isNotEmpty){
              if(flag=="Inserted"){
                vvv[vvv.length-1]=true;
              }else if(flag=="Updated"){
                vvv[_index_data]=true;
              }
              // setState(() {
              // prefs.setBool('status', true);
              status_bool=true;
              Map hhhhh={"time": tt, "sound": ss};
              // data_compar.add(hhhhh);
              mqtt_data_check=true;

              // });
            }

          }

          // normal_exam_data=all_day['exam'];
          // log(" exam data :  $normal_exam_data");
        }
      }
      else if(_topic=='$imei/log'){
        log_arr=payload;
      }
      print("topic is $_topic Payload is $payload");
    });
    // });
    print("up up up");
    // List day=['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    MqttService.subscribeTopic("$imei/alarmlist");
    MqttService.subscribeTopic("$imei/log");
    Map<String, String> ms={"command":"all"};
    print("day data   : $ms");
    MqttService.publish("$imei/getAlarmlist", jsonEncode(ms).toString());
    setState(() {

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_music();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
          ),
          width: double.infinity,
          // color: Colors.red,
          child: Column(
            children:  [
              const SizedBox(height: 10,),
              edit_bool?const Text("Edit Schedule",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),) :const Text("Add Schedule",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
            ],
          ),
        ),
        const Divider(color: Colors.blue,thickness: 3),
        // SizedBox(height: 20,),
        ElevatedButton.icon(
          onPressed: () {
            _selectTime(context);
            // Handle button press
          },
          icon: const Icon(Icons.access_time, size: 18.0),
           label: Text("${_time.format(context)}"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            disabledForegroundColor: Colors.grey.withOpacity(0.38),
            disabledBackgroundColor: Colors.grey.withOpacity(0.12), // Color when the button is disabled
          ),
        ),
        // TextButton(
        //   child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       const Icon(Icons.timer),
        //       const Text('Pick time'),
        //     ],
        //   ),
        //   onPressed: () async {
        //     final TimeOfDay? pickedTime = await showTimePicker(
        //       context: context,
        //       initialTime: TimeOfDay.now(),
        //       builder: (context, child) {
        //         return MediaQuery(
        //           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        //           child: child ?? Container(),
        //         );
        //       },
        //     );
        //
        //     if (pickedTime != null) {
        //       setState(() {
        //         time = "${(pickedTime.hour).toString().length==1?"0${pickedTime.hour}":pickedTime.hour}:${(pickedTime.minute).toString().length==1?"0${pickedTime.minute}":pickedTime.minute}";
        //         time_bool=true;
        //         // print("time : $times");
        //         // time = 'Time selected: ${pickedTime.format(context)}';
        //       });
        //     }
        //   },
        // ),
        // time_bool?Text("Time : $time"):Text(time),
        Padding(
          padding: const EdgeInsets.all(8.0),
          // child: DropdownSearch<String>(
          //   popupProps:  const PopupProps.menu(
          //     showSelectedItems: true,
          //     showSearchBox: true,

          //     // disabledItemFn: (String s) => s.startsWith('I'),
          //   ),

          //   items: music_data1,
          //   dropdownDecoratorProps: const DropDownDecoratorProps(
          //     dropdownSearchDecoration: InputDecoration(
          //       labelText: "Select Music",
          //       border: OutlineInputBorder(),
          //       suffixIcon: Icon(Icons.arrow_drop_down),
          //       hintText: "Please select valid Music",
          //     ),
          //   ),
          //   onChanged:  (value) {
          //     setState(() {
          //       dropdownValue = value as String;
          //       // print("music : $music");
          //     });
          //   },
          //   selectedItem: dropdownValue,
          // ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      edit_bool=false;
                      _time=TimeOfDay.now();
                      dropdownValue="";
                    });
                    Navigator.pop(context);
                    // _selectTime(context);
                    // Handle button press
                  },
                  icon: const Icon(Icons.access_time, size: 18.0),
                  label: const Text("Cancel"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    disabledForegroundColor: Colors.grey.withOpacity(0.38),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.12), // Color when the button is disabled
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () async{
                    if(dropdownValue!=null&&dropdownValue!=""&&dropdownValue!.isNotEmpty){
                      time ="${_time.hour.toString().length==1?"0${_time.hour}":_time.hour}:${_time.minute.toString().length==1?"0${_time.minute}":_time.minute}";
                      Map<String,String> _shedule={"time": "$time", "sound": "$dropdownValue"};
                      tt=time;
                      ss=dropdownValue!;
                      // log(" add data : ${jsonEncode(_shedule)}");
                      SharedPreferences tr= await  SharedPreferences.getInstance();
                      var  mobileno= tr.getString("mobile")??"";
                      String uri ="http://api.iautobells.com/api/autobell_device.php";
                      if(edit_bool){

                        Map<String,dynamic> update_data={"mode":mode,"day":day,"exidata":data[_index_data],"update":_shedule};
                        Map<String,dynamic> ody_data ={"action":"update","device_id":imei,"data":jsonEncode(update_data)};
                        http.Response response=await http.post(Uri.parse(uri),body:ody_data);
                        log("response data : "+response.body);
                        log("response code : "+response.statusCode.toString());
                        // var u_data= jsonDecode(response.body);
                        if(response.statusCode==200){
                          log("updated");
                          aaa[_index_data]=true;
                          // final SharedPreferences prefs = await SharedPreferences.getInstance();
                          // prefs.setBool("apiupdate", true);
                          update_bool=true;
                        }else{
                          log(" not updated");
                        }
                        data[_index_data]=_shedule;
                        setState(() {
                          flag="Updated";
                        });
                      }
                      else{
                        // log("data : $data");
                        // log("timei contain check :: ${data.where((element) => element['time'] == time).isEmpty}");
                        if(data.where((element) => element['time'] == time).isEmpty){
                          Map<String,dynamic> update_data={"mode":mode,"day":day,"data":_shedule};
                          Map<String,dynamic> ody_data ={"action":"add","device_id":imei,"data":jsonEncode(update_data)};
                          http.Response response=await http.post(Uri.parse(uri),body:ody_data);
                          log("response data : "+response.body);
                          log("response code : "+response.statusCode.toString());
                          // var u_data= jsonDecode(response.body);
                          if(response.statusCode==200){
                            log("added");
                            aaa.add(true);
                            // final SharedPreferences prefs = await SharedPreferences.getInstance();
                            // prefs.setBool("apiupdate", true);
                            update_bool=true;
                          }else{
                            log(" not added");
                          }
                          data.add(_shedule);
                          vvv.add(false);
                          setState(() {
                            flag="Inserted";
                          });
                        }else{
                          setState(() {
                            flag="Available";
                          });
                        }
                      }
                      try{
                        // await MqttService.initMqtt();
                        if(mode=='normal'){
                          Map<String,String> data={"time":time,"sound":dropdownValue.toString()};
                          var message={ 'day': day, 'mode':"normal", 'alarms': [data] };
                          print("data  : $data");
                          print("complete data : ${jsonEncode(message).toString()}");
                          MqttService.publish("$imei/schedule", jsonEncode(message).toString());
                        }else if(mode=="exam"){
                          Map<String,String> data={"time":time,"sound":dropdownValue.toString()};
                          var message={ 'day': day, 'mode':"exam", 'alarms': [data] };
                          print("data  : $data");
                          print("complete data : ${jsonEncode(message).toString()}");
                          MqttService.publish("$imei/schedule", jsonEncode(message).toString());
                          // MqttService.publish("$imei/exam_schedule", jsonEncode(message).toString());
                        }
                        get_mqtt_data();
                      }catch(e){
                        setState(() {
                          flag="Error";
                        });
                      }
                    }else{
                      log("not");
                      setState(() {
                        flag="NotValid";
                      });
                    }
                    setState(() {
                      edit_bool=false;
                      _time=TimeOfDay.now();
                      dropdownValue="";
                    });
                    if(flag=="NotValid"){
                      Navigator.pop(context, "test");
                      // Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please Enter Valid Data'),backgroundColor: Colors.orange,));
                    }else if(flag=="Available"){
                      Navigator.pop(context, "test");
                      // Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data Already Available'),backgroundColor: Colors.orange,));
                      log("data already available");
                    }
                    else if(flag=="Inserted"){
                      Navigator.pop(context, "test");
                      // Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Successfully Inserted'),backgroundColor: Colors.green,));
                    }
                    else if(flag=="Updated"){
                      Navigator.pop(context, "test");
                      // Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Successfully Updated'),backgroundColor: Colors.green,));
                    }
                    else if(flag=="Error"){
                      // Navigator.of(context).pop();
                      Navigator.pop(context, "test");
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error'),backgroundColor: Colors.orange,));
                    }
                  },
                  icon: const Icon(Icons.save, size: 18.0),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    disabledForegroundColor: Colors.grey.withOpacity(0.38),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.12), // Color when the button is disabled
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}