//#region for IE8 不支援JavaScript的Object.keys
if (!Object.keys) {
    Object.keys = (function () {
        'use strict';
        var hasOwnProperty = Object.prototype.hasOwnProperty,
            hasDontEnumBug = !({ toString: null }).propertyIsEnumerable('toString'),
            dontEnums = [
              'toString',
              'toLocaleString',
              'valueOf',
              'hasOwnProperty',
              'isPrototypeOf',
              'propertyIsEnumerable',
              'constructor'
            ],
            dontEnumsLength = dontEnums.length;

        return function (obj) {
            if (typeof obj !== 'function' && (typeof obj !== 'object' || obj === null)) {
                throw new TypeError('Object.keys called on non-object');
            }

            var result = [], prop, i;

            for (prop in obj) {
                if (hasOwnProperty.call(obj, prop)) {
                    result.push(prop);
                }
            }

            if (hasDontEnumBug) {
                for (i = 0; i < dontEnumsLength; i++) {
                    if (hasOwnProperty.call(obj, dontEnums[i])) {
                        result.push(dontEnums[i]);
                    }
                }
            }
            return result;
        };
    }());
}
//#endregion

//#region NumberToChinese - 數字轉成國字
function NumberToChinese(SendNumber) {
    var chnNumChar = ["零", "壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖"];

    return chnNumChar[SendNumber];
}
//#endregion

//#region NumberToCh - 數字轉大寫
function NumberToCh(SendNumber) {
    var chnNumChar = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"
        , "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九"
        , "二十", "二十一", "二十二", "二十三", "二十四", "二十五", "二十六", "二十七", "二十八", "二十九"
        , "三十", "三十一", "三十二", "三十三", "三十四", "三十五", "三十六", "三十七", "三十八", "三十九"
    ];

    return chnNumChar[SendNumber];
}
//#endregion

//#region getRootPath - 獲取web ap根路徑 ex:http://web02/nOpt
function getRootPath() {
    var strFullPath = window.document.location.href;
    var strPath = window.document.location.pathname;
    var pos = strFullPath.indexOf(strPath);
    var prePath = strFullPath.substring(0, pos);
    var postPath = strPath.substring(0, strPath.substr(1).indexOf('/') + 1);
    return (prePath + postPath);
}
//#endregion

//#region getRootDir - 獲取web ap根目錄 ex:nOpt
function getRootDir() {
    var strPath = window.document.location.pathname;
    var postPath = strPath.substring(0, strPath.substr(1).indexOf('/') + 1);
    return postPath;
}
//#endregion

//#region ajaxByGet - ajax function(get)
function ajaxByGet(url, param) {
    return $.ajax({
        url: url,
        type: "get",
        cache: false,
        async: false,
        data: param
    });
}
//#endregion

//#region ajaxByForm - ajax function(submit form)
function ajaxByForm(url, param) {
    return $.ajax({
        url: url,
        type: "post",
        data: param,
        contentType: false,
        cache: false,
        processData: false,
        beforeSend: function (xhr) {
            $("#dialog").html("<div align='center'><h1>存檔中...</h1></div>");
            $("#dialog").dialog({ title: '存檔訊息', modal: true, maxHeight: 500, width: 800, buttons: [] });
        }
    });
}
//#endregion

//#region ajaxByPost - ajax function(post)
function ajaxByPost(url, param) {
    return $.ajax({
        url: url,
        type: "post",
        cache: false,
        async: false,
        data: param
    });
}
//#endregion

