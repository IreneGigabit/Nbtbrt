<script language="javascript" type="text/javascript">
//檢查輸入資料及存檔前是否可立案收文
//pjob_branch: 系統區所別
//pkeytype: cappl_name:案件名稱(中)、eappl_name: 案件名稱(英)、ap_cname:公司/行號/人名稱(中)、ap_ename:公司/行號/人名稱(英)、
//          ap_crep:代表人(中)、ap_erep:代表人(英)
//pkeydata: 關鍵字

//案件名稱檢查
function appl_name_watch(pvalue,pmaxlength,palt){
    //檢查長度
    fDataLen(pvalue,pmaxlength,palt);
    
    //檢查是否為雙邊代理查照對象
    if (check_CustWatch("appl_name",pvalue)) {
        return false;
    }
}
//客戶/申請人名稱檢查,pvalue中文欄位資料,pevalue英文欄位資料
function cust_name_chk(pvalue,pevalue){
    if (check_CustWatch("ap_cname",pvalue)){
        return true;
    }
    if (check_CustWatch("ap_ename",pevalue)) { 
        return true;
    }
    return false;
}
//客戶/申請人代表人檢查
function aprep_name_chk(pvalue,pevalue){
    if (check_CustWatch("ap_crep",pvalue)){
        return true;
    }
    if (check_CustWatch("ap_erep",pevalue)) { 
        return true;
    }
    return false;
}

function check_CustWatch(pchk,pvalue){
    var pjob_branch="<%=Session["SeBranch"]%>";
    //檢查是否為雙邊代理查照對象
    if (pchk=="cappl_name" || pchk=="appl_name"){
        if (pvalue!=""){
            if (check_ctrl_keydata(pjob_branch,"cappl_name",pvalue) == "A"){//A:不可立案,B:提醒
                return true;
            }
        }
    }
    if (pchk=="eappl_name" || pchk=="appl_name"){
        if (pvalue!=""){
            if (check_ctrl_keydata(pjob_branch,"eappl_name",pvalue) == "A"){//A:不可立案,B:提醒
                return true;
            }
        }
    }
    if (pchk=="cappl_name" || pchk=="appl_name"){
        if (pvalue!=""){
            if (check_ctrl_keydata(pjob_branch,pchk,pvalue) == "A"){//A:不可立案,B:提醒
                return true;
            }
        }
    }
    return false;
}

function check_ctrl_keydata(pjob_branch,pkeytype,pkeydata){
    var rtn= "Z";
    var searchSql = "select a.*,(select code_name from cust_code where code_type='keytype' and cust_code=b.keytype) as keytypenm";
    searchSql+= ",(select branchname from sysctrl.dbo.branch_code where branch=a.in_branch) as in_branchnm";
    searchSql+= " from query_main a inner join query_detail b on a.query_sqlno=b.query_sqlno";
    searchSql+= " and b.keytype='"+ pkeytype +"' and b.keydata='"+ pkeydata+"'";
    searchSql+= " where 1=1 ";
    searchSql+= " and a.query_stat='YZ' and stat_code<>'N'";
    searchSql+= " and a.ctrl_dates<='"+(new Date()).format("yyyy/MM/dd")+"'";
    searchSql+= " and a.ctrl_datee>='"+(new Date()).format("yyyy/MM/dd")+"'";

    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/JsonGetSqlDataSidbs.aspx",
        data: { sql: searchSql },
        async: false,
        cache: false,
        success: function (json) {
            var JSONdata = $.parseJSON(json);
            if (JSONdata.length > 0) {
                rtn = "B";  //提示
                var tmsg = "本案申請人因前有爭訟案件自"+dateReviver(JSONdata[0].ctrl_dates, "yyyy年M月d日")+"起列管至"+dateReviver(JSONdata[0].ctrl_datee, "yyyy年M月d日")+"，";
                tmsg+= "詳情請至雙邊代理查照結果查詢輸入流水號「"+JSONdata[0].query_sqlno+"」。";
                tmsg+= "\n欲入案請先獲得「"+JSONdata[0].in_branchnm+"」單位允許。";
                tmsg+= "\n\n按「是」表回畫面修改，按「否」表繼續執行作業 !!!";
                if (confirm(tmsg)){
                    rtn = "A";
                }
            }
        },
        error: function () { toastr.error("<a href='" + this.url + "' target='_new'>檢查是否為雙邊代理查照對象失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>"); }
    });
    return rtn;
}
</script>
