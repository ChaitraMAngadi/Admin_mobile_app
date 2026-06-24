import 'dart:convert';
 import 'package:admin_mobile_application/routes/app_router.dart';
import 'package:admin_mobile_application/services/DeviceHeader.dart';
import 'package:admin_mobile_application/services/cacheManager.dart';
import 'package:admin_mobile_application/services/constants.dart';
import 'package:admin_mobile_application/services/secureStorage.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class SlotModel {
  final String startTime;
  final String endTime;
  final String? patientname;
  final String? patientMobile;

  bool get isBooked => patientname != null;

  SlotModel({
    required this.startTime,
    required this.endTime,
    this.patientname,
    this.patientMobile,
  });


  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      startTime: json["startTime"],
      endTime: json["endTime"],
      patientname: json["patientname"],
      patientMobile: json["patientMobile"]?.toString(),
    );
  }
}


 String formatDate(String date) {
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return '';
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }

class AdminPageProvider extends ChangeNotifier {
  List<Map<String, dynamic>> admindetails = [];
  List<Map<String, dynamic>> admindetailedprofile = [];
  // List<Map<String, dynamic>> patientoutvisits = [];z
  Map<String, dynamic> patientoutvisits = {};
  List<Map<String, dynamic>> visits = [];
  List<Map<String, dynamic>> filteredPatients = [];
  List<Map<String, dynamic>> allpatients = [];
  List<Map<String, dynamic>> patientdetails = [];
  List<Map<String, dynamic>> alldoctors = [];
  List<Map<String, dynamic>> alldoctorsdetails = [];
  List<Map<String, dynamic>> gettodaysvisits = [];
  List<Map<String, dynamic>> filteredvisits = [];
  List<Map<String, dynamic>> todaysappointments = [];
  List<Map<String, dynamic>> filteredtodaysappointments = [];

       final String Outvisits  = 'outvisits';

       final String kProfile  = 'profile';

  final CacheManager _cache = CacheManager();


    bool addingpatient = false;
    bool editingpatient = false;
    bool addingoutvisit = false;  



  final SecureStorage secureStorage = SecureStorage();

  Future<void> getalladmins(BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/doctor/getalladmin";
    // '${Constants.baseUrl}/app/log-in/phone-otp'
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        admindetails =
            json.decode(response.body)['data'].cast<Map<String, dynamic>>();

        notifyListeners();
      } else if(response.statusCode == 401){
        await refreshtoken(context);
        Constants.token = await secureStorage.readSecureData('token') ?? '';
        try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        admindetails =
            json.decode(response.body)['data'].cast<Map<String, dynamic>>();

        notifyListeners();
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
      }
    } catch (e) {
      print(e);
    }
      }
       else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getPatientsByPageWithSearch(int page, String searchQuery,BuildContext context ) async {
  final String url = searchQuery.isNotEmpty 
      ? "${Constants.baseUrl}/api/v1/admin/getpatientbyadmin?page=$page&search=${Uri.encodeComponent(searchQuery)}"
      : "${Constants.baseUrl}/api/v1/admin/getpatientbyadmin?page=$page";

  Constants.token = await secureStorage.readSecureData('token') ?? '';
  // print(Constants.admintoken);

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Constants.token}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);

      // Get new patients from response
      List<Map<String, dynamic>> newPatients = json.decode(response.body)['data'].cast<Map<String, dynamic>>();

      if (page == 1) {
        // First page or new search - replace existing data
        allpatients = newPatients;
        filteredPatients = [...allpatients];
      } else {
        // Subsequent pages - append data
        allpatients.addAll(newPatients);
        filteredPatients = [...allpatients];
      }
      
      notifyListeners();
    } else if(response.statusCode == 401){
await refreshtoken(context);
Constants.token = await secureStorage.readSecureData('token') ?? '';

try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Constants.token}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);

      // Get new patients from response
      List<Map<String, dynamic>> newPatients = json.decode(response.body)['data'].cast<Map<String, dynamic>>();

      if (page == 1) {
        // First page or new search - replace existing data
        allpatients = newPatients;
        filteredPatients = [...allpatients];
      } else {
        // Subsequent pages - append data
        allpatients.addAll(newPatients);
        filteredPatients = [...allpatients];
      }
      
      notifyListeners();
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print("Exception in getPatientsByPageWithSearch: $e");
  }

    }
     else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print("Exception in getPatientsByPageWithSearch: $e");
  }
}

