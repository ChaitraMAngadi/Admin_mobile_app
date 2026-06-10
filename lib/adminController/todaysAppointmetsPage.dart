
import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:admin_mobile_application/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TodaysAppointmentsPage extends StatefulWidget {
  const TodaysAppointmentsPage({super.key});

  @override
  State<TodaysAppointmentsPage> createState() => _TodaysAppointmentsPageState();
}

class _TodaysAppointmentsPageState extends State<TodaysAppointmentsPage> {
  late Future fetchtodaysappointments;
  final SecureStorage secureStorage = SecureStorage();

  TextEditingController _searchController = TextEditingController();

  String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());


  @override
  void initState() {
    super.initState();
    AdminPageProvider adminPageProvider = context.read<AdminPageProvider>();
    fetchtodaysappointments =
        adminPageProvider.gettodaysappointments(context).then((_) {
      setState(() {
        adminPageProvider.filteredtodaysappointments =
            adminPageProvider.todaysappointments;
      });
    });

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          // Reset to full list when search is cleared
          adminPageProvider.filteredtodaysappointments =
              adminPageProvider.todaysappointments;
        } else {
          adminPageProvider.filteredtodaysappointments =
              adminPageProvider.todaysappointments.where((visit) {
            final name = visit['patientname']?.toLowerCase() ?? '';
            final mobile =
                visit['patientMobile'].toString().toLowerCase() ?? '';
            
            return name.contains(query) ||
                mobile.contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    return formattedDate;
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No search results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0857C0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear Search',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Keep your existing shimmer methods
  Widget _buildShimmerItem() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
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
          SizedBox(height: 12),
          _buildShimmerBox(width: double.infinity, height: 18),
          SizedBox(height: 8),
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
      {required double width,
      required double height,
      double borderRadius = 8}) {
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
      backgroundColor: AppColors.softPinkish,
      // appBar: AppBar(

      //   title: Text('Todays Appointments',
      //   style: TextStyle(
      //     fontSize: 20,
      //     fontWeight: FontWeight.bold,
      //   ),),
      //   centerTitle: true,
      // ),

      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: AppColors.primaryGradient,
    ),
  ),
  elevation: 0,
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Today's Appointments",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        formattedDate,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    ],
  ),
),

        body: RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Consumer<AdminPageProvider>(
        builder: (context, adminPageProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                
                  RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: FutureBuilder(
                      future: fetchtodaysappointments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.76,
                              child: _buildShimmerList());
                        } else {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                                child: Column(
                                  children: [
                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(""),
                                                          Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14,),
                                                            decoration: BoxDecoration(
                                                              // color: Colors.purple.shade100,
                                                              gradient: AppColors.primaryGradient,
                                                              borderRadius: BorderRadius.all(Radius.circular(16),)
                                                            ),
                                                            child: Text("${adminPageProvider.filteredtodaysappointments.length} APPOINTMENTS",
                                                            style: TextStyle(fontWeight: FontWeight.bold,
                                                            fontSize: 13,
                                                            color: Colors.white,),),
                                                          )
                                                        ],
                                                      ),
                                  ],
                                ),
                              ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Patient by id or name...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                              SafeArea(
                                child: adminPageProvider
                                        .filteredtodaysappointments.isEmpty
                                    ? SizedBox(
                                        height: MediaQuery.of(context).size.height *
                                            0.76,
                                        child: _searchController.text.isNotEmpty
                                            ? _buildNoSearchResults() // <-- show no results UI if searching
                                            : const Center(
                                                child: Text(
                                                  "No Appoiments to show",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                      )
                                    : SizedBox(
                                        height: MediaQuery.of(context).size.height *
                                            0.76,
                                        child: ListView.builder(
                                          itemCount: adminPageProvider
                                              .filteredtodaysappointments.length,
                                          itemBuilder: (context, index) {
                                            final item = adminPageProvider
                                                .filteredtodaysappointments[index];
                                            return TodaysAppointmentModel(status: item['status']??'',
                                              patientname: item['patientname']??'',
                                              patientmobile: item['patientMobile'].toString()??'',
                                              starttime: item['startTime']??'',
                                              endtime: item['endTime']??'',
                                              doctorname: item['doctor']['name']??'',
                                            );
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ));
  }

  Future<void> _handleRefresh() async {
    AdminPageProvider adminPageProvider = context.read<AdminPageProvider>();

    await Future.delayed(Duration(seconds: 2));
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    setState(() {
      fetchtodaysappointments = adminPageProvider.gettodaysappointments(context);
      adminPageProvider.filteredtodaysappointments =
          adminPageProvider.todaysappointments;
    });
  }
}

// class TodaysAppointmentModel extends StatelessWidget {
//   const TodaysAppointmentModel({
//     super.key,
//     required this.patientname,
//     required this.patientmobile,
//     required this.starttime,
//     required this.endtime,
//     required this.doctorname,
//   });
//   final String patientname;
//   final String patientmobile;
//   final String starttime;
//   final String endtime;
//   final String doctorname;
//   // final bool isreport;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(
//         bottom: 16,
//         left: 16,
//         right: 16,
//       ),
//       child: ListTile(
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8))),
//         tileColor: Colors.grey.shade100,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Text(
//                   'Name: ',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 Text(
//                   patientname,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 const Text(
//                   'Mobile: ',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   patientmobile,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               children: [
//                 const Text(
//                   'Doctor: ',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   doctorname,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//             Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(16)),
//                   color: Colors.blue.shade100),
//               child: Text(
//                 '$starttime - $endtime',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue.shade800,
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class TodaysAppointmentModel extends StatelessWidget {
//   const TodaysAppointmentModel({
//     super.key,
//     required this.patientname,
//     required this.patientmobile,
//     required this.starttime,
//     required this.endtime,
//     required this.doctorname,
//   });

//   final String patientname;
//   final String patientmobile;
//   final String starttime;
//   final String endtime;
//   final String doctorname;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.circular(22)),
         
//         ),
//         child: Column(
//           children: [
//             Container(
//               height: 4,
//               decoration:BoxDecoration(
//                 gradient: AppColors.primaryGradient,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(22))
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xffF7FAFC),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
                    
