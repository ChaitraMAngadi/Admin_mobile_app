
import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
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

  @override
  void initState() {
    super.initState();
    AdminPageProvider adminPageProvider = context.read<AdminPageProvider>();
    fetchtodaysappointments =
        adminPageProvider.gettodaysappointments().then((_) {
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
      appBar: AppBar(

        title: Text('Todays Appointments',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),),
        centerTitle: true,
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
                      future: fetchtodaysappointments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.76,
                              child: _buildShimmerList());
                        } else {
                          return SafeArea(
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
                                        return TodaysAppointmentModel(
                                          patientname: item['patientname']??'',
                                          patientmobile: item['patientMobile'].toString()??'',
                                          starttime: item['startTime']??'',
                                          endtime: item['endTime']??'',
                                          doctorname: item['doctor']['name']??'',
                                        );
                                      },
                                    ),
                                  ),
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
      fetchtodaysappointments = adminPageProvider.gettodaysappointments();
      adminPageProvider.filteredtodaysappointments =
          adminPageProvider.todaysappointments;
    });
  }
}

class TodaysAppointmentModel extends StatelessWidget {
  const TodaysAppointmentModel({
    super.key,
    required this.patientname,
    required this.patientmobile,
    required this.starttime,
    required this.endtime,
    required this.doctorname,
  });
  final String patientname;
  final String patientmobile;
  final String starttime;
  final String endtime;
  final String doctorname;
  // final bool isreport;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
        left: 16,
        right: 16,
      ),
      child: ListTile(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        tileColor: Colors.grey.shade100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Name: ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  patientname,
                  style: const TextStyle(
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'Mobile: ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  patientmobile,
                  style: const TextStyle(
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 6,
            ),
            Row(
              children: [
                const Text(
                  'Doctor: ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  doctorname,
                  style: const TextStyle(
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: Colors.blue.shade100),
              child: Text(
                '$starttime - $endtime',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