Future<void> getPatientsByPage(int page, BuildContext context) async {
  await getPatientsByPageWithSearch(page, '', context);
}

Future<void> getadmindetailedprofile(BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/getmyprofile";

    Constants.token = await secureStorage.readSecureData('token') ?? '';
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];

        if (data is List) {
          admindetailedprofile = List<Map<String, dynamic>>.from(data);
          

          notifyListeners();
        } else if (data is Map) {
          admindetailedprofile = [Map<String, dynamic>.from(data)];
          print('doctor details : $admindetailedprofile');
          // print(doctordetailedprofile);
        }
        notifyListeners();
      } else if(response.statusCode == 401){
        await refreshtoken(context);

        Constants.token = await secureStorage.readSecureData('token') ?? '';

        try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];

        if (data is List) {
          admindetailedprofile = List<Map<String, dynamic>>.from(data);
          

          notifyListeners();
        } else if (data is Map) {
          admindetailedprofile = [Map<String, dynamic>.from(data)];
          print('doctor details : $admindetailedprofile');
          // print(doctordetailedprofile);
        }
        notifyListeners();
      } else {
        print('${response.body}');
      }
    } catch (e) {
      print(e);
    }
      }
       else {
        print('${response.body}');
      }
    } catch (e) {
      print(e);
    }
  }

Future<void> addpatient(String name, String phone, String gender,
      String email, String dob, BuildContext context) async {
    try {
      Constants.token = await secureStorage.readSecureData('token') ?? '';
      final headers = await DeviceHeaders.getDeviceHeaders();


      final Map<String, dynamic> requestBody = {
        "name": name,
        "gender": gender,
        "phone": phone,
        "DOB": dob,
      };

      if (email.isNotEmpty) {
        requestBody["email"] = email;
      }

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/v1/admin/addpatient'),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        addingpatient = false;
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'Patient Registered successfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);
        getPatientsByPage(1,context);
        Navigator.pop(context);
      } else if(response.statusCode == 401){
        await refreshtoken(context);

        try {
      Constants.token = await secureStorage.readSecureData('token') ?? '';
      final headers = await DeviceHeaders.getDeviceHeaders();


      final Map<String, dynamic> requestBody = {
        "name": name,
        "gender": gender,
        "phone": phone,
        "DOB": dob,
      };

      if (email.isNotEmpty) {
        requestBody["email"] = email;
      }

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/v1/admin/addpatient'),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        addingpatient = false;
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'Patient Registered successfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);
        getPatientsByPage(1,context);
        Navigator.pop(context);
      } else {
        print(response.body);
        addingpatient = false;
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } catch (e) {
      addingpatient = false;
      final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
    }
      }
       else {
        print(response.body);
        addingpatient = false;
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } catch (e) {
      addingpatient = false;
      final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
    }
  }


  Future<void> getpatient(String id, BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/getpatientbyid/$id";
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];

        if (data is List) {
          patientdetails = List<Map<String, dynamic>>.from(data);
          notifyListeners();
        } else if (data is Map) {
          patientdetails = [Map<String, dynamic>.from(data)];
          print(patientdetails);
          notifyListeners();
        }
        notifyListeners();
        // print(patientdetails);
      } else if(response.statusCode == 401){
        await refreshtoken(context);

        Constants.token = await secureStorage.readSecureData('token') ?? '';

        try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];

        if (data is List) {
          patientdetails = List<Map<String, dynamic>>.from(data);
          notifyListeners();
        } else if (data is Map) {
          patientdetails = [Map<String, dynamic>.from(data)];
          print(patientdetails);
          notifyListeners();
        }
        notifyListeners();
        // print(patientdetails);
      } else {
        print('${response.body}');
      }
    } catch (e) {
      print(e);
    }
      } else {
        print('${response.body}');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> editpatient(String id, String name, String dob, String gender,
      String email, String phone, BuildContext context) async {
    try {
      Constants.token = await secureStorage.readSecureData('token') ?? '';

      final headers = await DeviceHeaders.getDeviceHeaders();


      print(
          "name: $name gender: $gender DOB: $dob email: $email phone: $phone");

      final Map<String, dynamic> requestBody = {
        "name": name,
        "gender": gender,
        "DOB": dob,
        "phone": phone,
        "email": email,
      };

      // if (phone.isNotEmpty) {
      //   requestBody["memberphone"] = phone;
      // }

      // if (email.isNotEmpty) {
      //   requestBody["email"] = email;
      // }

      String url = "${Constants.baseUrl}/api/v1/admin/editpatient/$id";
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        editingpatient = false;
        await getpatient(id, context);
        
        notifyListeners();
        print(responseData);
        final msg = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              "Patient details updated Successfully",
              style: TextStyle(color: Colors.grey[50]),
            ));
        ScaffoldMessenger.of(context).showSnackBar(msg);
        getPatientsByPage(1, context);
        // getallpatients();
        Navigator.pop(context);

        notifyListeners();
      } else if(response.statusCode == 401){
        await refreshtoken(context);

        try {
      Constants.token = await secureStorage.readSecureData('token') ?? '';

      final headers = await DeviceHeaders.getDeviceHeaders();


      print(
          "name: $name gender: $gender DOB: $dob email: $email phone: $phone");

      final Map<String, dynamic> requestBody = {
        "name": name,
        "gender": gender,
        "DOB": dob,
        "phone": phone,
        "email": email,
      };

      // if (phone.isNotEmpty) {
      //   requestBody["memberphone"] = phone;
      // }

      // if (email.isNotEmpty) {
      //   requestBody["email"] = email;
      // }

      String url = "${Constants.baseUrl}/api/v1/admin/editpatient/$id";
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        editingpatient = false;
        await getpatient(id, context);
        
        notifyListeners();
        print(responseData);
        final msg = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              "Patient details updated Successfully",
              style: TextStyle(color: Colors.grey[50]),
            ));
        ScaffoldMessenger.of(context).showSnackBar(msg);
        getPatientsByPage(1, context);
        // getallpatients();
        Navigator.pop(context);

        notifyListeners();
      } else {
        final responseData = jsonDecode(response.body);
       editingpatient = false;
        final msg = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData['msg'],
              style: TextStyle(color: Colors.grey[50]),
            ));
        ScaffoldMessenger.of(context).showSnackBar(msg);
      }
    } catch (e) {
      editingpatient = false;
      final error = SnackBar(
          backgroundColor: Colors.red[400], content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
    }
      }
       else {
        final responseData = jsonDecode(response.body);
       editingpatient = false;
        final msg = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData['msg'],
              style: TextStyle(color: Colors.grey[50]),
            ));
        ScaffoldMessenger.of(context).showSnackBar(msg);
      }
    } catch (e) {
      editingpatient = false;
      final error = SnackBar(
          backgroundColor: Colors.red[400], content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
    }
  }

  Future<void> getpatientoutvisits(String id, BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/getpatientvisits/$id";
    // '${Constants.baseUrl}/app/log-in/phone-otp'
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);

         patientoutvisits = responseData["data"];
            print(patientoutvisits);
            // print(visits);

        notifyListeners();
      } else if(response.statusCode == 401){

        await refreshtoken(context);

        Constants.token = await secureStorage.readSecureData('token') ?? '';

        try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);

         patientoutvisits = responseData["data"];

            // visits = json.decode(response.body)['data']["visits"].cast<Map<String, dynamic>>();
            print(patientoutvisits);
            // print(visits);

        notifyListeners();
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
      }
    } catch (e) {
      print(e);
    }
      }
      
       else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
      }
    } catch (e) {
      print(e);
    }
  }


