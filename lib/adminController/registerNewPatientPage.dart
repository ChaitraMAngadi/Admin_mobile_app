import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/theme/app_colors.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

@RoutePage()
class RegisterNewPatientPage extends StatefulWidget {
  const RegisterNewPatientPage({super.key});

  @override
  State<RegisterNewPatientPage> createState() => _RegisterNewPatientPageState();
}

class _RegisterNewPatientPageState extends State<RegisterNewPatientPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  late String formatedJoiDate;

  final List<String> _genderOptions = [
    'male',
    'female',
    'other'
  ];
  String? _selectedGender;

  String formatJoiDate(String pickedDate) {
    final parsedDate = DateTime.parse(pickedDate); // Parse the ISO 8601 string
    final formattedJoiDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    return formattedJoiDate;
  }

  String calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();

    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (days < 0) {
      final previousMonth = DateTime(today.year, today.month, 0);
      days += previousMonth.day;
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    return '$years year, $months month, $days day';
  }

  @override
  Widget build(BuildContext context) {
    AdminPageProvider adminprovider =
        context.read<AdminPageProvider>();
    return Scaffold(
      backgroundColor: AppColors.badgeBg,
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back,
          color: Colors.white,)),
           flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
          title: Text(
            "Register Patient",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Name of the Patient*',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _nameController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9 ]'),
                      )
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null; // Return null if validation is successful
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter full name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Email of the Patient',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9.@]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null; // No error for empty value
                      }

                       const emailRegex =
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|org|net|edu|gov|in|io|co|me|info|biz|xyz)$';

                      // const emailRegex =
                      //     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                      if (!RegExp(emailRegex).hasMatch(value!)) {
                        return 'Enter a valid email address';
                      }
                      return null; // Return null if the input is valid
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter email',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Phone number of the patient',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    validator: (value) {
                      if (value!.length != 10) {
                        return 'Phone number must be exactly 10 digits';
                      }
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter phone',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Date of Birth of the patient*',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1950),
                                  //DateTime.now() - not to allow to choose before today.
                                  lastDate: DateTime.now());

                              if (pickedDate != null) {
                                print(pickedDate);
                                String formattedDate =
                                    DateFormat('dd/MM/yyyy').format(pickedDate);
                                print(formattedDate);
                                _dobController.text = formattedDate;
                                formatedJoiDate =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);

                                String age = calculateAge(pickedDate);
                                _ageController.text = age;
                                // setState(() {
                                //   dob.text = formattedDate;
                                // });
                              } else {}
                            },
                            child: Icon(Icons.calendar_month_outlined)),
                      ),
                      border: OutlineInputBorder(),
                      hintText: 'Enter DOB',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter DOB';
                      }
                      return null; // Return null if validation is successful
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gender of the patient*',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      hintText: 'Select gender of the patient',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    ),
                    value: _selectedGender,
                    validator: (value) => value == null
                        ? 'Please select gender of the patient'
                        : null,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    items: _genderOptions.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Age of the patient*',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    readOnly: true,
                    controller: _ageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Age',
                    ),
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      gradient: AppColors.primaryGradient,
                    ),
                    child: ElevatedButton(
                      style:  ButtonStyle(
                        padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 14)),
                        backgroundColor: adminprovider.addingpatient? const WidgetStatePropertyAll( Colors.grey):
                            const WidgetStatePropertyAll(Colors.transparent),
                            shadowColor: WidgetStatePropertyAll(Colors.transparent),
                        shape: const WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(14)),
                          ),
                        ),
                      ),
                      onPressed: adminprovider.addingpatient? null: () async {
                        if (formkey.currentState!.validate()) {
                          setState(() {
                            adminprovider.addingpatient = true;
                          });
                          await adminprovider.addpatient(
                              _nameController.text,
                              _phoneController.text,
                              _selectedGender!,
                              _emailController.text,
                              formatedJoiDate,
                              context);

                          await adminprovider.getPatientsByPage(1);

                          // patientpageprovider.notify();
                        }
                      },
                      child:adminprovider.addingpatient? CircularProgressIndicator(): const Text(
                        'Register Patient',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              )),
        ));
  }
}
