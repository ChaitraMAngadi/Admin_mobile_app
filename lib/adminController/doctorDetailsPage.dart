import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/routes/app_router.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:admin_mobile_application/theme/app_colors.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({super.key});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  late Future fetchalldoctorsdetails;
  final SecureStorage secureStorage = SecureStorage();

  initState() {
    super.initState();
    AdminPageProvider adminpageprovider = context.read<AdminPageProvider>();

    fetchalldoctorsdetails = adminpageprovider.getalldoctorsdetails(context);
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Consumer<AdminPageProvider>(
          builder: (context, adminpageprovider, child) {
            return SafeArea(
              child: FutureBuilder(
                future: fetchalldoctorsdetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerLoading();
                  } else {
                    return SafeArea(
                        child: adminpageprovider.alldoctorsdetails.isEmpty
                            ? SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: const Center(
                                    child: Text("No Doctors Details to show")))
                            : SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: ListView.builder(
                                  itemCount: adminpageprovider
                                      .alldoctorsdetails.length,
                                  itemBuilder: (context, index) {
                                    final item = adminpageprovider
                                        .alldoctorsdetails[index];

                                    return AdminModel(
                                      name: item['name'],
                                      adminId: item['userid'],
                                      createdAt: formatDate(item['createdAt']),
                                      phone: item['phone'],
                                      onView: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return ViewAdminModel(
                                              name: item['name'],
                                              adminId: item['userid'],
                                              email: item['email'] ?? "",
                                              phonenumber: item['phone'] ?? 0,
                                              createdat:
                                                  formatDate(item['createdAt']),
                                              gender: item['gender'],
                                              doctorgegnum: item[
                                                      'doctorRegistrationNumber'] ??
                                                  '',
                                              qualification:
                                                  item['qualification'] ?? '',
                                              specialization:
                                                  item['specialization'] ?? '',
                                              secondaryphone:
                                                  item['phone2'].toString() ??
                                                      '',
                                              boardofregistration: item[
                                                      'board_of_registration'] ??
                                                  "",
                                              yearofregistration:
                                                  item['year_of_registration']
                                                          .toString() ??
                                                      '',
                                              
                                            );
                                          },
                                        );
                                      },
                                      scheduleonTap: () {
                                        context.router.push(SlotRoute(patientId:item['userid'],
                                        doctorname: item['name'],));
                                      },
                                    );
                                  },
                                ),
                              ));
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.74,
      child: ListView.builder(
        itemCount: 4, // Show 8 shimmer items
        itemBuilder: (context, index) {
          return _buildShimmerItem();
        },
      ),
    );
  }

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
          // Date and hospital row
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShimmerBox(width: 200, height: 32, borderRadius: 16),
              SizedBox(
                width: 24,
              ),
              _buildShimmerBox(width: 60, height: 32, borderRadius: 16),
            ],
          ),
          SizedBox(height: 12),

          // Patient name
          _buildShimmerBox(width: 200, height: 24),
          SizedBox(height: 8),

          // Chief complaint
          _buildShimmerBox(width: 200, height: 24),
          SizedBox(height: 4),
          _buildShimmerBox(width: 200, height: 24),

          SizedBox(height: 16),

          // Action buttons row
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

  Future<void> _handleRefresh() async {
    AdminPageProvider adminpageprovider = context.read<AdminPageProvider>();

    await Future.delayed(Duration(seconds: 2));
    adminpageprovider.invalidateCache(key: adminpageprovider.kProfile);
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    setState(() {
      fetchalldoctorsdetails = adminpageprovider.getalldoctorsdetails(context);
    });
  }
}

// class _AdminsPageState extends State<AdminsPage> {
//   late Future fetchalladmins;
//   final SecureStorage secureStorage = SecureStorage();

//   initState() {
//     super.initState();
//     AdminPageProvider adminpageprovider = context.read<AdminPageProvider>();

//     fetchalladmins = adminpageprovider.getalladmins();
//   }

