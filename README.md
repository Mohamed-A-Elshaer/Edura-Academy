# 📱 Edura Academy

**Edura** is a mobile educational platform that allows instructors to upload and manage courses, while enabling students to browse, watch, and follow courses directly from their smartphones. It aims to simplify access to educational content with a user-friendly interface, organized course structures, and smooth video playback for remote and self-paced learning.

---

## 🧩 Project Overview

Edura enables:

- Instructors to manage and upload educational content.
- Students to learn remotely through mobile devices.
- Smooth video playback with intuitive UI.

---

## 🖥️ Detailed Setup Instructions

### 🪟 Windows Requirements

- Windows 10 or later (64-bit).
- At least 8GB of RAM (16GB recommended).
- 5GB of available disk space.
- Internet connection.

---

## ⚙️ Prerequisites

Before setting up **Edura Academy**, make sure the following are installed:

1. **Flutter SDK** (Compatible with `^3.5.3`) – See `pubspec.yaml` lines 21–22  
2. **Dart SDK** – Comes with Flutter installation  
3. **Git** – For version control ([Download Git](https://git-scm.com))  
4. **Development Environment** (choose one):  
   - Android Studio / IntelliJ IDEA  
   - Visual Studio Code with Flutter extension  
5. **Android SDK** – Required for Android builds:
   - Android Emulator or physical device
   - Minimum SDK version as per project

---

## 🧰 Setup Instructions (Windows)

### 1️⃣ Install Flutter SDK

1. Download from [flutter.dev](https://flutter.dev)  
2. Extract the ZIP to a location (avoid spaces/special characters)  
3. Add `flutter\bin` to your system `PATH`:  
   - Open "Environment Variables"
   - Edit the `PATH` variable and add the Flutter `bin` path  
4. Run the following command to verify installation:

```bash
flutter doctor
2️⃣ Install Git
 1-Download and install from git-scm.com.
 2-Use default installation settings.
3️⃣ Install Android Studio
Download from developer.android.com

During installation, make sure the following are selected:

Android SDK

Android SDK Platform

Android Virtual Device

After installation:

Open Android Studio → File → Settings → Plugins

Search for Flutter → Install (this also installs Dart)

4️⃣ (Optional) Install Visual Studio
Download from visualstudio.microsoft.com

During installation, choose "Desktop development with C++"

5️⃣ Clone the Repository
bash
Copy
Edit
git clone https://github.com/Mohamed-A-Elshaer/Edura-Academy.git
cd Edura-Academy
6️⃣ Install Project Dependencies
bash
Copy
Edit
flutter pub get
Check pubspec.yaml lines 30–56

7️⃣ Run the Application
Connect an Android device or start an emulator

Run:

bash
Copy
Edit
flutter run
🔐 Required Permissions
The app requires the following permissions (check AndroidManifest.xml lines 3–6):

📷 Camera access

💾 Storage access for media files

🌐 Internet access

🛠️ Troubleshooting
1. flutter doctor shows errors
Follow suggestions shown by the command

Make sure environment variables (e.g. PATH) are correctly configured

2. Dependency conflicts
bash
Copy
Edit
flutter clean
flutter pub get
Check version compatibility in pubspec.yaml

3. Firebase configuration issues
Ensure google-services.json or GoogleService-Info.plist is placed in the correct directory

Make sure package name / bundle ID matches your Firebase project

4. Supabase connection errors
Verify Supabase URL and API key in main.dart

Check internet connection and Supabase service status

5. Build fails due to Android SDK issues
Open Android Studio → SDK Manager

Install any missing components

Ensure Android SDK version matches the one used in the project

6. iOS build fails
Update Xcode to the latest version

Run pod install inside the ios/ directory

Make sure your Apple Developer account is set up correctly

7. App crashes on startup
Check logs for specific error messages

Verify Firebase and Supabase configurations are correct


