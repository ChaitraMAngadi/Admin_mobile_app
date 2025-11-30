import 'dart:async';

import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/routes/app_router.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AllPatientsPage extends StatefulWidget {
  const AllPatientsPage({super.key});

  @override
  State<AllPatientsPage> createState() => _AllPatientsPageState();
}

class _AllPatientsPageState extends State<AllPatientsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final SecureStorage secureStorage = SecureStorage();
  late Future fetchadminprofile;

  late AdminPageProvider adminprovider;

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Timer? _debounceTimer;
  String _currentSearchQuery = '';
  bool _isSearching = false; 

  @override
  void initState() {
    super.initState();
    adminprovider = context.read<AdminPageProvider>();

    _fetchInitialData();

    fetchadminprofile = adminprovider.getadmindetailedprofile();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMorePatients();
      }
    });

    _searchController.addListener(() {
      final query = _searchController.text.trim();
      
      _debounceTimer?.cancel();
      
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (_currentSearchQuery != query) {
          _currentSearchQuery = query;
          _performSearch(query);
        }
      });
    });
  }

  Future<void> _fetchInitialData() async {
    await adminprovider.getPatientsByPageWithSearch(_currentPage, _currentSearchQuery);
    // await homePageProvider.getdoctordetails();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      _isLoadingMore = false;
      _isSearching = true; 
      adminprovider.allpatients.clear();
      adminprovider.filteredPatients.clear();
    });

    await adminprovider.getPatientsByPageWithSearch(_currentPage, query);
    
    setState(() {
      _hasMore = adminprovider.allpatients.isNotEmpty;
      _isSearching = false; // Reset searching flag
    });
  }

  Future<void> _loadMorePatients() async {
    setState(() => _isLoadingMore = true);
    _currentPage += 1;

    final previousLength = adminprovider.allpatients.length;
    await adminprovider.getPatientsByPageWithSearch(_currentPage, _currentSearchQuery);
    final newLength = adminprovider.allpatients.length;

    if (newLength == previousLength) {
      _hasMore = false;
    }

    setState(() => _isLoadingMore = false);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      _isSearching = false; // Reset searching flag
      adminprovider.allpatients.clear();
      adminprovider.filteredPatients.clear();
    });
    await _fetchInitialData();
  }

  String formatDate(String date) {
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return '';
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  // Add this method for "No search results found" UI
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
              _currentSearchQuery = '';
              _performSearch('');
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

  Widget _buildShimmerBox({
    required double width, 
    required double height, 
    double borderRadius = 8
  }) {
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
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Consumer<AdminPageProvider>(
          builder: (context, adminprovider, child) {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Register Patient Button
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: ElevatedButton(
                      // onPressed: (){},
                      onPressed: () => context.router.push(RegisterNewPatientRoute()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0857C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
                          SizedBox(width: 6),
                          Text("Register Patient", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  // Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Patient by id or name...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _currentSearchQuery = '';
                                  _performSearch('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Main content area
                  Expanded(
                    child: _buildMainContent(adminprovider),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(AdminPageProvider adminprovider) {
    // Show shimmer while searching or initial load
    if (_isSearching || (_currentPage == 1 && adminprovider.allpatients.isEmpty && _isLoadingMore)) {
      return _buildShimmerList();
    }
    
    // Show "No search results found" if search query exists but no results
    if (_currentSearchQuery.isNotEmpty && adminprovider.allpatients.isEmpty) {
      return _buildNoSearchResults();
    }
    
    // Show shimmer for initial load (when no search query)
    if (adminprovider.allpatients.isEmpty && _currentSearchQuery.isEmpty) {
      return _buildShimmerList();
    }
    
    // Show the actual list
    return ListView.builder(
      controller: _scrollController,
      itemCount: adminprovider.allpatients.length + (_hasMore && _isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < adminprovider.allpatients.length) {
          final sorted = adminprovider.allpatients
            ..sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
          final item = sorted[index];
          final isCreatedByAdmin = item["createdByAdmin"] != null;


          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTileModel(
              isCreatedByAdmin:item["createdByAdmin"]??"" ,
              patientname: item['name'], patientId: item['patientId'],
              isActive: item['isActive'] ?? true, 
              
            // viewonTap: (){
            //   showDialog(
            //     context: context,
            //     builder: (context) {
            //       return item["createdByAdmin"] == null
            //           ? ViewModel(
            //               name: item['name'],
            //               patientid: item['patientId'],
            //               email: item['email'] ?? "",
            //               phonenumber: item['phone'] ?? 0,
            //               dob: formatDate(item['DOB'] ?? ""),
            //               age: item['age'] ?? "",
            //               gender: item['gender'] ?? "",
            //               createdbyadmin: "",
            //               adminame: "",
            //               // createdbydoctor: "",
            //               createdbydoctor: item['doctor']['name'] ,
            //               doctoruserid:item['doctor']['userid'] ,
            //               adminuserid: '',
            //               createdat: formatDate(item['createdAt']),
            //             )
            //           : ViewModel(
            //               name: item['name'],
            //               patientid: item['patientId'],
            //               email: item['email'] ?? "",
            //               phonenumber: item['phone'] ?? 0,
            //               dob: formatDate(item['DOB'] ?? ""),
            //               age: item['age'] ?? "",
            //               gender: item['gender'] ?? "",
            //               createdbyadmin: "",
            //               adminame: adminprovider.admindetailedprofile.first["name"] ?? "",
            //               adminuserid:adminprovider.admindetailedprofile.first["userid"] ?? "",
            //               doctoruserid: '',
            //               createdbydoctor: "",
            //               // createdbydoctor: "${homePageProvider.doctordetails.first["name"]} - ${homePageProvider.doctordetails.first["userid"]}",
            //               createdat: formatDate(item['createdAt']),
            //             );
            //     },
            //   );
              
            // },
            //

viewonTap: () {
  showDialog(
    context: context,
    builder: (context) {
      final isCreatedByAdmin = item["createdByAdmin"] != null;
      final isCreatedByDoctor = item["createdByDoctor"] != null;

      if (isCreatedByDoctor && item["doctor"] != null) {
        // Created by doctor
        return ViewModel(
          name: item['name'],
          patientid: item['patientId'],
          email: item['email'] ?? "",
          phonenumber: item['phone'] ?? 0,
          dob: formatDate(item['DOB'] ?? ""),
          age: item['age'] ?? "",
          gender: item['gender'] ?? "",
          createdbyadmin: "",
          adminame: "",
          createdbydoctor: item['doctor']?['name'] ?? "",
          doctoruserid: item['doctor']?['userid'] ?? "",
          adminuserid: '',
          createdat: formatDate(item['createdAt']),
        );
      } else if (isCreatedByAdmin) {
        // Created by admin
        return ViewModel(
          name: item['name'],
          patientid: item['patientId'],
          email: item['email'] ?? "",
          phonenumber: item['phone'] ?? 0,
          dob: formatDate(item['DOB'] ?? ""),
          age: item['age'] ?? "",
          gender: item['gender'] ?? "",
          createdbyadmin: item['createdByAdmin'] ?? "",
          adminame: adminprovider.admindetailedprofile.first["name"] ?? "",
          adminuserid: adminprovider.admindetailedprofile.first["userid"] ?? "",
          createdbydoctor: "",
          doctoruserid: "",
          createdat: formatDate(item['createdAt']),
        );
      } else {
        // Fallback (if neither found)
        return ViewModel(
          name: item['name'],
          patientid: item['patientId'],
          email: item['email'] ?? "",
          phonenumber: item['phone'] ?? 0,
          dob: formatDate(item['DOB'] ?? ""),
          age: item['age'] ?? "",
          gender: item['gender'] ?? "",
          createdbyadmin: "",
          adminame: "",
          createdbydoctor: "",
          doctoruserid: "",
          createdat: formatDate(item['createdAt']), adminuserid: '',
        );
      }
    },
  );
},



            editonTap:isCreatedByAdmin? (){
              context.router.push(EditPatientAdminRoute(patientId:item['patientId'] ));
            }:(){},
             outvisitonTap: (){
              context.router.push(PatientAdminOutvisitsRoute(patientId: item['patientId']));
            }, 
            // invisitonTap: (){
            //   // context.router.push(PatientAdminInvisitsRoute(patientId: item['patientId'], name: item['name']));
            // }
            ),
          );
        } else if (_hasMore && _isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}


class ListTileModel extends StatelessWidget {
  const ListTileModel({
    super.key,
  
    required this.patientname,
    required this.patientId, required this.viewonTap, required this.editonTap, required this.outvisitonTap, required this.isActive, required this.isCreatedByAdmin,
    //  required this.invisitonTap,
    
  });
  final String patientname;
  final VoidCallback viewonTap;
  final VoidCallback editonTap;
  final VoidCallback outvisitonTap;
  // final VoidCallback invisitonTap;
  final String patientId;
  final bool isActive;
  final String isCreatedByAdmin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        tileColor: Colors.grey.shade50,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  patientname,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // IconButton(onPressed: viewonTap, icon: const Icon(Icons.remove_red_eye_outlined,
                // color:Color(0xFF0857C0) ,))
              ],
            ),
            Text(
              patientId,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            
          ],
        ),
        
        subtitle:
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                        backgroundColor:Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    onPressed: viewonTap, child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text("View",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0857C0),
                    ),),
                    SizedBox(width: 4,),
                    Icon(Icons.remove_red_eye,
                    color: Color(0xFF0857C0),),
                  ],)),
                ),SizedBox(width: 4,),
          Expanded(
            flex: 1,
            child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                        backgroundColor:Colors.blue.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    onPressed: outvisitonTap,
                     child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text("Visits",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),),
                    SizedBox(width: 2,),
                    Icon(Icons.open_in_new,
                    color: Colors.blue.shade700,),
                  ],)),
          ),
                SizedBox(width: 4,),
                Expanded(
                  child: ElevatedButton(
                     style: ElevatedButton.styleFrom(
                        backgroundColor:isCreatedByAdmin.isNotEmpty? Colors.brown.shade100:Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // padding:
                        //     EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    onPressed: editonTap,
                     child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text("Edit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:isCreatedByAdmin.isNotEmpty? Colors.brown.shade700:Colors.grey,
                    ),),
                    SizedBox(width: 4,),
                    Icon(Icons.edit_square,
                    color:isCreatedByAdmin.isNotEmpty? Colors.brown.shade700 : Colors.grey,),
                  ],)),
                ),
                // IconButton(onPressed: editonTap, icon: const Icon(Icons.edit_square,
                // color:Color(0xFF0857C0) ,))
          
        ]),
      ),
    );
  }
}

