import 'package:alhamra_1/core/providers/auth_provider.dart';
import 'package:alhamra_1/core/utils/app_styles.dart';
import 'package:alhamra_1/features/shared/widgets/custom_button.dart';
import 'package:alhamra_1/features/shared/widgets/custom_textfield.dart';
import 'package:alhamra_1/features/shared/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  bool _syncedFromUser = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    if (user != null) _syncedFromUser = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
  

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui! (Simulasi)')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    // Sinkronisasi sekali ketika user tersedia setelah dimuat async
    if (!_syncedFromUser && user != null) {
      _nameController.text = user.fullName;
      _emailController.text = user.email;
      // phoneNumber
      if (user.phoneNumber.isNotEmpty) {
        _phoneController.text = user.phoneNumber;
      }
      _syncedFromUser = true;
    }

    return Scaffold(
      backgroundColor: AppStyles.greyColor,
      appBar: AppBar(
        title: const Text('Edit Akun'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AppStyles.getResponsivePadding(context),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfilePictureEditor(context),
              const SizedBox(height: 30),
              _buildTextField(context,
                controller: _nameController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(context,
                controller: _phoneController,
                label: 'Nomor Telepon',
                hint: 'Masukkan nomor telepon',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(context,
                controller: _emailController,
                label: 'Email',
                hint: 'Masukkan email',
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Email biasanya tidak bisa diubah
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Simpan',
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureEditor(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    return UserAvatar(
      user: user,
      radius: 50,
      showEditButton: true,
      onEditTap: () {
        // Implementasi logika untuk memilih gambar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur ganti gambar belum tersedia.')),
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: hint,
          validator: validator,
        ),
      ],
    );
  }
}