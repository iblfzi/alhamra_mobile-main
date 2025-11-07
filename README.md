# Al-Hamra Mobile App 🕌

A comprehensive mobile application for Islamic boarding school (Pesantren) management, built with Flutter and Firebase. This app serves as a digital platform connecting parents with their children's educational journey at Al-Hamra Islamic Boarding School.

## 📱 Features

### 🏠 **Home Dashboard**
- Personalized greeting with Islamic salutation
- Real-time notifications system
- Quick access to all major features
- Beautiful gradient UI with Islamic aesthetics

### 👨‍👩‍👧‍👦 **Student Management**
- Multiple student profiles per parent account
- Student information cards with photos
- Easy switching between children's profiles
- Comprehensive student data management

### 💰 **Financial Management**
- Digital wallet integration
- Balance checking and top-up functionality
- Transaction history tracking
- Payment processing for school fees

### 📚 **Academic Features**
- **Student Profile**: Complete student information
- **Academic Info**: Course details and schedules
- **Attendance**: Real-time attendance tracking
- **Academic Grades**: Performance monitoring
- **Tahfidz Qur'an**: Quranic memorization progress
- **Tahsin Qur'an**: Quranic recitation improvement
- **Mutabaah**: Daily Islamic practice tracking

### 🏢 **Facilities Information**
- Interactive facility showcase
- Historical mosque information
- Dormitory and building details
- Visual facility tours

### 📰 **News & Updates**
- Latest school announcements
- Event notifications
- Islamic content and articles
- Photo galleries from school activities

### 🔐 **Authentication & Security**
- Firebase Authentication integration
- Secure login system
- Session management
- Data encryption

## 🛠️ Technology Stack

### **Frontend**
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Material Design 3** - Modern UI components
- **Google Fonts** - Typography (Poppins)

### **Backend & Services**
- **Firebase Core** - Backend infrastructure
- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Firebase Realtime Database** - Real-time data sync

### **State Management**
- **Provider** - State management solution
- **Shared Preferences** - Local data persistence

### **UI/UX Libraries**
- **Cached Network Image** - Optimized image loading
- **Loading Animation Widget** - Beautiful loading indicators
- **Awesome Bottom Bar** - Enhanced navigation
- **Font Awesome Flutter** - Icon library
- **Flutter SVG** - Vector graphics support

### **Utilities**
- **Intl** - Internationalization (Indonesian locale)
- **URL Launcher** - External link handling

## 📋 Prerequisites

Before running this project, make sure you have:

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (compatible with Flutter version)
- **Android Studio** or **VS Code** with Flutter extensions
- **Firebase Project** with the following services enabled:
  - Authentication
  - Cloud Firestore
  - Realtime Database
- **Android SDK** (API level 23 or higher)
- **iOS Development Tools** (for iOS deployment)

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/alhamra-mobile-app.git
cd alhamra-mobile-app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download and place configuration files:
   - `android/app/google-services.json` (Android)
   - `ios/Runner/GoogleService-Info.plist` (iOS)
4. Update [`firebase_options.dart`](lib/firebase_options.dart) with your project configuration

### 4. Android Setup
1. Update [`android/app/build.gradle.kts`](android/app/build.gradle.kts):
   ```kotlin
   applicationId = "your.package.name"
   ```
2. Ensure minimum SDK version is 23 or higher

### 5. iOS Setup (Optional)
1. Open [`ios/Runner.xcworkspace`](ios/Runner.xcworkspace) in Xcode
2. Update Bundle Identifier
3. Configure signing certificates

### 6. Run the Application
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device_id>
```

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── berita_model.dart    # News model
│   ├── santri_model.dart    # Student model
│   └── user_model.dart      # User model
├── providers/               # State management
│   └── auth_provider.dart   # Authentication provider
├── screens/                 # UI screens
│   ├── splash_screen.dart   # Splash screen
│   ├── onboard_screen.dart  # Onboarding
│   ├── login_screen.dart    # Login interface
│   ├── home_screen.dart     # Main navigation
│   ├── beranda_page.dart    # Dashboard
│   ├── pembayaran_page.dart # Payment screen
│   ├── profil_page.dart     # Profile screen
│   ├── status_page.dart     # Status screen
│   └── bantuan_screen.dart  # Help screen
├── services/                # Business logic
│   ├── auth_service.dart    # Authentication service
│   ├── berita_service.dart  # News service
│   ├── santri_service.dart  # Student service
│   └── seeder_service.dart  # Data seeding
├── utils/                   # Utilities
│   └── app_styles.dart      # App styling constants
└── widgets/                 # Reusable components
    ├── child_info_card.dart # Student info widget
    ├── custom_app_bar.dart  # Custom app bar
    ├── custom_button.dart   # Custom button
    ├── custom_textfield.dart# Custom text field
    ├── profile_list_tile.dart# Profile list item
    └── saldo_card.dart      # Balance card widget
```

## 🎨 Design System

### **Color Palette**
- **Primary**: Blue gradient tones
- **Secondary**: Complementary accent colors
- **Background**: Clean white with subtle shadows
- **Text**: High contrast for accessibility

### **Typography**
- **Font Family**: Poppins (Google Fonts)
- **Weights**: 400 (Regular), 500 (Medium), 600 (SemiBold)
- **Sizes**: Responsive scaling for different screen sizes

### **Components**
- **Cards**: Rounded corners with subtle shadows
- **Buttons**: Material Design 3 styling
- **Icons**: Font Awesome and Material Icons
- **Images**: Cached loading with placeholders

## 🔧 Configuration

### **Environment Variables**
Create a `.env` file in the root directory:
```env
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
```

### **Build Configuration**
- **Minimum SDK**: Android API 23 (Android 6.0)
- **Target SDK**: Latest stable Android API
- **iOS Deployment Target**: iOS 12.0+

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate test coverage
flutter test --coverage
```

## 📦 Building for Production

### **Android APK**
```bash
flutter build apk --release
```

### **Android App Bundle**
```bash
flutter build appbundle --release
```

### **iOS**
```bash
flutter build ios --release
```

## 🤝 Contributing

We welcome contributions to improve the Al-Hamra Mobile App! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### **Code Style Guidelines**
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation (2 spaces)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Development Team**: Flutter Developers
- **UI/UX Design**: Design Team
- **Backend**: Firebase Integration Team
- **QA**: Quality Assurance Team

## 📞 Support

For support and questions:

- **Email**: support@alhamra-app.com
- **Documentation**: [Wiki](https://github.com/yourusername/alhamra-mobile-app/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/alhamra-mobile-app/issues)

## 🔄 Version History

- **v1.0.0** - Initial release with core features
  - Authentication system
  - Student management
  - News and announcements
  - Facility information
  - Basic payment integration

## 🎯 Roadmap

### **Upcoming Features**
- [ ] Push notifications
- [ ] Offline mode support
- [ ] Multi-language support (Arabic, English)
- [ ] Advanced reporting and analytics
- [ ] Video streaming for classes
- [ ] Chat system between parents and teachers
- [ ] Calendar integration
- [ ] Document management system

---

**Made with ❤️ for the Al-Hamra Islamic Boarding School community**

*"And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose."* - Quran 65:3
