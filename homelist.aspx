<%@ Page Language="C#" CodePage="65001" %>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>
<%@ Register Src="~/homelist_job1.ascx" TagPrefix="uc1" TagName="homelist_job1" %>
<%@ Register Src="~/homelist_job2.ascx" TagPrefix="uc1" TagName="homelist_job2" %>
<%@ Register Src="~/homelist_job3.ascx" TagPrefix="uc1" TagName="homelist_job3" %>
<%@ Register Src="~/homelist_job5.ascx" TagPrefix="uc1" TagName="homelist_job5" %>
<%@ Register Src="~/homelist_job6.ascx" TagPrefix="uc1" TagName="homelist_job6" %>

<script runat="server">
    protected string StrProjectName = Sys.Project;
    protected Dictionary<string, string> rights = new Dictionary<string, string>();
    protected Dictionary<string, string> rightsE = new Dictionary<string, string>();

    string SQL = "";
    
    DBHelper conn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (conn != null) conn.Dispose();
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(Object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        conn = new DBHelper(Conn.btbrt).Debug(Request["chkTest"] == "TEST");
        cnn = new DBHelper(Conn.ODBCDSN).Debug(Request["chkTest"] == "TEST");

        //kind: homelist_job(?).inc
        SQL = "select c.dept,c.kind,a.logingrp,c.Rights from logingrp a,sysctrl b,homeright c";
        SQL += " where a.syscode='" + Sys.Syscode + "' and b.scode='" + Session["scode"] + "'";
        SQL += " and a.syscode=b.syscode and a.logingrp=b.logingrp and a.syscode=c.syscode and a.logingrp=c.logingrp";
        using (SqlDataReader dr = cnn.ExecuteReader(SQL)) {
            while (dr.Read()) {
                switch (dr.SafeRead("dept", "").ToUpper()) {
                    case "T":
                        rights[dr.SafeRead("kind", "")] = dr.SafeRead("Rights", "").ToUpper();
                        break;
                    case "TE":
                        rightsE[dr.SafeRead("kind", "")] = dr.SafeRead("Rights", "").ToUpper();
                        break;
                }
            }
        }

        //foreach (KeyValuePair<string, string> item in rights) {
        //    Response.Write(string.Format("rights[{0}]={1}<br/" + ">", item.Key, item.Value));
        //}
        //Response.Write("<HR>");
        //foreach (KeyValuePair<string, string> item in rightsE) {
        //    Response.Write(string.Format("rightsE[{0}]={1}<br/" + ">", item.Key, item.Value));
        //}
        //Response.Write("<HR>");
        //Response.Write(rights.TryGet("3") + "<bR>");
        //Response.Write(rightsE.TryGet("3") + "<bR>");
        
        ChildBind();
        this.DataBind();
    }

    //將共用參數(權限值)傳給子控制項
    private void ChildBind() {
        homelist_job1.rights = rights;
        homelist_job1.rightsE = rightsE;
        homelist_job2.rights = rights;
        homelist_job2.rightsE = rightsE;
        homelist_job3.rights = rights;
        homelist_job3.rightsE = rightsE;
        homelist_job5.rights = rights;
        homelist_job5.rightsE = rightsE;
        homelist_job6.rights = rights;
        homelist_job6.rightsE = rightsE;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<BODY background="./images/back01.gif" style="margin-left:2em;margin-right:2em;background-repeat: repeat-y;">
    <%if (rights.TryGet("1")!=""||rightsE.TryGet("1")!=""){%>
    <uc1:homelist_job1 runat="server" ID="homelist_job1" />
    <!--INCLUDE FILE="homelist_job1.inc" --><!--營業-->
	<%}%>
    <%if (rights.TryGet("2")!=""||rightsE.TryGet("2")!=""){%>
    <uc1:homelist_job2 runat="server" ID="homelist_job2" />
    <!--INCLUDE FILE="homelist_job2.inc" --><!--主管-->
	<%}%>
    <%if (rights.TryGet("3")!=""||rightsE.TryGet("3")!=""){%>
    <uc1:homelist_job3 runat="server" ID="homelist_job3" />
    <!--INCLUDE FILE="homelist_job3.inc" --><!--程序-->
	<%}%>
    <%if (rights.TryGet("5")!=""||rightsE.TryGet("5")!=""){%>
    <uc1:homelist_job5 runat="server" ID="homelist_job5" />
    <!--INCLUDE FILE="homelist_job5.inc" --><!--承辦-->
	<%}%>
    <%if (rights.TryGet("6")!=""||rightsE.TryGet("6")!=""){%>
    <uc1:homelist_job6 runat="server" ID="homelist_job6" />
    <!--INCLUDE FILE="homelist_job6.inc" --><!--會計-->	
	<%}%>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        //隱藏出口案
        $('.data3,.data3h').hide();

        //只觸發.data2(國內案)
        //個人件數
        $('.data2 .loadnum').each(function () {
            var $this = $(this);
            var right = $this.attr("attr-right") || "";//權限1
            var rightE = $this.attr("attr-rightE") || "";//權限2
            var sql = $this.attr("attr-sql") || "";//執行的sql
            var href = $this.attr("attr-href") || "";//連結的網頁
            if (right != "" || rightE != "") {
                doajax($this, "", sql, href);
            }
        });

        //主管件數
        $('.data2 .loadnumA').each(function () {
            var $this = $(this);
            var right = $this.attr("attr-right") || "";//權限
            var sql = $this.attr("attr-sql") || "";//執行的sql
            var href = $this.attr("attr-href") || "";//連結的網頁

            if (right == "A") {
                doajax($this, "A", sql, href);
            }
        });

        //其他種類件數(特殊條件)
        $('.data2.loadnumR').each(function () {
            var $this = $(this);
            var right = $this.attr("attr-right") || "";//權限
            var sql = $this.attr("attr-sql") || "";//執行的sql
            var href = $this.attr("attr-href") || "";//連結的網頁,權限低
            var hrefA = $this.attr("attr-hrefA") || "";//連結的網頁,權限高

            if (right == 0) {//權限低
                doajax($this, "", sql, href);
            } else {
                doajax($this, "R", sql, hrefA);
            }
        });
    });

    //type=A主管權限,顯示:(n)
    //type=R特殊條件,顯示:0 (n)
    //其他,顯示:n
    function doajax(obj, type, sql, href) {
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/JsonGetSqlData.aspx",
            data: { sql: sql },
            cache: false,
            beforeSend: function () {
                if (type == "A") {
                    obj.html('(<img src="images/Pulse-1s-20px_r.gif" style="vertical-align: middle;" />)');
                } else {
                    obj.html('<img src="images/Pulse-1s-20px_r.gif" style="vertical-align: middle;" />');
                }
            },
            success: function (json) {
                var JSONdata = $.parseJSON(json);
                var num = "0";
                if (JSONdata.length > 0) {
                    num = JSONdata[0].num;
                }

                //有傳link且有件數才要顯示link
                var html = "", href_s = "", href_e = "";
                //if (href != "" && num != "0") {
                    href_s = "<a href='" + href + "'>";
                    href_e = "</a>";
                //};

                if (type == "A") {
                    html = "(" + href_s + num + href_e + ")";
                } else if (type == "R") {
                    html = "0 (" + href_s + num + href_e + ")";
                } else {
                    html = href_s + num + href_e;
                }
                obj.html(html);
            },
            error: function (json) {
                if (type == "A") {
                    obj.html('(<img src="images/fail-1.1s-20px.png" style="vertical-align: middle;" />)');
                } else {
                    obj.html('<img src="images/fail-1.1s-20px.png" style="vertical-align: middle;" />')
                }
            }
        });
    }
</script>
