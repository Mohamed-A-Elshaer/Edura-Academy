#Project overview :
  The project, titled Edura, is a mobile educational platform that allows instructors to upload and manage courses, while enabling students to browse, watch, and follow courses directly from their smartphones. The application aims to simplify access to educational content, offering a user-friendly interface, organized course structures, and smooth video playback to support remote and self-paced learning.
#Detailed Setup Instructions :
  Windows:
   Windows 10 or later (64-bit).
   At least 8GB of RAM (16GB recommended).
   5GB of available disk space.
   Internet connection.
#Prerequisites:
  Before setting up Edura Academy, you need to install the following software:
    1-Flutter SDK (version compatible with SDK ^3.5.3) pubspec.yaml:21-22.
    3-Dart SDK - This comes with Flutter installation.   
    2-Git for version control.
    3-Development Environment:
      Android Studio/IntelliJ IDEA, or
 Visual Studio Code with Flutter extension. 
    4-Android SDK (for Android development)
    Minimum SDK version as per project requirements.
    Android emulator or physical device for testing.
 #Setup Instructions for Windows:
1. Install Flutter SDK
    1-Download Flutter SDK from flutter.dev.
    2-Extract the zip file to a desired location (avoid paths with spaces or special characters).
    3-Add Flutter to your PATH:
       Search for "Environment Variables" in Windows search
Add the flutter\bin directory to your PATH variable.
    4-Verify installation by running:
        flutter doctor
2.Install Git
  1-Download and install Git from git-scm.com.
  2-Use default settings during installation.
3.Install Android Studio
  1-Download and install Android Studio from developer.android.com.
  2-During installation, ensure "Android SDK", "Android SDK Platform", and "Android Virtual Device" are selected.
  3-Launch Android Studio and complete the setup wizard.
  4-Install Flutter and Dart plugins:
     Open Android Studio.
     Go to File > Settings > Plugins.
     Search for "Flutter" and install it (this will also install the Dart plugin).
4.Install Visual Studio (for Windows development - optional)
  Download Visual Studio from visualstudio.microsoft.com
  During installation, select "Desktop development with C++".
5. Clone the Repository
    1-Open Command Prompt.
    2-Navigate to your desired directory for the project.
    3-Clone the repository:
       git clone https://github.com/Mohamed-A-Elshaer/Edura-Academy.git  
       cd Edura-Academy
   6. Install Project Dependencies
       1-Run the following command to get all dependencies:
         flutter pub get  
         pubspec.yaml:30-56 
   7.Run the Application
      Connect a device or start an emulator
      Run the application:
      flutter run
      #Required Permissions:
The application requires the following permissions:
  AndroidManifest.xml:3-6.
  Camera access.
  Storage access for media files.
  Internet access.
#Troubleshooting:
Common Issues and Solutions:
 1-Flutter doctor shows errors:
    Follow the recommendations provided by the flutter doctor command
    Make sure all paths are correctly set in your environment variables
2-Dependency conflicts:
    Run flutter clean and then flutter pub get to refresh dependencies
    Check for version compatibility in the pubspec.yaml file
3-Firebase configuration issues:
    Ensure the configuration files (google-services.json or GoogleService-Info.plist) are placed in the correct directories
    Verify that the package name/bundle ID matches between your app and Firebase project
4-Supabase connection errors:
  Verify your Supabase URL and API key in the main.dart file
  Check your network connection and Supabase service status
5-Build fails due to Android SDK issues:
  Open Android Studio > SDK Manager and install any missing components
  Ensure the Android SDK version in your project settings matches the available SDK
6-iOS build fails:
  Update Xcode to the latest version
  Run pod install in the ios directory
  Make sure your Apple Developer account is properly set up for signing
7-App crashes on startup:
  Check the logs for specific error messages
  Verify that all required services (Firebase, Supabase) are configured correctly
