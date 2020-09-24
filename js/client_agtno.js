//檢查輸入出名代理人是否與預設出名代理人相同
//pchk:N一般案、C涉外案
//pvalue:輸入的出名代理人

function TAgt(pchk) {
    if(pchk=="C"){
        this.tagt_no="A32";//2017/3/24修改涉外案為A32，依2017/3/15發佈業務出名配置表，2017/4/1涉外案改為劉&尹&(&惲)
    }else{
        this.tagt_no="A19"
    }

    this.init = function () {
        //抓取現行預設出名代理人
        //N:一般案件預設出名代理人
        //C:涉外案件預設出名代理人
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
                    this.tagt_no = JSONdata[0].remark;
                }
            }
        });
    };

    this.init();

    //this.get_gagtno = function(pchk) {
    //    alert(this.tagt_no);
    //};
};

var df_tagt={
    no:""
    , name: ""
    ,namefull:""
};
function get_gagtno = function (pchk) {
    //抓取現行預設出名代理人
    //N:一般案件預設出名代理人
    //C:涉外案件預設出名代理人
    if (pchk == "C") {
        df_tagt.no = "A32";//2017/3/24修改涉外案為A32，依2017/3/15發佈業務出名配置表，2017/4/1涉外案改為劉&尹&(&惲)
    } else {
        df_tagt.no = "A19";
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
                df_tagt.no = JSONdata[0].cust_code;
                df_tagt.name = JSONdata[0].agt_name;
                df_tagt.namefull = JSONdata[0].agt_namefull;
            }
        }
    });
}