Future<void> getdoctorsnurses(BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/getassociateddoctorname";
    // '${Constants.baseUrl}/app/log-in/phone-otp'
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
        alldoctors =
            json.decode(response.body)['data'].cast<Map<String, dynamic>>();
           
            print('alldoctors $alldoctors');
            
        notifyListeners();
      } else if(response.statusCode == 401){
        await refreshtoken(context);
         Constants.token = await secureStorage.readSecureData('token') ?? '';
        try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
        alldoctors =
            json.decode(response.body)['data'].cast<Map<String, dynamic>>();
           
            print('alldoctors $alldoctors');
            
        notifyListeners();
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
      }
    } catch (e) {
      print(e);
    }
      }
       else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
      }
    } catch (e) {
      print(e);
    }
  }

Future<void> addoutvisit(
      String patientId,
      String cheifcomplaint,
      String height,
      String weight,
      String bp,
      String temperature,
      String heartrate,
      String associatedDoctor,
      BuildContext context) async {
    try {
      Constants.token = await secureStorage.readSecureData('token') ?? '';
      final headers = await DeviceHeaders.getDeviceHeaders();


      final Map<String, dynamic> requestBody = {
        "chief_complaint": cheifcomplaint,
        "associatedDoctorId": associatedDoctor
      };

      if (height.isNotEmpty) {
        requestBody["height"] = height;
      }
      if (weight.isNotEmpty) {
        requestBody["weight"] = weight;
      }
      if (bp.isNotEmpty) {
        requestBody["bp"] = bp;
      }
      if (heartrate.isNotEmpty) {
        requestBody["heart_rate"] = heartrate;
      }
      if (temperature.isNotEmpty) {
        requestBody["temparature"] = temperature;
      }
      print(requestBody);

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/v1/admin/addvisit/$patientId'),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        addingoutvisit = false;
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'Visit added successfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);

        getpatientoutvisits(patientId, context);

        notifyListeners();

        Navigator.pop(context);
      } else if(response.statusCode == 401){
        await refreshtoken(context);

        try {
      Constants.token = await secureStorage.readSecureData('token') ?? '';
      final headers = await DeviceHeaders.getDeviceHeaders();


      final Map<String, dynamic> requestBody = {
        "chief_complaint": cheifcomplaint,
        "associatedDoctorId": associatedDoctor
      };

      if (height.isNotEmpty) {
        requestBody["height"] = height;
      }
      if (weight.isNotEmpty) {
        requestBody["weight"] = weight;
      }
      if (bp.isNotEmpty) {
        requestBody["bp"] = bp;
      }
      if (heartrate.isNotEmpty) {
        requestBody["heart_rate"] = heartrate;
      }
      if (temperature.isNotEmpty) {
        requestBody["temparature"] = temperature;
      }
      print(requestBody);

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/v1/admin/addvisit/$patientId'),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        addingoutvisit = false;
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'Visit added successfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);

        getpatientoutvisits(patientId, context);

        notifyListeners();

        Navigator.pop(context);
      } else {
        print(response.body);
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.pop(context);
        addingoutvisit = false;
      }
    } catch (e) {
      final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
      Navigator.pop(context);
      addingoutvisit = false;
    }
      } else {
        print(response.body);
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.pop(context);
        addingoutvisit = false;
      }
    } catch (e) {
      final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
      Navigator.pop(context);
      addingoutvisit = false;
    }
  }

  Future<void> getalldoctorsdetails(BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/getassociateddoctorsdetails";
    // '${Constants.baseUrl}/app/log-in/phone-otp'
    Constants.token = await secureStorage.readSecureData('token') ?? '';
    try {
       if (_cache.isCacheValid(kProfile)) return;
 final cachedVisits = _cache.get<List<Map<String, dynamic>>>(kProfile);
      if (cachedVisits != null) {
        alldoctorsdetails = cachedVisits;
        // filteredVisits = List.from(allvisits);
        notifyListeners();
        return;
      }
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        alldoctorsdetails =
            json.decode(response.body)['data'].cast<Map<String, dynamic>>();
            print('alldoctorsdetails $alldoctorsdetails');

            // _cache.markCached(kProfile);
            _cache.set(kProfile, alldoctorsdetails);
        notifyListeners();
      } else if(response.statusCode == 401){
        await refreshtoken(context);
Constants.token = await secureStorage.readSecureData('token') ?? '';
        try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        alldoctorsdetails =
            json.decode(response.body)['data'].cast<Map<String, dynamic>>();
            print('alldoctorsdetails $alldoctorsdetails');
// _cache.markCached(kProfile);
_cache.set(kProfile, alldoctorsdetails);
        notifyListeners();
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
      }
    } catch (e) {
      print(e);
    }
      }
       else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        // print(responseData);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> gettodaysoutvisits(BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/gettodayspatients";

    Constants.token = await secureStorage.readSecureData('token') ?? '';
    
    try {
      // if (_cache.isCacheValid(Outvisits)) return;
      // final cachedVisits = _cache.get<List<Map<String, dynamic>>>(Outvisits);
      // if (cachedVisits != null) {
      //   gettodaysvisits = cachedVisits;
      //   filteredVisits = List.from(allvisits);
      //   notifyListeners();
      //   return;
      // }

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
       
        gettodaysvisits =
            json.decode(response.body)['data'].cast<Map<String, dynamic>>();
        print('todays visits : $gettodaysvisits');

        // _cache.markCached(Outvisits);
        notifyListeners();
      } else if(response.statusCode == 401){
        await refreshtoken(context);

 Constants.token = await secureStorage.readSecureData('token') ?? '';

        try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
       
        gettodaysvisits =
            json.decode(response.body)['data'].cast<Map<String, dynamic>>();
        print('todays visits : $gettodaysvisits');
        // _cache.markCached(Outvisits);
        notifyListeners();
      } else if (response.statusCode == 404) {
        print('No visits found');
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
      }
       else if (response.statusCode == 404) {
        print('No visits found');
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }


