//#region isJson - 檢查是否為json格式
function isJson(str) {
    try {
        $.parseJSON(str);
    } catch (e) {
        return false;
    }
    return true;
}
//#endregion

//#region fDataLen - 檢查字串長度
function fDataLen(pObj) {
    if (pObj instanceof jQuery) pObj = pObj[0];//jquery selector要加[0]
    var tLen = pObj.value.CodeLength();
    var pLen = pObj.maxLength;
    var pmsg = pObj.alt;
    if(pLen==0 || tLen<=pLen) {
        return false;
    }else{
        alert(pmsg+"長度過長，請檢查!!!");
        return true;
    }
}
//#endregion

//#region fDataLenX - 檢查字串長度
//pStr:字串
//pLen:資料最大長度,若傳入0則傳回資料長度
//pmsg:欄位名稱,若Error則回傳 ""
function fDataLenX(pStr, pLen, pmsg) {
    var tLen=pStr.CodeLength();
    if(pLen==0 || tLen<=pLen) {
        return tLen;
    }else{
        alert(pmsg+"長度過長，請檢查!!!");
        return "";
    }
}
//#endregion

//#region fChkDataLen - 檢查字串長度
//pObj:檢查長度之物件
//pmsg:欄位名稱,若Error則回傳 ""
function fChkDataLen(pObj,pmsg){
    pObj.value = pObj.value.ReplaceAll("&","＆");
    pObj.value = pObj.value.ReplaceAll("'","’");

    var tLen=pObj.value.CodeLength();
    var pLen=pObj.maxLength;
    if(pObj.maxLength==0 || tLen<=pLen) {
        return tLen;
    }else{
        var tc =  pLen / 2;
        var te =  pLen;
        alert(pmsg+" 長度過長，請檢查! \r\n(提示=中文字最多: " + tc + "個字 / 英文字最多: " + te + "個字)");
        pObj.focus();
        return "";
    }
}
//#endregion

//#region chkNull - 檢查物件值不可為空白
function chkNull(pFieldName,pObj)
{
    if (pObj instanceof jQuery) pObj = pObj[0];//jquery selector要加[0]
    if (pObj.value == "") {
        alert(pFieldName+"必須輸入!!!");
        pObj.focus();
        return true;
    }
    return false;
}
//#endregion

//#region chkNull2 - 檢查物件值不可為空白
function chkNull2(pFieldName,pObj)
{
    if (pObj.value=="") {
        $(pObj).addClass("chkError");
        return pFieldName + "必須輸入!!!<BR>";
    }
    $(pObj).removeClass("chkError");
    return "";
}
//#endregion

//#region ChkDate - 檢查日期格式=chkdateformat
function ChkDate(pObj) {//=chkdateformat
    if (pObj instanceof jQuery) pObj = pObj[0];//jquery selector要加[0]
    if (pObj.value=="")return false;
    if ($.isDate(pObj.value)==false){
        alert("日期格式錯誤，請重新輸入!!! 日期格式:YYYY/MM/DD");
        pObj.focus();
        return true;
    }
}
//#endregion

//#region chkSEDate - 檢查起始日不可大於迄止日
function chkSEDate(pSdate, pEdate, pmsg){
    if (pSdate == "" || pEdate == "") {
        return true;
    }
    if (Date.parse(new Date(pSdate)) > Date.parse(new Date(pEdate))) {
        alert(pmsg + "起始日不可大於迄止日");
        return false;
    }
    return true;
}
//#endregion

//#region chkNum - 檢查必須為數值(可空白)
function chkNum(pValue, pmsg) {
    if (pValue != "") {
        if (!IsNumeric(pValue)) {
            alert(pmsg + "必須為數值!!!");
            return true;
        }
    }
    return false;
}
//#endregion

//#region chkNum1 - 檢查必須為數值(可空白)
function chkNum1(pObj, pmsg) {
    if (pObj instanceof jQuery) pObj = pObj[0];//jquery selector要加[0]
    if (pObj.value != "") {
        if (!IsNumeric(pObj.value)) {
            alert(pmsg + "必須為數值!!!");
            pObj.focus();
            return true;
        }
    }
    return false;
}
//#endregion

//#region chkInt - 檢查物件值不可為小數
function chkInt(pObj, pFieldName) {
    if (pObj instanceof jQuery) pObj = pObj[0];//jquery selector要加[0]

    var num=parseFloat(pObj.value || 0, 10);
    if (Math.floor(num) ===num) {
        return false;
    } else {
        alert(pFieldName + "必須為整數，請重新輸入!!!");
        return true;
    }
}
//#endregion

