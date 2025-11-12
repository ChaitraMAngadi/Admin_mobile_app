import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

@RoutePage()
class PatientAdminOutvisitsPage extends StatefulWidget {
  const PatientAdminOutvisitsPage({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  State<PatientAdminOutvisitsPage> createState() => _PatientAdminOutvisitsPageState();
}


class _PatientAdminOutvisitsPageState
    extends State<PatientAdminOutvisitsPage> {
  late Future fetchoutvisits;
  late Future fetchalldoctorsnurses;
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    final adminprovider = context.read<AdminPageProvider>();
    fetchoutvisits = adminprovider.getpatientoutvisits(widget.patientId);
    fetchalldoctorsnurses = adminprovider.getdoctorsnurses();
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShimmerBox(width: 200, height: 32, borderRadius: 16),
              _buildShimmerBox(width: 60, height: 32, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 12),
          _buildShimmerBox(width: double.infinity, height: 18),
          const SizedBox(height: 8),
          _buildShimmerBox(width: 200, height: 16),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShimmerBox(width: 90, height: 32, borderRadius: 16),
              _buildShimmerBox(width: 90, height: 32, borderRadius: 16),
              _buildShimmerBox(width: 90, height: 32, borderRadius: 16),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(
      {required double width, required double height, double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(-1.0, 0.0),
          end: Alignment(1.0, 0.0),
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 1000 + (index * 100)),
          child: _buildShimmerItem(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Patient Visits",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Consumer<AdminPageProvider>(
          builder: (context, adminprovider, child) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16, top: 8),
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return RegisterVisitModel(
                                patientId: widget.patientId,
                                alldoctors: adminprovider.alldoctors,
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0857C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_alt_1_outlined,
                                color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              "Add Visit",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder(
                      future: fetchoutvisits,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.81,
                            child: _buildShimmerList(),
                          );
                        } else {
                          // ✅ Extract visits properly
                          // final visits = adminprovider.patientoutvisits["data"]["visits"] ?? [];
                          final visits = adminprovider.patientoutvisits["visits"] ?? [];


                          return visits.isEmpty
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.81,
                                  child: const Center(
                                    child: Text(
                                      "No Visits found for this patient\nPlease add a visit.",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.81,
                                  child: ListView.builder(
                                    itemCount: visits.length,
                                    itemBuilder: (context, index) {
                                      final visit = visits[index];
                                      final doctor =
                                          visit["associatedDoctor"] ?? {};

                                      return VisitModel(
                                        cheifcomplaint:
                                            visit["chief_complaint"] ?? "N/A",
                                        visitdate:
                                            formatDate(visit["visit_date"]),
                                        complaintId: visit["_id"] ?? "",
                                        patientId: widget.patientId,
                                        viewontap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return VisitViewModel(
                                                cheifcomplaint:
                                                    visit["chief_complaint"] ??
                                                        "",
                                                height: visit["height"] ?? "",
                                                weight: visit["weight"] ?? "",
                                                bp: visit["bp"] ?? "",
                                                temprature:
                                                    visit["temperature"] ?? "",
                                                heartrate:
                                                    visit["heart_rate"] ?? "",
                                                visitdate: formatDate(
                                                    visit["visit_date"]),
                                                associateddoctor:
                                                    '${doctor['name'] ?? ''}, ${doctor['userid'] ?? ''}',
                                              );
                                            },
                                          );
                                        },
                                        isDiagnosed: visit['isVisited'] ?? false,
                                      );
                                    },
                                  ),
                                );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
   Future<void> _handleRefresh() async {
    AdminPageProvider adminprovider =
        context.read<AdminPageProvider>();

    await Future.delayed(Duration(seconds: 2));
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    setState(() {
      fetchoutvisits = adminprovider.getpatientoutvisits(widget.patientId);
    });
  }
  }



class VisitModel extends StatelessWidget {
  const VisitModel({
    super.key,
    required this.cheifcomplaint,
    required this.visitdate,
    // required this.supportingimages,
    // required this.createdtime,
    // required this.supportingimaesontap,
    required this.viewontap,
    required this.complaintId,
    required this.patientId, required this.isDiagnosed,
  });

  final String cheifcomplaint;
  final String visitdate;
  // final List<dynamic> supportingimages;
  final String complaintId;
  final String patientId;
  final bool isDiagnosed;

  // final String createdtime;
  final VoidCallback viewontap;

  @override
  Widget build(BuildContext context) {
   
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Visit Date:",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        visitdate,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: viewontap,
                      icon: const Icon(
                        Icons.remove_red_eye,
                        color: Color(0Xff2556B9),
                      )),
                 
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                "Cheif-Complaint :",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                cheifcomplaint,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 4,
              ),
               Text(isDiagnosed? 'Visit Completed': 'Not Visited',
                 style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDiagnosed ? Colors.green.shade700 : Colors.red.shade700,
                 ),
                 )
            ],
          ),
        ),
      ),
    );
  }
}

