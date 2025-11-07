import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:alhamra_1/core/services/odoo_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/auth_provider.dart';
import '../../profile/screens/bantuan_screen.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.greyColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [_buildHeader(context), _buildForm(context)]),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: AppStyles.getResponsiveHeight(context, 0.4),
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppStyles.primaryColor, AppStyles.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: DecorationImage(
            image: AssetImage('assets/gambar/overlay.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: AppStyles.getResponsiveHeight(context, 0.25),
                maxWidth: AppStyles.getResponsiveWidth(context, 0.8),
              ),
              child: Image.asset(
                'assets/logo/splashscreen.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: AppStyles.getResponsiveSpacing(
                context,
                small: 8.0,
                medium: 10.0,
                large: 12.0,
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: AppStyles.getResponsivePadding(
        context,
        small: const EdgeInsets.all(24.0),
        medium: const EdgeInsets.all(28.0),
        large: const EdgeInsets.all(32.0),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan email & password anda.',
              style: AppStyles.bodyText(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: AppStyles.getResponsiveSpacing(
                context,
                small: 24.0,
                medium: 28.0,
                large: 32.0,
              ),
            ),
            Text(
              'Email',
              style: AppStyles.bodyText(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: AppStyles.getResponsiveSpacing(
                context,
                small: 8.0,
                medium: 10.0,
                large: 12.0,
              ),
            ),
            CustomTextField(
              controller: _emailController,
              hintText: 'Masukkan Email Akun Disini',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(
              height: AppStyles.getResponsiveSpacing(
                context,
                small: 20.0,
                medium: 22.0,
                large: 24.0,
              ),
            ),
            Text(
              'Password',
              style: AppStyles.bodyText(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: AppStyles.getResponsiveSpacing(
                context,
                small: 8.0,
                medium: 10.0,
                large: 12.0,
              ),
            ),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Masukkan Password Akun Disini',
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: AppStyles.getResponsiveSpacing(context)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BantuanScreen(),
                    ),
                  );
                },
                child: Text(
                  'Butuh Bantuan?',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: AppStyles.getResponsiveFontSize(context),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: AppStyles.getResponsiveSpacing(
                context,
                small: 24.0,
                medium: 28.0,
                large: 32.0,
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  CustomButton(text: 'Masuk', onPressed: () => _login(context)),
                  SizedBox(height: AppStyles.getResponsiveSpacing(context)),
                  CustomButton(
                    text: 'Adukan Keluhan',
                    onPressed: () => _showContactOptions(context),
                    color: Colors.white,
                    textColor: AppStyles.primaryColor,
                    icon: Icons.support_agent,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        try {
          final odoo = OdooApiService();
          final result = await odoo.login(_emailController.text, _passwordController.text);
          // Simpan session_id dan siswa_id ke key yang juga dipakai oleh PaymentPage
          final prefs = await SharedPreferences.getInstance();
          final sessionFromPrefs = prefs.getString('odoo_session_id');
          if (sessionFromPrefs != null && sessionFromPrefs.isNotEmpty) {
            await prefs.setString('session_id', sessionFromPrefs);
          }
          final siswaId = result['siswa_id'];
          if (siswaId != null) {
            await prefs.setString('siswa_id', siswaId.toString());
          }

          // Set default selected student name di provider dari anak pertama
          try {
            final children = await odoo.getChildren();
            if (children.isNotEmpty) {
              final first = children.first;
              final studentName = (first['name'] ?? first['nama'] ?? '').toString();
              if (studentName.isNotEmpty) {
                // ignore: use_build_context_synchronously
                context.read<AuthProvider>().selectStudent(studentName);
              }
            }
          } catch (_) {}
        } catch (e) {
          // Jika login Odoo gagal, lanjutkan ke home tetapi fitur Tagihan butuh refresh setelah login Odoo berhasil
          // Dapat ditingkatkan dengan menampilkan informasi non-blocking
        }
        Navigator.pushReplacementNamed(context, '/home'); // Navigasi ke HomeScreen
      } else if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Login Gagal',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Text(
                authProvider.errorMessage,
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(
                      color: AppStyles.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            AppStyles.getResponsiveFontSize(
              context,
              small: 20.0,
              medium: 22.0,
              large: 24.0,
            ),
          ),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: AppStyles.getResponsivePadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hubungi Melalui', style: AppStyles.heading2(context)),
              SizedBox(
                height: AppStyles.getResponsiveSpacing(
                  context,
                  small: 20.0,
                  medium: 22.0,
                  large: 24.0,
                ),
              ),
              CustomButton(
                text: 'Whatsapp : 0894-8347-387',
                onPressed: () async {
                  final Uri url = Uri.parse('https://wa.me/628948347387');
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                color: AppStyles.primaryColor,
                icon: FontAwesomeIcons.whatsapp,
              ),
              SizedBox(height: AppStyles.getResponsiveSpacing(context)),
              CustomButton(
                text: 'Telp Biasa : 0894-8347-387',
                onPressed: () async {
                  final Uri url = Uri.parse('tel:08948347387');
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                color: Colors.white,
                textColor: AppStyles.primaryColor,
                icon: Icons.phone,
              ),
            ],
          ),
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
