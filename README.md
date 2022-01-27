# yaru_skeleton

This example extends Flutter's "skeleton" app template to apply the selected
theme as a system theme on Ubuntu.

![yaru-skeleton](https://raw.githubusercontent.com/jpnurmi/yaru_skeleton/main/screenshot.png "Yaru skeleton app screenshot")

This README goes through the steps using the Flutter tool from the command line,
but IDEs such as Visual Studio Code, Android Studio, and IntelliJ IDEA have
Flutter plugins to make the development experience smoother.

**TODO**: There is also a [video]() available that does the same steps from within VS Code.

## Skeleton

The skeleton app template is used as a starting point. Notice to pass the
`--template skeleton` argument:

  ```
  $ flutter create --template skeleton yaru_skeleton
  ```

Switch to the `yaru_skeleton` directory, open it in your favorite editor, and
run the app:

```
$ flutter run
```

## Yaru

[Yaru](https://pub.dev/packages/yaru) theme provides the Ubuntu look'n'feel. Add
it as a dependency to `pubspec.yaml`:

```
$ flutter pub add yaru
```

In `app.dart`, import `yaru/yaru.dart` and assign `yaruLight` and `yaruDark` to
`MaterialApp.theme` and `MaterialApp.themeDark`, respectively.

<details><summary>diff</summary>

```diff
diff --git a/lib/src/app.dart b/lib/src/app.dart
index 504429e..7a9d5cf 100644
--- a/lib/src/app.dart
+++ b/lib/src/app.dart
@@ -1,6 +1,7 @@
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
+import 'package:yaru/yaru.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
@@ -56,8 +57,8 @@ class MyApp extends StatelessWidget {
          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
-          theme: ThemeData(),
-          darkTheme: ThemeData.dark(),
+          theme: yaruLight,
+          darkTheme: yaruDark,
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
```
</details>

## GSettings

[GSettings](https://pub.dev/packages/gsettings) and
[D-Bus](https://pub.dev/packages/dbus) are used to read and write the system
theme. Add the dependencies to `pubspec.yaml`:

```
$ flutter pub add dbus
$ flutter pub add gsettings
```

In `settings_service.dart`, reimplement the existing `SettingsService` using
`GSettings` as a backend.

<details><summary>diff</summary>

```diff

diff --git a/lib/src/settings/settings_service.dart b/lib/src/settings/settings_service.dart
index 6f94dc3..a68af6f 100644
--- a/lib/src/settings/settings_service.dart
+++ b/lib/src/settings/settings_service.dart
@@ -1,4 +1,6 @@
+import 'package:dbus/dbus.dart';
import 'package:flutter/material.dart';
+import 'package:gsettings/gsettings.dart';

/// A service that stores and retrieves user settings.
///
@@ -15,3 +17,26 @@ class SettingsService {
    // http package to persist settings over the network.
  }
}
+
+class GSettingsService implements SettingsService {
+  final _gsettings = GSettings('org.gnome.desktop.interface');
+
+  @override
+  Future<ThemeMode> themeMode() async {
+    final theme = await _gsettings.get('gtk-theme') as DBusString;
+    if (theme.value == 'Yaru-dark') {
+      return ThemeMode.dark;
+    } else {
+      return ThemeMode.light;
+    }
+  }
+
+  @override
+  Future<void> updateThemeMode(ThemeMode theme) async {
+    if (theme == ThemeMode.dark) {
+      _gsettings.set('gtk-theme', const DBusString('Yaru-dark'));
+    } else {
+      _gsettings.set('gtk-theme', const DBusString('Yaru'));
+    }
+  }
+}
```
</details>

Finally, replace the original `SettingsService` with `GSettingsService` in
`main.dart`.

<details><summary>diff</summary>

```diff
diff --git a/lib/main.dart b/lib/main.dart
index eb568f2..cac81b2 100644
--- a/lib/main.dart
+++ b/lib/main.dart
@@ -7,7 +7,7 @@ import 'src/settings/settings_service.dart';
void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
-  final settingsController = SettingsController(SettingsService());
+  final settingsController = SettingsController(GSettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
```
</details>
