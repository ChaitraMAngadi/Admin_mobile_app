import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


@RoutePage()
class SlotPage extends StatefulWidget {
  const SlotPage({
    super.key,
    required this.patientId,
    required this.doctorname,
  });
  final String patientId;
  final String doctorname;

  @override
  State<SlotPage> createState() => _SlotPageState();
}

class _SlotPageState extends State<SlotPage> {
  late TextEditingController loginController;
  late TextEditingController logoutController;
  late TextEditingController durationController;
  late ScrollController _dateScrollController;

  late TextEditingController dateController;

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
    '1 Hour',
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
     _dateScrollController = ScrollController();

    //   final p = context.read<AdminPageProvider>();
    // p.loadInitialData(widget.patientId, selectedDate).then((_) {
    //   _refreshControllers(p);
    // });

    dateController = TextEditingController(
      text: DateFormat("dd-MM-yyyy").format(selectedDate),
    );


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = Provider.of<AdminPageProvider>(context, listen: false);
      await p.loadInitialData(widget.patientId, selectedDate);

    _refreshControllers(p);
    });

    // Scroll to today after build
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //   _scrollToToday();
  // });
  }

   void _refreshControllers(AdminPageProvider p) {
     loginController.text = p.loginTime;
      logoutController.text = p.logoutTime;

      // ✅ convert "30" → "30 Minutes"
      selectedDurationText = durationToLabel[p.duration];

      durationController.text = p.duration.toString();

      setState(() {});
  }


 void _scrollToToday() {
  if (!_dateScrollController.hasClients) {
    // Wait a bit if still not attached
    Future.delayed(const Duration(milliseconds: 200), _scrollToToday);
    return;
  }

  final index = 7; // today is the 8th item (0-based index)
  final itemWidth = 82.0; // your container width + margin

  _dateScrollController.animateTo(
    index * itemWidth,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOut,
  );
}


 bool get isPastDate {
    final now = DateTime.now();
    return selectedDate.isBefore(
      DateTime(now.year, now.month, now.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AdminPageProvider>(context);
    final bool hasBookedSlots = p.finalSlots.any((slot) => slot.isBooked);


    return WillPopScope(
       onWillPop: () async {
    final provider = Provider.of<AdminPageProvider>(context, listen: false);
    provider.loginTime = '9:00';
    provider.logoutTime = '17:00';
    provider.duration = 30;
    return true; // allow back
  },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Doctor Appointment Management",
            style: TextStyle(
              color: Color(0xFF0857C0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: p.isLoading
            ? shimmer()
            : SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 10,
                  right: 16,
                  left: 16,
                  bottom: 16,
                ),
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
                              enabled: !hasBookedSlots,
                              decoration: InputDecoration(
                                focusColor: Colors.grey,
                                border: OutlineInputBorder(),
                                hintText: 'Login Time',
                                suffix:hasBookedSlots?null: GestureDetector(
                                  onTap: () async {
                                    TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime,
                                    );
      
                                    if (pickedTime != null) {
                                      setState(() {
                                        selectedTime = pickedTime;
                                        loginController.text = formatted24(pickedTime);
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
                              enabled: !hasBookedSlots,
                              decoration: InputDecoration(
                                focusColor: Colors.grey,
                                // enabledBorder: OutlineInputBorder(),
                                border: OutlineInputBorder(),
                                hintText: 'Logout Time',
                                suffix:hasBookedSlots? null: GestureDetector(
                                  onTap: () async {
                                    TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime,
                                    );
      
                                    if (pickedTime != null) {
                                      setState(() {
                                        selectedTime = pickedTime;
                                        logoutController.text = formatted24(
                                          pickedTime,
                                        );
                                        // ✅ 24-hour format
                                      });
                                    }
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
                              onChanged:hasBookedSlots?null: (newValue) {
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
                              style:  ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 20,
                                  ),
                                ),
                                backgroundColor:hasBookedSlots?WidgetStatePropertyAll(
                                  Colors.grey.shade400,
                                ): WidgetStatePropertyAll(
                                  Color(0XFF0857C0),
                                ),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              onPressed:hasBookedSlots? null: () async {
                                if (loginController.text.trim().isEmpty ||
                                    logoutController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please select both Login and Logout times.",
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
      
                                // ✅ Parse both times to compare
                                final loginParts = loginController.text.split(
                                  ":",
                                );
                                final logoutParts = logoutController.text.split(
                                  ":",
                                );
      
                                if (loginParts.length < 2 ||
                                    logoutParts.length < 2) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Invalid time format."),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
      
                                final loginTime = DateTime(
                                  2024,
                                  1,
                                  1,
                                  int.parse(loginParts[0]),
                                  int.parse(loginParts[1]),
                                );
      
                                final logoutTime = DateTime(
                                  2024,
                                  1,
                                  1,
                                  int.parse(logoutParts[0]),
                                  int.parse(logoutParts[1]),
                                );
      
                                // ✅ Check condition: login must be earlier than logout
                                if (logoutTime.isBefore(loginTime) ||
                                    logoutTime.isAtSameMomentAs(loginTime)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Logout time must be after Login time.",
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                                // int duration = int.parse(durationController.text);
                                await p.updateDoctorTiming(
                                  widget.patientId,
                                  loginController.text.trim(),
                                  logoutController.text.trim(),
                                  int.parse(durationController.text.trim()),
                                  selectedDate,
                                  context,
                                );
      
                                // Implement time change logic
                              },
                              child:  Text(
                                "Update Time",
                                style: TextStyle(
                                  color:hasBookedSlots?Colors.grey.shade800: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if(hasBookedSlots)
                            SizedBox(height: 8,),
                            if(hasBookedSlots)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16,
                              vertical: 8,),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(16,)),
                                color: Colors.amber.shade50,
                              ),
                              child: Text("⚠️ Timing updates are disabled because there are existing bookings on this date. Please cancel all bookings first to modify the schedule.",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent.shade700,
                              ),),
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    
                    Card(
                      
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Select Appointment Date",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),),
                            SizedBox(height: 6,),
                            TextFormField(
                                      controller: dateController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: GestureDetector(
                                              onTap: _openCalendar,
                                              child:
                                                  Icon(Icons.calendar_month_outlined)),
                                        ),
                                        border: OutlineInputBorder(),
                                        hintText: 'Enter date',
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter date';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                            //         ElevatedButton(
                            //   style:  ButtonStyle(
                            //     padding: WidgetStatePropertyAll(
                            //       EdgeInsets.symmetric(
                            //         vertical: 14,
                            //         horizontal: 20,
                            //       ),
                            //     ),
                            //     backgroundColor: WidgetStatePropertyAll(
                            //       Color(0XFF0857C0),
                            //     ),
                            //     shape: WidgetStatePropertyAll(
                            //       RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.all(
                            //           Radius.circular(14),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            //   onPressed:() async {
                               
                                // await p.loadByDate(selectedDate, widget.patientId);
                                // _refreshControllers(p);
      
                            //     // Implement time change logic
                            //   },
                            //   child:  Text(
                            //     "Change Date",
                            //     style: TextStyle(
                            //       color: Colors.white,
                            //       fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // )

                          ],
                        ),
                      ),
                    ),
                    // dateSelector(p),
                    SizedBox(height: 20),
                    slotGrid(p),
                  ],
                ),
              ),
      ),
    );
  }

 void _openCalendar() async {
    DateTime today = DateTime.now();
  final p = Provider.of<AdminPageProvider>(context, listen: false);

    // Limit: last 7 days + next 7 days
    DateTime firstDate = today.subtract(const Duration(days: 7));
    DateTime lastDate = today.add(const Duration(days: 7));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: "Select a Date",     // Title
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Header color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat("dd-MM-yyyy").format(picked);
   
      });
      p.loadByDate(selectedDate, widget.patientId);
                                _refreshControllers(p);
    }
  }


