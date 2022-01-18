import 'package:dbus/dbus.dart';
import 'package:flutter/material.dart';
import 'package:gsettings/gsettings.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async => ThemeMode.system;

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
  }
}

class GSettingsService implements SettingsService {
  final _gsettings = GSettings('org.gnome.desktop.interface');

  @override
  Future<ThemeMode> themeMode() async {
    final theme = await _gsettings.get('gtk-theme') as DBusString;
    if (theme.value == 'Yaru-dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  @override
  Future<void> updateThemeMode(ThemeMode theme) async {
    if (theme == ThemeMode.dark) {
      _gsettings.set('gtk-theme', const DBusString('Yaru-dark'));
    } else {
      _gsettings.set('gtk-theme', const DBusString('Yaru'));
    }
  }
}