//#region ajaxScriptByGet - ajax function(get)
function ajaxScriptByGet(titleName, url) {
    $.ajax({
        url: url,
        type: "get",
        dataType: "script",
        async: false,
        cache: false,
        error: function (xhr) {
            $("#dialog").html("<a href='" + this.url + "' target='_new'>" + titleName + "<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
            $("#dialog").dialog({ title: titleName + '失敗！', modal: true, maxHeight: 500, width: "90%" });
        }
    });
}
//#endregion

//#region decodeStr - 將&#nnnn;轉為字元
function decodeStr(encodedString) {
    var textArea = document.createElement('textarea');
    textArea.innerHTML = encodedString;
    return textArea.value;
}
//#endregion

//#region NulltoEmpty - 若為null回傳空字串
function NulltoEmpty(s) {
    if (s == null || s == undefined) return "";
    return s;
}
//#endregion

//#region xRound - 四捨五入
function xRound(num, pos) {
    var size = Math.pow(10, (pos || 0));
    return Math.round(num * size) / size;
    //return Math.round(Math.round(val * Math.pow(10, (pos || 0) + 1)) / 10) / Math.pow(10, (pos || 0));
}
//#endregion

//#region padLeft - 左邊補0(padStr)
function padLeft(str, len, padStr) {
    str = '' + str;
    return str.length >= len ? str : new Array(len - str.length + 1).join(padStr) + str;
}
//#endregion

//#region padRight - 右邊補0(padStr)
function padRight(str, len, padStr) {
    str = '' + str;
    return str.length >= len ? str : str + new Array(len - str.length + 1).join(padStr);
}
//#endregion

//#region dateReviver - json日期格式返回new Date格式
//ex:dateConvert(jOpt.last_date);
function dateConvert(value) {
    var a;
    var b;
    //a→2018-12-26T10:47:00
    //a1→2020-01-21T15:18:49.26
    if (typeof value === 'string') {
        //a = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})$/.exec(value);
        a = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)$/.exec(value);
        if (a) {
            b = new Date(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6]);
        }
    }
    if (b != null) {
        return b;
    }
    else {
        return "";
    }
}
//#endregion

//#region dateReviver - json日期格式轉指定格式
//ex: dateReviver(jOpt.last_date, "yyyy/M/d");
function dateReviver(value, pstr) {
    var a;
    var b;
    //a→2018-12-26T10:47:00
    //a1→2020-01-21T15:18:49.26
    if (typeof value === 'string') {
        //a = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})$/.exec(value);
        a = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)$/.exec(value);
       if (a) {
            b = new Date(+a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6]);
        }
    }
    if (b != null) {
        return b.format(pstr);
    }
    else {
        return "";
    }
}
//#endregion

//#region CInt - vbscript CInt Convertion
function CInt(n) {
    return parseInt(n || 0, 10);
}
//#endregion

//#region CDbl - vbscript CDbl Convertion
function CDbl(n) {
    return parseFloat(n || 0, 10);
}
//#endregion

//#region CLng - vbscript CLng Convertion
function CLng(n) {
    return parseInt(n || 0, 10);
}
//#endregion

//#region IsNumeric - vbscript IsNumeric Convertion
function IsNumeric(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}
//#endregion

//#region IsEmpty - vbscript IsEmpty + IsNull + "" Convertion
function IsEmpty(n) {
    if (n === undefined || n == null || n == "") {
        return true;
    }
    return false;
}
//#endregion

//#region CDate - vbscript CDate Convertion
//比較日期時要加.getTime(),ex: CDate("2021/3/2").getTime()==CDate("2021/3/2").getTime()
function CDate(Str) {
    return new Date(Str.replace(/-/g, "/"));
    //return Date.parse(Str.replace(/-/g, "/"));
}
//#endregion

//#region Today - 取得當天日期
//比較日期時要加.getTime(),ex: Today.getTime()==CDate("2021/3/2").getTime()
function Today() {
    var td = new Date();
    td.setHours(0, 0, 0, 0);
    return td;
}
//#endregion

//#region getJoinValue - 串接明細欄位
//ex: $("#rows_chk").val(getJoinValue("#dataList>tbody input[id^='chk_']"));
function getJoinValue(selector,symbol) {
    var s = "\f";
    if (typeof symbol !== "undefined") { s = symbol; }
    return s + $(selector).map(function () {
        $this = $(this);
        if ($this.prop("type") == "checkbox") {
            return $(this).prop("checked") ? $this.val() : "";
        } else {
            return $this.val();
        }
    }).get().join(s);//\f是換頁鍵Chr(12)
}
//#endregion

//#region Date.prototype.format - js日期格式fotmat轉換
//("yyyy-MM-dd")
//("yyyy-MM-dd hh:mm:ss")
Date.prototype.format = function (fmt) {
    var o = {
        "M+": this.getMonth() + 1,
        "d+": this.getDate(),
        "h+": this.getHours(),
        "H+": this.getHours()%12,
        "m+": this.getMinutes(),
        "s+": this.getSeconds(),
        "q+": Math.floor((this.getMonth() + 3) / 3),
        "S": this.getMilliseconds()
    };
    if (/(y+)/.test(fmt)) {
        fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
    }
    if (/(t+)/.test(fmt)) {
        fmt = fmt.replace(RegExp.$1, (this.getHours() >= 12 ? '下午' : '上午'));
    }
    for (var k in o) {
        if (new RegExp("(" + k + ")").test(fmt)) {
            fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
        }
    }
    return fmt;
}
//#endregion