//   String formatDate(String date) {
//     final parsedDate = DateTime.parse(date);
//     final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
//     return formattedDate;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: Consumer<AdminPageProvider>(
//           builder: (context, adminpageprovider, child) {
//             return SafeArea(
//               child: FutureBuilder(
//                 future: fetchalladmins,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.74,
//                         child: Center(child: CircularProgressIndicator()));
//                   } else {
//                     return SafeArea(
//                         child: adminpageprovider.admindetails.isEmpty
//                             ? SizedBox(
//                                 height: MediaQuery.of(context).size.height,
//                                 child: Center(child: Text("No Admins to show")))
//                             : SizedBox(
//                                 height: MediaQuery.of(context).size.height,
//                                 child: ListView.builder(
//                                   itemCount:
//                                       adminpageprovider.admindetails.length,
//                                   itemBuilder: (context, index) {
//                                     final item =
//                                         adminpageprovider.admindetails[index];

//                                     return AdminModel(
//                                       name: item['name'],
//                                       adminId: item['userid'],
//                                       createdAt: formatDate(item['createdAt']),
//                                       phone: item['phone'],
//                                       onView: () {
//                                         showDialog(
//                                           context: context,
//                                           builder: (context) {
//                                             return ViewAdminModel(
//                                               name: item['name'],
//                                               adminId: item['userid'],
//                                               email: item['email'] ?? "",
//                                               phonenumber: item['phone'] ?? 0,
//                                               createdat:
//                                                   formatDate(item['createdAt']),
//                                             );
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                               ));
//                   }
//                 },
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> _handleRefresh() async {
//     AdminPageProvider adminpageprovider = context.read<AdminPageProvider>();

//     await Future.delayed(Duration(seconds: 2));
//     Constants.token = await secureStorage.readSecureData('token') ?? '';
//     setState(() {
//       fetchalladmins = adminpageprovider.getalladmins();
//     });
//   }
// }

// class AdminModel extends StatefulWidget {
//   const AdminModel({
//     super.key,
//     required this.name,
//     required this.adminId,
//     required this.createdAt,
//     required this.phone,
//     required this.onView, required this.scheduleonTap,
    
//   });

//   final String name;
//   final String adminId;
//   final String createdAt;
//   final int phone;
//   final VoidCallback onView;
//     final VoidCallback scheduleonTap;


//   @override
//   State<AdminModel> createState() => _AdminModelState();
// }

// class _AdminModelState extends State<AdminModel> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, right: 16),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       const Text(
//                         "Name: ",
//                         style: TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.bold),
//                       ),
//                       Text("${widget.name}", style: TextStyle(fontSize: 14)),
//                     ],
//                   ),
//                   IconButton(
//                       onPressed: widget.onView,
//                       icon: Icon(
//                         Icons.remove_red_eye,
//                         color: Color(0xFF0857C0),
//                       ))
//                 ],
//               ),
//               // Text("PatientName: ${widget.patientName}"),
//               Row(
//                 children: [
//                   const Text(
//                     "Doctor ID: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text("${widget.adminId}", style: TextStyle(fontSize: 14)),
//                 ],
//               ),
//               SizedBox(height: 8),
//               // Text("CreatedAt: ${widget.createdAt}"),
//               Row(
//                 children: [
//                   const Text(
//                     "Phone: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text("${widget.phone.toString()}",
//                       style: TextStyle(fontSize: 14)),
//                 ],
//               ),
//               SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Text(
//                     "Created At: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text("${widget.createdAt}", style: TextStyle(fontSize: 14)),
//                 ],
//               ),
//               SizedBox(height: 12),

//               SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: const ButtonStyle(
//                   padding: WidgetStatePropertyAll(
//                       EdgeInsets.symmetric(vertical: 14)),
//                   backgroundColor: WidgetStatePropertyAll(Color(0XFF0857C0)),
//                   shape: WidgetStatePropertyAll(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(14)),
//                     ),
//                   ),
//                 ),
//                 onPressed: widget.scheduleonTap,
//                 child: const Text(
//                   'Schedule Appointment',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             SizedBox(height: 12,)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class AdminModel extends StatelessWidget {
  const AdminModel({
    super.key,
    required this.name,
    required this.adminId,
    required this.createdAt,
    required this.phone,
    required this.onView,
    required this.scheduleonTap,
  });

  final String name;
  final String adminId;
  final String createdAt;
  final int phone;
  final VoidCallback onView;
  final VoidCallback scheduleonTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10),bottom: Radius.circular(22)),
          border: Border.all(color: Colors.red.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(height: 4,

            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22))),),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔴 Doctor ID + Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "DOCTOR ID",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            adminId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _iconButton(
                            icon: Icons.remove_red_eye,
                            color: AppColors.primary,
                            onTap: onView,
                          ),
                          const SizedBox(width: 8),
                          _iconButton(
                            icon: Icons.calendar_month,
                            color: Colors.green,
                            onTap: scheduleonTap,
                          ),
                        ],
                      )
                    ],
                  ),
            
                  const SizedBox(height: 14),
            
                  /// 🩺 Doctor Name Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xffF7FAFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.stethoscope,
                          color: Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "DOCTOR NAME",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
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
          ],
        ),
      ),
    );
  }

  /// 🔘 Action Icon Button
  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}


