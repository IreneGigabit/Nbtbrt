//判斷字串是否為JSON格式
function isJSON(str) {
    if (typeof str == 'string') {
        try {
            var obj = JSON.parse(str);
            if (typeof obj == 'object' && obj) {
                return true;
            } else {
                return false;
            }
        } catch (e) {
            return false;
        }
    }
    return false;
}

//pStr:字串
//pLen:資料最大長度,若傳入0則傳回資料長度
//pmsg:欄位名稱,若Error則回傳 ""
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

//check field null:檢查物件值不可為空白
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

//check field null:檢查物件值不可為空白
function chkNull2(pFieldName,pObj)
{
    if (pObj.value=="") {
        $(pObj).addClass("chkError");
        return pFieldName + "必須輸入!!!<BR>";
    }
    $(pObj).removeClass("chkError");
    return "";
}

//check field integer:檢查物件值不可為小數
function chkInt(pFieldName,pObj){
    if (pObj instanceof jQuery) pObj = pObj[0];//jquery selector要加[0]
    if (Math.floor(pObj.value) === pObj.value) {
        return false;
    }else{
        alert(pFieldName+"必須為整數，請重新輸入!!!");
        return true;
    }
}


//檢查日期格式
function ChkDate(pObj) {//=chkdateformat
    if (pObj instanceof jQuery) pObj = pObj[0];//jquery selector要加[0]
    if (pObj.value=="")return false;
    if ($.isDate(pObj.value)==false){
        alert("日期格式錯誤，請重新輸入!!! 日期格式:YYYY/MM/DD");
        pObj.focus();
        return true;
    }
}

/*
chkSEDate: 起始日不可大於迄止日
chkEDate:	檢查西元年輸入正確否
*/
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

function chkNum(pValue, pmsg) {
    if (pValue != "") {
        if (!IsNumeric(pValue)) {
            alert(pmsg + "必須為數值!!!");
            return true;
        }
    } else {
        return false;
    }
}

function chkNum1(pObj, pmsg) {
    if (pObj.value != "") {
        if (!IsNumeric(pObj.value)) {
            alert(pmsg + "必須為數值!!!");
            pObj.focus();
            return true;
        }
    } else {
        return false;
    }
}

function chkRadio(pFieldName, pmsg){
    if($("input[name='"+pFieldName+"']:checked").length!=0){
        return true;
    }else{
        alert("請選擇" + pmsg + "！");
        return false;
    }
}

//內商申請號與註冊號之不足位數補0
function chkgno(pvalue,plen){
    pvalue = pvalue.trim();//2012/12/12修改，因發現輸入有空白，所以trim掉後補足
    if (pvalue == "") return "";
    return padLeft(pvalue,plen,"0");//左邊補0
}


//檢查申請號並補足9碼
function chk_dmt_applyno(pobject,plen){
    var pvalue=pobject.value;
    
    if (chkNum(pvalue,"申請號")) return false;
    if (fDataLenX(pvalue, plen, "申請號")) return false;
    var tno=chkgno(pvalue,plen);
    pobject.value=tno;
}

//檢查註冊號號並補足8碼
function chk_dmt_issueno(pobject, plen) {
    var pvalue = pobject.value;

    if (chkNum(pvalue, "註冊號")) return false;
    if (fDataLenX(pvalue, plen, "註冊號")) return false;
    var tno = chkgno(pvalue, plen);
    pobject.value = tno;
}

//檢查核駁號並補足7碼
function chk_dmt_rejno(pobject, plen) {
    var pvalue = pobject.value;

    if (chkNum(pvalue, "核駁號")) return false;
    if (fDataLenX(pvalue, plen, "核駁號")) return false;
    var tno = chkgno(pvalue, plen);
    pobject.value = tno;
}