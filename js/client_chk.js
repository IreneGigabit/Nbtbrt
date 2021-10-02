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

//#region fChkDataLen - 檢查字串長度
//pObj:檢查長度之物件
//pmsg:欄位名稱,若Error則回傳 ""
//同上方fChkDataLen，增加指定長度ChkLen
function fChkDataLen2(pObj, ChkLen, pmsg) {
    pObj.value = pObj.value.ReplaceAll("&", "＆");
    pObj.value = pObj.value.ReplaceAll("'", "’");

    var tLen = pObj.value.CodeLength();
    if (tLen != ChkLen) {
        //var tc = pLen / 2;
        //var te = pLen;
        alert(pmsg + "需為" + ChkLen + "碼，請檢查!");
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

//#region chkID - 編審(身份證字號,統一編號)
/*	傳入參數:	1.pUserID:身份證字號:10位文數字,統一編號:8位數字
				2.pType:ID:編審身份證字號,TaxID:編審統一編號
	傳回參數:Boolean:True不正確,False正確	*/
function chkID(pUserID, pType) {
    var ix_I;
    if (pUserID == "") { return false; }
    switch (pType) {
        case "ID": //編審身份證字號
            var tAreaNo;
            var tCheckSum;
            var tAreaCode;
            var tSecondID;         //身份證第二碼

            pUserID = pUserID.toUpperCase();
            tAreaCode = pUserID.substr(0, 1);
            if (pUserID.length != 10)  //確定身份證字號有10碼
            {
                alert("輸入無效的身份證字號 (ex:資料長度錯誤) !");
                return true;
            }
            if (tAreaCode.valueOf() < "A" && tAreaCode.valueOf() > "Z")  //確定首碼在A-Z之間
            {
                alert("輸入無效的身份證字號 (ex:首碼應介於A-Z之間) !");
                return true;
            }
            if (isNaN(parseInt(pUserID.substring(1, 10), 10)) == true)  //確定2-10碼是數字
            {
                alert("輸入無效的身份證字號 (ex:第2-10碼須是數字) !");
                return true;
            }
            //身份證號碼第 2 碼必須為 1 或 2
            tSecondID = pUserID.substr(1, 1);
            if (tSecondID != 1 && tSecondID != 2) {
                alert("輸入無效的身份證字號 !");
                return true;
            }
            //取得首碼對應的區域碼，A ->10, B->11, ..H->17,I->34, J->18...
            tAreaNo = "ABCDEFGHJKLMNPQRSTUVXYWZIO".search(tAreaCode) + 10;
            pUserID = tAreaNo.toString(10) + pUserID.substring(1, 10);

            //  取得CheckSum的值,核對身份證號碼是否正確
            //  A = 第1碼, A0 = 第1碼*(10-1), A1 = 第2碼*(10-2), A2 = 第3碼*(10-3)
            //  A3 = 第4碼*(10-4), A4 = 第5碼*(10-5), A5 = 第6碼*(10-6)
            //  A6 = 第7碼*(10-7), A7 = 第8碼*(10-8), A8 = 第9碼*(10-9)
            //  CheckSum = A+A0+A1+A2+A3+A4+A5+A6+A7+A8

            tCheckSum = parseInt(pUserID.substr(0, 1), 10) + parseInt(pUserID.substr(10, 1), 10);
            for (ixI = 1; ixI <= 9; ixI++)
            { tCheckSum = tCheckSum + parseInt(pUserID.substr(ixI, 1), 10) * (10 - ixI); }
            if ((tCheckSum % 10) != 0) {
                alert("輸入無效的身份證字號 !");
                return true;
            }
            return false;
            break;

        case "TaxID": //編審統一編號
            var tSum = 0;
            var tDiv = 0;
            var tMod = 0;
            var tStr = "12121241";

            if (parseInt(pUserID.substring(0, 8), 10) != pUserID) //確定1-8碼是數字 
            {
                alert("輸入無效的統一編號 (ex:須為8位數字)!");
                return true;
            }
            if (isNaN(parseInt(pUserID.substring(0, 8), 10)) == true) //確定1-8碼是數字
            {
                alert("輸入無效的統一編號 (ex:須為8位數字)!");
                return true;
            }
            for (ixI = 0; ixI <= 7; ixI++)//套公式編審
            {
                tDiv = parseInt(parseInt(pUserID.substr(ixI, 1), 10) * parseInt(tStr.substr(ixI, 1)) / 10);
                tMod = parseInt(parseInt(pUserID.substr(ixI, 1), 10) * parseInt(tStr.substr(ixI, 1)) % 10);
                tSum = tSum + tDiv + tMod;
            }
            tSum = parseInt(tSum % 10);

            if ((tSum == 0 || tSum == 9) && pUserID.substr(6, 1) == "7")
            { return false; } //正確
            if (tSum == 0)
            { return false; } //正確
            else
            {
                alert("輸入無效的統一編號 !"); //不正確
                return true;
            }
            break;
    }
}
//#endregion
