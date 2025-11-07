import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_styles.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isBackPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background with curved shape
          ClipPath(
            clipper: OnboardClipper(),
            child: Container(
              height: AppStyles.getResponsiveHeight(context, 0.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppStyles.primaryColor, AppStyles.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/gambar/overlay.png'),
                  fit: BoxFit.cover,
                  opacity: 0.4,
                ),
              ),
            ),
          ),
          // PageView for onboarding content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    buildOnboardPage(
                      constraints: constraints,
                      imagePath: 'assets/gambar/welcome1.png',
                      title: 'Selamat Datang',
                      description:
                          'Selamat datang di aplikasi IBS Al-Hamra, sistem digital yang menghubungkan orang tua dengan pesantren. Aplikasi ini memudahkan Anda untuk memantau perkembangan dan aktivitas anak secara langsung selama berada di lingkungan pesantren.',
                    ),
                    buildOnboardPage(
                      constraints: constraints,
                      imagePath: 'assets/gambar/welcome2.png',
                      title: 'Aktivitas Anak',
                      description:
                          'Pantau kegiatan harian anak, absensi, serta keikutsertaannya dalam kegiatan pesantren dengan mudah. Semua informasi disajikan secara real-time dan terstruktur agar orang tua selalu merasa dekat dan terinformasi.',
                    ),
                    buildOnboardPage(
                      constraints: constraints,
                      imagePath: 'assets/gambar/welcome3.png',
                      title: ' Akademik & Keuangan',
                      description:
                          'Lihat perkembangan akademik, nilai, serta laporan disiplin anak. Aplikasi ini juga menyediakan akses ke informasi tabungan dan tanggungan biaya yang tercatat secara transparan.',
                    ),
                    buildOnboardPage(
                      constraints: constraints,
                      imagePath: 'assets/gambar/welcome4.png',
                      title: 'Mulai Sekarang',
                      description:
                          'Gunakan akun yang diberikan oleh admin untuk login. Jika Anda mengalami kendala seperti lupa password atau belum menerima akun, hubungi admin melalui WhatsApp di 0894-8347-387.',
                    ),
                  ],
                );
              },
            ),
          ),
          // Top buttons (Back and Skip) - Placed after PageView to be clickable
          Positioned(
            top: AppStyles.getStatusBarHeight(context) + 16,
            left: AppStyles.getResponsiveSpacing(context),
            right: AppStyles.getResponsiveSpacing(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(
                    'Lewati',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AppStyles.getResponsiveFontSize(
                        context,
                        small: 13.0,
                        medium: 14.0,
                        large: 15.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom controls (dots and buttons)
          Positioned(
            bottom: AppStyles.getResponsiveSpacing(
              context,
              small: 32.0,
              medium: 36.0,
              large: 40.0,
            ),
            left: AppStyles.getResponsiveSpacing(context),
            right: AppStyles.getResponsiveSpacing(context),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(
                        horizontal: AppStyles.getResponsiveSpacing(
                          context,
                          small: 3.0,
                          medium: 4.0,
                          large: 4.0,
                        ),
                      ),
                      height: AppStyles.getResponsiveFontSize(
                        context,
                        small: 6.0,
                        medium: 7.0,
                        large: 8.0,
                      ),
                      width: _currentPage == index
                          ? AppStyles.getResponsiveFontSize(
                              context,
                              small: 20.0,
                              medium: 22.0,
                              large: 24.0,
                            )
                          : AppStyles.getResponsiveFontSize(
                              context,
                              small: 6.0,
                              medium: 7.0,
                              large: 8.0,
                            ),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppStyles.primaryColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  height: AppStyles.getResponsiveSpacing(
                    context,
                    small: 24.0,
                    medium: 28.0,
                    large: 30.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      GestureDetector(
                        onTapDown: (_) => setState(() => _isBackPressed = true),
                        onTapUp: (_) => setState(() => _isBackPressed = false),
                        onTapCancel: () =>
                            setState(() => _isBackPressed = false),
                        onTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          transform: Matrix4.identity()
                            ..scale(_isBackPressed ? 0.95 : 1.0),
                          child: OutlinedButton(
                            onPressed: null, // Handled by GestureDetector
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppStyles.getCardBorderRadius(context),
                                ),
                              ),
                              side: BorderSide(
                                color: AppStyles.primaryColor,
                                width: 0.5,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppStyles.getResponsiveSpacing(
                                  context,
                                  small: 24.0,
                                  medium: 28.0,
                                  large: 30.0,
                                ),
                                vertical: AppStyles.getResponsiveSpacing(
                                  context,
                                  small: 10.0,
                                  medium: 11.0,
                                  large: 12.0,
                                ),
                              ),
                            ),
                            child: Text(
                              'Kembali',
                              style: GoogleFonts.poppins(
                                color: AppStyles.primaryColor,
                                fontSize: AppStyles.getResponsiveFontSize(
                                  context,
                                  small: 14.0,
                                  medium: 15.0,
                                  large: 16.0,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: AppStyles.getResponsiveWidth(context, 0.2),
                      ), // Placeholder to keep space
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < 3) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        } else {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppStyles.getCardBorderRadius(context),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppStyles.getResponsiveSpacing(
                            context,
                            small: 32.0,
                            medium: 36.0,
                            large: 40.0,
                          ),
                          vertical: AppStyles.getResponsiveSpacing(
                            context,
                            small: 12.0,
                            medium: 13.0,
                            large: 14.0,
                          ),
                        ),
                      ),
                      child: Text(
                        _currentPage < 3 ? 'Lanjut' : 'Mulai',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: AppStyles.getResponsiveFontSize(
                            context,
                            small: 14.0,
                            medium: 15.0,
                            large: 16.0,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOnboardPage({
    required BoxConstraints constraints,
    required String imagePath,
    required String title,
    required String description,
  }) {
    // Calculate available height for content
    final availableHeight = constraints.maxHeight;
    final imageSize = availableHeight * 0.25; // 25% of available height
    final topSpacing = availableHeight * 0.08; // 8% for top spacing
    final bottomSpacing = availableHeight * 0.20; // 20% for bottom controls
    
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: AppStyles.getResponsivePadding(context),
            child: Column(
              children: [
                SizedBox(height: topSpacing),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: AppStyles.getResponsiveFontSize(
                      context,
                      small: 20.0,
                      medium: 24.0,
                      large: 26.0,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: AppStyles.getResponsiveSpacing(
                    context,
                    small: 16.0,
                    medium: 20.0,
                    large: 24.0,
                  ),
                ),
                Container(
                  height: imageSize.clamp(150.0, 250.0),
                  width: imageSize.clamp(150.0, 250.0),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      height: imageSize.clamp(150.0, 250.0) * 1.1,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppStyles.getResponsiveSpacing(
                    context,
                    small: 24.0,
                    medium: 32.0,
                    large: 40.0,
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppStyles.getResponsiveSpacing(
                        context,
                        small: 24.0,
                        medium: 32.0,
                        large: 40.0,
                      ),
                    ),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade700,
                        fontSize: AppStyles.getResponsiveFontSize(
                          context,
                          small: 12.0,
                          medium: 14.0,
                          large: 15.0,
                        ),
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: bottomSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardClipper extends CustomClipper<Path> {
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


