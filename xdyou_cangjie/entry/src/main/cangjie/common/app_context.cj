package ohos_app_cangjie_entry.common

import kit.AbilityKit.UIAbilityContext

// The Preferences API is process-scoped.  Keep the UIAbility context in the
// same top-level module variable used by the official Cangjie sample so it is
// available when ArkUI creates the entry component.
public var globalAbilityContext: ?UIAbilityContext = None

public class AppContext {
    public static func initialize(value: UIAbilityContext): Unit {
        globalAbilityContext = Some(value)
    }

    public static func get(): UIAbilityContext {
        match (globalAbilityContext) {
            case Some(value) => value
            case None => throw Exception("Application context is not available")
        }
    }
}