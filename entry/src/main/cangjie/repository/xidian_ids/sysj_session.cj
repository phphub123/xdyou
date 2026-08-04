package ohos_app_cangjie_entry.repository.xidian_ids

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.regex.*
import std.time.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.*

// Other-experiment service. It never synthesizes an IDS session: the redirect
// chain must consume the genuine HUKS-restored cookie and reach Sysj itself.
public class SysjSession {
    static let baseUrl = "https://sysj.xidian.edu.cn"
    static let timeList: Array<String> = ["08:30","09:15","09:20","10:05","10:25","11:10","11:15","12:00","14:00","14:45","14:50","15:35","15:55","16:40","16:45","17:30","19:00","19:45","19:55","20:35","20:40","21:25"]

    func headerValue(headers: HashMap<String,String>, name: String): String { for((key,value) in headers){if(key.toAsciiLower()==name.toAsciiLower()){return value}};return "" }
    func mergeCookie(base: String, raw: String): String {
        let values=ArrayList<String>(); for(pair in Regex(";").split(base)){this.upsert(values,pair.trimAscii())}
        for(line in Regex("[\\r\\n,]+").split(raw)){let fields=Regex(";").split(line);if(fields.size>0){this.upsert(values,fields[0].trimAscii())}}
        var result="";for(pair in values){if(result!=""){result+="; "};result+=pair};return result
    }
    func upsert(values:ArrayList<String>,pair:String):Unit{if(!pair.contains("=")){return};let name=Regex("=").split(pair)[0]+"=";var i:Int64=0;while(i<values.size){if(values[i].startsWith(name)){values[i]=pair;return};i+=1};values.add(pair)}
    func absolute(current:String,location:String):String{if(location.startsWith("http://")||location.startsWith("https://")){return location};match(Regex(#"^(https?://[^/]+)"#,RegexFlag.IgnoreCase).find(current,group:true)){case Some(root)=>if(location.startsWith("/")){return root.matchString(1)+location};case None=>()};let slash=current.lastIndexOf("/");return if(slash.isSome()){current[0..slash.getOrThrow()+1]+location}else{SysjSession.baseUrl+"/"+location}}
    func request(method:RequestMethod,url:String,cookie:String,body:String,success:(UInt32,HashMap<String,String>,String,String)->Unit,failure:(String)->Unit):Unit{
        let client=createHttp();let headers=HashMap<String,String>();headers["Accept"]="text/html,application/xhtml+xml,*/*;q=0.8";headers["User-Agent"]="Mozilla/5.0 (HarmonyOS; XDYou) AppleWebKit/537.36";if(cookie!=""){headers["Cookie"]=cookie};headers["Content-Type"]="application/x-www-form-urlencoded"
        try{let options=HttpRequestOptions(method:method,header:headers,extraData:HttpData.StringData(body),expectDataType:HttpDataType.StringValue,usingCache:false,connectTimeout:10000,readTimeout:30000);client.request(url,options,{error,response=>client.destroy();match(error){case Some(value)=>failure("其他实验服务网络错误 ${value.code}: ${value.message}");case None=>match(response){case Some(value)=>match(value.result){case HttpData.StringData(text)=>success(value.responseCode,value.header,value.cookies,text);case _=>failure("其他实验服务返回非文本响应。")};case None=>failure("其他实验服务未返回响应。")}}})}catch(e:BusinessException){client.destroy();failure("无法启动其他实验请求：${e.code} ${e.message}")}
    }
    public func load(success:(ArrayList<ExperimentData>)->Unit,failure:(String)->Unit):Unit{
        let snapshot=SessionStore().restore();if(!snapshot.loggedIn||snapshot.cookieHeader==""){failure("其他实验需要真实 IDS 会话，请先完成正式登录。");return}
        this.follow(SysjSession.baseUrl+"/xidian/test",snapshot.cookieHeader,0,{url,body,cookie=>this.finishLogin(url,body,cookie,success,failure)},failure)
    }
    func follow(url:String,cookie:String,depth:Int64,success:(String,String,String)->Unit,failure:(String)->Unit):Unit{
        if(depth>20){failure("其他实验 SSO 重定向超过限制。");return}
        this.request(RequestMethod.Get,url,cookie,"",{code,headers,cookies,body=>let merged=this.mergeCookie(cookie,cookies+"\n"+this.headerValue(headers,"set-cookie"));if(code==301||code==302||code==303||code==307||code==308){let location=this.headerValue(headers,"location");if(location==""){failure("其他实验 SSO 重定向缺少 Location。") }else{this.follow(this.absolute(url,location),merged,depth+1,success,failure)}}else if(code==200){success(url,body,merged)}else{failure("其他实验 SSO 返回 HTTP ${code}。")}},failure)
    }
    func finishLogin(url:String,body:String,cookie:String,success:(ArrayList<ExperimentData>)->Unit,failure:(String)->Unit):Unit{
        if(url.contains("ids.xidian.edu.cn")||body.contains("authserver/login")){failure("IDS 会话已失效，其他实验需要重新正式登录。");return}
        match(Regex(#"var\s+password\s*=\s*[\"']([^\"']+)[\"']"#).find(body,group:true)){
            case Some(found)=>let account=SessionStore().restore().account;let form="username=${this.encode(account)}&password=${this.encode(found.matchString(1))}";this.request(RequestMethod.Post,SysjSession.baseUrl+"/xidian/webapp/login",cookie,form,{code,headers,cookies,_=>let merged=this.mergeCookie(cookie,cookies+"\n"+this.headerValue(headers,"set-cookie"));if(code==301||code==302||code==303){let location=this.headerValue(headers,"location");if(location!=""){this.follow(this.absolute(SysjSession.baseUrl+"/xidian/webapp/login",location),merged,0,{_,_,ready=>this.loadWeek(1,ready,ArrayList<ExperimentData>(),success,failure)},failure)}else{failure("其他实验登录重定向缺少 Location。")}}else if(code==200){this.loadWeek(1,merged,ArrayList<ExperimentData>(),success,failure)}else{failure("其他实验登录返回 HTTP ${code}。")}},failure)
            case None=>
                match(Regex(#"\?code=([^&\\]+)\\u0026"#).find(body,group:true)){
                    case Some(found)=>
                        let state=this.queryValue(url,"state")
                        if(state==""){failure("其他实验 OAuth 回调缺少 state 参数。");return}
                        let callback=SysjSession.baseUrl+"/xidian/webapp/callback?code=${this.encode(found.matchString(1))}&state=${this.encode(state)}"
                        this.follow(callback,cookie,0,{u,b,c=>this.finishLogin(u,b,c,success,failure)},failure)
                    case None=>failure("其他实验 OAuth 未返回授权码或登录凭据。")
                }
        }
    }
    func queryValue(url:String,name:String):String{match(Regex("[?&]${name}=([^&]+)").find(url,group:true)){case Some(value)=>value.matchString(1);case None=>""}}
    func encode(value:String):String{value.replace("%","%25").replace(" ","%20").replace("!","%21").replace("#","%23").replace("&","%26").replace("+","%2B").replace("/","%2F").replace("=","%3D").replace("?","%3F")}
    func loadWeek(week:Int64,cookie:String,result:ArrayList<ExperimentData>,success:(ArrayList<ExperimentData>)->Unit,failure:(String)->Unit):Unit{
        if(week>25){result.sortBy(comparator:{left,right=>left.firstStart().compare(right.firstStart())});success(result);return}
        this.request(RequestMethod.Post,SysjSession.baseUrl+"/xidian/StudentCurrWeekTimetable",cookie,"weeks=${week}",{code,_,_,html=>if(code!=200){failure("其他实验第 ${week} 周课表返回 HTTP ${code}。") }else{try{this.parseWeek(html,result);this.loadWeek(week+1,cookie,result,success,failure)}catch(e:Exception){failure("其他实验第 ${week} 周课表解析失败：${e.message}")}}},failure)
    }
    func parseWeek(html:String,result:ArrayList<ExperimentData>):Unit{
        let table=this.timetableTable(html)
        let dates=this.weekDates(table)
        var day:Int64=1
        while(day<=7){
            var period:Int64=1
            while(period<=11){
                let content=this.cell(table,day,period)
                if(content==""){period+=1;continue}
                let fields=this.cellFields(content)
                if(fields.size<3){period+=1;continue}
                let name=this.valueAfter(fields[0],"???student.timetable.course???：")
                let room=this.valueAfter(fields[1],"???schedule.course.lab???：")
                let teacher=this.valueAfter(fields[2],"???student.timetable.teacher???：")
                if(name==""||room==""||teacher==""){period+=1;continue}
                let startTime=SysjSession.timeList[(period-1)*2]
                var endTime=SysjSession.timeList[(period-1)*2+1]
                while(period<11&&this.cell(table,day,period+1)==content){
                    period+=1
                    endTime=SysjSession.timeList[(period-1)*2+1]
                }
                let start=DateTime.parse("${dates[day-1]} ${startTime}:00","yyyy-MM-dd HH:mm:ss")
                let end=DateTime.parse("${dates[day-1]} ${endTime}:00","yyyy-MM-dd HH:mm:ss")
                this.addRange(result,name,room,teacher,start,end)
                period+=1
            }
            day+=1
        }
    }
    func timetableTable(html:String):String{
        let tables=ArrayList<String>()
        for(found in Regex(#"(?is)<table\b[^>]*>(.*?)</table>"#).findAll(html,group:true)){tables.add(found.matchString())}
        if(tables.size<2){throw Exception("其他实验课表响应未包含第二张课程表。")}
        return tables[1]
    }
    func weekDates(table:String):ArrayList<String>{
        let dates=ArrayList<String>()
        for(found in Regex(#"\b(20\d{2}-\d{1,2}-\d{1,2})\b"#).findAll(table,group:true)){
            let date=found.matchString(1)
            if(!dates.contains(date)&&dates.size<7){dates.add(date)}
        }
        if(dates.size<7){throw Exception("其他实验课表未包含完整的七日日期。")}
        return dates
    }
    func cell(html:String,day:Int64,period:Int64):String{
        let pattern=Regex("(?is)<td\\b[^>]*do-labReservation\\s*=\\s*[\\\"']${day},${period}[\\\"'][^>]*>(.*?)</td>")
        match(pattern.find(html,group:true)){case Some(value)=>value.matchString(1).trimAscii();case None=>""}
    }
    func cellFields(content:String):ArrayList<String>{
        let normalized=Regex(#"(?is)<br\s*/?>"#).replaceAll(content,"\n")
        let text=Regex(#"(?is)<[^>]+>"#).replaceAll(normalized,"")
        let result=ArrayList<String>()
        for(line in Regex("[\\r\\n]+").split(text)){
            let value=line.replace("&nbsp;"," ").replace("&amp;","&").trimAscii()
            if(value!=""){result.add(value)}
        }
        return result
    }
    func valueAfter(value:String,label:String):String{
        return if(value.startsWith(label)){value[label.size..value.size].trimAscii()}else{""}
    }
    func addRange(result:ArrayList<ExperimentData>,name:String,room:String,teacher:String,start:DateTime,end:DateTime):Unit{
        var existing:Int64=-1
        var index:Int64=0
        while(index<result.size){
            if(result[index].name==name&&result[index].classroom==room&&result[index].teacher==teacher){existing=index;break}
            index+=1
        }
        if(existing<0){
            let ranges=ArrayList<ExperimentTimeRange>()
            ranges.add(ExperimentTimeRange(start,end))
            result.add(ExperimentData(ExperimentType.Others,name,room,ranges,teacher))
        }else{result[existing].timeRanges.add(ExperimentTimeRange(start,end))}
    }
}
