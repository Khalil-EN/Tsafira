import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../services/api_services.dart';
import '../../widgets/common/app_avatar.dart';


class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  static const Color _blue = Color(0xFF1976D2);
  static const Color _navy = Color(0xFF18335A);

  bool _isSaving = false;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _dateController;

  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(
      text: widget.user['firstName']?.toString() ?? '',
    );

    _lastNameController = TextEditingController(
      text: widget.user['lastName']?.toString() ?? '',
    );

    _emailController = TextEditingController(
      text: widget.user['email']?.toString() ?? '',
    );

    _birthDate = _parseBirthDate(
      widget.user['birthDate'],
    );

    _dateController = TextEditingController(
      text: _birthDate != null
          ? _formatDate(_birthDate!)
          : '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dateController.dispose();

    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: _navy,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: _navy,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            32,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildAvatarPreview(),

              const SizedBox(height: 30),

              _buildProfileField(
                label: 'First Name',
                controller: _firstNameController,
                textInputAction:
                TextInputAction.next,
              ),

              const SizedBox(height: 16),

              _buildProfileField(
                label: 'Last Name',
                controller: _lastNameController,
                textInputAction:
                TextInputAction.next,
              ),

              const SizedBox(height: 16),

              _buildProfileField(
                label: 'Email',
                controller: _emailController,
                keyboardType:
                TextInputType.emailAddress,
                textInputAction:
                TextInputAction.next,
              ),

              const SizedBox(height: 16),

              _buildDateField(),

              const SizedBox(height: 24),

              // Password is deliberately not edited here.
              _buildSecurityTile(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

  // ================================================================
  // AVATAR
  // ================================================================

  Widget _buildAvatarPreview() {
    final profilePicture = widget.user['profilePicture']?.toString();

    return Center(
      child: Stack(
        children: [
          AppAvatar(
            source: profilePicture,
            name: _firstNameController.text,
            radius: 52,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: _blue,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _selectAvatar,
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PROFILE FIELD
  // ================================================================

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _blue,
              ),
            ),
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DATE FIELD
  // ================================================================

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: _dateController,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.calendar_today_outlined,
                color: _blue,
              ),
              onPressed: _selectDate,
            ),
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // SECURITY
  // ================================================================

  Widget _buildSecurityTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.lock_outline,
            color: _blue,
          ),
        ),
        title: const Text(
          'Password & Security',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text(
          'Manage your password separately',
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.black38,
        ),
        onTap: () {
          // Add your change-password screen here.
        },
      ),
    );
  }

  // ================================================================
  // AVATAR SELECTION
  // ================================================================

  Future<void> _selectAvatar() async {
    // Keep this separate from the profile update API.
    //
    // Example future implementation:
    // final selectedAvatar = await showModalBottomSheet<String>(
    //   context: context,
    //   builder: (_) => AvatarPicker(),
    // );
    //
    // Then update the selected avatar in the form state.
  }

  // ================================================================
  // DATE PICKER
  // ================================================================

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final initialDate = _birthDate ??
        DateTime(
          now.year - 18,
          now.month,
          now.day,
        );

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
    );

    if (picked == null) return;

    setState(() {
      _birthDate = picked;
      _dateController.text =
          _formatDate(picked);
    });
  }

  // ================================================================
  // SAVE
  // ================================================================

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields.'),
        ),
      );
      return;
    }

    final updates = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };

    if (_birthDate != null) {
      updates['birthDate'] = _birthDate!.toIso8601String();
    }

    setState(() => _isSaving = true);

    try {
      await AuthService.updateProfile(updates);
      await context.read<UserProvider>().refreshUser();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update profile.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ================================================================
  // DATE HELPERS
  // ================================================================

  DateTime? _parseBirthDate(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
