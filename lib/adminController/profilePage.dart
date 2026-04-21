
import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/routes/app_router.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  late Future fetchadminprofile;
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AdminPageProvider adminprovider = context.read<AdminPageProvider>();
    fetchadminprofile = adminprovider.getadmindetailedprofile(context);
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    // SecureStorage secureStorage = SecureStorage();
    AdminPageProvider adminprovider = context.read<AdminPageProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                  future: fetchadminprofile,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerList();
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Error fetching data"));
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: adminprovider.admindetailedprofile.length,
                        itemBuilder: (context, index) {
                          final item =
                              adminprovider.admindetailedprofile[index];
                          // final hospitalbranch =
                          //     item['associatedHospitalBranch'];
                          // final hospital = hospitalbranch['associatedHospital'];

                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "My Details",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade700),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Name: ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(
                                              child: Text(
                                                item['name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                                softWrap: true,
                                                overflow: TextOverflow.visible,
                                              ),
                                            )
                                          ],
                                        ),
                                        // const SizedBox(
                                        //   height: 6,
                                        // ),
                                        // Row(
                                        //   children: [
                                        //     const Text(
                                        //       "ID: ",
                                        //       style: TextStyle(
                                        //           fontSize: 16,
                                        //           fontWeight: FontWeight.bold),
                                        //     ),
                                        //     Text(
                                        //       item['userid'],
                                        //       style: const TextStyle(
                                        //         fontSize: 16,
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Email: ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(
                                              child: Text(
                                                item['email'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                                softWrap: true,
                                                overflow: TextOverflow.visible,
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              "Phone: ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              item['phone'].toString(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            )
                                          ],
                                        ),
                                        // SizedBox(
                                        //   height: 6,
                                        // ),
                                        // Row(
                                        //   children: [
                                        //     const Text(
                                        //       "Gender: ",
                                        //       style: TextStyle(
                                        //           fontSize: 16,
                                        //           fontWeight: FontWeight.bold),
                                        //     ),
                                        //     Text(
                                        //       item['gender'],
                                        //       style: const TextStyle(
                                        //         fontSize: 16,
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0857C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () async {
                    secureStorage.deleteSecureData('token');
                    secureStorage.deleteSecureData('role');
                    // secureStorage.deleteSecureData('admintoken');
                    // secureStorage.deleteSecureData('nursetoken');

                    setState(() {});
                    Constants.token =
                        await secureStorage.readSecureData('token') ?? '';
                    Constants.role =
                        await secureStorage.readSecureData('role') ?? '';
                    // Constants.admintoken =
                    //     await secureStorage.readSecureData('admintoken') ?? '';
                    // Constants.nursetoken =
                    //     await secureStorage.readSecureData('nursetoken') ?? '';
                         context.router.replaceAll([const LoginRoute()]);
                    // context.router.replaceAll([HomeRoute()]);
                    // homePageProvider.selectedIndex = 0;
                    // homePageProvider.notify();
                  },
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Widget _buildShimmerLoading() {
  //   return SizedBox(
  //     height: MediaQuery.of(context).size.height * 0.74,
  //     child: ListView.builder(
  //       itemCount: 4, // Show 8 shimmer items
  //       itemBuilder: (context, index) {
  //         return _buildShimmerItem();
  //       },
  //     ),
  //   );
  // }

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
          // _buildShimmerBox(width: double.infinity, height: 18),
          // SizedBox(height: 8),
          // _buildShimmerBox(width: 200, height: 16),
          // SizedBox(height: 4),

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
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 1000 + (index * 100)),
          child: _buildShimmerItem(),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    AdminPageProvider adminprovider = context.read<AdminPageProvider>();

    await Future.delayed(Duration(seconds: 2));
    Constants.token =
        await secureStorage.readSecureData('token') ?? '';
    setState(() {
      fetchadminprofile = adminprovider.getadmindetailedprofile(context);
    });
  }
}
