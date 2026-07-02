import 'package:admin_mobile_application/provider/adminProvider.dart';
import 'package:admin_mobile_application/theme/app_colors.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

@RoutePage()
class EditPatientAdminPage extends StatefulWidget {
  const EditPatientAdminPage({super.key, required this.patientId});

  final String patientId;

  @override
  State<EditPatientAdminPage> createState() => _EditPatientAdminPageState();
}

class _EditPatientAdminPageState extends State<EditPatientAdminPage> {
  late Future fetchpatient;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final formkey = GlobalKey<FormState>();

  String formatedJoiDate = '';
  String formatedJoiPreviousDate = '';

  Map<String, dynamic>? _patientData;

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
    return formattedDate;
  }

  String? newSelectedGender;

  final List<String> _genderOptions = [
    'male',
    'female',
    'transgender',
    'other'
  ];
  String? _selectedGender;

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
  void initState() {
    super.initState();
    AdminPageProvider adminprovider =
        context.read<AdminPageProvider>();
    fetchpatient = adminprovider.getpatient(widget.patientId, context).then((_) {
      if (adminprovider.patientdetails.isNotEmpty) {
        final data = adminprovider.patientdetails.first;
        // print(data);
        _patientData = data;
        _nameController.text = data["name"] ?? "";
        formatedJoiPreviousDate = data["DOB"] ?? "";
        _dobController.text = formatDate(data["DOB"] ?? "");
        formatedJoiDate = data["DOB"] ?? "";
        _selectedGender = data["gender"];
        _emailController.text = data["email"] ?? "";
        _ageController.text = calculateAge(DateTime.parse(data["DOB"] ?? ""));
        // _ageController.text = data["age"] ?? "";
        _phoneController.text = (data["phone"] ?? "").toString();
      }
    });
  }

  // Shimmer skeleton widget
  Widget _buildShimmerSkeleton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field shimmer
            _buildShimmerField(),
            const SizedBox(height: 16),
            
            // Email field shimmer
            _buildShimmerField(),
            const SizedBox(height: 16),
            
            // Phone field shimmer
            _buildShimmerField(),
            const SizedBox(height: 16),
            
            // DOB field shimmer
            _buildShimmerField(),
            const SizedBox(height: 16),
            
            // Gender field shimmer
            _buildShimmerField(),
            const SizedBox(height: 16),
            
            // Age field shimmer
            _buildShimmerField(),
            const SizedBox(height: 32),
            
            // Button shimmer
            _buildShimmerButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label shimmer
        Container(
          height: 16,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        // Field shimmer
        Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[200]!),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerButton() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            "Edit Patient",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
        ),
        // body: 
        // Center(child: Text("data"),),);
        body: Consumer<AdminPageProvider>(
          builder: (context, adminprovider, child) {
            return FutureBuilder(
              future: fetchpatient,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show shimmer skeleton instead of CircularProgressIndicator
                  return _buildShimmerSkeleton();
                } else {
                  return Container(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Form(
                        key: formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Name of the Patient*',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _nameController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9 ]'),
                                )
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter name';
                                }
                                return null;
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter email',
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Phone number of the patient*',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                            lastDate: DateTime.now());

                                        if (pickedDate != null) {
                                          print(pickedDate);
                                          String formattedDate =
                                              DateFormat('dd/MM/yyyy')
                                                  .format(pickedDate);
                                          print(formattedDate);
                                          _dobController.text = formattedDate;
                                          formatedJoiDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);

                                         String age = calculateAge(pickedDate);
                                          _ageController.text = age;
                                        } else {}
                                      },
                                      child:
                                          Icon(Icons.calendar_month_outlined)),
                                ),
                                border: OutlineInputBorder(),
                                hintText: 'Enter DOB',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter DOB';
                                }
                                return null;
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
                              value: _selectedGender,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                hintText: 'Select gender of the patient',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 15),
                              ),
                              validator: (value) => value == null
                                  ? 'Please select gender of the patient'
                                  : null,
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                  newSelectedGender = newValue;
                                  print(_selectedGender);
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
                            // TextFormField(
                            //   readOnly: true,
                            //   controller: _ageController,
                            //   decoration: const InputDecoration(
                            //     border: OutlineInputBorder(),
                            //     hintText: 'Enter Age',
                            //   ),
                            // ),
                            TextFormField(
                              readOnly: true,
                              controller: _ageController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: _ageController.text,
                                // hintStyle: TextStyle(color: Colors.black)
                              ),
                            ),
                            const SizedBox(height: 32),
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
                                  backgroundColor: adminprovider.editingpatient ? const WidgetStatePropertyAll(Colors.grey):
                                      const WidgetStatePropertyAll(Colors.transparent),
                                      shadowColor: WidgetStatePropertyAll(Colors.transparent),
                                  shape: const WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(14)),
                                    ),
                                  ),
                                ),
                                onPressed:adminprovider.editingpatient? null : () async {
                                  if (formkey.currentState!.validate()) {
                                    setState(() {
                                      adminprovider.editingpatient = true;
                                    });
                                    await adminprovider.editpatient(
                                      widget.patientId,
                                      _nameController.text,
                                      formatedJoiDate,
                                      newSelectedGender ?? _selectedGender!,
                                      _emailController.text,
                                      _phoneController.text,
                                      context,
                                    );

                                    await adminprovider.getPatientsByPage(1, context);

                                    // patientpageprovider.notify();
                                  }
                                },
                                child:adminprovider.editingpatient? CircularProgressIndicator(): const Text(
                                  'Edit Patient',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ));
  }
}
