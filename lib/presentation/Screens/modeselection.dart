// import 'package:flutter/material.dart';
// import 'package:rimza1/data/user.dart';


// class ModeSelectionScreen extends StatelessWidget {
//   final DeviceModel device;

//   const ModeSelectionScreen({Key? key, required this.device}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Mode Selection'),
//       ),
//       body: Center(
//         child: Text('Selected Device: ${device.deviceName}'),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:rimza1/Logic/bloc/modeselection/modeselection_bloc.dart';
import 'package:rimza1/Logic/bloc/modeselection/modeselection_event.dart';
import 'package:rimza1/Logic/bloc/modeselection/modeselection_state.dart';
import 'package:rimza1/data/user.dart';
import 'package:rimza1/presentation/widget/widgets.dart';

class ModeSelectionScreen extends StatelessWidget {
  // final Map<String, String> device;
  final DeviceModel device;

  const ModeSelectionScreen({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ModeSelectionBloc(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
          title: Text(
                 '${device.deviceName}',
            // Text('Selected Device: ${device.deviceName}'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            Lottie.asset('assets/lotties/green.json', width: 60, height: 60),
            SizedBox(width: 10),
          ],
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<ModeSelectionBloc, ModeSelectionState>(
          builder: (context, state) {
            return Padding(
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
                              Text(
                                state.currentTime,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Technology",
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(state.currentDate, style: TextStyle(fontSize: 15)),
                              SizedBox(height: 4,),
                              Text("Today : Working Day", style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 1,
                          color: Colors.black,
                          margin: EdgeInsets.symmetric(horizontal: 35),
                        ),
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
                                    onTap: () => context.read<ModeSelectionBloc>().add(ToggleExamMode()),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: state.isExamMode ? Colors.amber : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.list_alt, color: state.isExamMode ? Colors.white : Colors.black54),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => context.read<ModeSelectionBloc>().add(ToggleExamMode()),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: !state.isExamMode ? Colors.amber : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.alarm, color: !state.isExamMode ? Colors.white : Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(state.isExamMode ? "Exam Mode" : "Regular Mode"),
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
                          // ModeCard(icon: Icons.alarm, text: "Regular Mode", onTap: () => Get.to(() => WeekTabPage())),
                          ModeCard(icon: Icons.edit_document, text: "Exam Mode", onTap: () {}),
                          ModeCard(icon: Icons.calendar_month_outlined, text: "Holiday", onTap: () {}),
                        ],
                      ),
                      Column(
                        children: [
                          // ModeCard(icon: Icons.music_note_sharp, text: "Music", onTap: () => Get.to(() => AudioListPage())),
                          // ModeCard(icon: Icons.timer, text: "SVM", onTap: () => Get.to(() => Scheduletask())),
                          // ModeCard(icon: Icons.speaker, text: "DVM", onTap: () => Get.to(() => Dvmscreen())),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}



