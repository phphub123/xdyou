package ohos_app_cangjie_entry.external

import ohos.ark_interop.*
import ohos.business_exception.*
import kit.AbilityKit.*
import ohos_app_cangjie_entry.common.*

public class SystemCapabilityBridge {
    private static var instance: ?SystemCapabilityBridge = None
    private let runtime: JSRuntime
    private let context: JSContext

    private init() {
        this.runtime = JSRuntime()
        this.context = this.runtime.mainContext
    }

    public static func getInstance(): SystemCapabilityBridge {
        match (SystemCapabilityBridge.instance) {
            case Some(value) => value
            case None =>
                let value = SystemCapabilityBridge()
                SystemCapabilityBridge.instance = Some(value)
                value
        }
    }

    public func publishCourseReminder(id: Int64, title: String, text: String, completed: (Bool, String) -> Unit): Unit {
        if (this.context.isInBindThread()) {
            this.publishOnArkThread(id, title, text, completed)
        } else {
            this.context.postJSTask { this.publishOnArkThread(id, title, text, completed) }
        }
    }

    public func addCalendarEvent(title: String, startTime: Int64, endTime: Int64,
        completed: (Bool, String) -> Unit): Unit {
        let permissionList: Array<Permissions> = ["ohos.permission.READ_CALENDAR", "ohos.permission.WRITE_CALENDAR"]
        let resultCallback = {
            errorCode: Option<BusinessException>, data: Option<PermissionRequestResult> =>
            match (errorCode) {
                case Some(error) => completed(false, "${error.code}: ${error.message}")
                case None =>
                    match (data) {
                        case Some(result) =>
                            var granted = result.authResults.size == permissionList.size
                            for (value in result.authResults) {
                                if (value != 0) { granted = false }
                            }
                            if (granted) { this.runCalendarAdd(title, startTime, endTime, completed) }
                            else { completed(false, "日历权限未授予，请在系统设置中允许后重试。") }
                        case None => completed(false, "日历权限请求未返回结果。")
                    }
            }
        }
        try {
            AbilityAccessCtrl.createAtManager().requestPermissionsFromUser(AppContext.get(), permissionList, resultCallback)
        } catch (error: BusinessException) { completed(false, "${error.code}: ${error.message}") }
        catch (error: Exception) { completed(false, error.message) }
    }

    private func runCalendarAdd(title: String, startTime: Int64, endTime: Int64,
        completed: (Bool, String) -> Unit): Unit {
        if (this.context.isInBindThread()) {
            this.addCalendarEventOnArkThread(title, startTime, endTime, completed)
        } else {
            this.context.postJSTask { this.addCalendarEventOnArkThread(title, startTime, endTime, completed) }
        }
    }

    private func addCalendarEventOnArkThread(title: String, startTime: Int64, endTime: Int64,
        completed: (Bool, String) -> Unit): Unit {
        try {
            let module = this.context.requireArkModule("@ohos.calendarManager").asObject()
            let manager = module.callMethod("getCalendarManager", [AppContext.get().toJSValue(this.context)]).asObject()
            let getCalendarCallback = this.context.function({ context, info =>
                if (info.count > 0 && !info[0].isUndefined()) {
                    completed(false, info[0].toString())
                } else if (info.count < 2 || !info[1].isObject()) {
                    completed(false, "系统默认日历不可用。")
                } else {
                    let calendar = info[1].asObject()
                    let event = context.object()
                    event["type"] = context.number(0.0).toJSValue()
                    event["title"] = context.string(title).toJSValue()
                    event["startTime"] = context.number(Float64(startTime)).toJSValue()
                    event["endTime"] = context.number(Float64(endTime)).toJSValue()
                    let addCallback = context.function({ innerContext, addInfo =>
                        let error = if (addInfo.count > 0 && !addInfo[0].isUndefined()) { addInfo[0].toString() } else { "" }
                        if (error == "" && addInfo.count > 1) { completed(true, "eventId=${addInfo[1].toString()}") }
                        else if (error == "") { completed(true, "日历事件已添加。") }
                        else { completed(false, error) }
                        innerContext.undefined().toJSValue()
                    })
                    calendar.callMethod("addEvent", [event.toJSValue(), addCallback.toJSValue()])
                }
                context.undefined().toJSValue()
            })
            manager.callMethod("getCalendar", [getCalendarCallback.toJSValue()])
        } catch (error: BusinessException) { completed(false, "${error.code}: ${error.message}") }
        catch (error: Exception) { completed(false, error.message) }
    }

    private func publishOnArkThread(id: Int64, title: String, text: String, completed: (Bool, String) -> Unit): Unit {
        try {
            let module = this.context.requireArkModule("@ohos.notificationManager").asObject()
            let normal = this.context.object()
            normal["title"] = this.context.string(title).toJSValue()
            normal["text"] = this.context.string(text).toJSValue()
            let content = this.context.object()
            let contentTypes = module["ContentType"].asObject()
            content["notificationContentType"] = contentTypes["NOTIFICATION_CONTENT_BASIC_TEXT"]
            content["normal"] = normal.toJSValue()
            let request = this.context.object()
            request["id"] = this.context.number(Float64(id)).toJSValue()
            request["content"] = content.toJSValue()
            let callback = this.context.function({ context, info =>
                let error = if (info.count > 0 && !info[0].isUndefined()) { info[0].toString() } else { "" }
                completed(error == "", error)
                context.undefined().toJSValue()
            })
            module.callMethod("publish", [request.toJSValue(), callback.toJSValue()])
        } catch (error: BusinessException) { completed(false, "${error.code}: ${error.message}") }
        catch (error: Exception) { completed(false, error.message) }
    }
}