Widget slotGrid(AdminPageProvider p) {
    if (isPastDate) {
      return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: p.finalSlots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, index) {
        final slot = p.finalSlots[index];

        return GestureDetector(
          onTap: () {
            // ✅ Only allow booking/deleting if not past date
            if (isPastDate) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cannot modify past date slots."),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
            // /slot.isBooked ? showDeletePopup(slot, p) : showBookPopup(slot, p);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: slot.isBooked ? Colors.red : Colors.white,
              border: Border.all(
                color: slot.isBooked ? Colors.red : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${slot.startTime} - ${slot.endTime}",
                  style: TextStyle(
                    color: slot.isBooked ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slot.isBooked ? "BOOKED" : "PAST",
                  style: TextStyle(
                    color: slot.isBooked ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: p.finalSlots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, index) {
        final slot = p.finalSlots[index];

        return GestureDetector(
          onTap: () {
            // ✅ Only allow booking/deleting if not past date
            if (isPastDate) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cannot modify past date slots."),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
            slot.isBooked ? showDeletePopup(slot, p) : showBookPopup(slot, p);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: slot.isBooked ? Colors.red : Colors.white,
              border: Border.all(
                color: slot.isBooked ? Colors.red : Colors.green,
              ),
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
                const SizedBox(height: 4),
                Text(
                  slot.isBooked ? "BOOKED" : "AVAILABLE",
                  style: TextStyle(
                    color: slot.isBooked ? Colors.white : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                    const Text(
                      "Book Appointment",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Name",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
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
                const SizedBox(height: 6),
                const Text(
                  "Mobile Number",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: mobile,
                 inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Mobile',
                  ),
                  validator: (value) {
                    if (value!.length != 10) {
                        return 'Phone number must be exactly 10 digits';
                      }
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                        return 'Enter a valid phone number';
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
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Slot: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${slot.startTime}-${slot.endTime}",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Date: ${formatDate(selectedDate.toString())}",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
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
                      if (formkey.currentState!.validate()) {
                        await p.bookSlot(
                          widget.patientId,
                          slot,
                          selectedDate,
                          name.text,
                          mobile.text,
                          context,
                        );
                        Navigator.pop(context);
                        p.loadByDate(selectedDate, widget.patientId);
                      }
                    },
                    child: const Text(
                      "Confirm Booking",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ DELETE POPUP
  void showDeletePopup(SlotModel slot, AdminPageProvider p) {
    print("slot.patientMobile ${slot}");
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
                  const Text(
                    "Delete Booking",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
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
                        Text(
                          "Booking",
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        ElevatedButton(
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 20,
                              ),
                            ),
                            backgroundColor: WidgetStatePropertyAll(Colors.red),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            await p.deleteSlot(
                              widget.patientId,
                              slot,
                              selectedDate,
                              context,
                            );
                            Navigator.pop(context);
                            p.loadByDate(selectedDate, widget.patientId);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          "Name: ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          slot.patientname ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          "Mobile: ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          slot.patientMobile ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          "Time Slot: ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${slot.startTime}-${slot.endTime}' ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          "Date: ",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatDate(selectedDate.toString()) ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (_, __) => Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
// void _openDateBottomSheet() {
//     DateTime today = DateTime.now();

//     // Past 7 → Today → Next 7
//     List<DateTime> selectableDates = List.generate(
//       15,
//       (i) => today.add(Duration(days: i - 7)),
//     );

//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.all(15),
//           height: 380,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Select Date",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               Divider(),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: selectableDates.length,
//                   itemBuilder: (ctx, i) {
//                     DateTime d = selectableDates[i];
//                     String formatted = DateFormat("dd-MM-yyyy").format(d);

//                     return ListTile(
//                       title: Text(
//                         formatted,
//                         style: TextStyle(
//                           fontWeight: d.day == today.day &&
//                                   d.month == today.month &&
//                                   d.year == today.year
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                           color: d.isAtSameMomentAs(today)
//                               ? Colors.blue
//                               : Colors.black,
//                         ),
//                       ),
//                       onTap: () {
//                         setState(() {
//                           selectedDate = d;
//                           dateController.text = formatted;
//                         });

//                         // widget.onDateSelected(d); 
//                         Navigator.pop(context);
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }


  // Widget dateSelector(AdminPageProvider p) {
  //   List<DateTime> dates = List.generate(
  //     15,
  //     (i) => DateTime.now().subtract(Duration(days: 7 - i)),
  //   );

  //   return SizedBox(
  //     height: 75,
  //     child: ListView.builder(
  //       controller: _dateScrollController,
  //       scrollDirection: Axis.horizontal,
  //       itemCount: dates.length,
  //       itemBuilder: (_, i) {
  //         DateTime d = dates[i];
  //         bool active =
  //             d.day == selectedDate.day &&
  //             d.month == selectedDate.month &&
  //             d.year == selectedDate.year;

  //         return GestureDetector(
  //           onTap: () {
  //             setState(() => selectedDate = d);
  //             p.loadByDate(d, widget.patientId);
  //           },
  //           child: Container(
  //             margin: const EdgeInsets.only(right: 12),
  //             width: 70,
  //             padding: const EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               color: active ? Colors.blue : Colors.grey.shade300,
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Column(
  //               children: [
  //                 Text(
  //                   DateFormat("EEE").format(d),
  //                   style: TextStyle(
  //                     color: active ? Colors.white : Colors.black,
  //                   ),
  //                 ),
  //                 Text(
  //                   d.day.toString(),
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     color: active ? Colors.white : Colors.black,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }





  
}
