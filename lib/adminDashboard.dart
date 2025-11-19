import 'package:admin_mobile_application/adminController/adminPatientPage.dart';
import 'package:admin_mobile_application/adminController/doctorDetailsPage.dart';
import 'package:admin_mobile_application/adminController/profilePage.dart';
import 'package:admin_mobile_application/adminController/todayVisitPage.dart';
import 'package:admin_mobile_application/adminController/todaysAppointmetsPage.dart';
import 'package:admin_mobile_application/loginPage.dart';
import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/routes/app_router.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



@RoutePage()
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
final SecureStorage secureStorage = SecureStorage();
  late Future fetchadmin;
  bool isLoading = true;

  final List<Widget> _pages = const [
    AllPatientsPage(),
     DoctorDetailsPage(),
     TodaysOutvisitsPage(),
    //  AdminProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkToken();
    AdminPageProvider adminPageProvider = context.read<AdminPageProvider>();
    fetchadmin = adminPageProvider.getadmindetailedprofile();
  }


 Future<void> _checkToken() async {
    Constants.token = await secureStorage.readSecureData('token');
    Constants.role = await secureStorage.readSecureData('role');
    print(Constants.token);
    print(Constants.role);
    setState(() {
      Constants.token = Constants.token ?? '';
      isLoading = false;
    });
  }

@override
Widget build(BuildContext context) {
  return Consumer<AdminPageProvider>(
    builder: (context, adminPageProvider, child) {
      return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF0857C0),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: const Text(
            "Admin Dashboard",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF0857C0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    if (adminPageProvider.admindetailedprofile.isNotEmpty) ...[
                      Text(
                        "${adminPageProvider.admindetailedprofile.first['name']}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${adminPageProvider.admindetailedprofile.first['email']}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${adminPageProvider.admindetailedprofile.first['phone']}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ]
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.switch_account_rounded),
                title: const Text('Appointments'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TodaysAppointmentsPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await secureStorage.deleteSecureData('token');
                  await secureStorage.deleteSecureData('phone');
                  Constants.token =
                      await secureStorage.readSecureData('token') ?? '';
                      await secureStorage.readSecureData('phone') ?? '';
                  context.router.replaceAll([LoginRoute()]);
                },
              ),
            ],
          ),
        ),
        body: _buildBody(adminPageProvider),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Patients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_rounded),
              label: 'Doctors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin_rounded),
              label: "Today's Visits",
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.person),
            //   label: 'Profile',
            // ),
          ],
          backgroundColor: const Color(0xFF0857C0),
          currentIndex: _selectedIndex,
          iconSize: 30,
          selectedLabelStyle: const TextStyle(fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          showUnselectedLabels: true,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      );
    },
  );
}

Widget _buildBody(AdminPageProvider adminPageProvider) {
  if (Constants.token.isEmpty) {
    return const LoginPage();
  }
  return FutureBuilder(
    future: fetchadmin,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      return _pages[_selectedIndex];
    },
  );
}



//   @override
//   Widget build(BuildContext context) {
//  if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Consumer<AdminPageProvider>(builder:(context, adminPageProvider, child) {

//       if (Constants.token.isEmpty) {
//           return const LoginPage();
//         } 
//         else{
//           return FutureBuilder(future: fetchadmin, builder:(context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               return Scaffold(
//        appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor:const Color(0xFF0857C0) ,
//         centerTitle: true,
//         title: const Text("Admin Dashboard",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),)),
//         drawer: Drawer(
//                   child: ListView(
//                     padding: EdgeInsets.zero,
//                     children: [
//                       DrawerHeader(
//                         decoration: const BoxDecoration(
//                           color: Color(0xFF0857C0),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const CircleAvatar(
//                               radius: 25,
//                               backgroundColor: Colors.white,
//                               child: Icon(Icons.person, color: Colors.blue),
//                             ),
//                             const SizedBox(height: 10),
//                             if (adminPageProvider.admindetailedprofile.isNotEmpty)
//                               Text(
//                                 "${adminPageProvider.admindetailedprofile.first['name']}",
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                               if (adminPageProvider.admindetailedprofile.isNotEmpty)
//                               Text(
//                                 "${adminPageProvider.admindetailedprofile.first['email']}",
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                               if (adminPageProvider.admindetailedprofile.isNotEmpty)
//                               Text(
//                                 "${adminPageProvider.admindetailedprofile.first['phone']}",
//                                 style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                           ],
//                         ),
//                       ),
//                       ListTile(
//                         leading: const Icon(Icons.switch_account_rounded),
//                         title: const Text('Appointments'),
//                         onTap: () {
//                           Navigator.pop(context);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const TodaysAppointmentsPage()),
//                           );
//                         },
//                       ),
//                       // ListTile(
//                       //   leading: const Icon(Icons.feedback),
//                       //   title: const Text('Feedback'),
//                       //   onTap: () {
//                       //     Navigator.pop(context);
//                       //     Navigator.push(
//                       //       context,
//                       //       MaterialPageRoute(
//                       //           builder: (context) => const FeedbackDashboard()),
//                       //     );
//                       //   },
//                       // ),
//                       const Divider(),
//                       ListTile(
//                         leading: const Icon(Icons.logout),
//                         title: const Text('Logout'),
//                         onTap: () async {
//                     secureStorage.deleteSecureData('token');

//                     setState(() {});
//                     Constants.token =
//                         await secureStorage.readSecureData('token') ?? '';

//                     context.router.replaceAll([LoginRoute()]);
//                     // homePageProvider.selectedIndex = 0;
//                     // homePageProvider.notify();
//                   },
//                       ),
//                     ],
//                   ),
//                 ),
        
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: 
//       BottomNavigationBar(
//               type: BottomNavigationBarType.fixed,
//               items: const <BottomNavigationBarItem>[
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.group),
//                   label: 'Patients',
//                 ),

//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person_pin_rounded),
//                   label: 'Doctors',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person_pin_rounded),
//                   label: 'Today\'s Visits',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person),
//                   label: 'Profile',
//                 ),
//               ],
//               backgroundColor: const Color(0xFF0857C0),
//               currentIndex: _selectedIndex,
//               iconSize: 30,
//               selectedLabelStyle: const TextStyle(fontSize: 16),
//               unselectedLabelStyle: const TextStyle(fontSize: 16),
//               showUnselectedLabels: true,
//               selectedItemColor: Colors.white,
//               unselectedItemColor: Colors.white54,
//               // unselectedItemColor: const Color(0xFF545454),
//               // selectedItemColor: const Color(0xFF0857C0),
//               onTap: (index) => setState(() => _selectedIndex = index),
//             ),
//     );
//           },);
//         }
      
//     },);
    
//   ;
//   }
}
