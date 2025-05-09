import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart' show Get;
import 'package:get/get_navigation/get_navigation.dart';

class Dvmscreen extends StatefulWidget {
  const Dvmscreen({super.key});

  @override
  State<Dvmscreen> createState() => _DvmscreenState();
}

String? selectedSubject;
  List<String> subjects = ['0007_Long_Bell_1_mp3'];

class _DvmscreenState extends State<Dvmscreen> {
   List<bool> isSelected = [true, false];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
appBar:  AppBar(
        title: Text(
          "Direct Voice Music",
          style: TextStyle(color: Colors.blue.shade900),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade900),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              // color: const Color.fromARGB(255, 0, 0, 0),
              isSelected: isSelected,
              selectedColor: Colors.white,
              // color: Colors.grey,
              fillColor: Colors.amber.shade400,

              onPressed: (index) {
                setState(() {
                  for (int i = 0; i < isSelected.length; i++) {
                    isSelected[i] = i == index;
                  }
                });
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.mic, color: isSelected[0] ? Colors.white : Colors.blue.shade900,),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.file_copy, color: isSelected[0] ? Colors.blue.shade900 : Colors.white,),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(padding: EdgeInsets.all(18),
      child: Column(
        children: [
          SizedBox(height: 20,),
          DropdownButtonFormField<String>(
              decoration: InputDecoration(
                focusColor: Colors.blue.shade900,
                labelText: "Select Music",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              value: selectedSubject,
              items:
                  subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                });
              },
            ),
            SizedBox(height: 80,),
          //  Miccircle()
          MicButton(),
          SizedBox(height: 20,),
          Center(
            child: Text("00:00:00",style: TextStyle(color: Colors.blue.shade900,fontSize: 30,fontWeight: FontWeight.bold),),
          )
        
        ],
      ),
      ),
    );
  }
}

class MicButton extends StatefulWidget {
  const MicButton({Key? key}) : super(key: key);

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          // 🔥 Your action here
          print("Mic Button Pressed!");
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: _isPressed
                  ? [Colors.amber.shade400, Colors.amber.shade400]
                  : [Colors.blue.shade800, Colors.blue.shade900],
              center: Alignment.topLeft,
              radius: 1.2,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
          ),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade900,
              border: Border.all(color: Colors.white, width: 4),
            ),
            // child: const Icon(
            //   Icons.mic,
            //   size: 50,
            //   color: Colors.white,
            // ),
             child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(16), // control image size
                child: Image.asset(
                  'assets/images/Mic.png', // 🔄 Your image path
                  fit: BoxFit.contain,
                  color: Colors.white, // remove if the image is colored
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}