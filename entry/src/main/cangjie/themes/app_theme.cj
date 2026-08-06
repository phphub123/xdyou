package ohos_app_cangjie_entry.themes

import kit.ArkUI.*
import ohos_app_cangjie_entry.repository.*

public class AppTheme {
    public static let preferenceKey: String = "xdyouThemePreference"

    public static func bootstrap(): Unit {
        Environment.envProp<ColorMode>("colorMode", ColorMode.Light)
        AppStorage.setOrCreate<String>(AppTheme.preferenceKey, AppTheme.normalize(SessionStore().restoreTheme()))
    }

    public static func normalize(value: String): String {
        return if (value == "Light") { "Light" } else if (value == "Dark") { "Dark" } else { "System" }
    }

    public static func setPreference(value: String, language: String): Unit {
        let preference = AppTheme.normalize(value)
        SessionStore().saveDisplaySettings(language, preference)
        AppStorage.setOrCreate<String>(AppTheme.preferenceKey, preference)
    }

    public static func isDark(preference: String, systemMode: ColorMode): Bool {
        return if (AppTheme.normalize(preference) == "Dark") { true }
            else if (AppTheme.normalize(preference) == "Light") { false }
            else { systemMode == ColorMode.Dark }
    }
}

public class ThemePalette {
    // Migrated from source_2.0/lib/themes/default.dart DefaultColor light/dark.
    public static func pageBackground(dark: Bool): Int64 { return if (dark) { 0xFF12151C } else { 0xFFFAF9FF } }
    public static func surface(dark: Bool): Int64 { return if (dark) { 0xFF1D222C } else { 0xFFF7F7FF } }
    public static func inputSurface(dark: Bool): Int64 { return if (dark) { 0xFF202733 } else { 0xFFF5F6FB } }
    public static func navSurface(dark: Bool): Int64 { return if (dark) { 0xFF181D27 } else { 0xFFF3F3FB } }
    public static func primary(dark: Bool): Int64 { return if (dark) { 0xFF9FC9FF } else { 0xFF3F5F90 } }
    public static func primaryContainer(dark: Bool): Int64 { return if (dark) { 0xFF00325B } else { 0xFFD0E4FF } }
    public static func primary(): Int64 { return ThemePalette.primary(false) }
    public static func primaryText(): Int64 { return 0xFFFFFFFF }
    public static func textPrimary(dark: Bool): Int64 { return if (dark) { 0xFFF2F4F8 } else { 0xFF202229 } }
    public static func textSecondary(dark: Bool): Int64 { return if (dark) { 0xFFBBC3D0 } else { 0xFF565C67 } }
    public static func border(dark: Bool): Int64 { return if (dark) { 0xFF394252 } else { 0xFFD9DAE2 } }
    public static func mutedPrimary(dark: Bool): Int64 { return if (dark) { 0xFF263C5A } else { 0xFFE8EDF6 } }
}
