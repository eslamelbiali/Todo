import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/theme.dart';
import 'package:todo/ui/widgets/button.dart';
import 'package:todo/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController taskController = Get.put(TaskController());

  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();
  int selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String selectedRepeat = 'none';
  List<String> repeatList = ['Daily', 'Weekly', 'Monthly'];
  int selectedColor = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        actions: const [
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('images/person.jpeg'),
          ),
          SizedBox(
            width: 20,
          )
        ],
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 24,
            color: primaryClr,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Text(
              'Add Task',
              style: headingStyle,
            ),
            InputField(
              hint: 'Enter Title Here',
              title: 'Title',
              controller: titleController,
            ),
            InputField(
              hint: 'Enter Note Here',
              title: 'Note',
              controller: noteController,
            ),
            InputField(
              hint: DateFormat.yMd().format(_selectedDate),
              title: 'Date',
              widget: IconButton(
                  onPressed: () => addDateFromUser(),
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  )),
            ),
            Row(
              children: [
                Expanded(
                    child: InputField(
                  hint: startTime,
                  title: 'Start Time',
                  widget: IconButton(
                      onPressed: () => getTimeFromUser(isStartTime: true),
                      icon: const Icon(
                        Icons.access_time,
                        color: Colors.grey,
                      )),
                )),
                Expanded(
                    child: InputField(
                  hint: endTime,
                  title: 'End Time',
                  widget: IconButton(
                      onPressed: () => getTimeFromUser(isStartTime: false),
                      icon: const Icon(
                        Icons.access_time,
                        color: Colors.grey,
                      )),
                )),
              ],
            ),
            InputField(
              hint: '$selectedRemind minutes early',
              title: 'Remind',
              widget: DropdownButton(
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.blueGrey,
                style: subTitleStyle,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                iconSize: 32,
                underline: Container(
                  height: 0,
                ),
                items: remindList
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          '$e',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (int? value) {
                  setState(() {
                    selectedRemind = value!;
                  });
                },
              ),
            ),
            InputField(
              hint: selectedRepeat,
              title: 'Repeat',
              widget: DropdownButton(
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.blueGrey,
                style: subTitleStyle,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                iconSize: 32,
                underline: Container(
                  height: 0,
                ),
                items: repeatList
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRepeat = value.toString();
                  });
                },
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color',
                      style: titleStyle,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Wrap(
                      children: List.generate(
                        3,
                        (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = index;
                              });
                            },
                            child: CircleAvatar(
                              child: selectedColor == index
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                              backgroundColor: index == 0
                                  ? primaryClr
                                  : index == 1
                                      ? pinkClr
                                      : orangeClr,
                              radius: 16,
                            )),
                      ),
                    )
                  ],
                ),
                MyButton(
                    label: 'Create Task',
                    onTap: () {
                      validateDate();
                    }),
              ],
            )
          ],
        )),
      ),
    );
  }

  validateDate() {
    if (titleController.text.isNotEmpty && noteController.text.isNotEmpty) {
      addTaskToDb();
      Get.back();
    } else if (titleController.text.isEmpty || noteController.text.isEmpty) {
      Get.snackbar('Title', '',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: pinkClr,
          icon: const Icon(
            Icons.warning_amber,
            color: Colors.red,
          ));
    } else {
      print('SOMETHING BAD HAPPENED');
    }
  }

  addTaskToDb() async {
    int value = await taskController.addTask(
      task: Task(
        title: titleController.text,
        note: noteController.text,
        isCompleted: 0,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: startTime,
        endTime: endTime,
        color: selectedColor,
        remind: selectedRemind,
        repeat: selectedRepeat,
      ),
    );
    print('$value');
  }

  addDateFromUser() async {
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
    );
    if (_pickedDate != null)
      setState(() {
        _selectedDate = _pickedDate;
      });
    else
      print('It\'s null Something wrong');
  }

  getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? _pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(
              DateTime.now().add(const Duration(minutes: 15))),
    );
    String formattingTime = _pickedTime!.format(context);
    if (isStartTime)
      setState(() {
        startTime = formattingTime;
      });
    else if (!isStartTime)
      setState(() {
        endTime = formattingTime;
      });
    else
      print('It\'s null Something wrong');
  }
}
