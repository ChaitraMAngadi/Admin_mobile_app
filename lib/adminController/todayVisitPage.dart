import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:admin_mobile_application/theme/app_colors.dart';
import 'package:auto_route/auto_route.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TodaysOutvisitsPage extends StatefulWidget {
  const TodaysOutvisitsPage({super.key});

  @override
  State<TodaysOutvisitsPage> createState() => _TodaysOutvisitsPageState();
}

class _TodaysOutvisitsPageState extends State<TodaysOutvisitsPage> {
  late Future fetchtodaysoutvisits;
  final SecureStorage secureStorage = SecureStorage();

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AdminPageProvider adminPageProvider = context.read<AdminPageProvider>();
    fetchtodaysoutvisits = adminPageProvider.gettodaysoutvisits(context).then((_) {
      setState(() {
        adminPageProvider.filteredvisits = adminPageProvider.gettodaysvisits;
      });
    });

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          // Reset to full list when search is cleared
          adminPageProvider.filteredvisits = adminPageProvider.gettodaysvisits;
        } else {
          adminPageProvider.filteredvisits =
              adminPageProvider.gettodaysvisits.where((visit) {
            final name = visit['name']?.toLowerCase() ?? '';
            final chiefcomplaint =
                visit['chief_complaint']?.toLowerCase() ?? '';
            final id = visit['patientId']?.toLowerCase() ?? '';
            return name.contains(query) ||
                id.contains(query) ||
                chiefcomplaint.contains(query);
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
        body: RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Consumer<AdminPageProvider>(
        builder: (context, adminPageProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
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
                  RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: FutureBuilder(
                      future: fetchtodaysoutvisits,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.76,
                              child: _buildShimmerList());
                        } else {
                          return SafeArea(
                            child: adminPageProvider.filteredvisits.isEmpty
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.76,
                                    child: _searchController.text.isNotEmpty
                                        ? _buildNoSearchResults() // <-- show no results UI if searching
                                        : const Center(
                                            child: Text(
                                              "No Todays Visits to show",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                  )
                                : SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.73,
                                    child: ListView.builder(
                                      itemCount: adminPageProvider
                                          .filteredvisits.length,
                                      itemBuilder: (context, index) {
                                        final item = adminPageProvider
                                            .filteredvisits[index];
                                        return TodaysVisitModel(
                                          visitdate: formatDate(item["visit_date"]),
                                          patientname: item['name'],
                                          patientId: item['patientId'],
                                          viewonTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                final isCreatedByAdmin =
                                                    item["createdByAdmin"] !=
                                                        null;
                                                final isCreatedByDoctor =
                                                    item["createdByDoctor"] !=
                                                        null;

                                                if (isCreatedByDoctor) {
                                                  // Created by doctor
                                                  return VisitViewModel(
                                                    name: item['name'],
                                                    id: item['patientId'],
                                                    age: item['DOB'],
                                                    gender: item['gender'],
                                                    phone: item['phone'].toString(),
                                                    email: item['email']??"",
                                                    dob: formatDate(item['DOB']),
                                                    createdby: '',
                                                    associateddoctor:' ${item[
                                                                'complaint']
                                                            ['associatedDoctor']
                                                        ['name']} - ${item[
                                                                'complaint']
                                                            ['associatedDoctor']
                                                        ['userid']}',
                                                    complaint: item['complaint']
                                                        ['chief_complaint'],
                                                    createdbyadmin: '',
                                                    createddoctor: '',
                                                  );
                                                } else if (isCreatedByAdmin) {
                                                  // Created by admin
                                                  return VisitViewModel(
                                                    name: item['name'],
                                                    id: item['patientId'],
                                                    age: item['DOB'],
                                                    gender: item['gender'],
                                                    phone: item['phone'].toString(),
                                                    email: item['email'],
                                                    dob: formatDate(item['DOB']),
                                                    createdby:
                                                        '${item['createdByAdmin']
                                                            ['name']} - ${item['createdByAdmin']
                                                            ['userid']}',
                                                    associateddoctor: ' ${item[
                                                                'complaint']
                                                            ['associatedDoctor']
                                                        ['name']} - ${item[
                                                                'complaint']
                                                            ['associatedDoctor']
                                                        ['userid']}',
                                                    complaint: item['complaint']
                                                        ['chief_complaint'],
                                                    createdbyadmin:
                                                        '${item['createdByAdmin']
                                                            ['name']} - ${item['createdByAdmin']
                                                            ['userid']}',
                                                    createddoctor: '',
                                                  );
                                                } else {
                                                  // Fallback (if neither found)
                                                  return VisitViewModel(
                                                    name: item['name'],
                                                    id: item['patientId'],
                                                    age: item['DOB'],
                                                    gender: item['gender'],
                                                    phone: item['phone'].toString(),
                                                    email: item['email'],
                                                    dob: item['DOB'],
                                                    createdby: '',
                                                    associateddoctor: item[
                                                                'complaint']
                                                            ['associatedDoctor']
                                                        ['name'],
                                                    complaint: item['complaint']
                                                        ['chief_complaint'],
                                                    createdbyadmin: '',
                                                    createddoctor: '',
                                                  );
                                                }
                                              },
                                            );

                                            // showDialog(
                                            //                             context: context,
                                            //                             builder: (context) {
                                            //                               return VisitViewModel(name: item['name'], id: item['patientId'],
                                            //                                age: item['age'], gender: item['gender'],
                                            //                                 phone: item['phone'], email: item['email'], dob: item['DOB'],
                                            //                                 createdby: createdby, associateddoctor: associateddoctor, complaint: complaint, createdbyadmin: createdbyadmin, createddoctor: '',)
                                            //                             },
                                            //                           );
                                          },
                                          chiefcomplaint: item['complaint']
                                                  ['chief_complaint'] ??
                                              '',
                                          isreport: item['complaint']
                                                  ['isReport'] ??
                                              '',
                                          complaintId: item['_id'],
                                        );
                                      },
                                    ),
                                  ),
                          );

                          // return SafeArea(
                          //     child: doctorprovider.gettodaysvisits.isEmpty
                          //         ? SizedBox(
                          //             height:
                          //                 MediaQuery.of(context).size.height *
                          //                     0.65,
                          //             child: const Center(
                          //                 child: Text(
                          //               "No Out Visits to show",
                          //               style: TextStyle(
                          //                   fontWeight: FontWeight.bold),
                          //             )))
                          //         : SizedBox(
                          //             height:
                          //                 MediaQuery.of(context).size.height *
                          //                     0.65,
                          //             child: ListView.builder(
                          //               itemCount: doctorprovider
                          //                   .gettodaysvisits.length,
                          //               // Patientpageprovider.allpatients.length,
                          //               itemBuilder: (context, index) {
                          //                 //                                         final sortedPatients = Patientpageprovider.filteredPatients
                          //                 // ..sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

                          //                 // final item = doctorprovider.gettodaysvisits[index];

                          //                 final item = doctorprovider
                          //                     .gettodaysvisits[index];
                          //                 // Patientpageprovider
                          //                 //     .allpatients[index];

                          //                 return TodaysVisitModel(
                          //                   patientname: item['name'],
                          //                   patientId: item['patientId'],
                          //                   viewonTap: () {},
                          //                   startdiagnosisonTap: () {},
                          //                   supportingimagesonTap: () {},
                          //                   chiefcomplaint:
                          //                       item['chief_complaint']??'',
                          //                   diagnosissummary:
                          //                       item['diagnosis_summary'] ?? '',
                          //                   complaintId: item['id'],
                          //                 );
                          //               },
                          //             ),
                          //           ));
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
adminPageProvider.invalidateCache(key: adminPageProvider.Outvisits);
    await Future.delayed(Duration(seconds: 2));
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    setState(() {
      fetchtodaysoutvisits = adminPageProvider.gettodaysoutvisits(context);
      adminPageProvider.filteredvisits = adminPageProvider.gettodaysvisits;
    });
  }
}

