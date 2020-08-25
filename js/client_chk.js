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
function fDataLen(pStr, pLen, pmsg) {
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
    if (pObj.value=="") {
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
    if (Math.floor(pObj.value) === pObj.value){
        return false;
    }else{
        alert(pFieldName+"必須為整數，請重新輸入!!!");
        return true;
    }
}


//檢查日期格式
function ChkDate(pObj) {//=chkdateformat
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
    if (new Date(pSdate) > new Date(pEdate)) {
        alert(pmsg + "起始日不可大於迄止日");
        return false;
    }
    return true;
}

function isNumeric(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

function chkNum(pValue, pmsg) {
    if (pValue != "") {
        if (!isNumeric(pValue)) {
            alert(pmsg + "必須為數值!!!");
            return true;
        }
    } else {
        return false;
    }
}

function chkNum1(pObj, pmsg) {
    if (pObj.value != "") {
        if (!isNumeric(pObj.value)) {
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