// class ViewAdminModel extends StatelessWidget {
//   const ViewAdminModel({
//     super.key,
//     required this.name,
//     required this.adminId,
//     required this.email,
//     required this.phonenumber,
//     required this.createdat,
//     required this.gender,
//     required this.doctorgegnum,
//     required this.qualification,
//     required this.specialization,
//     required this.secondaryphone,
//     required this.boardofregistration,
//     required this.yearofregistration,
//   });

//   final String name;
//   final String adminId;
//   final String email;
//   final int phonenumber;
//   final String createdat;
//   final String gender;
//   final String doctorgegnum;
//   final String qualification;
//   final String specialization;
//   final String secondaryphone;
//   final String boardofregistration;
//   final String yearofregistration;

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: EdgeInsets.symmetric(horizontal: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Doctor Details",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                     onPressed: () {
//                       context.router.pop();
//                     },
//                     icon: Icon(Icons.close))
//               ],
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               children: [
//                 const Text(
//                   "Name: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Text("${name}", style: TextStyle(fontSize: 14)),
//               ],
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//             Row(
//               children: [
//                 const Text(
//                   "Email: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Text("${email}", style: TextStyle(fontSize: 14)),
//               ],
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//             Row(
//               children: [
//                 const Text(
//                   "Phone Number: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Text("${phonenumber}", style: TextStyle(fontSize: 14)),
//               ],
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//             Row(
//               children: [
//                 const Text(
//                   "DoctorId: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Text("${adminId}", style: TextStyle(fontSize: 14)),
//               ],
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//             Row(
//               children: [
//                 const Text(
//                   "Creation Date: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Text("$createdat", style: TextStyle(fontSize: 14)),
//               ],
//             ),
//             const SizedBox(
//               height: 8,
//             ),
//             Row(
//               children: [
//                 const Text(
//                   "Gender: ",
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 Text("${gender}", style: TextStyle(fontSize: 14)),
//               ],
//             ),
//             if (doctorgegnum.isNotEmpty)
//               const SizedBox(
//                 height: 8,
//               ),
//             if (doctorgegnum.isNotEmpty)
//               Row(
//                 children: [
//                   const Text(
//                     "Doctor Registration Number: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text("${doctorgegnum}", style: TextStyle(fontSize: 14)),
//                 ],
//               ),
//             if (qualification.isNotEmpty)
//               const SizedBox(
//                 height: 8,
//               ),
//             if (qualification.isNotEmpty)
//               Row(
//                 children: [
//                   const Text(
//                     "Qualification: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text("${qualification}", style: TextStyle(fontSize: 14)),
//                 ],
//               ),
//             if (specialization.isNotEmpty)
//               const SizedBox(
//                 height: 8,
//               ),
//             if (specialization.isNotEmpty)
//               Row(
//                 children: [
//                   const Text(
//                     "Specialization: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text("${specialization}", style: TextStyle(fontSize: 14)),
//                 ],
//               ),
//             if (boardofregistration.isNotEmpty)
//               const SizedBox(
//                 height: 8,
//               ),
//             if (boardofregistration.isNotEmpty)
//               Row(
//                 children: [
//                   const Text(
//                     "Board of registration: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text("${boardofregistration}",
//                       style: TextStyle(fontSize: 14)),
//                 ],
//               ),
//             if (yearofregistration.isNotEmpty)
//               const SizedBox(
//                 height: 8,
//               ),
//             if (yearofregistration != 'null')
//               Row(
//                 children: [
//                   const Text(
//                     "Year of registration: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text("${yearofregistration}", style: TextStyle(fontSize: 14)),
//                 ],
//               ),
//             if (secondaryphone.isNotEmpty)
//               const SizedBox(
//                 height: 8,
//               ),
//             if (secondaryphone != 'null')
//               Row(
//                 children: [
//                   const Text(
//                     "Secondary Phone: ",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                   ),
//                   Text("${secondaryphone}", style: TextStyle(fontSize: 14)),
//                 ],
//               ),
//             const SizedBox(
//               height: 8,
//             ),
            
//           ],
//         ),
//       ),
//     );
//   }
// }

class ViewAdminModel extends StatelessWidget {
  const ViewAdminModel({
    super.key,
    required this.name,
    required this.adminId,
    required this.email,
    required this.phonenumber,
    required this.createdat,
    required this.gender,
    required this.doctorgegnum,
    required this.qualification,
    required this.specialization,
    required this.secondaryphone,
    required this.boardofregistration,
    required this.yearofregistration,
  });

  final String name;
  final String adminId;
  final String email;
  final int phonenumber;
  final String createdat;
  final String gender;
  final String doctorgegnum;
  final String qualification;
  final String specialization;
  final String secondaryphone;
  final String boardofregistration;
  final String yearofregistration;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.bgGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔴 Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.mutedBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Doctor Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.primary),
                      onPressed: () => context.router.pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// 🧑 Name
                _infoCard(
                  icon: Icons.person,
                  title: "NAME",
                  value: name,
                  highlight: true,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  icon: Icons.email,
                  title: "EMAIL",
                  value: email,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  icon: Icons.phone,
                  title: "PHONE NUMBER",
                  value: phonenumber.toString(),
                  iconBg: Colors.green.shade50,
                  iconColor: Colors.green,
                ),

                const SizedBox(height: 12),

                /// Qualification + Specialization
                Row(
                  children: [
                    Expanded(
                      child: _smallCard(
                        title: "QUALIFICATION",
                        value: qualification,
                        icon: Icons.school,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _smallCard(
                        title: "SPECIALIZATION",
                        value: specialization,
                        icon: Icons.medical_services,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (doctorgegnum.isNotEmpty)
                  _infoCard(
                    icon: Icons.tag,
                    title: "DOCTOR REGISTRATION NUMBER",
                    value: doctorgegnum,
                    highlight: true,
                  ),

                const SizedBox(height: 12),

                if (yearofregistration != 'null')
                  _infoCard(
                    icon: Icons.calendar_month,
                    title: "YEAR OF REGISTRATION",
                    value: yearofregistration,
                  ),

                const SizedBox(height: 12),

                if (boardofregistration.isNotEmpty)
                  _infoCard(
                    icon: Icons.account_balance,
                    title: "BOARD OF REGISTRATION",
                    value: boardofregistration,
                  ),

                if (secondaryphone != 'null' &&
                    secondaryphone.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _infoCard(
                    icon: Icons.phone_android,
                    title: "SECONDARY PHONE",
                    value: secondaryphone,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Big Info Card
  Widget _infoCard({
    required String title,
    required String value,
    IconData? icon,
    bool highlight = false,
    Color? iconBg,
    Color? iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.softPinkish : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? AppColors.primary : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg ?? AppColors.mutedBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Small Side Card
  Widget _smallCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

