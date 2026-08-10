package ohos_app_cangjie_entry.controller

import ohos_app_cangjie_entry.model.*
import std.time.*
import ohos_app_cangjie_entry.repository.*

public class LoginViewModel {
    let ids: IDSSession = IDSSession()
    var pendingPage: ?IDSLoginPage = None
    var pendingAccount: String = ""
    var pendingPassword: String = ""
    var lastSliderFailure: String = ""

    // 账号密码、滑块和重定向均在后台完成；UI 只接收进度、二次认证挑战和最终会话。
    public func beginLogin(
        account: String,
        password: String,
        onState: (SessionState, String) -> Unit,
        onReAuthRequired: (IDSReAuthSession) -> Unit,
        onAuthenticated: (String) -> Unit
    ): Unit {
        if (account.trimAscii() == "") { onState(SessionState.Failed, "Student ID is required."); return }
        if (password == "") { onState(SessionState.Failed, "Password is required."); return }
        this.pendingAccount = account
        this.pendingPassword = password
        this.lastSliderFailure = ""
        onState(SessionState.Authenticating, "正在请求统一认证登录表单…")
        this.ids.requestLoginPage(EhallSession.landingUrl, { page =>
            this.pendingPage = Some(page)
            onState(SessionState.Authenticating, "正在后台完成滑块验证…")
            this.beginAutomaticCaptcha(page, 0, onState, onReAuthRequired, onAuthenticated)
        }, { error => this.fail(error, onState) })
    }

    // 与 Dart/Python 参考实现一致：最多刷新六轮图片，每轮尝试邻近偏移，不展示滑块 UI。
    func beginAutomaticCaptcha(
        page: IDSLoginPage,
        round: Int64,
        onState: (SessionState, String) -> Unit,
        onReAuthRequired: (IDSReAuthSession) -> Unit,
        onAuthenticated: (String) -> Unit
    ): Unit {
        this.ids.requestSliderCaptcha(page, { captcha =>
            try {
                let baseMove = SliderCaptchaAutoSolver.solveMove(captcha)
                this.tryAutomaticMoves(page, captcha, baseMove, 0, round, onState,
                    onReAuthRequired, onAuthenticated)
            } catch (error: Exception) {
                this.lastSliderFailure = "第 ${round + 1} 轮图片识别失败：${error.message}"
                if (round < 5) {
                    this.beginAutomaticCaptcha(page, round + 1, onState, onReAuthRequired, onAuthenticated)
                } else {
                    this.fail("后台滑块图片识别失败：${error.message}", onState)
                }
            }
        }, { error =>
            this.lastSliderFailure = "第 ${round + 1} 轮滑块请求失败：${error}"
            if (round < 5) {
                this.beginAutomaticCaptcha(page, round + 1, onState, onReAuthRequired, onAuthenticated)
            } else {
                this.fail(error, onState)
            }
        })
    }

    func tryAutomaticMoves(
        page: IDSLoginPage,
        captcha: SliderCaptcha,
        baseMove: Int64,
        index: Int64,
        round: Int64,
        onState: (SessionState, String) -> Unit,
        onReAuthRequired: (IDSReAuthSession) -> Unit,
        onAuthenticated: (String) -> Unit
    ): Unit {
        let deltas: Array<Int64> = [1, -1, 2, -2, 3, -3, 4]
        if (index >= deltas.size) {
            if (round < 5) {
                let refreshed = IDSLoginPage(page.hiddenFields, page.encryptSalt, captcha.cookieHeader)
                this.beginAutomaticCaptcha(refreshed, round + 1, onState, onReAuthRequired, onAuthenticated)
            } else {
                this.fail("后台滑块自动验证失败。最后原因：${if (this.lastSliderFailure == "") { "服务端拒绝了全部偏移" } else { this.lastSliderFailure }}", onState)
            }
            return
        }
        let move = baseMove + deltas[index]
        if (move < 0 || move > 280) {
            this.tryAutomaticMoves(page, captcha, baseMove, index + 1, round, onState,
                onReAuthRequired, onAuthenticated)
            return
        }
        let track = SliderCaptchaAutoSolver.tracks(move)
        sleep(Duration.millisecond * (track[1] - 100))
        this.ids.verifySlider(captcha, move, track[0], { accepted, cookie, summary =>
            if (accepted) {
                onState(SessionState.Authenticating, "滑块验证通过，正在提交账号密码…")
                this.submit(page, cookie, true, onState, onReAuthRequired, onAuthenticated)
            } else {
                this.lastSliderFailure = "第 ${round + 1} 轮偏移 ${move} 被拒绝：${summary}"
                onState(SessionState.Authenticating, "后台滑块第 ${round + 1}/6 轮，偏移 ${move} 被拒绝，正在重试…")
                this.tryAutomaticMoves(page, captcha, baseMove, index + 1, round, onState,
                    onReAuthRequired, onAuthenticated)
            }
        }, { error =>
            this.lastSliderFailure = "第 ${round + 1} 轮偏移 ${move} 请求异常：${error}"
            onState(SessionState.Authenticating, "后台滑块偏移 ${move} 请求异常，正在重试：${error}")
            this.tryAutomaticMoves(page, captcha, baseMove, index + 1, round, onState,
                onReAuthRequired, onAuthenticated)
        })
    }

    func submit(
        page: IDSLoginPage,
        cookie: String,
        captchaVerified: Bool,
        onState: (SessionState, String) -> Unit,
        onReAuthRequired: (IDSReAuthSession) -> Unit,
        onAuthenticated: (String) -> Unit
    ): Unit {
        this.ids.submitCredentials(page, cookie, captchaVerified, this.pendingAccount, this.pendingPassword,
            { authenticatedCookie =>
                this.pendingPassword = ""
                onAuthenticated(authenticatedCookie)
                onState(SessionState.LoggedIn, "IDS authentication succeeded.")
            }, { challengePage =>
                this.pendingPage = Some(challengePage)
                onState(SessionState.Authenticating, "服务端要求重新验证滑块，正在后台处理…")
                this.beginAutomaticCaptcha(challengePage, 0, onState, onReAuthRequired, onAuthenticated)
            }, { reAuth =>
                onState(SessionState.Authenticating, "账号密码与滑块已通过，正在准备短信二次认证…")
                reAuth.prepare({ => onReAuthRequired(reAuth) }, { error => this.fail(error, onState) })
            }, { error => this.fail(error, onState) })
    }

    public func clearPendingPassword(): Unit {
        this.pendingPassword = ""
    }

    func fail(message: String, onState: (SessionState, String) -> Unit): Unit {
        this.pendingPassword = ""
        onState(SessionState.Failed, message)
    }
}
