import 'package:alhamra_1/core/utils/app_styles.dart';
import 'package:alhamra_1/features/shared/widgets/custom_button.dart';
import 'package:alhamra_1/features/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class UbahKataSandiPage extends StatefulWidget {
  const UbahKataSandiPage({super.key});

  @override
  State<UbahKataSandiPage> createState() => _UbahKataSandiPageState();
}

class _UbahKataSandiPageState extends State<UbahKataSandiPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _savePassword() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementasi logika untuk mengubah kata sandi di backend/service
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi berhasil diubah! (Simulasi)'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.greyColor,
      appBar: AppBar(
        title: const Text('Ubah Kata Sandi'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AppStyles.getResponsivePadding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kata Sandi', style: AppStyles.heading2(context)),
              const SizedBox(height: 24),
              _buildPasswordField(
                context: context,
                controller: _oldPasswordController,
                label: 'Password Lama',
                hint: 'Masukkan password lama anda',
                isPasswordVisible: _isOldPasswordVisible,
                onToggleVisibility: () {
                  setState(() => _isOldPasswordVisible = !_isOldPasswordVisible);
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                context: context,
                controller: _newPasswordController,
                label: 'Password Baru',
                hint: 'Masukkan password baru',
                isPasswordVisible: _isNewPasswordVisible,
                onToggleVisibility: () {
                  setState(() => _isNewPasswordVisible = !_isNewPasswordVisible);
                },
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                context: context,
                controller: _confirmPasswordController,
                label: 'Konfirmasi Password Baru',
                hint: 'Masukkan kembali password baru',
                isPasswordVisible: _isConfirmPasswordVisible,
                onToggleVisibility: () {
                  setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                },
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Konfirmasi password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              CustomButton(text: 'Simpan', onPressed: _savePassword),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: hint,
          obscureText: !isPasswordVisible,
          suffixIcon: IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: onToggleVisibility,
          ),
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return '$label tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }
}