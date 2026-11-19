SKYLUG - UPDATE APP ICON AND APP NAME

This ZIP is a set of ready-to-copy files for your Flutter Android project.

1. BACK UP your existing Flutter project.
2. Extract this ZIP into:
   C:\flutter_demo\excess_baggage_calculator
   Choose to replace files when prompted.
   The ZIP includes:
   - lib/main.dart (SkyLug branding in drawer, app bar, About page)
   - assets/images/skylug_icon.png (original user-provided logo)
   - assets/images/skylug_launcher.png (square cloud launcher image)
   - android/app/src/main/res/mipmap-*/ic_launcher.png (Android launcher icons)

3. In the existing AndroidManifest.xml:
   android/app/src/main/AndroidManifest.xml
   find the <application ...> tag and set:
   android:label="SkyLug"
   Keep other attributes intact.
   The existing android:icon="@mipmap/ic_launcher" should remain.

4. Ensure pubspec.yaml has:
   flutter:
     uses-material-design: true
     assets:
       - assets/images/

5. In VS Code Terminal:
   flutter clean
   flutter pub get
   flutter run

6. If emulator still shows the old icon/name, uninstall the old
   excess_baggage_calculator app from emulator, then run flutter run.

IMPORTANT:
- Your package/application ID does not need to be changed.
- This replaces branding icons only. Functional UI icons (Calculate, Reset, etc.)
  intentionally remain the same for usability.
- The source file is provided without running Flutter compilation in this environment.
- Public GitHub repositories can expose files under assets/images/.
