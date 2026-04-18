# FitTracker 🏃‍♂️

FitTracker is a comprehensive Flutter-based mobile application designed for fitness tracking with a role-based access structure for both Clients and Administrators. The app incorporates modern, immersive UI experiences utilizing a custom dark theme and integrates with local database (SQLite) for rapid, offline-capable storage.

## ✨ Features

Based on the project's architecture, FitTracker supports the following functionalities:

**User Account Management**
- 🛡️ **Role-Based Access**: Specialized interfaces and routing for Clients and Admins.
- 🔐 **Authentication Flows**: Secure login and registration sequences for all user types.
- 👤 **Client Profile Setup**: Comprehensive profile configuration options utilizing device media storage (`image_picker`) for avatars and personalized settings.

**Client Features (`Client Dashboard`)**
- 📊 **Fitness Tracking Dashboard**: Centralized hub where clients oversee their fitness goals, track their progress, and visualize metrics.
- 🎨 **Immersive UI/UX**: Designed exclusively with a sleek dark mode. The application runs strictly in Portrait orientation for optimized usage and uses an immersive status bar. 

**Admin Features (`Admin Control Panel`)**
- 👨‍💻 **User Management Dashboard**: Exclusive admin view compiling a list of all registered clients on the platform.
- 🔍 **Detailed Records**: Deeper functionality extending into individual client profiles via the *Admin User Detail* screen, granting the administrator control and oversight of client activity and configurations.
- 🔑 **Admin Authentication**: Distinct login portal segregating admin authority from ordinary users.

**Technical Highlights**
- 💾 **Local Database**: Integration of `sqflite` for robust, persistent on-device data storage.
- 🖼️ **Asset Management**: Full implementation of dynamic fonts leveraging `google_fonts`.

---

## 🛠️ Prerequisites

To successfully configure, run, or build this application, you will need the following tools set up in your working environment:

- **Flutter SDK**: Ensure you are using a compatible up-to-date version. 
  *(Defined environment dictates Dart SDK range `^3.11.3`)*
  [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** or **Visual Studio Code**: Ensure necessary Flutter & Dart extensions are installed.
- **Java SDK**: Minimum version 11 required to build the APK.
- **Android Emulator** or a Physical Android Device to run the build.

---

## 🚀 How to Run Locally

To test the application in a development environment:

1. Clone or download the repository to your local machine.
2. Open your terminal or command prompt in the root of the project directory.
3. Install the dependencies by running:
   ```bash
   flutter pub get
   ```
4. Start an emulator or plug in your physical device.
5. Run the application:
   ```bash
   flutter run
   ```

---

## 📦 How to Build the App (APK Generation)

To package the app for distribution or installation on your own Android device, execute the following specific build commands.

1. Ensure your terminal path is located at the project root (`d:\Mobile App` or equivalent).
2. Fetch dependencies (if not done already):
   ```bash
   flutter pub get
   ```
3. Run the Flutter build protocol:
   ```bash
   flutter build apk
   ```
   *Note: If you need a split APK per ABI (reduces APK size depending on the device architecture), use:*
   ```bash
   flutter build apk --split-per-abi
   ```
4. **Locate the Output**:
   Once the process completes (which will include tasks like `assembleRelease` and tree-shaking icons), the final installer will be exported to:
   > `<project_root>\build\app\outputs\flutter-apk\app-release.apk`
   
You can transfer this `.apk` file to any Android device to initiate software installation directly.

---

## 📂 Key Project Structure

A quick overview of important directories relative to the source code:

- `lib/main.dart` - Essential initialization wrapper, controls immersive system UI overlays, portrait orientations, and application bootstrapping.
- `lib/theme/` - Contains definitions for customized UI aesthetics, such as `AppTheme.darkTheme`.
- `lib/screens/` - Houses the respective view controllers distinguishing Admin and Client functionalities.