//#region Date.prototype.addDays - js日期加上 X 天
//var today = new Date();
//today.addDays(7);
Date.prototype.addDays = function (days) {
    this.setDate(this.getDate() + days);
    return this;
}
//#endregion

//#region Date.prototype.addMonths - js日期加上 X 月
//var today = new Date();
//today.addMonths(7);
Date.prototype.addMonths = function (months) {
    this.setMonth(this.getMonth() + months);
    return this;
}
//#endregion

//#region Date.prototype.addYears - js日期加上 X 年
//var today = new Date();
//today.addYears(7);
Date.prototype.addYears = function (years) {
    this.setYear(this.getFullYear() + years);
    return this;
}
//#endregion

//#region Number.prototype.format - 將數值轉換貨幣表示法
/*
n:取到小數第幾位
x:幾位一撇
Number(-1654349.7).format(0,3); →   -1,654,350
Number(-1654349.7).format(2,4); →   -165,4349.70
Number(-1654349.7).format();   →   -1,654,350
*/
Number.prototype.format = function (n, x) {
    var re = '\\d(?=(\\d{' + (x || 3) + '})+' + (n > 0 ? '\\.' : '$') + ')';
    return this.toFixed(Math.max(0, ~ ~n)).replace(new RegExp(re, 'g'), '$&,');
};
//#endregion

//#region String.prototype.IN - 類似T-SQL的IN，判斷字串是否符合清單中的任何值(不分大小寫)。
/*
"FCF".IN("FC1,FC10,FC9,FCA,FCB,FCF") → true
*/
String.prototype.IN = function (n) {
    var arr = n.split(",");
    return arr.map(function (value) {
        return value.toLowerCase();
    }).indexOf(String(this).toLowerCase())>-1;
}
//#endregion

//#region String.prototype.ReplaceAll - 全部取代
String.prototype.ReplaceAll = function (s1, s2) {
    return this.replace(new RegExp(s1, "gmi"), s2);//全域性匹配+多行匹配+不分大小寫
}
//#endregion

//#region String.prototype.Right - 取右邊N個字
String.prototype.Right = function (n) {
	if (n <= 0)
		return "";
	else if (n > String(this).length)
		return this;
	else {
		var iLen = String(this).length;
		return String(this).substring(iLen, iLen - n);
	}
}
//#endregion

//#region String.prototype.Left - 取左邊N個字
String.prototype.Left = function (n) {
	if (n <= 0)
		return "";
	else if (n > String(this).length)
		return this;
	else
		return String(this).substring(0, n);
}
//#endregion

//#region String.prototype.CutData - 截取左邊N個byte,超過時後面加...
String.prototype.CutData = function (n) {
    if (n <= 0)
        return "";
    else if (n > String(this).CodeLength())
        return this;
    else {
        var len = 0, tStr2 = "";
        for (i = 0; i < String(this).length; i++) {
            chCd = String(this).charCodeAt(i);
            if (chCd > 255) len += 2;
            else len += 1;

            if (len > n) {
                tStr2 += "...";
                break;
            }
            tStr2 += String(this).substr(i, 1);
        }
        return tStr2;
    }
}
//#endregion

//#region String.prototype.CodeLength - 計算字串byte(英數=1,中文=2)
String.prototype.CodeLength = function () {
    /*
    var len = 0;
    var i = 0;
    var chCd;
    for (i = 0; i < String(this).length; i++) {
        chCd = String(this).charCodeAt(i);
        if (chCd > 255) len += 2;
        else len += 1;
    }
    return len;
    */
    return this.replace(/[^\x00-\xff]/g, "xx").length;
}
//#endregion

//#region String.prototype.trim - 去除字串前後空白
if (!String.prototype.trim) {
	String.prototype.trim = function () {
		//return this.replace(/[(^\s+)(\s+$)]/g,"");//會把字符串中間的空白也去掉  
		//return this.replace(/^\s+|\s+$/g,""); //  
		return this.replace(/^\s+/g, "").replace(/\s+$/g, "");
	};
}
//#endregion

