import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:table_calendar_example/models/country_code.dart';
import 'package:table_calendar_example/screens/auth/verify_screen.dart';
import 'package:table_calendar_example/services/api_services.dart';
import 'package:table_calendar_example/widgets/common/country_picker_bottom_sheet.dart';
import 'package:table_calendar_example/screens/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _birthDateController = TextEditingController();

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phoneNumber = '';
  String _password = '';
  DateTime? _birthDate;

  bool _obscurePassword = true;
  bool _isRegistering = false;
  String? _selectedAvatar;
  String _errorMessage = '';

  late CountryCode _selectedCountry;

  final List<String> _avatars = List.generate(
    10,
        (index) => 'assets/avatars/avatar_${(index + 1).toString().padLeft(2, '0')}.png',
  );

  @override
  void initState() {
    super.initState();
    _selectedCountry = countryCodes.firstWhere(
          (country) => country.isoCode == 'MA',
      orElse: () => countryCodes.first,
    );
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = '');

    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Please fill in all required fields correctly.');
      return;
    }

    if (_selectedAvatar == null) {
      setState(() => _errorMessage = 'Please choose an avatar.');
      return;
    }

    setState(() => _isRegistering = true);

    final String fullPhoneNumber = _phoneNumber.trim().isEmpty
        ? ''
        : '${_selectedCountry.dialCode}${_phoneNumber.trim()}';
    final email = _email.trim().toLowerCase();

    final String profilePicture =
    _selectedAvatar!.split('/').last.replaceAll('.png', '');

    final Map<String, dynamic> userData = {
      'firstName': _firstName.trim(),
      'lastName': _lastName.trim(),
      'email': email,
      'birthDate': _birthDate != null
          ? DateFormat('yyyy-MM-dd').format(_birthDate!)
          : null,
      'phoneNumber': fullPhoneNumber,
      'password': _password,
      'profilePicture': profilePicture,
    };

    try {
      await AuthService.register(userData);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  Future<void> _showCountryPicker() async {
    final CountryCode? selected = await showModalBottomSheet<CountryCode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CountryPickerBottomSheet(selectedCountry: _selectedCountry),
    );

    if (selected != null) {
      setState(() => _selectedCountry = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 24),
                const Text(
                  'Get Started now',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an account or log in to explore\nour app',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                _buildAuthToggle(),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty) _buildErrorMessage(),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose your avatar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pick an avatar for your profile',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                _buildAvatarGrid(),
                if (_selectedAvatar == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Please choose an avatar',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'First Name',
                        hint: 'Lois',
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                        onChanged: (v) => _firstName = v,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: 'Last Name',
                        hint: 'Becket',
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                        onChanged: (v) => _lastName = v,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Email',
                  hint: 'loisbecket@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  onChanged: (v) => _email = v,
                ),
                const SizedBox(height: 16),
                _buildBirthDateField(),
                const SizedBox(height: 16),
                _buildPhoneField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/nadi_logo.png',
      width: 150,
      height: 120,
      errorBuilder: (_, __, ___) => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.travel_explore, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildAuthToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _avatars.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final avatar = _avatars[index];
        final bool isSelected = _selectedAvatar == avatar;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAvatar = avatar;
              _errorMessage = '';
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                avatar,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String? Function(String?) validator,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        TextFormField(
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth date',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _birthDateController,
          readOnly: true,
          decoration: _inputDecoration('18/03/2000').copyWith(
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          validator: (_) =>
          _birthDate == null ? 'Birth date is required' : null,
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );

            if (pickedDate != null) {
              setState(() {
                _birthDate = pickedDate;
                _birthDateController.text =
                    DateFormat('dd/MM/yyyy').format(pickedDate);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Phone Number',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              '(optional)',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _showCountryPicker,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedCountry.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 5),
                    Text(_selectedCountry.dialCode, style: const TextStyle(fontSize: 13)),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('612 345 678'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final digits = value.replaceAll(RegExp(r'\D'), '');
                  return digits.length < 5 ? 'Enter a valid phone number' : null;
                },
                onChanged: (value) => _phoneNumber = value,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        TextFormField(
          obscureText: _obscurePassword,
          decoration: _inputDecoration('••••••••').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your password';
            if (value.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
          onChanged: (value) => _password = value,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.blue.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _isRegistering ? null : _register,
        child: _isRegistering
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text(
          'Register',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
    );
  }
}