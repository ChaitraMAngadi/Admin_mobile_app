import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// @RoutePage()
// class SlotPage extends StatefulWidget {
//   const SlotPage({super.key});

//   @override
//   State<SlotPage> createState() => _SlotPageState();
// }

// class _SlotPageState extends State<SlotPage> {
//   int selectedDuration = 15;
//   List<String> generatedSlots = [];

//   // int selectedDuration = 15;
// List<int> durations = [15, 30, 60];

// Widget durationSelector() {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: durations.map((d) {
//       return GestureDetector(
//         onTap: () {
//           setState(() {
//             selectedDuration = d;
//             loadSlots(); // regenerate slot list
//           });
//         },
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 8),
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: BoxDecoration(
//             color: selectedDuration == d ? Colors.blue : Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             "$d min",
//             style: TextStyle(
//               color: selectedDuration == d ? Colors.white : Colors.black,
//             ),
//           ),
//         ),
//       );
//     }).toList(),
//   );
// }

// Widget slotGrid(List<String> slots) {
//   return GridView.builder(
//     shrinkWrap: true,
//     physics: NeverScrollableScrollPhysics(),
//     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//       crossAxisCount: 3,
//       mainAxisSpacing: 12,
//       crossAxisSpacing: 12,
//       childAspectRatio: 2.8,
//     ),
//     itemCount: slots.length,
//     itemBuilder: (context, index) {
//       return Container(
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.grey),
//         ),
//         child: Text(slots[index]),
//       );
//     },
//   );
// }

//   @override
//   void initState() {
//     super.initState();
//     loadSlots();
//   }

//   void loadSlots() {
//     String login = "08:30";   // API se aayega
//     String leave = "18:30";   // API se aayega

//     generatedSlots = generateSlots(
//       loginTime: login,
//       leaveTime: leave,
//       intervalMinutes: selectedDuration,
//     );
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Select Slot")),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             Text("Slot Duration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),

//             durationSelector(),
//             SizedBox(height: 20),

//             Text("Available Slots", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),

//             slotGrid(generatedSlots),
//           ],
//         ),
//       ),
//     );
//   }
// }

// List<String> generateSlots({
//   required String loginTime,
//   required String leaveTime,
//   required int intervalMinutes,
// }) {
//   List<String> slots = [];

//   DateTime start = DateTime.parse("2024-01-01 $loginTime:00");
//   DateTime end = DateTime.parse("2024-01-01 $leaveTime:00");

//   while (start.isBefore(end)) {
//     slots.add("${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}");
//     start = start.add(Duration(minutes: intervalMinutes));
//   }
//   return slots;
// }

/// ✅ MAIN UI PAGE
///

@RoutePage()
class SlotPage extends StatefulWidget {
  const SlotPage(
      {super.key, required this.patientId, required this.doctorname});
  final String patientId;
  final String doctorname;

  @override
  State<SlotPage> createState() => _SlotPageState();
}

class _SlotPageState extends State<SlotPage> {
  late TextEditingController loginController;
  late TextEditingController logoutController;
  late TextEditingController durationController;

  String? newSelectedTime;
  final Map<int, String> durationToLabel = {
    15: "15 Minutes",
    30: "30 Minutes",
    45: "45 Minutes",
    60: "1 Hour",
  };

  final Map<String, int> labelToDuration = {
    "15 Minutes": 15,
    "30 Minutes": 30,
    "45 Minutes": 45,
    "1 Hour": 60,
  };

  String? selectedDurationText;

  final List<String> _durationOptions = [
    '15 Minutes',
    '30 Minutes',
    '45 Minutes',
    '1 Hour'
  ];
  String? _selectedTime;

  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime =
      TimeOfDay.now(); // Initialize with current time or a specific time

