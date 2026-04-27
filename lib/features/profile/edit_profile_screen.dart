import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_dropdown.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Divyanshu Gupta');
  final TextEditingController _emailController =
      TextEditingController(text: '');
  final TextEditingController _phoneController =
      TextEditingController(text: '');
  final TextEditingController _bioController1 = TextEditingController(
      text: "I don't read news...");
  final TextEditingController _bioController2 = TextEditingController(
      text: 'I conquer 60 words at a time on My Petition');

  String? _selectedState;
  String? _selectedCity;

  // Dummy data for dropdowns
  final List<String> _states = ['Maharashtra', 'Delhi', 'Karnataka', 'Gujarat'];
  final List<String> _cities = ['Mumbai', 'Pune', 'Nagpur', 'New Delhi', 'Bengaluru'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController1.dispose();
    _bioController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          title: 'Edit Profile',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Profile image with edit icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B0000),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.grey200, width: 3),
                  ),
                  child: const Center(
                    child: AppText(
                      title: 'DG',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),

            // Form Fields
            _buildTextField('Full Name', _nameController, hintText: 'Enter your full name'),
            const SizedBox(height: 20),
            _buildTextField('Email Address', _emailController, hintText: 'Enter your email address', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildTextField('Phone Number', _phoneController, hintText: 'Enter your phone number', keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField('State', _selectedState, _states, (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField('City', _selectedCity, _cities, (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField('Bio Line 1', _bioController1, hintText: 'Enter a short bio'),
            const SizedBox(height: 20),
            _buildTextField('Bio Line 2', _bioController2, maxLines: 2, hintText: 'Tell us more about yourself'),

            const SizedBox(height: 50),

            // Save Button
            CustomButton(
              text: 'Save Changes',
              height: 48,
              borderRadius: 12,
              backgroundColor: AppColors.accent,
              onPressed: () {
                // Save logic here
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType? keyboardType, String? hintText}) {
    return CustomTextField(
      label: label,
      hint: hintText ?? '',
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }

  Widget _buildDropdownField(String label, String? selectedValue,
      List<String> items, ValueChanged<String?> onChanged) {
    return SingleSelectionDropdown<String>(
      title: label,
      selectedValue: selectedValue,
      items: items,
      onSelectionChanged: onChanged,
      getId: (s) => s,
      getName: (s) => s,
    );
  }
}

