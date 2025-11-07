import 'package:flutter/material.dart';

import '../../../core/models/nilai_model.dart';
import '../../../core/utils/app_styles.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_card_widget.dart';

class NilaiDetailPage extends StatelessWidget {
  final Subject subject;
  final String studentName;

  const NilaiDetailPage({
    super.key,
    required this.subject,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: subject.name,
        backgroundColor: AppStyles.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildGradeDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return CustomCardWidget(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Nilai',
            style: AppStyles.sectionTitle(context),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'Nama Santri', studentName),
          const Divider(height: 24),
          _buildInfoRow(context, 'Mata Pelajaran', subject.name),
          const Divider(height: 24),
          _buildInfoRow(
            context,
            'Nilai Rata-rata',
            subject.grades.average.toStringAsFixed(1),
            valueColor: AppStyles.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeDetails(BuildContext context) {
    final grades = subject.grades;
    return CustomCardWidget(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Penilaian',
            style: AppStyles.sectionTitle(context),
          ),
          const SizedBox(height: 20),
          _buildGradeItem(
            context,
            icon: Icons.assignment_outlined,
            label: 'Nilai Tugas',
            value: grades.tugas,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildGradeItem(
            context,
            icon: Icons.biotech_outlined,
            label: 'Nilai Praktikum',
            value: grades.praktikum,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildGradeItem(
            context,
            icon: Icons.edit_note_outlined,
            label: 'Nilai UTS',
            value: grades.uts,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildGradeItem(
            context,
            icon: Icons.school_outlined,
            label: 'Nilai UAS',
            value: grades.uas,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.bodyText(context).copyWith(color: Colors.grey[600])),
        Text(
          value,
          style: AppStyles.bodyText(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeItem(BuildContext context, {required IconData icon, required String label, int? value, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.w500)),
        ),
        Text(
          value?.toString() ?? 'N/A',
          style: AppStyles.heading2(context).copyWith(fontSize: 22, color: value != null ? Colors.black87 : Colors.grey),
        ),
      ],
    );
  }
}