import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/app_styles.dart';
import '../widgets/profile_list_tile.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppStyles.greyColor,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppStyles.getResponsivePadding(context),
              children: <Widget>[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppStyles.getCardBorderRadius(context),
                    ),
                  ),
                  child: Padding(
                    padding: AppStyles.getResponsivePadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileInfoRow(
                          context,
                          'Nama Lengkap',
                          user.fullName,
                        ),
                        _buildProfileInfoRow(
                          context,
                          'Email',
                          user.email,
                        ),
                        _buildProfileInfoRow(
                          context,
                          'Jenis Kelamin',
                          user.gender,
                        ),
                        _buildProfileInfoRow(
                          context,
                          'Nomor Telepon',
                          user.phoneNumber,
                        ),
                        _buildProfileInfoRow(
                          context,
                          'Alamat',
                          user.address,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: AppStyles.getResponsiveSpacing(
                    context,
                    small: 20.0,
                    medium: 22.0,
                    large: 24.0,
                  ),
                ),
                ProfileListTile(
                  icon: Icons.exit_to_app,
                  title: 'Logout',
                  color: Colors.redAccent,
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    // Use named route to ensure clean navigation
                    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                      '/login',
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
    );
  }
  

  Widget _buildProfileInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(
          height: AppStyles.getResponsiveSpacing(
            context,
            small: 2.0,
            medium: 3.0,
            large: 4.0,
          ),
        ),
        Text(
          value,
          style: AppStyles.bodyText(context),
        ),
        if (!isLast)
          Divider(
            height: AppStyles.getResponsiveSpacing(
              context,
              small: 20.0,
              medium: 22.0,
              large: 24.0,
            ),
          ),
      ],
    );
  }
}


