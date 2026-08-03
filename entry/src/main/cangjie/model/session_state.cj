package ohos_app_cangjie_entry.model

public enum SessionState {
    | None
    | Restoring
    | LoggedOut
    | Authenticating
    | CaptchaRequired
    | LoggedIn
    | Failed
}

public class SessionSnapshot {
    public let account: String
    public let cookieHeader: String
    public let loggedIn: Bool

    public init(account: String, cookieHeader: String, loggedIn: Bool) {
        this.account = account
        this.cookieHeader = cookieHeader
        this.loggedIn = loggedIn
    }
}
