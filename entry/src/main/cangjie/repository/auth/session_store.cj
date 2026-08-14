package ohos_app_cangjie_entry.repository.auth

import kit.ArkData.*
import ohos_app_cangjie_entry.common.*
import ohos_app_cangjie_entry.model.*

public class SessionStore {
    static let storeName: String = "xdyou_session"
    static let accountKey: String = "idsAccount"
    static let legacyCookieKey: String = "ehallCookie"
    static let encryptedCookieKey: String = "ehallCookieEncrypted"
    static let loggedInKey: String = "loggedIn"
    static let languageKey: String = "language"
    static let themeKey: String = "theme"

    let preferences: Preferences

    public init() {
        this.preferences = Preferences.getPreferences(AppContext.get(), SessionStore.storeName)
    }

    public func restore(): SessionSnapshot {
        let account = this.stringValue(SessionStore.accountKey)
        let loggedIn = this.boolValue(SessionStore.loggedInKey)
        var encryptedCookie = this.stringValue(SessionStore.encryptedCookieKey)
        let legacyCookie = this.stringValue(SessionStore.legacyCookieKey)
        if (encryptedCookie == "" && legacyCookie != "") {
            try {
                encryptedCookie = SecureSessionCipher.encrypt(legacyCookie)
                this.preferences.put(SessionStore.encryptedCookieKey, PreferencesValueType.StringData(encryptedCookie))
                this.preferences.delete(SessionStore.legacyCookieKey)
                this.preferences.flush()
            } catch (_) {
                this.invalidateStoredSession()
                return SessionSnapshot(account, "", false)
            }
        }
        if (!loggedIn || encryptedCookie == "") { return SessionSnapshot(account, "", false) }
        try {
            let cookieHeader = SecureSessionCipher.decrypt(encryptedCookie)
            return SessionSnapshot(account, cookieHeader, cookieHeader != "")
        } catch (_) {
            this.invalidateStoredSession()
            return SessionSnapshot(account, "", false)
        }
    }

    public func saveAuthenticatedSession(account: String, cookieHeader: String): Unit {
        if (account == "" || cookieHeader == "") { throw Exception("Refusing to persist an incomplete IDS session") }
        let encryptedCookie = SecureSessionCipher.encrypt(cookieHeader)
        this.preferences.put(SessionStore.accountKey, PreferencesValueType.StringData(account))
        this.preferences.delete(SessionStore.legacyCookieKey)
        this.preferences.put(SessionStore.encryptedCookieKey, PreferencesValueType.StringData(encryptedCookie))
        this.preferences.put(SessionStore.loggedInKey, PreferencesValueType.BoolData(true))
        this.preferences.flush()
    }

    public func saveDisplaySettings(language: String, theme: String): Unit {
        this.preferences.put(SessionStore.languageKey, PreferencesValueType.StringData(language))
        this.preferences.put(SessionStore.themeKey, PreferencesValueType.StringData(theme))
        this.preferences.flush()
    }
    public func saveSetting(key: String, value: String): Unit {
        if (key == SessionStore.legacyCookieKey || key == SessionStore.encryptedCookieKey || key == SessionStore.loggedInKey) {

            throw IllegalArgumentException("Sensitive session keys cannot use ordinary settings storage")
        }
        this.preferences.put("setting_${key}", PreferencesValueType.StringData(value))
        this.preferences.flush()
    }

    public func restoreSetting(key: String, defaultValue!: String = ""): String {
        let value = this.stringValue("setting_${key}")
        return if (value == "") { defaultValue } else { value }
    }

    public func restoreLanguage(): String {
        let value = this.stringValue(SessionStore.languageKey)
        return if (value == "") { "Chinese" } else { value }
    }

    public func restoreTheme(): String {
        let value = this.stringValue(SessionStore.themeKey)
        return if (value == "") { "System" } else { value }
    }
    public func clearSession(): Unit {
        this.invalidateStoredSession()
    }

    public func clearAll(): Unit {
        this.preferences.clear()
        this.preferences.flush()
        SecureSessionCipher.deleteKey()
    }

    func invalidateStoredSession(): Unit {
        this.preferences.delete(SessionStore.legacyCookieKey)
        this.preferences.delete(SessionStore.encryptedCookieKey)
        this.preferences.delete(SessionStore.loggedInKey)
        this.preferences.flush()
    }

    func stringValue(key: String): String {
        match (this.preferences.get(key, PreferencesValueType.StringData(""))) {
            case PreferencesValueType.StringData(value) => value
            case _ => ""
        }
    }

    func boolValue(key: String): Bool {
        match (this.preferences.get(key, PreferencesValueType.BoolData(false))) {
            case PreferencesValueType.BoolData(value) => value
            case _ => false
        }
    }
}