//#region chkRadio - 檢查Radio須任取一
function chkRadio(pFieldName, pmsg) {
    if($("input[name='"+pFieldName+"']:checked").length!=0){
        return true;
    }else{
        alert("請選擇" + pmsg + "！");
        return false;
    }
}
//#endregion

//#region dmt_IMG_Click - 連結內商查詢期限管制、進度查詢及交辦內容
function dmt_IMG_Click(pType) {
    if ($("#seq").val() != "") {
        switch (pType) {
            case 1://期限管制
                var url=getRootPath() + "/brtam/brta21disEdit.aspx?prgid=" + $("#prgid").val() + "&seq=" + $("#seq").val() + "&seq1=" + $("#seq1").val() + "&qtype=A&rsqlno=&step_grade=&submitTask=Q";
                window.open(url, "myWindowOneN", "width=780 height=490 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
                //$('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
                //.dialog({ autoOpen: true, modal: true, height: 490, width: 780, title: "期限管制" });
                break;
            case 2: //收發進度
                var url = getRootPath() + "/brtam/brta61_Edit.aspx?submitTask=Q&qtype=A&closewin=Y&winact=1&aseq=" + $("#seq").val() + "&aseq1=" + $("#seq1").val();
                window.open(url, "myWindowOneN", "width=900 height=700 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
                //$('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
                //.dialog({ autoOpen: true, modal: true, height: 680, width: 900, title: "收發進度" });
                break;
            case 4://交辦內容
                var url = getRootPath() + "/brt4m/brt13_List.aspx?prgid=" + $("#prgid").val() + "&pfx_seq=" + $("#seq").val() + "&pfx_seq1=" + $("#seq1").val() + "&submitTask=Q";
                window.open(url, "myWindowOneN", "width=780 height=490 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
                //$('#dialog').html('<iframe style="border: 0px;" src="' + url + '" width="100%" height="100%"></iframe>')
                //.dialog({ autoOpen: true, modal: true, height: 490, width: 780, title: "期限管制" });
                break;
        }
    } else {
        alert("請先輸入本所編號後再執行查詢功能!!");
    }
}
//#endregion

//#region chkgno - 內商申請號與註冊號之不足位數補
function chkgno(pvalue, plen) {
    pvalue = pvalue.trim();//2012/12/12修改，因發現輸入有空白，所以trim掉後補足
    if (pvalue == "") return "";
    return padLeft(pvalue,plen,"0");//左邊補0
}
//#endregion

//#region chk_dmt_applyno - 檢查申請號並補足
function chk_dmt_applyno(pobject, plen) {
    var pvalue=pobject.value;
    
    if (chkNum(pvalue,"申請號")) return false;
    if (fDataLenX(pvalue, plen, "申請號")=="") return false;
    var tno=chkgno(pvalue,plen);
    pobject.value=tno;
}
//#endregion

//#region chk_dmt_issueno - 檢查註冊號號並補足
function chk_dmt_issueno(pobject, plen) {
    var pvalue = pobject.value;

    if (chkNum(pvalue, "註冊號")) return false;
    if (fDataLenX(pvalue, plen, "註冊號") == "") return false;
    var tno = chkgno(pvalue, plen);
    pobject.value = tno;
}
//#endregion

//#region chk_dmt_rejno - 檢查核駁號並補足7碼
function chk_dmt_rejno(pobject, plen) {
    var pvalue = pobject.value;

    if (chkNum(pvalue, "核駁號")) return false;
    if (fDataLenX(pvalue, plen, "核駁號") == "") return false;
    var tno = chkgno(pvalue, plen);
    pobject.value = tno;
}
//#endregion

//#region fseq_chk - 檢查本所編號7碼
function fseq_chk(pObject) {
    if (pObject.value != "") {
        var b = pObject.value.trim();
        if (b.Right(1) == ",") {
            alert("最後的本所編號不可有逗號!");
            pObject.focus();
            return;
        }

        var b1 = b.split(",");
        for (var i = 0; i < b1.length; i++) {
            if (isNaN(b1[i])) {
                alert("『" + b1[i] + "』需為數值!");
                pObject.focus();
                return;
            }
        }
    }
}
//#endregion
