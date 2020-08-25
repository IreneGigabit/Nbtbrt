//獲取web ap根路徑 ex:http://web02/nOpt
function getRootPath() {
    var strFullPath = window.document.location.href;
    var strPath = window.document.location.pathname;
    var pos = strFullPath.indexOf(strPath);
    var prePath = strFullPath.substring(0, pos);
    var postPath = strPath.substring(0, strPath.substr(1).indexOf('/') + 1);
    return (prePath + postPath);
}

//獲取web ap根目錄 ex:nOpt
function getRootDir() {
    var strPath = window.document.location.pathname;
    var postPath = strPath.substring(0, strPath.substr(1).indexOf('/') + 1);
    return postPath;
}

//串接欄位的值
function getValueStr(selector, symbol) {
    return $(selector).map(function () {
        return $(this).val();
    }).get().join(symbol);
}

/*ajax function(get)*/
function ajaxByGet(url, param) {
    return $.ajax({
        url: url,
        type: "get",
        cache: false,
        async: false,
        data: param
    });
}

/*ajax function(post)*/
function ajaxByPost(url, param) {
    return $.ajax({
        url: url,
        type: "post",
        cache: false,
        async: false,
        data: JSON.stringify(param)
    });
}

//將&#nnnn;轉為字元
function decodeStr(encodedString) {
    var textArea = document.createElement('textarea');
    textArea.innerHTML = encodedString;
    return textArea.value;
}

//#region NulltoEmpty 若為null回傳空字串
function NulltoEmpty(s) {
    if (s == null || s == undefined) return "";
    return s;
}
//#endregion

//#region 四捨五入
function xRound(num, pos) {
    var size = Math.pow(10, (pos || 0));
    return Math.round(num * size) / size;
    //return Math.round(Math.round(val * Math.pow(10, (pos || 0) + 1)) / 10) / Math.pow(10, (pos || 0));
}
//#endregion

//#region dateReviver
//json日期格式返回new Date格式
//dateConvert(jOpt.last_date);
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
//end region

//#region dateReviver
//json日期格式轉指定格式
//dateReviver(jOpt.last_date, "yyyy/M/d");
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
//end region

//#region Date.prototype.format
//js日期格式fotmat轉換
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
//#end region

//#region Date.prototype.addDays
//js日期加上 X 天
//var today = new Date();
//today.addDays(7);
Date.prototype.addDays = function (days) {
    this.setDate(this.getDate() + days);
    return this;
}
//#end region

//#region Date.prototype.addMonths
//js日期加上 X 月
//var today = new Date();
//today.addMonths(7);
Date.prototype.addMonths = function (months) {
    this.setDate(this.getMonth() + months);
    return this;
}
//#end region

/*將數值轉換貨幣表示法
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

String.prototype.ReplaceAll = function (s1, s2) {
    return this.replace(new RegExp(s1, "gm"), s2);
}

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

String.prototype.Left = function (n) {
	if (n <= 0)
		return "";
	else if (n > String(this).length)
		return this;
	else
		return String(this).substring(0, n);
}

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

//#region CodeLength計算字元長度(英數=1,中文=2)
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

if (!String.prototype.trim) {
	String.prototype.trim = function () {
		//return this.replace(/[(^\s+)(\s+$)]/g,"");//會把字符串中間的空白也去掉  
		//return this.replace(/^\s+|\s+$/g,""); //  
		return this.replace(/^\s+/g, "").replace(/\s+$/g, "");
	};
}

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

//靜態函式
(function ($) {
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
})(jQuery);
$(document).ajaxStart(function () { $.maskStart("資料載入中"); });
$(document).ajaxStop(function () { $.maskStop(); });
$(function () {
    //若有 ☑測試 預設打勾
    $("#chkTest").click(function (e) {
        $("#ActFrame").showFor($(this).prop("checked"));
    });
    $("#chkTest").prop("checked", true).triggerHandler("click");
});