//#region showBlockUI - 顯示畫面遮罩(叫用blockUI plugin)
function showBlockUI(param) {
    $.blockUI({
        message: "<div id=\"divProgress\">" +
        "<img id=\"imgLoading\" src=\"../images/loading.gif\" style=\"border-width:0px;\" /><br />" +
        "<h2 style=\"color:#aaaaaa\">" + param + "</h2>" +
        "</div>",
        //message: param,
        css: { borderWidth: '0px', backgroundColor: 'transparent' } //透明背景
    });
}
//#endregion

(function ($) {
    //#region $.isDate 判斷是否為日期
    $.isDate = function (strDate) {
        //alert(strDate);
        if (strDate == null) return false;
        if (strDate == undefined) return false;
        var dt_reg = new RegExp(/^\d{4}(\D)\d{1,2}(\D)\d{1,2}$/);
        var b = dt_reg.test(strDate);
        var s1 = "-";
        var s2 = "-";
        //console.log(strDate,b);
        if (b) {
            var dareDec = dt_reg.exec(strDate);
            s1 = dareDec[1];
            s2 = dareDec[2];
            var nn = Date.parse(strDate.replace(/\D/g, "/"));
            //alert(nn);
            if (isNaN(nn))
                b = false;
            else
                b = true;
        } else b = false;

        if (b) {
            //console.log(strDate, b);
            var nndt = new Date(strDate.replace(/\D/g, "/"));
            var str2 = nndt.getFullYear() + s1 + (nndt.getMonth() + 1) + s2 + nndt.getDate();
            //alert(str2);
            b = false;
            if (str2 == strDate.replace(s1 + "0", s1).replace(s2 + "0", s2)) b = true;
        }

        return b;
    }
    //#endregion

    //#region $.maskStart 顯示遮罩
    $.maskStart = function (msg) {
        var w = Math.max($(window).width(), $(document).width());
        var h = Math.max($(window).height(), $(document).height());

        if ($("body").find("#divProgress").length == 0) {
            $("body").append("<div id=\"divProgress\" style=\"display:none;\">" +
			"<img id=\"imgLoading\" src=\"../images/loading.gif\" style=\"border-width:0px;\" /><br />" +
			"<font color=\"#1B3563\">" + msg + "</font>" +
			"</div>");
        }

        if ($("body").find("#divMaskFrame").length == 0) {
            $("body").append("<div id=\"divMaskFrame\" style=\"display:none;\"></div>");
        }

        $("#divMaskFrame").css({
            'overflow': 'hidden',
            'background-color': '#F2F4F7',
            'width': w,
            'height': h,
            'position': 'absolute',
            'z-index': '999998',
            'opacity': '0.7',
            '-moz-opacity': '0.7',
            '-khtml-opacity': '0.7',
            'filter': 'alpha(opacity=70)',
            'top': '0',
            'left': '0'
        });

        var t = (h / 2) - ($("#divProgress").height() / 2);
        $("#divProgress").css({
            'text-align': 'center',
            'position': 'absolute',
            'top': t,
            'left': '50%',
            //'background-color': '#88bbff',
            'opacity': '0.9',
            '-moz-opacity': '0.9',
            '-khtml-opacity': '0.9',
            'filter': 'alpha(opacity=90)',
            'z-index': '999999'
        });


        $("body").css("cursor", "wait");
        $("#divMaskFrame").show();
        if (msg != "" && msg != undefined && msg != null) {
            $("#divProgress").show();
        }
    }
    //#endregion

    //#region $.maskStop 關閉遮罩
    $.maskStop = function (msg) {
        $("#divMaskFrame").fadeOut(500);
        $("#divProgress").fadeOut(500);
        $("body").css("cursor", "default");
    }
    //#endregion

    //#region labelfor 把radio/checkbox加上labelfor
    $.fn.labelfor = function () {
        var selectedObjects = this;
        $(selectedObjects).each(function () {
            var input = $(this);
            if (input.type == "radio" || input.type == "checkbox") {
                if ($(input).attr("id") != "") {
                    $(input).next("label").attr("for", $(input).attr("id"));
                }
            }
        });
        return selectedObjects;
    }
    //#endregion

    //#region lock 指定唯讀模式
    $.fn.lock = function (cond) {
        var selectedObjects = this;
        $(selectedObjects).each(function () {
            var input = $(this);
            if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
                if ($(input).hasClass("dateField")) {
                    //$(input).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
                    $(input).datepick('destroy');
                }
                if (this.type == "text" || this.type == "textarea" || this.type == "hidden") {
                    $(input).prop('readonly', true).addClass('SEdit');
                } else {
                    $(input).prop('disabled', true);
                }
            } else {
                if ($(input).hasClass("dateField")) {
                    //$(input).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
                    $(input).datepick('destroy');
                }
                $(input).prop('readonly', false).removeClass('SEdit').prop('disabled', false);
            }
        });
        return selectedObjects;
    }
    //#endregion

    //#region unlock 指定解鎖模式
    $.fn.unlock = function (cond) {
        var selectedObjects = this;
        $(selectedObjects).each(function () {
            var input = $(this);
            if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
                if ($(input).hasClass("dateField")) {
                    //$(input).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
                    $(input).datepick();
                }
                $(input).prop('readonly', false).removeClass('SEdit').prop('disabled', false);
            } else {
                if ($(input).hasClass("dateField")) {
                    //$(input).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
                    $(input).datepick();
                }
                if (this.type == "text" || this.type == "textarea" || this.type == "hidden") {
                    $(input).prop('readonly', true).addClass('SEdit');
                } else {
                    $(input).prop('disabled', true);
                }
            }
        });
        return selectedObjects;
    }
    //#endregion

    //#region hideFor 指定隱藏模式
    $.fn.hideFor = function (cond) {
        var selectedObjects = this;
        $(selectedObjects).each(function () {
            var input = $(this);
            if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
                if ($(input).hasClass("dateField")) {
                    $(input).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
                }
                $(input).hide();
            } else {
                if ($(input).hasClass("dateField")) {
                    $(input).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
                }
                $(input).show();
            }
        });
        return selectedObjects;
    }
    //#endregion

    //#region showFor 指定顯示模式
    $.fn.showFor = function (cond) {
        var selectedObjects = this;
        $(selectedObjects).each(function () {
            var input = $(this);
            if (typeof cond === "undefined" || cond) {//符合條件 或 沒給條件
                if ($(input).hasClass("dateField")) {
                    $(input).datepick("option", "showOnFocus", true).next(".datepick-trigger:first").show();
                }
                $(input).show();
            } else {
                if ($(input).hasClass("dateField")) {
                    $(input).datepick("option", "showOnFocus", false).next(".datepick-trigger:first").hide();
                }
                $(input).hide();
            }
        });
        return selectedObjects;
    }
    //#endregion

    //#region getOption
    $.fn.extend({
        getOption: function (option) {
            var obj = $(this);
            var defaults = {
                debug: false,
                url: "",
                data: null,
                dataList: null,
                showEmpty: true,//顯示"請選擇"
                valueFormat: "",//option的value格式,用{}包住欄位,ex:{scode}
                textFormat: "",//option的文字格式,用{}包住欄位,ex:{scode}_{sc_name}
                attrFormat: "",//option的attribute格式,用{}包住欄位,ex:value1='{scode1}' value2='{sscode}'
                firstOpt: "",//要在最上面額外增加option,ex:<option value='*'>全部<option>
                lastOpt: "",//要在最下面額外增加option,ex:<option value='*'>全部<option>
                setValue: ""//預設值
            };
            var settings = $.extend(defaults, option || {});  //初始化

            var debugurl = settings.url + "?";// + unescape(unescape($.param(settings.data)));
            if (settings.data != null) debugurl += unescape(unescape($.param(settings.data)));
            if (settings.debug) {
                if ($("body").find("#divDebug").length == 0) {
                    $("body").append("<div id=\"divDebug\" style=\"display:none;color:#1B3563\"></div>");
                }
                $("#divDebug").html("<a href=\"" + debugurl + "\" target=\"_blank\">Open getOption Debug Win<a>");
                $("#divDebug").show();
                $("#divDebug").fadeOut(5000);
            }

            return this.each(function () {
                var obj = $(this);
                obj.empty();

                if (settings.dataList == null) {
                    $.ajax({
                        async: false,
                        cache: false,
                        type: "get",
                        data: settings.data,
                        url: settings.url,
                        success: function (json) {
                            settings.dataList = $.parseJSON(json);
                        },
                        beforeSend: function (jqXHR, settings) {
                            jqXHR.url = settings.url;
                            //toastr.info("<a href='" + jqXHR.url + "' target='_new'>debug！\n" + jqXHR.url + "</a>");
                        },
                        error: function (xhr) {
                            $("#dialog").html("<a href='" + this.url + "' target='_new'>載入查詢清單發生錯誤(getOption)！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                            $("#dialog").dialog({ title: '載入查詢清單發生錯誤(getOption)！', modal: true, maxHeight: 500, width: "90%" });
                        }
                    });
                }

                if (settings.firstOpt != "") {
                    obj.append(settings.firstOpt);
                }
                if (settings.showEmpty) {
                    obj.append("<option value='' style='COLOR:blue'>請選擇</option>");
                }
                $.each(settings.dataList, function (i, item) {
                    //處理value
                    var val = settings.valueFormat;
                    //Object.keys(item).forEach(function (key) {
                    //    var re = new RegExp("{" + key + "}", "ig");
                    //    val = val.replace(re, item[key]);
                    //});
                    jQuery.each(Object.keys(item), function (ix, key) {
                        var re = new RegExp("{" + key + "}", "ig");
                        val = val.replace(re, item[key]);
                    });

                    //處理text
                    var txt = settings.textFormat;
                    //Object.keys(item).forEach(function (key) {
                    //    var re = new RegExp("{" + key + "}", "ig");
                    //    txt = txt.replace(re, item[key]);
                    //});
                    jQuery.each(Object.keys(item), function (ix, key) {
                        var re = new RegExp("{" + key + "}", "ig");
                        txt = txt.replace(re, item[key]);
                    });

                    //處理attribute
                    var attr = settings.attrFormat;
                    //Object.keys(item).forEach(function (key) {
                    //    var re = new RegExp("{" + key + "}", "ig");
                    //    attr = attr.replace(re, item[key]);
                    //});
                    jQuery.each(Object.keys(item), function (ix, key) {
                        var re = new RegExp("{" + key + "}", "ig");
                        attr = attr.replace(re, item[key]);
                    });

                    obj.append("<option value='" + val + "' " + attr + ">" + txt + "</option>");
                });
                if (settings.lastOpt != "") {
                    obj.append(settings.lastOpt);
                }

                obj.val(settings.setValue);


            });
        }
    });
    //#endregion

    //#region getRadio
    $.fn.extend({
        getRadio: function (option) {
            var obj = $(this);
            var defaults = {
                debug: false,
                url: "",
                data: null,
                dataList: null,
                mod: null,//幾個換行(<br>)
                objName: "",//radio的name(群組名)
                valueFormat: "",//radio的value格式,用{}包住欄位,ex:{scode}
                textFormat: "",//radio的文字格式,用{}包住欄位,ex:{scode}_{sc_name}
                attrFormat: "",//radio的attribute格式,用{}包住欄位,ex:value1='{scode1}' value2='{sscode}'
                setValue: ""//預設值
            };
            var settings = $.extend(defaults, option || {});  //初始化

            var debugurl = settings.url + "?";// + unescape(unescape($.param(settings.data)));
            if (settings.data != null) debugurl += unescape(unescape($.param(settings.data)));
            if (settings.debug) {
                if ($("body").find("#divDebug").length == 0) {
                    $("body").append("<div id=\"divDebug\" style=\"display:none;color:#1B3563\"></div>");
                }
                $("#divDebug").html("<a href=\"" + debugurl + "\" target=\"_blank\">Open getRadio Debug Win<a>");
                $("#divDebug").show();
                $("#divDebug").fadeOut(5000);
            }

            return this.each(function () {
                var obj = $(this);
                obj.empty();

                if (settings.dataList == null) {
                    $.ajax({
                        async: false,
                        cache: false,
                        type: "get",
                        data: settings.data,
                        url: settings.url,
                        success: function (json) {
                            settings.dataList = $.parseJSON(json);
                        },
                        beforeSend: function (jqXHR, settings) {
                            jqXHR.url = settings.url;
                            //toastr.info("<a href='" + jqXHR.url + "' target='_new'>debug！\n" + jqXHR.url + "</a>");
                        },
                        error: function (xhr) {
                            $("#dialog").html("<a href='" + this.url + "' target='_new'>載入查詢清單發生錯誤(getRadio)！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                            $("#dialog").dialog({ title: '載入查詢清單發生錯誤(getRadio)！', modal: true, maxHeight: 500, width: "90%" });
                        }
                    });
                }

                $.each(settings.dataList, function (i, item) {
                    //處理value
                    var val = settings.valueFormat;
                    //Object.keys(item).forEach(function (key) {
                    //    var re = new RegExp("{" + key + "}", "ig");
                    //    val = val.replace(re, item[key]);
                    //});
                    jQuery.each(Object.keys(item), function (ix, key) {
                        var re = new RegExp("{" + key + "}", "ig");
                        val = val.replace(re, item[key]);
                    });

                    //處理text
                    var txt = settings.textFormat;
                    //Object.keys(item).forEach(function (key) {
                    //    var re = new RegExp("{" + key + "}", "ig");
                    //    txt = txt.replace(re, item[key]);
                    //});
                    jQuery.each(Object.keys(item), function (ix, key) {
                        var re = new RegExp("{" + key + "}", "ig");
                        txt = txt.replace(re, item[key]);
                    });

                    //處理attribute
                    var attr = settings.attrFormat;
                    //Object.keys(item).forEach(function (key) {
                    //    var re = new RegExp("{" + key + "}", "ig");
                    //    attr = attr.replace(re, item[key]);
                    //});
                    jQuery.each(Object.keys(item), function (ix, key) {
                        var re = new RegExp("{" + key + "}", "ig");
                        attr = attr.replace(re, item[key]);
                    });

                    if (val.toLowerCase() == settings.setValue.toLowerCase())
                        obj.append("<label><input type='radio' id='" + settings.objName + val + "' name='" + settings.objName + "' value='" + val + "' " + attr + " checked>" + txt + "</label>");
                    else
                        obj.append("<label><input type='radio' id='" + settings.objName + val + "' name='" + settings.objName + "' value='" + val + "' " + attr + ">" + txt + "</label>");

                    if (settings.mod != null) {
                        if ((i + 1) % settings.mod == 0 && (i + 1) < settings.dataList.length) {
                            obj.append("<BR>");
                        }
                    }
                });
            });
        }
    });
    //#endregion

    //#region getCheckbox
    $.fn.extend({
        getCheckbox: function (option) {
            var obj = $(this);
            var defaults = {
                debug: false,
                url: "",
                data: null,
                dataList: null,
                mod: null,//幾個換行(<br>)
                objName: "",//checkbox的name(群組名)
                valueFormat: "",//checkbox的value格式,用{}包住欄位,ex:{scode}
                textFormat: "",//checkbox的文字格式,用{}包住欄位,ex:{scode}_{sc_name}
                attrFormat: "",//checkbox的attribute格式,用{}包住欄位,ex:value1='{scode1}' value2='{sscode}'
                setValue: ""//預設值
            };
            var settings = $.extend(defaults, option || {});  //初始化

            var debugurl = settings.url + "?";// + unescape(unescape($.param(settings.data)));
            if (settings.data != null) debugurl += unescape(unescape($.param(settings.data)));
            if (settings.debug) {
                if ($("body").find("#divDebug").length == 0) {
                    $("body").append("<div id=\"divDebug\" style=\"display:none;color:#1B3563\"></div>");
                }
                $("#divDebug").html("<a href=\"" + debugurl + "\" target=\"_blank\">Open getcheckbox Debug Win<a>");
                $("#divDebug").show();
                $("#divDebug").fadeOut(5000);
            }

            return this.each(function () {
                var obj = $(this);
                obj.empty();

                if (settings.dataList == null) {
                    $.ajax({
                        async: false,
                        cache: false,
                        type: "get",
                        data: settings.data,
                        url: settings.url,
                        success: function (json) {
                            settings.dataList = $.parseJSON(json);
                        },
                        beforeSend: function (jqXHR, settings) {
                            jqXHR.url = settings.url;
                            //toastr.info("<a href='" + jqXHR.url + "' target='_new'>debug！\n" + jqXHR.url + "</a>");
                        },
                        error: function (xhr) {
                            $("#dialog").html("<a href='" + this.url + "' target='_new'>載入查詢清單發生錯誤(getCheckbox)！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                            $("#dialog").dialog({ title: '載入查詢清單發生錯誤(getCheckbox)！', modal: true, maxHeight: 500, width: "90%" });
                        }
                    });
                }

                $.each(settings.dataList, function (i, item) {
                    //處理value
                    var val = settings.valueFormat;
                    //Object.keys(item).forEach(function (key) {
                    //    var re = new RegExp("{" + key + "}", "ig");
                    //    val = val.replace(re, item[key]);
                    //});
                    jQuery.each(Object.keys(item), function (ix, key) {
                        var re = new RegExp("{" + key + "}", "ig");
                        val = val.replace(re, item[key]);
                    });

                    //處理text
                    var txt = settings.textFormat;
                    //Object.keys(item).forEach(function (key) {
                    //    var re = new RegExp("{" + key + "}", "ig");
                    //    txt = txt.replace(re, item[key]);
                    //});
                    jQuery.each(Object.keys(item), function (ix, key) {
                        var re = new RegExp("{" + key + "}", "ig");
                        txt = txt.replace(re, item[key]);
                    });

                    //處理attribute
                    var attr = settings.attrFormat;
                    //Object.keys(item).forEach(function (key) {
                    //    var re = new RegExp("{" + key + "}", "ig");
                    //    attr = attr.replace(re, item[key]);
                    //});
                    jQuery.each(Object.keys(item), function (ix, key) {
                        var re = new RegExp("{" + key + "}", "ig");
                        attr = attr.replace(re, item[key]);
                    });

                    if (val.toLowerCase() == settings.setValue.toLowerCase())
                        obj.append("<label><input type='checkbox' id='" + settings.objName + val + "' name='" + settings.objName + "' value='" + val + "' " + attr + " checked>" + txt + "</label>");
                    else
                        obj.append("<label><input type='checkbox' id='" + settings.objName + val + "' name='" + settings.objName + "' value='" + val + "' " + attr + ">" + txt + "</label>");

                    if (settings.mod != null) {
                        if ((i + 1) % settings.mod == 0 && (i + 1) < settings.dataList.length) {
                            obj.append("<BR>");
                        }
                    }
                });
            });
        }
    });
    //#endregion

})(jQuery);


//#region 畫面載入時綁定function & 行為
$(function () {
    ///////////////////////////////////////////////////////////////
    //分頁相關
    //設定表頭排序圖示
    $(".setOdr").each(function (i) {
        $(this).remove("span.odby");
        if ($(this).attr("v1").toLowerCase() == $("#SetOrder").val().toLowerCase()) {
            //$(this).append("<span class='odby'>▲</span>");//⇧
            $(this).after("<span class='odby'>▲</span>");
        }
    });
    //每頁幾筆
    $("body").on("change", "#PerPage", function (e) {
        //$("#PerPage").change(function (e) {
        $("#GoPage").val("1");//回到第一頁
        goSearch();
    });
    //指定第幾頁
    $("body").on("change", "#GoPage", function (e) {
        //$("#divPaging").on("change", "#GoPage", function (e) {
        goSearch();
    });
    //上下頁
    $("body").on("click", ".pgU,.pgD", function (e) {
        //$(".pgU,.pgD").click(function (e) {
        $("#GoPage").val($(this).attr("v1"));
        goSearch();
    });
    //排序
    $("body").on("click", ".setOdr", function (e) {
        //$(".setOdr").click(function (e) {
        $("#GoPage").val("1");//回到第一頁
        $("#SetOrder").val($(this).attr("v1"));
        goSearch();
    });
    //重新整理
    $("body").on("click", ".imgRefresh", function (e) {
        //$(".imgRefresh").click(function (e) {
        goSearch();
    });
    //查詢條件
    $("body").on("click", ".imgQry", function (e) {
        //$(".imgQry").click(function (e) {
        $("#id-div-slide").slideToggle("fast");
    });
    //關閉視窗
    $("body").on("click", ".imgCls", function (e) {
        //$(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            //if (window.parent.Etop.goSearch !== undefined) {
            //    window.parent.Etop.goSearch();
            //}
            window.parent.tt.rows = "100%,0%";
        } else {
            if (window.parent.$('.ui-dialog-content:visible').length > 0) {
                window.parent.$('.ui-dialog-content:visible').dialog('destroy').empty();
                //window.parent.$('#dialog').dialog('close');
            } else {
                window.close();
            }
        }
    });
    ///////////////////////////////////////////////////////////////

    //若有 ☑測試 預設打勾
    $("#ActFrame").hide();//取消使用ActFrame
    $("#chkTest").click(function (e) {
        $("#ActFrame").showFor($(this).prop("checked"));
        $(".bsubmit").prop("disabled", false);
    });
    //$("#chkTest").prop("checked", true).triggerHandler("click");
    $("#chkTest").prop("checked", false).triggerHandler("click");//預設不勾
});
//#endregion
