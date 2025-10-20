import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import '/registration/done/farmer_done.dart';
import '/registration/farmer_tac.dart';

class FarmerRegistration extends StatefulWidget {
  final bool hasAcceptedTerms; // add this

  const FarmerRegistration({super.key, this.hasAcceptedTerms = false});

  @override
  State<FarmerRegistration> createState() => _FarmerRegistrationState();
}

class _FarmerRegistrationState extends State<FarmerRegistration> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zipController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _detailedAddressController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;

  File? _idFrontImage;
  File? _idBackImage;

  List<dynamic> _regions = [];
  List<dynamic> _provinces = [];
  List<dynamic> _cities = [];
  List<dynamic> _barangays = [];

  String? _selectedRegion;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedBarangay;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    final String data = await rootBundle.loadString('assets/address/region.json');
    setState(() {
      _regions = json.decode(data);
    });
  }

  Future<void> _loadProvinces(String regionCode) async {
    final String data = await rootBundle.loadString('assets/address/province.json');
    final List<dynamic> allProvinces = json.decode(data);

    setState(() {
      _provinces = allProvinces
          .where((p) => p['region_code'].toString() == regionCode.toString())
          .toList();
      _selectedProvince = _provinces.isNotEmpty ? _provinces.first['province_code'].toString() : null;
      _cities = [];
      _selectedCity = null;
      _barangays = [];
      _selectedBarangay = null;
    });
  }

  Future<void> _loadCities(String provinceCode) async {
    final String data = await rootBundle.loadString('assets/address/city.json');
    final List<dynamic> allCities = json.decode(data);

    setState(() {
      _cities = allCities
          .where((c) => c['province_code'].toString() == provinceCode.toString())
          .toList();
      _selectedCity = _cities.isNotEmpty ? _cities.first['city_code'].toString() : null;
      _barangays = [];
      _selectedBarangay = null;
    });
  }

  Future<void> _loadBarangays(String cityCode) async {
    final String data = await rootBundle.loadString('assets/address/barangay.json');
    final List<dynamic> allBarangays = json.decode(data);

    setState(() {
      _barangays = allBarangays
          .where((b) => b['city_code'].toString() == cityCode.toString())
          .toList();
      _selectedBarangay = _barangays.isNotEmpty ? _barangays.first['brgy_code'].toString() : null;
    });
  }


  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isFront) {
          _idFrontImage = File(picked.path);
        } else {
          _idBackImage = File(picked.path);
        }
      });
    }
  }

  Future<String> _uploadImage(File file, String userId, String type) async {
    final ref = FirebaseStorage.instance.ref().child('farmer_uploads/$userId/$type.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the Terms & Conditions')),
      );
      return;
    }
    if (_selectedRegion == null ||
        _selectedProvince == null ||
        _selectedCity == null ||
        _selectedBarangay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your complete location')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userId = user.uid;

      String? frontUrl;
      String? backUrl;
      if (_idFrontImage != null) {
        frontUrl = await _uploadImage(_idFrontImage!, userId, 'id_front');
      }
      if (_idBackImage != null) {
        backUrl = await _uploadImage(_idBackImage!, userId, 'id_back');
      }


      // Save to farmer_registration
      await FirebaseFirestore.instance.collection('farmer_registration').doc(userId).set({
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'id_front': frontUrl ?? '',
        'id_back': backUrl ?? '',
        'farm_name': _farmNameController.text.trim(),
        'region': _selectedRegion,
        'province': _selectedProvince,
        'city': _selectedCity,
        'barangay': _selectedBarangay,
        'detailed_address': _detailedAddressController.text.trim(),
        'zip_code': _zipController.text.trim(),
        'userId': userId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'isRegistered': true,
        'role': 'farmer',
        'hasAcceptedTerms': _acceptedTerms,

      });

      // Update user collection
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'status': 'pending',
        'email': _emailController.text.trim(),
        'role': 'farmer',
      }, SetOptions(merge: true));


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FarmerDonePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting registration: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(
          'Farmer Registration',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle('Farmer Information'),
              buildTextField('Full Name', _fullNameController),
              buildTextField('Email', _emailController, type: TextInputType.emailAddress),
              buildTextField('Phone Number', _phoneController, prefixText: '+63', type: TextInputType.phone),
              const SizedBox(height: 10),
              uploadField('ID Front', true),
              uploadField('ID Back', false),
              const SizedBox(height: 20),
              sectionTitle('Farm Information'),
              buildTextField('Farm Name', _farmNameController),

              // Dropdowns wrapped safely to prevent overflow
              LayoutBuilder(
                builder: (context, constraints) {
                  final dropdownWidth = constraints.maxWidth; // safe width
                  return Column(
                    children: [
                      SizedBox(
                        width: dropdownWidth,
                        child: buildDropdownField(
                          hint: 'Region',
                          items: _regions,
                          selectedValue: _selectedRegion,
                          onChanged: (val) {
                            setState(() {
                              _selectedRegion = val;
                              _loadProvinces(val!);
                            });
                          },
                          valueKey: 'region_code',
                          nameKey: 'region_name',
                        ),
                      ),
                      SizedBox(
                        width: dropdownWidth,
                        child: buildDropdownField(
                          hint: 'Province',
                          items: _provinces,
                          selectedValue: _selectedProvince,
                          onChanged: (val) {
                            setState(() {
                              _selectedProvince = val;
                              _loadCities(val!);
                            });
                          },
                          valueKey: 'province_code',
                          nameKey: 'province_name',
                        ),
                      ),
                      SizedBox(
                        width: dropdownWidth,
                        child: buildDropdownField(
                          hint: 'City / Municipality',
                          items: _cities,
                          selectedValue: _selectedCity,
                          onChanged: (val) {
                            setState(() {
                              _selectedCity = val;
                              _loadBarangays(val!);
                            });
                          },
                          valueKey: 'city_code',
                          nameKey: 'city_name',
                        ),
                      ),
                      SizedBox(
                        width: dropdownWidth,
                        child: buildDropdownField(
                          hint: 'Barangay',
                          items: _barangays,
                          selectedValue: _selectedBarangay,
                          onChanged: (val) {
                            setState(() {
                              _selectedBarangay = val;
                            });
                          },
                          valueKey: 'brgy_code',
                          nameKey: 'brgy_name',
                        ),
                      ),
                    ],
                  );
                },
              ),

              buildTextField('Detailed Address', _detailedAddressController),
              buildTextField('ZIP Code', _zipController, type: TextInputType.number),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (val) {
                      setState(() {
                        _acceptedTerms = val!;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FarmerTac(),
                          ),
                        );
                      },
                      child: Text(
                        'I agree to the Terms & Conditions',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'SUBMIT',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: const Color(0xFF1B5E20),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller,
      {TextInputType type = TextInputType.text, String? prefixText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (value) {
          if (value == null || value.isEmpty) return '$hint is required';
          if (hint == 'Email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
            return 'Email is invalid';
          }
          if (hint == 'Phone Number' &&
              (!RegExp(r'^9\d{9}$').hasMatch(value))) {
            return 'Phone number must start with 9 and have 10 digits';
          }
          if (hint == 'ZIP Code' && !RegExp(r'^\d{4}$').hasMatch(value)) {
            return 'ZIP code must be 4 digits';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixText: prefixText,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget buildDropdownField({
    required String hint,
    required List<dynamic> items,
    required String? selectedValue,
    required Function(String?) onChanged,
    String valueKey = 'code',
    String nameKey = 'name',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item[valueKey].toString(), // convert to String
            child: Text(item[nameKey]),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $hint';
          }
          return null;
        },
      ),
    );
  }





  Widget uploadField(String label, bool isFront) {
    File? file = isFront ? _idFrontImage : _idBackImage;
    return GestureDetector(
      onTap: () => _pickImage(isFront),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(file != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                color: file != null ? Colors.green : Colors.grey),
            Text(
              file != null ? '${label} Selected' : 'Upload $label',
              style: GoogleFonts.poppins(color: file != null ? Colors.green : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