  String formatted24(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  final formkey = GlobalKey<FormState>();

  // @override
  // void initState() {
  //   super.initState();
  //   Provider.of<AdminPageProvider>(context, listen: false).loadInitialData(widget.patientId);
  // }

  @override
  void initState() {
    super.initState();

    loginController = TextEditingController();
    logoutController = TextEditingController();
    durationController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = Provider.of<AdminPageProvider>(context, listen: false);
      await p.loadInitialData(widget.patientId);

      loginController.text = p.loginTime;
      logoutController.text = p.logoutTime;

      // ✅ convert "30" → "30 Minutes"
      selectedDurationText = durationToLabel[p.duration];

      durationController.text = p.duration.toString();

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AdminPageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Doctor Appointment Management",
          style:
              TextStyle(color: Color(0xFF0857C0), fontWeight: FontWeight.bold),
        ),
      ),
      body: p.isLoading
          ? shimmer()
          : SingleChildScrollView(
              padding:
                  EdgeInsets.only(top: 10, right: 16, left: 16, bottom: 16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Doctor: ${p.doctorname}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Login Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            readOnly: true,
                            cursorColor: Colors.grey,
                            controller: loginController,

                            decoration: InputDecoration(
                              focusColor: Colors.grey,
                              border: OutlineInputBorder(),
                              hintText: 'Login Time',
                              suffix: GestureDetector(
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );

                                  if (pickedTime != null) {
                                    setState(() {
                                      selectedTime = pickedTime;
                                      logoutController.text =
                                          pickedTime.format(context);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.timer_outlined,
                                  color: Color(0xFF0857C0),
                                ),
                              ),
                            ),

                            // decoration: InputDecoration(labelText: "Login Time (HH:MM)"),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Logout Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            readOnly: true,
                            cursorColor: Color(0xFF0857C0),
                            controller: logoutController,
                            decoration: InputDecoration(
                              focusColor: Colors.grey,
                              // enabledBorder: OutlineInputBorder(),
                              border: OutlineInputBorder(),
                              hintText: 'Logout Time',
                              suffix: GestureDetector(
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );

                                  if (pickedTime != null) {
                                    setState(() {
                                      selectedTime = pickedTime;
                                      logoutController.text = formatted24(
                                          pickedTime); // ✅ 24-hour format
                                    });
                                  }

                                  // TimeOfDay? pickedTime = await showTimePicker(
                                  //   context: context,
                                  //   initialTime: selectedTime,
                                  // );

                                  // if (pickedTime != null) {
                                  //   setState(() {
                                  //     selectedTime = pickedTime;
                                  //     logoutController.text = pickedTime.format(context);
                                  //   });
                                  // }
                                },
                                child: Icon(
                                  Icons.timer_outlined,
                                  color: Color(0xFF0857C0),
                                ),
                              ),
                            ),

                            // decoration: InputDecoration(labelText: "Leave Time (HH:MM)"),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Time Frame',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            value: selectedDurationText,
                            decoration: InputDecoration(
                              hintText: 'Select Time Duration',
                              border: OutlineInputBorder(),
                            ),
                            items: durationToLabel.values.map((label) {
                              return DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedDurationText = newValue;

                                // ✅ Convert "30 Minutes" → "30"
                                durationController.text =
                                    labelToDuration[newValue!].toString();
                              });
                            },
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            style: const ButtonStyle(
                              padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 20)),
                              backgroundColor:
                                  WidgetStatePropertyAll(Color(0XFF0857C0)),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14)),
                                ),
                              ),
                            ),
                            onPressed: () async {
                              // int duration = int.parse(durationController.text);
                              await p.updateDoctorTiming(
                                widget.patientId,
                                loginController.text.trim(),
                                logoutController.text.trim(),
                                int.parse(durationController.text.trim()),
                                context,
                              );

                              // Implement time change logic
                            },
                            child: const Text(
                              "Update Time",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  dateSelector(p),
                  SizedBox(height: 20),
                  slotGrid(p),
                ],
              ),
            ),
    );
  }

  /// ✅ DATE SELECTOR
  Widget dateSelector(AdminPageProvider p) {
    List<DateTime> dates = List.generate(
        15, (i) => DateTime.now().subtract(Duration(days: 7 - i)));

    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (_, i) {
          DateTime d = dates[i];
          bool active = d.day == selectedDate.day &&
              d.month == selectedDate.month &&
              d.year == selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() => selectedDate = d);
              p.loadByDate(d, widget.patientId);
            },
            child: Container(
              margin: EdgeInsets.only(right: 12),
              width: 70,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: active ? Colors.blue : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(DateFormat("EEE").format(d),
                      style: TextStyle(
                          color: active ? Colors.white : Colors.black)),
                  Text(d.day.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          color: active ? Colors.white : Colors.black)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ✅ SLOT GRID
  Widget slotGrid(AdminPageProvider p) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: p.finalSlots.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, index) {
        final slot = p.finalSlots[index];

        return GestureDetector(
          onTap: () {
            slot.isBooked ? showDeletePopup(slot, p) : showBookPopup(slot, p);
          },
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: slot.isBooked ? Colors.red : Colors.white,
              border:
                  Border.all(color: slot.isBooked ? Colors.red : Colors.green),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${slot.startTime} - ${slot.endTime}",
                  style: TextStyle(
                    color: slot.isBooked ? Colors.white : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  slot.isBooked ? "BOOKED" : "AVAILABLE",
                  style: TextStyle(
                    color: slot.isBooked ? Colors.white : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // /// ✅ SLOT GRID
  // Widget changeDoctorTime(AdminPageProvider p, String doctorname) {
  //   return Card(

  //     child:
  //     Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text("Doctor: $doctorname",
  //           style: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             fontSize: 16,
  //           ),),
  //           const SizedBox(height: 6),
  //           const Text('Login Time',
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold
  //           ),),
  //           const SizedBox(height: 4),
  //           TextField(
  //             decoration: InputDecoration(
  //                               border: OutlineInputBorder(),
  //                               hintText: 'Login Time',
  //                             ),
  //             // decoration: InputDecoration(labelText: "Login Time (HH:MM)"),
  //           ),
  //           const SizedBox(height: 6),
  //           const Text('Logout Time',
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold
  //           ),),
  //           const SizedBox(height: 4),
  //           TextField(
  //              decoration: InputDecoration(
  //                               border: OutlineInputBorder(),
  //                               hintText: 'Logout Time',
  //                             ),
  //             // decoration: InputDecoration(labelText: "Leave Time (HH:MM)"),
  //           ),
  //           const SizedBox(height: 6),
  //           DropdownButtonFormField<String>(
  //                             value: _selectedGender,
  //                             autovalidateMode:
  //                                 AutovalidateMode.onUserInteraction,
  //                             decoration: InputDecoration(
  //                               hintText: 'Select gender of the patient',
  //                               border: OutlineInputBorder(),
  //                               contentPadding: EdgeInsets.symmetric(
  //                                   horizontal: 12, vertical: 15),
  //                             ),
  //                             validator: (value) => value == null
  //                                 ? 'Please select gender of the patient'
  //                                 : null,
  //                             onChanged: (newValue) {
  //                               setState(() {
  //                                 _selectedGender = newValue;
  //                                 newSelectedGender = newValue;
  //                                 print(_selectedGender);
  //                               });
  //                             },
  //                             items: _genderOptions.map((String gender) {
  //                               return DropdownMenuItem<String>(
  //                                 value: gender,
  //                                 child: Text(gender),
  //                               );
  //                             }).toList(),
  //                           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               // Implement time change logic
  //             },
  //             child: Text("Update Time"),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }


String formatDate(String date) {
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return '';
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  /// ✅ BOOK POPUP
  void showBookPopup(SlotModel slot, AdminPageProvider p) {
    TextEditingController name = TextEditingController();
    TextEditingController mobile = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Form(
          key: formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Book Appointment",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),),
                            IconButton(
                  onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
                  ],
                ),
            const SizedBox(height: 12,),
            const Text("Name",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),),
            const SizedBox(height: 4,),
                TextFormField(
                    controller: name,
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Name';
                      }
                      return null; // Return null if validation is successful
                    },
                    decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter Name',
                                  ),
                    ),
                    const SizedBox(height: 6,),
                    const Text("Name",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),),
            const SizedBox(height: 4,),
                TextFormField(
                    controller: mobile,
                    decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter Mobile',
                                  ),
                                   validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Mobile number';
                      }
                      return null; // Return null if validation is successful
                    },
                    ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.all(Radius.circular(16),),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text('Selected Slot: ',
                      style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 15),),
                      const SizedBox(height: 4,),
                      Text("${slot.startTime}-${slot.endTime}",
                      style: const TextStyle(
                        fontSize: 15,
                      ),),
                      const SizedBox(height: 4,),
                      Text("Date: ${formatDate(selectedDate.toString())}",
                      style: const TextStyle(
                        fontSize: 15
                      ),),

                    ],
                  )),
                SizedBox(height: 16,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0857C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                                ),
                  onPressed: () async {
                    if(formkey.currentState!.validate()){
                              
                      await p.bookSlot(
                        widget.patientId, slot, selectedDate, name.text, mobile.text, context);
                    Navigator.pop(context);
                    p.loadByDate(selectedDate, widget.patientId);
                              
                    }
                  },
                  child: const Text("Confirm Booking",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  ),
                                ),
                ),
                const SizedBox(height: 10,),
              ],
            ),
          ),
        ),
        
      ),
    );
  }

  /// ✅ DELETE POPUP
  void showDeletePopup(SlotModel slot, AdminPageProvider p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.all(16),
        
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Delete Booking",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),),
                  IconButton(
                onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                padding:const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Booking",
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),),
                        ElevatedButton(
                          style: const ButtonStyle(
              padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
              backgroundColor: WidgetStatePropertyAll(Colors.red),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
            ),
                          onPressed: ()async{
                            await p.deleteSlot(widget.patientId, slot, selectedDate,context);
                Navigator.pop(context);
                p.loadByDate(selectedDate, widget.patientId);
                          }, child: const Text('Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),),),
                      ],
                    ),
                    const SizedBox(height: 6,),
                    Row(
                      children: [
                        const Text("Name:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),),
                        Text(slot.patientname??'',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6,),
                    Row(
                      children: [
                        const Text("Mobile:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),),
                        Text(slot.patientMobile??'',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6,),
                    Row(
                      children: [
                        const Text("Time Slot:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),),
                        Text('${slot.startTime}-${slot.endTime}'??'',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6,),
                    Row(
                      children: [
                        const Text("Date:",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),),
                        Text(formatDate(selectedDate.toString())??'',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ SHIMMER
  Widget shimmer() {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(16),
      physics: NeverScrollableScrollPhysics(),
      itemCount: 9,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