//                       Row(
//                         children: [
//                           Icon(Icons.person_outline, size: 18, color: Colors.grey),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     "PATIENT NAME",
//                                     style: const TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                         ],
//                       ),
//         const SizedBox(height: 8),
//         Text(
//           patientname,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
//                     const Divider(),

//                     Row(
//                       children: [
//                         Icon(Icons.phone_outlined, size: 18, color: Colors.grey),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "MOBILE",
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                       ],
//                     ),
//         const SizedBox(height: 8),
//         Text(
//           patientmobile,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
            
                    
//                     const Divider(),
            
//                     Row(
//                       children: [
//                         const Icon(Icons.access_time,
//                             size: 18, color: Colors.grey),
//                         const SizedBox(width: 8),
//                         const Text(
//                           "TIME SLOT",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey,
//                           ),
//                         ),
                       
                        
//                       ],
//                     ),
//                      const SizedBox(height: 12),
//                     Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             gradient: AppColors.primaryGradient,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             "$starttime - $endtime",
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
            
//                     const Divider(),
//                     const SizedBox(height: 4),
            
//                     const Text(
//                       "DOCTOR",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       doctorname,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _rowItem({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, size: 18, color: Colors.grey),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//             color: Colors.grey,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//           ),
//           overflow: TextOverflow.ellipsis,
//         ),
//       ],
//     );
//   }
// }

class TodaysAppointmentModel extends StatelessWidget {
  const TodaysAppointmentModel({
    super.key,
    required this.patientname,
    required this.patientmobile,
    required this.starttime,
    required this.endtime,
    required this.doctorname,
    required this.status,  // ADD THIS
  });

  final String patientname;
  final String patientmobile;
  final String starttime;
  final String endtime;
  final String doctorname;
  final String status;  // ADD THIS

  @override
  Widget build(BuildContext context) {
    final isBooked = status.toLowerCase() == 'booked';
    final statusColor = isBooked ? Colors.green : Colors.red;
    final statusBg = isBooked ? Colors.green.shade50 : Colors.red.shade50;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top gradient bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: isBooked ? Colors.green : Colors.red,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Status badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isBooked ? Icons.check_circle : Icons.cancel,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Patient Name
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text(
                        'Patient',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patientname,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Divider(height: 20),

                  // Mobile
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text(
                        'Mobile',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patientmobile,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Divider(height: 20),

                  // Time Slot
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text(
                        'Time Slot',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _timeChip(starttime, Icons.login),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward,
                            size: 16, color: Colors.grey),
                      ),
                      _timeChip(endtime, Icons.logout),
                    ],
                  ),

                  const Divider(height: 20),

                  // Doctor
                  Row(
                    children: [
                      const Icon(Icons.medical_services_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text(
                        'Doctor',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctorname,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0857C0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeChip(String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        // color: const Color(0xFF0857C0).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: const Color(0xFF0857C0).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(icon, size: 14, color: const Color(0xFF0857C0)),
          // const SizedBox(width: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}