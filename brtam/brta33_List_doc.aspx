<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();

    protected string url = "";
    protected string chkobj = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        
        url = Request["url"] ?? "";
        chkobj = Request["chkobj"] ?? "";
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
</head>

<body bgcolor=#ffffff><!--<%=url%>-->
<div align=right>
    <a href="javascript:void(0)" onclick="chkFrameFrame()">[確認]</a>&nbsp;
    <a href="javascript:void(0)" onclick="closeDocFrame()">[關閉]</a>
</div>
<iframe id="docframe" src="<%=url%>" width="100%" height="100%" frameborder="0" style="border:0px"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
    });

    //關閉
    function closeDocFrame() {
        document.getElementById('docframe').src = "about:blank";
        window.parent.tt.rows = '100%,*';
        var pf = window.parent.Etop.document;
        $("tr[rec='<%=chkobj%>']", pf).find("td").each(function (tdindex, tditem) {
            $(tditem).removeClass("enter");
        })
    }

    //確認
    function chkFrameFrame() {
        var pf = window.parent.Etop.document;
        $("#chk_<%=chkobj%>", pf).show();
        if ($("#chk_<%=chkobj%>", pf).prop("checked") == false) {
            $("#chk_<%=chkobj%>", pf).click();
        }
        document.getElementById('docframe').src = "about:blank";
        closeDocFrame();
    }
</script>
