import 'package:flutter/material.dart';
import 'search_overlay_widget.dart';
import 'student_selector_widget.dart';

/// Mixin that provides standardized student selection functionality
/// Use this mixin in any StatefulWidget that needs student selection
mixin StudentSelectionMixin<T extends StatefulWidget> on State<T> {
  
  // Default student data - can be overridden
  String get selectedStudent => _selectedStudent;
  List<String> get students => _students;
  bool get isStudentOverlayVisible => _studentOverlayVisible;
  
  String _selectedStudent = 'Naufal Ramadhan';
  final List<String> _students = [
    'Naufal Ramadhan',
    'Aisyah Zahra',
  ];
  bool _studentOverlayVisible = false;

  // Default avatar URL - can be overridden
  String get studentAvatarUrl => 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  /// Override this method to customize student list
  void initializeStudents(List<String> studentList, {String? initialStudent}) {
    _students.clear();
    _students.addAll(studentList);
    if (initialStudent != null && studentList.contains(initialStudent)) {
      _selectedStudent = initialStudent;
    }
  }

  /// Toggle student overlay visibility
  void toggleStudentOverlay() {
    setState(() {
      _studentOverlayVisible = !_studentOverlayVisible;
    });
  }

  /// Handle student selection
  void onStudentSelected(String student) {
    setState(() {
      _selectedStudent = student;
      _studentOverlayVisible = false;
    });
    // Override this method to add custom logic when student is selected
    onStudentChanged(student);
  }

  /// Override this method to handle student change events
  void onStudentChanged(String student) {
    // Default implementation does nothing
    // Override in your widget to add custom logic
  }

  /// Build the student selector widget
  Widget buildStudentSelector({
    String? customAvatarUrl,
    String buttonText = 'Ganti',
    IconData buttonIcon = Icons.swap_horiz,
  }) {
    return StudentSelectorWidget(
      selectedStudent: _selectedStudent,
      onTap: toggleStudentOverlay,
      avatarUrl: customAvatarUrl ?? studentAvatarUrl,
      buttonText: buttonText,
      buttonIcon: buttonIcon,
    );
  }

  /// Build the student overlay widget
  Widget buildStudentOverlay({
    String title = 'Pilih Santri',
    String searchHint = 'Cari santri...',
    String? customAvatarUrl,
  }) {
    return SearchOverlayWidget(
      isVisible: _studentOverlayVisible,
      title: title,
      items: _students,
      selectedItem: _selectedStudent,
      onItemSelected: onStudentSelected,
      onClose: toggleStudentOverlay,
      searchHint: searchHint,
      avatarUrl: customAvatarUrl ?? studentAvatarUrl,
    );
  }

  /// Build the complete student selection UI (selector + overlay)
  Widget buildStudentSelectionUI({
    String? customAvatarUrl,
    String buttonText = 'Ganti',
    IconData buttonIcon = Icons.swap_horiz,
    String overlayTitle = 'Pilih Santri',
    String searchHint = 'Cari santri...',
  }) {
    return Stack(
      children: [
        buildStudentSelector(
          customAvatarUrl: customAvatarUrl,
          buttonText: buttonText,
          buttonIcon: buttonIcon,
        ),
        if (_studentOverlayVisible)
          buildStudentOverlay(
            title: overlayTitle,
            searchHint: searchHint,
            customAvatarUrl: customAvatarUrl,
          ),
      ],
    );
  }
}
