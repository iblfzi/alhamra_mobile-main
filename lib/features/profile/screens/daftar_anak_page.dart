import 'package:alhamra_1/core/models/student_model.dart';
import 'package:alhamra_1/core/providers/auth_provider.dart';
import 'package:alhamra_1/features/shared/widgets/user_avatar.dart';
import 'package:alhamra_1/core/services/student_service.dart';
import 'package:alhamra_1/core/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class DaftarAnakPage extends StatefulWidget {
  const DaftarAnakPage({super.key});

  @override
  State<DaftarAnakPage> createState() => _DaftarAnakPageState();
}

class _DaftarAnakPageState extends State<DaftarAnakPage> {
  final StudentService _studentService = StudentService();
  List<StudentModel> _students = [];
  List<StudentModel> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStudents);
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStudents);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      // Fetch using Bearer token via StudentService (REST). Pass orangtuaId if available, otherwise 0 (ignored by service).
      final students = await _studentService.getStudentsByParent(user?.orangtuaId ?? 0);
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false;
      });
      // Set default selected child to the first item if none selected or selection invalid
      if (students.isNotEmpty) {
        final current = authProvider.selectedStudent;
        final exists = students.any((s) => s.name == current);
        if (!exists) {
          authProvider.selectStudent(students.first.name);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students
          .where((student) => 
              student.name.toLowerCase().contains(query) ||
              student.displayId.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan listen: true agar UI di sini juga ikut update jika ada perubahan
    final authProvider = Provider.of<AuthProvider>(context);
    final parentName = authProvider.user?.fullName ?? 'Nama Orang Tua';

    return Scaffold(
      backgroundColor: AppStyles.greyColor,
      appBar: AppBar(
        title: const Text('Daftar Anak'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AppStyles.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParentInfoCard(context, parentName, authProvider.selectedStudent),
            const SizedBox(height: 24),
            _buildSearchBar(context),
            const SizedBox(height: 16),
            _buildStudentList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildParentInfoCard(BuildContext context, String parentName, String selectedStudent) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.getCardBorderRadius(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            UserAvatar(
              user: Provider.of<AuthProvider>(context, listen: false).user,
              radius: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parentName, style: AppStyles.bodyText(context).copyWith(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Tuliskan apa yang anda cari . . .',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.getCardBorderRadius(context)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildStudentList(BuildContext context) {
    // Show loading indicator
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error message
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppStyles.bodyText(context).copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStudents,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state
    if (_filteredStudents.isEmpty) {
      // Check if it's because of search or truly empty
      final isSearching = _searchController.text.isNotEmpty;
      
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.people_outline,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                isSearching 
                    ? 'Tidak ada hasil pencarian'
                    : 'Belum Ada Data Anak',
                style: AppStyles.bodyText(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSearching
                    ? 'Coba kata kunci lain untuk mencari'
                    : 'Akun Anda belum memiliki data anak yang terdaftar.\n\nSilakan hubungi admin pesantren untuk menambahkan data anak Anda.',
                textAlign: TextAlign.center,
                style: AppStyles.bodyText(context).copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (!isSearching) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadStudents,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Muat Ulang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Show student list
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentSelectedStudent = Provider.of<AuthProvider>(context).selectedStudent;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return _StudentListItem(
          student: student,
          currentSelectedStudent: currentSelectedStudent,
          onSelect: (selectedName) async {
            // Simpan nama untuk tampilan
            authProvider.selectStudent(selectedName);
            // Simpan siswa_id agar halaman Tagihan memakai anak terpilih
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('siswa_id', student.id.toString());
            } catch (_) {}
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$selectedName dipilih sebagai anak aktif.')),
              );
              Navigator.of(context).pop(true);
            }
          },
        );
      },
    );
  }
}

class _StudentListItem extends StatelessWidget {
  final StudentModel student;
  final String? currentSelectedStudent;
  final ValueChanged<String> onSelect;

  const _StudentListItem({required this.student, this.currentSelectedStudent, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(student.name, style: AppStyles.bodyText(context)),
        subtitle: Text('ID: ${student.displayId}${student.className != null ? " • ${student.className}" : ""}', style: AppStyles.bodyText(context).copyWith(color: Colors.grey[600])),
        trailing: Radio<String>(value: student.name, groupValue: currentSelectedStudent, onChanged: (value) => onSelect(student.name), activeColor: AppStyles.primaryColor),
        onTap: () => onSelect(student.name),
      ),
    );
  }
}