class VisitViewModel extends StatelessWidget {
  const VisitViewModel({
    super.key,
    required this.cheifcomplaint,
    required this.height,
    required this.weight,
    required this.bp,
    required this.temprature,
    required this.heartrate,
    required this.visitdate, required this.associateddoctor,
  });

  final String cheifcomplaint;
  final String associateddoctor;
  final String height;
  final String weight;
  final String bp;
  final String temprature;
  final String heartrate;
  final String visitdate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Complaint Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      context.router.pop();
                    },
                    icon: const Icon(Icons.close))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Associated Doctor: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Text(
                    "$associateddoctor",
                    style: const TextStyle(fontSize: 14),
                    softWrap: true,
                  ),
                ),
                
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chief Complaint: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Flexible(
                  child: Text(
                    "$cheifcomplaint",
                    style: const TextStyle(fontSize: 14),
                    softWrap: true,
                  ),
                ),
               
              ],
            ),
            SizedBox(height: 8,),
            if (height != "") ...[
              Row(
                children: [
                  const Text(
                    "Height: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text("${height}", style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
            if (weight != "") ...[
              Row(
                children: [
                  const Text(
                    "Weight: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text("${weight}", style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
            if (temprature != "") ...[
              Row(
                children: [
                  const Text(
                    "Temperature: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text("${temprature}", style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
            if (bp != "") ...[
              Row(
                children: [
                  const Text(
                    "Blood Pressure: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text("${bp}", style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
            if (heartrate != "") ...[
              Row(
                children: [
                  const Text(
                    "Heart Rate: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text("${heartrate}", style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
            Row(
              children: [
                const Text(
                  "Visit Date: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("${visitdate}", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            // Row(
            //   children: [
            //     const Text(
            //       "Creation Time: ",
            //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            //     ),
            //     Text("${createdat}", style: TextStyle(fontSize: 14)),
            //   ],
            // ),
            // const SizedBox(
            //   height: 8,
            // ),
          ],
        ),
      ),
    );
  }
}

class RegisterVisitModel extends StatefulWidget {
  const RegisterVisitModel({
    super.key,
    required this.patientId, required this.alldoctors,
  });
  final String patientId;
  final List<Map<String, dynamic>> alldoctors;



  @override
  State<RegisterVisitModel> createState() => _RegisterVisitModelState();
}

class _RegisterVisitModelState extends State<RegisterVisitModel> {
  final TextEditingController cheifcomplaintController =
      TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController heartrateController = TextEditingController();
  final TextEditingController temperatureController = TextEditingController();

    Map<String, dynamic>? selectedConsultingDoctor;


  final formkey = GlobalKey<FormState>();

  DateTime today = DateTime.now();

  String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    AdminPageProvider adminprovider =
        context.read<AdminPageProvider>();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Enter Complaint Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          context.router.pop();
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Text(
                      "Visit Date: ",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(formattedDate, style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  " Cheif Complaint* ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 6,
                ),
                TextFormField(
                  controller: cheifcomplaintController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  // controller: _nameController,
                  // inputFormatters: [
                  //   LengthLimitingTextInputFormatter(20),
                  //   FilteringTextInputFormatter.allow(
                  //     RegExp(r'[a-zA-Z0-9 ]'),
                  //   )
                  // ],
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter cheif complaint';
                    }
                    return null; // Return null if validation is successful
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Cheif Complaint',
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  "Vitals",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Height",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          TextFormField(
                            controller: heightController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter Height',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Weight",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          TextFormField(
                            controller: weightController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter Weight',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BP",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          TextFormField(
                            controller: bpController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter Blood Pressure',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Temperature",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          TextFormField(
                            controller: temperatureController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter Temperature',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Heart Rate",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          TextFormField(
                            controller: heartrateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter Heart Rate',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            "",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
               SizedBox(height: 8,), 
                const Text("Consulting Doctor*",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownSearch<Map<String, dynamic>>(
                  items: widget.alldoctors,
                  itemAsString: (doc) => "${doc['name']} | ${doc['userid']}",
                  selectedItem: selectedConsultingDoctor,
                  popupProps: const PopupProps.menu(showSearchBox: true),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: "Select Consulting Doctor",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0857C0)),
                      ),
                    ),
                  ),
                           validator: (value) {
                    if (value == null) {
                      return "Please select a Consulting Doctor";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedConsultingDoctor = value;
                    });
                    debugPrint("Consulting Doctor ID: ${value?['userid']}");
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:adminprovider.addingoutvisit? null: () async {
                      if (formkey.currentState!.validate()) {
                         setState(() {
                                  adminprovider.addingoutvisit = true;
                                });
                        adminprovider.addoutvisit(
                          widget.patientId,
                          cheifcomplaintController.text,
                          heartrateController.text,
                          weightController.text,
                          bpController.text,
                          temperatureController.text,
                          heartrateController.text,
                          selectedConsultingDoctor?['_id'],
                          context,
                        );

                        await adminprovider.getpatientoutvisits(widget.patientId);
                      }

                      // context.router.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:adminprovider.addingoutvisit? Colors.grey.shade300: Color(0xFF0857C0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: Text("Submit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
