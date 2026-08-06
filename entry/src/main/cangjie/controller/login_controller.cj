package ohos_app_cangjie_entry.controller

import ohos_app_cangjie_entry.model.*
import std.time.*
import std.random.*
import ohos_app_cangjie_entry.repository.*

public class LoginViewModel {
    let ids: IDSSession = IDSSession()
    var pendingPage: ?IDSLoginPage = None
    var pendingAccount: String = ""
    var pendingPassword: String = ""

    public func beginLogin(
        account: String,
        password: String,
        onState: (SessionState, String) -> Unit,
        onCaptcha: (SliderCaptcha) -> Unit,
        onAuthenticated: (String) -> Unit
    ): Unit {
        if (account.trimAscii() == "") { onState(SessionState.Failed, "Student ID is required."); return }
        if (password == "") { onState(SessionState.Failed, "Password is required."); return }
        this.pendingAccount = account
        this.pendingPassword = password
        onState(SessionState.Authenticating, "Loading the current IDS login form...")
        this.ids.requestLoginPage(EhallSession.landingUrl, { page =>
            this.pendingPage = Some(page)
            onState(SessionState.Authenticating, "Completing IDS verification...")
            this.beginAutomaticCaptcha(page, 0, onState, onCaptcha, onAuthenticated)
        }, { error => this.fail(error, onState) })
    }

    func beginAutomaticCaptcha(
        page: IDSLoginPage,
        round: Int64,
        onState: (SessionState, String) -> Unit,
        onCaptcha: (SliderCaptcha) -> Unit,
        onAuthenticated: (String) -> Unit
    ): Unit {
        this.ids.requestSliderCaptcha(page, { captcha =>
            try {
                let baseMove = SliderCaptchaAutoSolver.solveMove(captcha)
                this.tryAutomaticMoves(page, captcha, baseMove, 0, round, onState, onCaptcha, onAuthenticated)
            } catch (error: Exception) {
                this.showManualCaptcha(captcha, "Image matching failed: ${error.message}", onState, onCaptcha)
            }
        }, { error => this.fail(error, onState) })
    }

    func tryAutomaticMoves(
        page: IDSLoginPage,
        captcha: SliderCaptcha,
        baseMove: Int64,
        index: Int64,
        round: Int64,
        onState: (SessionState, String) -> Unit,
        onCaptcha: (SliderCaptcha) -> Unit,
        onAuthenticated: (String) -> Unit
    ): Unit {
        let deltas: Array<Int64> = [1, -1, 2, -2, 3, -3, 4]
        if (index >= deltas.size) {
            if (round < 5) {
                let refreshed = IDSLoginPage(page.hiddenFields, page.encryptSalt, captcha.cookieHeader)
                this.beginAutomaticCaptcha(refreshed, round + 1, onState, onCaptcha, onAuthenticated)
            } else {
                this.showManualCaptcha(captcha, "Automatic attempts were rejected by IDS", onState, onCaptcha)
            }
            return
        }
        let move = baseMove + deltas[index]
        if (move < 1 || move > 280) {
            this.tryAutomaticMoves(page, captcha, baseMove, index + 1, round, onState, onCaptcha, onAuthenticated)
            return
        }
        let track = SliderCaptchaAutoSolver.tracks(move)
        sleep(Duration.millisecond * (track[1] - 100))
        this.ids.verifySlider(captcha, move, track[0], { accepted, cookie =>
            if (accepted) {
                onState(SessionState.Authenticating, "Submitting the account and password...")
                this.submit(page, cookie, true, onState, onCaptcha, onAuthenticated)
            } else {
                this.tryAutomaticMoves(page, captcha, baseMove, index + 1, round, onState, onCaptcha, onAuthenticated)
            }
        }, { _ =>
            this.tryAutomaticMoves(page, captcha, baseMove, index + 1, round, onState, onCaptcha, onAuthenticated)
        })
    }

    func showManualCaptcha(captcha: SliderCaptcha, reason: String, onState: (SessionState, String) -> Unit, onCaptcha: (SliderCaptcha) -> Unit): Unit {
        onCaptcha(captcha)
        onState(SessionState.CaptchaRequired, "${reason}. Complete the slider manually.")
    }

    func submit(
        page: IDSLoginPage,
        cookie: String,
        captchaVerified: Bool,
        onState: (SessionState, String) -> Unit,
        onCaptcha: (SliderCaptcha) -> Unit,
        onAuthenticated: (String) -> Unit
    ): Unit {
        this.ids.submitCredentials(page, cookie, captchaVerified, this.pendingAccount, this.pendingPassword, { authenticatedCookie =>
            this.pendingPassword = ""
            onAuthenticated(authenticatedCookie)
            onState(SessionState.LoggedIn, "IDS authentication succeeded.")
        }, { challengePage =>
            this.pendingPage = Some(challengePage)
            onState(SessionState.CaptchaRequired, "The server requested another captcha. Loading it now...")
            this.ids.requestSliderCaptcha(challengePage, { captcha =>
                onCaptcha(captcha)
                onState(SessionState.CaptchaRequired, "Complete the captcha required by IDS.")
            }, { error => this.fail(error, onState) })
        }, { error => this.fail(error, onState) })
    }

    public func verifyCaptcha(captcha: SliderCaptcha, move: Int64, tracks: String, onState: (SessionState, String) -> Unit, onAuthenticated: (String) -> Unit): Unit {
        onState(SessionState.Authenticating, "Verifying the IDS captcha...")
        this.ids.verifySlider(captcha, move, tracks, { accepted, cookie =>
            if (accepted) {
                match (this.pendingPage) {
                    case Some(page) => this.submit(page, cookie, true, onState, { _ => onState(SessionState.Failed, "IDS requested another captcha. Start sign in again.") }, onAuthenticated)
                    case None => this.fail("The IDS login form expired. Start sign in again.", onState)
                }
            } else { this.fail("IDS rejected the captcha. Start sign in again.", onState) }
        }, { error => this.fail(error, onState) })
    }

    func fail(message: String, onState: (SessionState, String) -> Unit): Unit {
        this.pendingPassword = ""
        onState(SessionState.Failed, message)
    }
}