class ViewModel extends StatelessWidget {
  const ViewModel({
    super.key,
    required this.name,
    required this.patientid,
    required this.email,
    required this.phonenumber,
    required this.dob,
    required this.age,
    required this.gender,
    required this.createdbydoctor,
    required this.createdat,
    required this.createdbyadmin,
    required this.adminame, required this.doctoruserid, required this.adminuserid,
  });

  final String name;
  final String patientid;
  final String email;
  final int phonenumber;
  final String dob;
  final String age;
  final String gender;
  final String createdbydoctor;
  final String createdat;
  final String createdbyadmin;
  final String adminame;
  final String doctoruserid;
  final String adminuserid;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Patient Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      context.router.pop();
                    },
                    icon: Icon(Icons.close))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Text(
                  "Name: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${name}",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if(email.isNotEmpty)
            const SizedBox(
              height: 8,
            ),
            if(email.isNotEmpty)
            Row(
              children: [
                const Text(
                  "Email: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${email}",
                  style: TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Text(
                  "Phone Number: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("${phonenumber}", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Text(
                  "DOB: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("${dob}", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Text(
                  "PatientId: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("${patientid}", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Text(
                  "Age: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("${age}", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Text(
                  "Gender: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("${gender}", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            if (createdbyadmin.isEmpty)
              Row(
                children: [
                  const Text(
                    "Created By Doctor: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${createdbydoctor}",
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (createdbyadmin.isEmpty)
               const SizedBox(
              height: 8,
            ),
              if (createdbyadmin.isEmpty)
              Row(
                children: [
                  const Text(
                    "Doctor Userid: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${doctoruserid}",
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            //   if (createdbyadmin.isEmpty)
            //   const SizedBox(
            //   height: 8,
            // ),
            if (createdbyadmin.isNotEmpty)
              Row(
                children: [
                  const Text(
                    "Created By Admin: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    adminame,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (createdbyadmin.isNotEmpty)
              const SizedBox(
              height: 8,
            ),
              if (createdbyadmin.isNotEmpty)
              Row(
                children: [
                  const Text(
                    "Admin Userid: ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    adminuserid,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Text(
                  "Creation Date: ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("$createdat", style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}