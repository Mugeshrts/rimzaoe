import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class WeekTabPage extends StatefulWidget {
  @override
  _WeekTabPageState createState() => _WeekTabPageState();
}

class _WeekTabPageState extends State<WeekTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  late Map<String, List<Map<String, String>>> dayItems;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this);
    dayItems = {
      for (var day in days)
        day: List.generate(
          10,
          (i) => {
            "id": UniqueKey().toString(), // unique identifier
            "time": "${9 + i}:00",
            "file": "000${i + 1}_LONG_BELL_1_.mp3",
          },
        ),
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

 void _editItem(String day, String id) {
    final item = dayItems[day]!.firstWhere((item) => item["id"] == id);
    print("Edit tapped: ${item['time']} - ${item['file']}");
    // You can add navigation or bottom sheet here
  }

void _deleteItem(String day, String id) {
    setState(() {
      dayItems[day]!.removeWhere((item) => item["id"] == id);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Regular',
          style: TextStyle(color: Colors.blue.shade900),
        ),
        actions: [
          IconButton(icon: Icon(Icons.copy), onPressed: () {}),
          IconButton(icon: Icon(Icons.content_paste), onPressed: () {}),
          IconButton(icon: Icon(Icons.delete), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: Colors.blue.shade900,
          indicatorWeight: 3,
          labelColor: Colors.blue.shade900,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: days.map((day) => Tab(text: day)).toList(),
        ),
        iconTheme: IconThemeData(color: Colors.blue.shade900),
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
                child: InkWell(
                  onTap: () {
                    Slidable.of(context)?.openEndActionPane();
                  },
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
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(12)),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              '${index + 1}',
                              style:
                                  TextStyle(color: Colors.blue.shade900),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${9 + index}:00',
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(height: 4),
                                Text(
                                  '000${index + 1}_LONG_BELL_1_.mp3',
                                  style:
                                      TextStyle(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(Icons.check_circle_outline_sharp,
                            color: Colors.blue),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.black),
                        SizedBox(width: 12),
                      ],
                    ),
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
        onPressed: () {},
      ),
    );
  }
}