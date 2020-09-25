//檢查輸入出名代理人是否與預設出名代理人相同
//pchk:N一般案、C涉外案
//pvalue:輸入的出名代理人
function check_agtno(pchk, pvalue) {
    if (pvalue != "") {
        if (check_ctrl_agtno(pchk, pvalue) == "A") {//A:不可交辦,B:提醒
            return true;
        }
    }
    return false;
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


//抓取現行預設出名代理人
function get_tagtno(pchk) {
    var tagt_no = { no: "", name: "", fullname: "" };
    //N:一般案件預設出名代理人
    //C:涉外案件預設出名代理人
    if (pchk == "C") {
        tagt_no.tagt_no = "A32";//2017/3/24修改涉外案為A32，依2017/3/15發佈業務出名配置表，2017/4/1涉外案改為劉&尹&(&惲)
        tagt_no.name = "劉＆尹(＆惲)";
        tagt_no.fullname = "劉法正＆尹重君(＆惲軼群)(涉外案-國際)";
    } else {
        tagt_no.tagt_no = "A19";
        tagt_no.name = "高＆楊(＆吳)";
        tagt_no.fullname = "高玉駿＆楊祺雄(＆吳俊彥)(聖島國際)";
    }

    var searchSql = "select mark,remark,cust_code,form_name as agt_name ";
    searchSql += ",(select agt_namefull from agt where agt_no=cust_code) as agt_namefull ";
    searchSql += "from cust_code ";
    searchSql += "where code_type='Tagt_no' ";
    searchSql += "and mark='" + pchk + "' ";

    $.ajax({
        type: "get",
        url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
        data: { sql: searchSql },
        async: false,
        cache: false,
        success: function (json) {
            var JSONdata = $.parseJSON(json);
            if (JSONdata.length > 0) {
                tagt_no.no = JSONdata[0].cust_code;
                tagt_no.name = JSONdata[0].agt_name;
                tagt_no.fullname = JSONdata[0].agt_namefull;
            }
        }
    });

    return tagt_no;
}