// class TodaysVisitModel extends StatelessWidget {
//   const TodaysVisitModel({
//     super.key,
//     required this.patientname,
//     required this.patientId,
//     required this.viewonTap,
//     required this.chiefcomplaint,
//     required this.complaintId,
//     required this.isreport,
//   });
//   final String patientname;
//   final VoidCallback viewonTap;
//   final String patientId;
//   final String complaintId;
//   final String chiefcomplaint;
//   final bool isreport;

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
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       'PatientId: ',
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.bold,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     Text(
//                       patientId,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//                 GestureDetector(
//                   onTap: viewonTap,
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF0857C0),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Text(
//                       'View',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 const Text(
//                   'Name: ',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     patientname,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               children: [
//                 Text(
//                   'chiefcomplaint: ',
//                   style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                 ),
//                 Expanded(
//                   child: Text(
//                     chiefcomplaint,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//             Text(
//               isreport ? 'Visit Completed' : 'Not Visited',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: isreport ? Colors.green.shade700 : Colors.red.shade700,
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

class TodaysVisitModel extends StatelessWidget {
  const TodaysVisitModel({
    super.key,
    required this.patientname,
    required this.patientId,
    required this.viewonTap,
    required this.chiefcomplaint,
    required this.complaintId,
    required this.isreport, required this.visitdate,
  });

  final String patientname;
  final VoidCallback viewonTap;
  final String patientId;
  final String complaintId;
  final String chiefcomplaint;
  final String visitdate;
  final bool isreport;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
     
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12),bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
Container(
  height: 4,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    gradient: AppColors.primaryGradient,
  ),
),
          /// Patient ID + View button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'PATIENT ID\n',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: patientId,
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            
                InkWell(
                  onTap: viewonTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.badgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.visibility,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(
                color: Colors.grey
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("PATIENT NAME", patientname),
                Divider(),
                _infoRow("CHIEF COMPLAINT", chiefcomplaint),
                Divider(),
                  _infoRow("VISIT DATE", visitdate),
                  Divider(),
                    Text(
            "STATUS",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6,),
                Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isreport
                  ? Colors.green.withOpacity(0.12)
                  : Colors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isreport ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isreport ? Colors.green : AppColors.primaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  isreport ? "VISIT COMPLETED" : "NOT VISITED",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isreport ? Colors.green : AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          )
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Status chip
          
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


// class VisitViewModel extends StatelessWidget {
//   const VisitViewModel({
//     super.key,
//     required this.name,
//     required this.id,
//     required this.age,
//     required this.gender,
//     required this.phone,
//     required this.email,
//     required this.dob,
//     required this.createdby,
//     required this.associateddoctor,
//     required this.complaint,
//     required this.createdbyadmin,
//     required this.createddoctor,
//   });

//   final String name;
//   final String id;
//   final String age;
//   final String gender;
//   final String phone;
//   final String email;
//   final String dob;
//   final String createdby;
//   final String createddoctor;
//   final String associateddoctor;
//   final String complaint;
//   final String createdbyadmin;

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Visit Details",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                     onPressed: () {
//                       context.router.pop();
//                     },
//                     icon: const Icon(Icons.close))
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             const Text(
//               "Patient Details",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Name: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Flexible(
//                   child: Text(
//                     name,
//                     style: const TextStyle(fontSize: 14),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "PatientId: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Flexible(
//                   child: Text(
//                     id,
//                     style: const TextStyle(fontSize: 14),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Age: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Flexible(
//                   child: Text(
//                     age,
//                     style: const TextStyle(fontSize: 14),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Gender: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Flexible(
//                   child: Text(
//                     gender,
//                     style: const TextStyle(fontSize: 14),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Phone: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Flexible(
//                   child: Text(
//                     phone,
//                     style: const TextStyle(fontSize: 14),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Date of birth: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Flexible(
//                   child: Text(
//                     dob,
//                     style: const TextStyle(fontSize: 14),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Email: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Flexible(
//                   child: Text(
//                     email,
//                     style: const TextStyle(fontSize: 14),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             if (createdbyadmin != '')
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Created By Admin: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Flexible(
//                     child: Text(
//                       createdby,
//                       style: const TextStyle(fontSize: 14),
//                       softWrap: true,
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(
//               height: 6,
//             ),
//             if (createdbyadmin == '')
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Created By Doctor: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Flexible(
//                     child: Text(
//                       createddoctor,
//                       style: const TextStyle(fontSize: 14),
//                       softWrap: true,
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(
//               height: 10,
//             ),
//             const Text(
//               "Patient Details",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Associated Doctor: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Flexible(
//                   child: Text(
//                     associateddoctor,
//                     style: const TextStyle(fontSize: 14),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Chief Complaint: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Flexible(
//                   child: Text(
//                     complaint,
//                     style: const TextStyle(fontSize: 14),
//                     softWrap: true,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

String calculateAge(String dob) {
  final birthDate = DateTime.parse(dob);
  final today = DateTime.now();
  int years = today.year - birthDate.year;
  int months = today.month - birthDate.month;
  int days = today.day - birthDate.day;

  if (days < 0) {
    months--;
    // Days in the month before 'today's month
    final prevMonth = DateTime(today.year, today.month, 0);
    days += prevMonth.day;
  }
  if (months < 0) {
    years--;
    months += 12;
  }

  if (years >= 5) {
    return '$years ${years == 1 ? 'year' : 'years'}';
  }

  if (years == 0 && months == 0) {
    return '0 month $days ${days == 1 ? 'day' : 'days'}';
  }

  return '$years ${years == 1 ? 'year' : 'years'} $months ${months == 1 ? 'month' : 'months'}';
}

class VisitViewModel extends StatelessWidget {
  const VisitViewModel({
    super.key,
    required this.name,
    required this.id,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.dob,
    required this.createdby,
    required this.associateddoctor,
    required this.complaint,
    required this.createdbyadmin,
    required this.createddoctor,
  });

  final String name;
  final String id;
  final String age;
  final String gender;
  final String phone;
  final String email;
  final String dob;
  final String createdby;
  final String createddoctor;
  final String associateddoctor;
  final String complaint;
  final String createdbyadmin;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ---------- Header ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.monitor_heart_outlined,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Visit Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.primaryDark),
                    onPressed: () => context.router.pop(),
                  )
                ],
              ),

              const SizedBox(height: 16),

              /// ---------- Patient Details ----------
              _sectionTitle("Patient Details"),

              _infoTile(
                icon: Icons.person_outline,
                label: "NAME",
                value: name,
              ),
              _infoTile(
                icon: Icons.tag,
                label: "PATIENT ID",
                value: id,
              ),
              _infoTile(
                icon: Icons.cake_outlined,
                label: "AGE",
                value: calculateAge(age),
              ),
              _infoTile(
                icon: Icons.person_2_outlined,
                label: "GENDER",
                value: gender,
              ),
              _infoTile(
                icon: Icons.call_outlined,
                label: "PHONE NUMBER",
                value: phone,
              ),
              _infoTile(
                icon: Icons.calendar_month_outlined,
                label: "DATE OF BIRTH",
                value: dob,
              ),
              _infoTile(
                icon: Icons.email_outlined,
                label: "EMAIL",
                value: email,
              ),

              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 16),

              /// ---------- Complaint Details ----------
              _sectionTitle("Complaint Details"),

              _infoTile(
                icon: Icons.medical_services_outlined,
                label: "ASSOCIATED DOCTOR",
                value: associateddoctor,
              ),
              _infoTile(
                icon: Icons.monitor_heart,
                label: "CHIEF COMPLAINT",
                value: complaint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- Section title ----------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  /// ---------- Info Card ----------
  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.badgeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