String loginTime = '9:00';
  String logoutTime = "17:00";
  int duration = 30;
  String doctorname = '';

  bool isLoading = true;

  List<SlotModel> bookedSlots = [];
  List<SlotModel> finalSlots = [];

  /// ✅ 1. First load → fetch timing + booked today
  Future<void> loadInitialData(String userid, DateTime date, BuildContext context) async {
    isLoading = true;
    Constants.token = await secureStorage.readSecureData('token') ?? '';


    try {
      final res = await http.get(Uri.parse(
        "${Constants.baseUrl}/api/v1/admin/gettdayschedule/$userid?$date"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
        
        );

    final data = jsonDecode(res.body);
    print(data);
    doctorname = data["doctorName"];

    if(data["doctorTime"] == null){
      loginTime = '9:00';
      logoutTime = '17:00';
      duration = 30;
    }
    else{
      // loginTime = '9:00';
      // logoutTime = '17:00';
      // duration = 30;
       loginTime = data["doctorTime"]["loginTime"];
    logoutTime = data["doctorTime"]["leaveTime"];
    duration = data["doctorTime"]["duration"];
    }

    bookedSlots = (data["slots"] as List)
        .map((e) => SlotModel.fromJson(e))
        .toList();

    generateSlots();

    isLoading = false;
    notifyListeners();
    if (res.statusCode == 401){

      await refreshtoken(context);
 isLoading = true;
    Constants.token = await secureStorage.readSecureData('token') ?? '';

try {
      final res = await http.get(Uri.parse(
        "${Constants.baseUrl}/api/v1/admin/gettdayschedule/$userid?$date"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
        
        );

    final data = jsonDecode(res.body);
    print(data);
    doctorname = data["doctorName"];

    if(data["doctorTime"] == null){
      loginTime = '9:00';
      logoutTime = '17:00';
      duration = 30;
    }
    else{
      // loginTime = '9:00';
      // logoutTime = '17:00';
      // duration = 30;
       loginTime = data["doctorTime"]["loginTime"];
    logoutTime = data["doctorTime"]["leaveTime"];
    duration = data["doctorTime"]["duration"];
    }

    bookedSlots = (data["slots"] as List)
        .map((e) => SlotModel.fromJson(e))
        .toList();

    generateSlots();

    isLoading = false;
    notifyListeners();
    } catch (e) {
      print(e);
    }


    }
    } catch (e) {
      print(e);
    }
  }

  /// ✅ 2. Date change → only slots API
  Future<void> loadByDate(DateTime date, String userid, BuildContext context) async {
    isLoading = true;
    // notifyListeners();

    String d = DateFormat("dd-MM-yyyy").format(date);

    Constants.token = await secureStorage.readSecureData('token') ?? '';


   try {
      final res = await http.get(Uri.parse(
        "${Constants.baseUrl}/api/v1/admin/getschedulebydate/$userid?date=$d"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
        );

    final data = jsonDecode(res.body);
    print(data);
    
     if(data["doctorTime"] != null){
       loginTime = data["doctorTime"]["loginTime"];
    logoutTime = data["doctorTime"]["leaveTime"];
    duration = data["doctorTime"]["duration"];
    }
    else{
      loginTime = '9:00';
      logoutTime = "17:00";
      duration = 30;
    }

    bookedSlots = (data["slots"] as List)
        .map((e) => SlotModel.fromJson(e))
        .toList();


    generateSlots();

    isLoading = false;
    notifyListeners();

    if(res.statusCode == 401){
      await refreshtoken(context);

       isLoading = true;
    // notifyListeners();

    String d = DateFormat("dd-MM-yyyy").format(date);

    Constants.token = await secureStorage.readSecureData('token') ?? '';

try {
      final res = await http.get(Uri.parse(
        "${Constants.baseUrl}/api/v1/admin/getschedulebydate/$userid?date=$d"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
        );

    final data = jsonDecode(res.body);
    print(data);
    
     if(data["doctorTime"] != null){
       loginTime = data["doctorTime"]["loginTime"];
    logoutTime = data["doctorTime"]["leaveTime"];
    duration = data["doctorTime"]["duration"];
    }
    else{
      loginTime = '9:00';
      logoutTime = "17:00";
      duration = 30;
    }

    bookedSlots = (data["slots"] as List)
        .map((e) => SlotModel.fromJson(e))
        .toList();


    generateSlots();

    isLoading = false;
    notifyListeners();
    
   } catch (e) {
     print(e);
   }      

    }
    
   } catch (e) {
     print(e);
   }
  }

  // /// ✅ Generate all slots from timings + merge booked
  // void generateSlots() {
  //   finalSlots.clear();

  //   DateTime start = DateTime.parse("2024-01-01 $loginTime:00");
  //   DateTime end = DateTime.parse("2024-01-01 $logoutTime:00");

  //   while (start.isBefore(end)) {
  //     final s = DateFormat("HH:mm").format(start);
  //     final e = DateFormat("HH:mm").format(start.add(Duration(minutes: duration)));

  //     SlotModel slot = bookedSlots.firstWhere(
  //       (b) => b.startTime == s,
  //       orElse: () => SlotModel(startTime: s, endTime: e),
  //     );

  //     finalSlots.add(slot);
  //     start = start.add(Duration(minutes: duration));
  //   }
  // }

bool isSlotBooked(DateTime slotStart, DateTime slotEnd, List<SlotModel> bookedSlots) {
  for (final booked in bookedSlots) {
    final bookedStart = DateFormat("HH:mm").parse(booked.startTime);
    final bookedEnd = DateFormat("HH:mm").parse(booked.endTime);

    // OVERLAP CONDITION
    if (slotStart.isBefore(bookedEnd) && slotEnd.isAfter(bookedStart)) {
      return true;
    }
  }
  return false;
}



//   void generateSlots() {
//   final List<SlotModel> all = [];

//   // Parse login + logout times
//   final start = DateFormat("HH:mm").parse(loginTime);
//   final end = DateFormat("HH:mm").parse(logoutTime);

//   DateTime current = start;

//   while (current.isBefore(end)) {
//     final next = current.add(Duration(minutes: duration));

//     if (!next.isAfter(end)) {
//       bool booked = isSlotBooked(current, next, bookedSlots);


//       all.add(
//         SlotModel(
//           startTime: DateFormat("HH:mm").format(current),
//           endTime: DateFormat("HH:mm").format(next),
//           patientname: booked ? "BOOKED" : null,
//         ),
//       );
//     }

//     current = next;
//   }

//   finalSlots = all;
// }


void generateSlots() {
  List<SlotModel> all = [];

  final start = DateFormat("HH:mm").parse(loginTime);
  final end = DateFormat("HH:mm").parse(logoutTime);

  DateTime current = start;

  while (current.isBefore(end)) {
    final next = current.add(Duration(minutes: duration));
    if (!next.isAfter(end)) {

      // Check if this slot is already booked from backend
      SlotModel? matched;

      for (var b in bookedSlots) {
        final bStart = DateFormat("HH:mm").parse(b.startTime);
        final bEnd = DateFormat("HH:mm").parse(b.endTime);

        // Overlap check
        if (current.isBefore(bEnd) && next.isAfter(bStart)) {
          matched = b; // this booked slot matches the current slot
          break;
        }
      }

      // If matched = booked slot from backend → carry real mobile number
      all.add(
        matched ??
            SlotModel(
              startTime: DateFormat("HH:mm").format(current),
              endTime: DateFormat("HH:mm").format(next),
              patientname: null,
              patientMobile: "", // free slot → keep empty string
            ),
      );
    }

    current = next;
  }

  finalSlots = all;
}


  /// ✅ Book Slot API
  Future<void> bookSlot(String userid,
      SlotModel slot, DateTime date, String name, String mobile, BuildContext context) async {

    Constants.token = await secureStorage.readSecureData('token') ?? '';
    final headers = await DeviceHeaders.getDeviceHeaders();


try{

    
final Map<String, dynamic> requestBody = {
         "bookingDate": DateFormat("dd-MM-yyyy").format(date),
      "startTime": slot.startTime,
      // "endTime": slot.endTime,
      "patientname": name,
      "patientMobile": mobile,
      };

      print(requestBody);

    final response = await http.post(
        Uri.parse("${Constants.baseUrl}/api/v1/admin/slotbook/$userid"),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'Slot Booked successfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);

      //  loadInitialData(userid);
 
  notifyListeners();

        // Navigator.pop(context);
      } else if(response.statusCode == 401){
        await refreshtoken(context);

          Constants.token = await secureStorage.readSecureData('token') ?? '';
    final headers = await DeviceHeaders.getDeviceHeaders();

        try{

    
final Map<String, dynamic> requestBody = {
         "bookingDate": DateFormat("dd-MM-yyyy").format(date),
      "startTime": slot.startTime,
      // "endTime": slot.endTime,
      "patientname": name,
      "patientMobile": mobile,
      };

      print(requestBody);

    final response = await http.post(
        Uri.parse("${Constants.baseUrl}/api/v1/admin/slotbook/$userid"),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'Slot Booked successfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);

      //  loadInitialData(userid);
 
  notifyListeners();

        // Navigator.pop(context);
      } else {
        print(response.body);  
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        // Navigator.pop(context);
        addingoutvisit = false;
      }
    
   } catch(e){
    print(e);
    final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
   }
      }

       else {
        print(response.body);  
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        // Navigator.pop(context);
        addingoutvisit = false;
      }
    
   } catch(e){
    print(e);
    final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
   }


    // await http.post(
    //     Uri.parse("${Constants.baseUrl}/api/v1/admin/slotbook/$userid"),
    //     headers: <String, String>{
    //       'Content-Type': 'application/json',
    //       'Authorization': 'Bearer ${Constants.token}',s
    //     },
    //     body: body);
  }

  /// ✅ Delete API
  Future<void> 
  deleteSlot(String userid,SlotModel slot, DateTime date, BuildContext context ) async {
        Constants.token = await secureStorage.readSecureData('token') ?? '';
        final headers = await DeviceHeaders.getDeviceHeaders();


    // final body = {
    //   "doctorId": userid,
    //   "date": DateFormat("dd-MM-yyyy").format(date),
    //   "startTime": slot.startTime,
    //   "endTime": slot.endTime,
    // };

    try{

final Map<String, dynamic> requestBody = {
         "bookingDate": DateFormat("dd-MM-yyyy").format(date),
      "startTime": slot.startTime,
      "endTime": slot.endTime,
      };

    final response = await http.delete(
        Uri.parse("${Constants.baseUrl}/api/v1/admin/deleteslot/$userid"),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              responseData["msg"],
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);

      //  loadInitialData(userid);
 
  notifyListeners();

        // Navigator.pop(context);
      } else if(response.statusCode == 401){
        await refreshtoken(context);
        
        Constants.token = await secureStorage.readSecureData('token') ?? '';
        final headers = await DeviceHeaders.getDeviceHeaders();
        
        try{

final Map<String, dynamic> requestBody = {
         "bookingDate": DateFormat("dd-MM-yyyy").format(date),
      "startTime": slot.startTime,
      "endTime": slot.endTime,
      };

    final response = await http.delete(
        Uri.parse("${Constants.baseUrl}/api/v1/admin/deleteslot/$userid"),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              responseData["msg"],
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);

      //  loadInitialData(userid);
 
  notifyListeners();

        // Navigator.pop(context);
      } else {
        print(response.body);  
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        // Navigator.pop(context);
       
      }
    
   } catch(e){
    final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
   }
      } else {
        print(response.body);  
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        // Navigator.pop(context);
       
      }
    
   } catch(e){
    final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
   }
   
  }
 

 Future<void> updateDoctorTiming(String doctorId, String login, String logout, int duration, DateTime date, BuildContext context) async {
  Constants.token = await secureStorage.readSecureData('token') ?? '';
final headers = await DeviceHeaders.getDeviceHeaders();

print(date);
   try{
    
final Map<String, dynamic> requestBody = {
        "loginTime": login,
    "leaveTime": logout,
    "duration": duration,
    "date": formatDate(date.toString()),
      };

      print(requestBody);

    final response = await http.put(
        Uri.parse("${Constants.baseUrl}/api/v1/admin/updatedoctortime/$doctorId"),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        addingoutvisit = false;
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'Timing Updated successfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);
        // loadInitialData(doctorId, date);
        loadByDate(date, doctorId,context);
       
 
  notifyListeners();

        // Navigator.pop(context);
      } else if(response.statusCode == 401){

        await refreshtoken(context);

         Constants.token = await secureStorage.readSecureData('token') ?? '';
final headers = await DeviceHeaders.getDeviceHeaders();

        try{
final Map<String, dynamic> requestBody = {
        "loginTime": login,
    "leaveTime": logout,
    "duration": duration,
    "date": formatDate(date.toString()),
      };

      print(requestBody);

    final response = await http.put(
        Uri.parse("${Constants.baseUrl}/api/v1/admin/updatedoctortime/$doctorId"),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.token}',
          'Content-Type': 'application/json',
          ...headers,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        addingoutvisit = false;
        // Successful POST request, handle the response here
        final responseData = jsonDecode(response.body);
        print(responseData);
        notifyListeners();

        final sucessSnackbar = SnackBar(
            backgroundColor: Colors.green[400],
            content: Text(
              'Timing Updated successfully',
              style: TextStyle(color: Colors.grey[50]),
            ));

        ScaffoldMessenger.of(context).showSnackBar(sucessSnackbar);
        // loadInitialData(doctorId, date);
        loadByDate(date, doctorId, context);
       
 
  notifyListeners();

        // Navigator.pop(context);
      } else {
        print(response.body);  
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        // Navigator.pop(context);
        addingoutvisit = false;
      }
    
   } catch(e){
    final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
   }
      }
       else {
        print(response.body);  
        final responseData = jsonDecode(response.body);
        final snackbar = SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData["msg"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        // Navigator.pop(context);
        addingoutvisit = false;
      }
    
   } catch(e){
    final error = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(error);
   }

  
}

Future<void> gettodaysappointments(BuildContext context) async {
    String url = "${Constants.baseUrl}/api/v1/admin/gettodaysappointments";

    Constants.token = await secureStorage.readSecureData('token') ?? '';
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
       
        todaysappointments =
            json.decode(response.body)['appointments'].cast<Map<String, dynamic>>();
        print('todays appointments : $todaysappointments');

        notifyListeners();
      } else if(response.statusCode == 401){
        await refreshtoken(context);

            Constants.token = await secureStorage.readSecureData('token') ?? '';

        try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Constants.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
       
        todaysappointments =
            json.decode(response.body)['appointments'].cast<Map<String, dynamic>>();
        print('todays appointments : $todaysappointments');

        notifyListeners();
      } else if (response.statusCode == 404) {
        print('No visits found');
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
      }
      
       else if (response.statusCode == 404) {
        print('No visits found');
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  
  Future<void> refreshtoken(BuildContext context) async {
    try {
      Constants.refreshtoken = await secureStorage.readSecureData('refreshtoken') ?? '';

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/v1/admin/refreshtokenadminmobile'),
        headers: <String, String>{
          'Authorization': 'Bearer ${Constants.refreshtoken}',
          'Content-Type': 'application/json',
          // ...headers,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await secureStorage.writeSecureData('token', responseData['token']);
        await secureStorage.writeSecureData('refreshtoken', responseData['refreshToken']);
        Constants.token = responseData['token'];
        Constants.refreshtoken = responseData['refreshToken'];
        print("Constants.doctortoken ${Constants.token}");
        print("Constants.doctorrefreshtoken ${Constants.refreshtoken}");

      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Only logout on auth errors
        await secureStorage.deleteSecureData('token');
        await secureStorage.deleteSecureData('refreshtoken');
        Constants.token = '';
        Constants.refreshtoken = '';
        if (context.mounted) context.router.popAndPush(SplashRoute());

      } else {
        // 500 or any other error — DO NOT logout, just print
        print("Refresh failed with status: ${response.statusCode} — ${response.body}");
      }

//       if (response.statusCode == 200) {
//        print(response.body);
//         final responseData = jsonDecode(response.body);
// await secureStorage.writeSecureData('token', responseData['token']);
//         await secureStorage.writeSecureData('refreshtoken', responseData['refreshToken']);
//         await secureStorage.readSecureData('token').then((value) {
//           Constants.token = value;
//         });

//   await secureStorage.readSecureData('refreshtoken').then((value) {
//           Constants.refreshtoken = value;
//         });
//         print("Constants.admintoken ${Constants.token}");
//         print("Constants.adminrefreshtoken ${Constants.refreshtoken}");


//         notifyListeners();
//       } else {
//         print(response.body);
//         final responseData = jsonDecode(response.body);
//          secureStorage.deleteSecureData('token');
//         secureStorage.deleteSecureData('refreshtoken');
//         print("token : ${Constants.token}");
//         print("refresh token : ${Constants.refreshtoken}");
//         context.router.popAndPush(SplashRoute());
       
//       }


    } catch (e) {
      final error = SnackBar(content: Text(e.toString()));
    }
  }
  
 void invalidateCache({String? key}) {
    if (key != null) {
      _cache.invalidate(key);
    } else {
      _cache.invalidateAll(); // Clears everything
    }
  }

  void notify() {
    notifyListeners();
  }
}
