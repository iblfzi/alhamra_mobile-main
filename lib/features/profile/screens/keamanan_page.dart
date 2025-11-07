import 'package:alhamra_1/core/utils/app_styles.dart';
import 'package:flutter/material.dart';

class KeamananPage extends StatelessWidget {
  const KeamananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Keamanan'),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Ubah Kata Sandi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/ubah-kata-sandi');
            },
          ),
        ],
      ),
    );
  }
}