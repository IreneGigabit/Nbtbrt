//檢查契約書種類是否有上傳相對應文件種類
//目前只針對總契約書
//pdept:T國內案TE出口案、pvalue:輸入的契約書種類、pchktype:A不可交辦B提醒
function check_doctype(pdept, pvalue, pchktype) {
    if (pvalue == "M") {
        //依據經營會報101年6月份經營會報應執行事項決議：
        //簽訂總契約書的客戶交辦案件時，應另提供由客戶窗口人員具名之委辦書。
        pdoc_type = "082";	//客戶案件委辦書
        if (check_ctrl_doctype(pdept, pdoc_type, pchktype) == "A") { //A:不可交辦,B:提醒
            return true;
        }
    }
    return false;
}

function check_ctrl_doctype(pdept,pdoc_type,pchktype){
    var rtn = "Z";
    var fld=$("#uploadfield").val();
    var sqlnum=CInt($("#"+fld+"_filenum").val());
    var doctype_name=$("#doc_type").val();
    if (pdept=="TE") doctype_name="doc_code";

    //檢查上傳筆數
    if (sqlnum==0){
        check_ctrl_doctype = "B" 
    }else{
        for i=1 to cint(sqlnum)
		    IF eval("reg." & fld &i&".value")<>empty	then  
                if trim(pdoc_type)=trim(eval("reg." & doctype_name &i&".value")) then
                    check_ctrl_doctype = "Z"
                    exit for
            else
                    check_ctrl_doctype = "B"  '提示
                end if
            end if
        next
    }
    if check_ctrl_doctype = "B" then  '提示	
        if pchktype="A" then
            tmsg = "簽訂總契約書的客戶交辦案件時，應再上傳客戶案件委辦書，請先上傳後再執行後續作業。(如需先交辦客收再後補，請勾選契約書相關文件後補，如不能勾選，請退回營洽修改)"
            msgbox tmsg
            check_ctrl_doctype = "A"	'不能交辦
        end if
        if pchktype="B" then		
            tmsg = "簽訂總契約書的客戶交辦案件時，應再上傳客戶案件委辦書，是否先上傳後再交辦？(如需先交辦客收再後補，請點選「是」回畫面後再勾選契約書相關文件後補)"
            ans = msgbox(tmsg,vbYesNo+vbdefaultbutton1)
            if ans=vbYes then
                check_ctrl_doctype = "A"	'不能交辦
            end if
        end if	
    end if	

    return rtn;
        }

function check_ctrl_agtno(pchk, pvalue) {
    var rtn = "Z";
    var tagt_no = get_tagtno(pchk);

    if (pvalue.trim() != tagt_no.no.trim()) {
        rtn = "B";  //提示	
        var tmsg = "涉外之進口案件的出名代理人應設定「" + tagt_no.no + "_" + tagt_no.fullname + "」，是否確定交辦？";
        if (!confirm(tmsg)) {
            rtn = "A";//不能交辦
        }
    }
    return trn;
}

