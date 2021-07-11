<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Data"  %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>

<!DOCTYPE html>

<script runat="server">
    protected string SiServer = Sys.SIServer;//聖島人主機
    protected string ProjectName = "";
    protected string LoginGrp = "";
    protected string StrUser = "";
    protected string Eblank = "";
	//protected string StrBkClr = "bgcolor=\"#5a63bd\"";
	//protected string StrDisp = " style=\"display:none\"";
	//protected string theTop = "44px";
    protected string sideWidth = "";//側邊欄寬
	protected string StrMenus = "";
	protected string scriptString = "";
	//protected string gcTestDisp = " style=\"display:none\"";
	protected string StrSYSs = "";//下拉選單
	//protected string mainPage = "";

    DBHelper cnn = null;//開完要在Page_Unload釋放,否則sql server連線會一直佔用
    private void Page_Unload(System.Object sender, System.EventArgs e) {
        if (cnn != null) cnn.Dispose();
    }

    private void Page_Load(System.Object sender, System.EventArgs e) {
		Response.CacheControl = "Private";
		Response.AddHeader("Pragma", "no-cache");
		Response.Expires = -1;

        cnn = new DBHelper(Conn.ODBCDSN, false).Debug(false);

        sideWidth = "220";
        if (Convert.ToBoolean(Session["Password"])) {
            ProjectName = Sys.Project;//.getAppSetting("Project");
            LoginGrp = Sys.GetSession("LoginGrp");
            StrUser = Sys.GetSession("sc_name");
            if (Sys.IsDebug()){
                Eblank = "<span id='btnEblank' style='cursor:pointer;color:brown;' v1='65%,*' v2='100%,*'>[Eblank frame]</span>&nbsp;";
            }

            CreateMenu();
        }
        
		this.DataBind();
	}

    private void CreateMenu() {
        //StrUser = ProjectName + " / " + Session["sc_name");
        string SQL = "SELECT a.APcode, a.APnameC, a.APorder, a.APserver, a.APpath, a.ReMark" +
             ", b.LoginGrp, b.Rights" +
             ", c.APcatCName, c.APCatID" +
             " FROM AP AS a" +
             " INNER JOIN LoginAP AS b ON a.APcode = b.APcode AND a.SYScode = b.SYScode" +
             " INNER JOIN APcat AS c ON a.APcat = c.APcatID AND a.SYScode = c.SYScode " +
             " WHERE b.LoginGrp = '" + Session["LoginGrp"] + "'" +
            //" AND b.SYScode = '" + Session["Syscode"] + "'" +//新舊系統用同一個syscode,但menu要分開
             " AND b.SYScode = '" + Sys.Sysmenu + "'" +
             " AND (b.Rights & 1) > 0 " +
             " ORDER BY c.APseq, a.APorder, a.APcode";
        DataTable dt = new DataTable();
        cnn.DataTable(SQL, dt);

        int xn = 0;
        int xItemCount = 0;
        //int xmIdx = 1;
        int xmIdx = 0;
        string xapcat = "";
        string xaporder = "";
        string xapcode = "";
        string xapo = "";
        //string xpath = "";

        //StrMenus = "<table cellSpacing=\"0\" cellPadding=\"0\" bgColor=\"#5A63BD\" border=\"0\"><tr>\n";
        StrMenus = "<table cellSpacing=\"0\" cellPadding=\"0\" bgColor=\"\" border=\"0\"><tr>\n";
        scriptString = "";
        for (int i = 0; i < dt.Rows.Count; i++) {
            if (dt.Rows[i]["APcatCName"].ToString() != xapcat) {
                xn = xn + 1;
                xapcat = dt.Rows[i]["APcatCName"].ToString();
                xaporder = "";
                xItemCount = 1;
                StrMenus += "<td width=\"87\" align=\"center\" class=\"apcat tab-title\" v1=\"" + xn.ToString() + "\" height=\"19\" valign=\"bottom\">" + xapcat + "</td>\n";
            }
            if (dt.Rows[i]["APNameC"].ToString() != xapcode) {
                scriptString += "\t\tzmenu[" + xmIdx.ToString() + "] = new MenuItem();\n";
                scriptString += "\t\tzmenu[" + xmIdx.ToString() + "].mIdx = " + xn.ToString() + ";\n";
                scriptString += "\t\tzmenu[" + xmIdx.ToString() + "].sIdx = " + xItemCount.ToString() + ";\n";
                scriptString += "\t\tzmenu[" + xmIdx.ToString() + "].Code = \"" + dt.Rows[i]["APcode"].ToString() + "\";\n";
                scriptString += "\t\tzmenu[" + xmIdx.ToString() + "].Cat = \"" + dt.Rows[i]["APcatID"].ToString() + "\";\n";
                scriptString += "\t\tzmenu[" + xmIdx.ToString() + "].Name = \"" + dt.Rows[i]["APNameC"].ToString() + "\";\n";

                //scriptString += "\t\tzmenu[" + xmIdx.ToString() + "].Link = \"" + dt.Rows[i]["APpath"].ToString() + "?prgid=" + dt.Rows[i]["APcode"].ToString() + "\";\n";
                if (Sys.Host == "localhost") {
                    scriptString += "\t\tzmenu[" + xmIdx.ToString() + "].Link = \"http://" + Sys.Host + "/" + dt.Rows[i]["APpath"].ToString() +
                                                                                "?prgid=" + dt.Rows[i]["APcode"].ToString() +
                                                                                "&prgname=" + Server.UrlEncode(dt.Rows[i]["APNameC"].ToString()) +
                                                                                dt.Rows[i]["ReMark"].ToString() + "\";\n";
                } else {
                    scriptString += "\t\tzmenu[" + xmIdx.ToString() + "].Link = \"http://" + dt.Rows[i]["APserver"].ToString() + "/" + dt.Rows[i]["APpath"].ToString() +
                                                                         "?prgid=" + dt.Rows[i]["APcode"].ToString() +
                                                                         "&prgname=" + Server.UrlEncode(dt.Rows[i]["APNameC"].ToString()) +
                                                                         dt.Rows[i]["ReMark"].ToString() + "\";\n";
                }
                xapo = dt.Rows[i]["APorder"].ToString().Substring(0, 1);
                if (xapo != xaporder) {
                    if (xItemCount != 0)
                        scriptString += "\t\tzmenu[" + xmIdx.ToString() + "].Bar = \"Y\";\n";
                    xaporder = xapo;
                }
                xmIdx = xmIdx + 1;
                xItemCount = xItemCount + 1;
                xapcode = dt.Rows[i]["APNameC"].ToString();
            }
        }
        StrMenus += "</tr></table>";

        StrSYSs = "";
        //求取該登入人員所有的系統權限(不含本系統)
        SQL = "SELECT a.sysserver+ISNULL(a.syspath, '')path, a.sysnameC, a.syscode";
        SQL += " FROM sysctrl AS b";
        SQL += " INNER JOIN SYScode AS a ON b.syscode=a.syscode";
        SQL += " WHERE b.scode='" + Session["scode"] + "'";
        //SQL += " AND a.syscode<>'" + Session["syscode"] + "'";//新舊系統用同一個syscode,但menu要分開
        SQL += " AND a.syscode<>'" + Sys.Sysmenu + "'";

        DataTable dt_1 = new DataTable();
        cnn.DataTable(SQL, dt_1);
        for (int i = 0; i < dt_1.Rows.Count; i++) {
            StrSYSs += "<option value=\"" + dt_1.Rows[i]["path"].ToString() + "\" value1=\"" + dt_1.Rows[i]["Syscode"].ToString() + "\">◎" + dt_1.Rows[i]["sysnameC"].ToString() + "</option>";
        }
    }
</script>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="x-ua-compatible" content="IE=10">
    <title>台北所商標網路作業系統(<%#Sys.Host%>)</title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<body style="margin:0px 0px 0px 0px;overflow:hidden;background:url('images/top/back5.gif');background-repeat: no-repeat;">
    <table id="toptable" cellspacing="0" cellpadding="0" width="100%" border="0">
        <tr>
            <td width="2%">&nbsp;</td>
            <td align="left" style="background-image: url(images/top/w02.png); background-repeat: no-repeat;background-size: 199px 26px; padding-left: 65px;">
                <%#ProjectName%>
            </td>
            <td align="right" width="30%">
                <img class="headImg" onclick="javascript:gosite('list')" style="cursor:pointer;" title="回系統首頁" alt="回系統首頁" border="0" src="images/top/head05-list.gif">
                <img class="headImg" onclick="javascript:gosite('menu')" style="cursor:pointer;" title="回主功能表" alt="回主功能表" border="0" src="images/top/head05-menu.gif">
                <img class="headImg" onclick="javascript:gosite('home')" style="cursor:pointer;" title="登出回首頁" alt="登出回首頁" border="0" src="images/top/head05-home.gif">
            </td>
            <td align="right" valign=top>
                <%#Eblank%>
                <span style="font-size:12px;color:red" title="<%#LoginGrp%>"><%#StrUser%></span>
                <img src="images/top/go-1.gif" alt="" width="22" height="10" />
				<select id="goweb" name="goweb">
	                <option value="" style="color:#000088">請選擇其他網路作業系統...</option>
                    <%#StrSYSs%>
                    <option value="">----------</option>	
                    <option value="logout">→登出</option> 		
                </select>	
            </td>		
        </tr>
    </table>
    <table cellspacing="0" cellpadding="0" width="100%" border="0">
        <!--tr style="background-color:#5a63bd"-->
        <tr style="background:linear-gradient(to bottom, #d4d9f7 5%, #5a63bd 100%);">
            <td width="30" id="imgSide" style="cursor:pointer;background-size:60% 95%;background-repeat:no-repeat;">
                <%--<img id="imgSide" style="cursor:pointer;" src="images/x-1.gif" />&nbsp;&nbsp;--%>
            </td>
            <td height="20">
                <%#StrMenus%>
            </td>
        </tr>
    </table>
    <iframe id="workfram" src="mainFrame.aspx?sidewidth=<%#sideWidth%>" style="z-index: 1; position:absolute; width: 99.8%; height: 800px; left: 0px;"></iframe>
    <div id="oPopBody" style="position:absolute; display:none;z-index: 10; width:250px"></div>
    <form method="post" id="reg" name="reg" target="_top">
        <input type="hidden" name="syscode" value="<%=Request["syscode"]%>">
        <input type="hidden" name="tfx_scode" value="<%=Session["Scode"]%>">
        <input type="hidden" name="tfx_sys_password" value="" />
        <input type="hidden" name="sys_pwd" value="<%=Session["SeSysPwd"]%>">
        <input type="hidden" name="toppage" value="<%=Session["SeTopPage"]%>">
        <input type="hidden" name="ctrlleft" value="<%=Request["ctrlleft"]%>">
        <input type="hidden" name="ctrltab" value="<%=Request["ctrltab"]%>">
        <input type="hidden" name="ctrlhomelist" value="<%=Request["ctrlhomelist"]%>">
        <input type="hidden" name="ctrlhomelistshow" value="<%=Request["ctrlhomelistshow"]%>">
    </form>
</body>
</html>


<script type="text/javascript" language="javascript">
    var zmenu = Array();
    var oPopup;
    var oPopup1;
    var mi = 0;
    var mLeft = 0

    $(function () {
        $("#imgSide").click(function (e) {
            var ifrm = $("#workfram").contents();
            if ($(ifrm).find("#f").attr("cols") == "0,*") {
                $(ifrm).find("#f").attr("cols", "<%#sideWidth%>,*");
                //$(this).attr("src", "images/x-2.gif");
                $(this).css("background-image","url(images/x-2.gif)"); 
            } else {
                $(ifrm).find("#f").attr("cols", "0,*");
                //$(this).attr("src", "images/x-1.gif");
                $(this).css("background-image","url(images/x-1.gif)"); 
            }
        });
        $(document).click(function (e) { $("#oPopBody").hide(); });
        $(".apcat").mouseover(function (e) { $(this).addClass("tab-titleon").removeClass("tab-title"); $(this).click(); });
        $(".apcat").mouseout(function (e) { $(this).addClass("tab-title").removeClass("tab-titleon") });
        $(".apcat").click(menuClick);
        $("#oPopBody").mouseleave(function (e) { $(this).hide(); });
        //$("#goweb").change(gosite);
        $("#imgSide").css("background-image", "url(images/x-2.gif)");
        
        $(window).load(setIframe);
        $(window).resize(setIframe);
        init();
    });

    function init() {
    <%#scriptString%>
    }

    function setIframe(e) {
        $("#workfram").height(($(window).height() - 48) + 'px');
        $("#workfram").width("100%");
    }

    function menuClick(e) {
        var sObj = e.target;
        var pos = $(sObj).position();
        mi = parseInt($(sObj).attr("v1"));
        var i = 0;
        var i0 = 0;
        var maxLen = 0;
        var menuHeight = 0;
        var menuWidth = 0;
        var menuHtm = "";
        for (i = 0 ; i < zmenu.length ; i++) {
            if (zmenu[i].mIdx == mi) {
                if (zmenu[i].Bar == "Y" && i0 > 0) {
                    //menuHtm += "<hr style=\"height: 1px; color: #a0a0a0; background-color: #a0a0a0\" />";
                    menuHtm += "<hr class=\"style-one\"/>";
                    menuHeight += 2;
                }
                //if (zmenu[i].Name.CodeLength() > maxLen) maxLen = zmenu[i].Name.CodeLength();
                maxLen = Math.max(zmenu[i].Name.CodeLength(), maxLen)
                zmenu[i].pTop = menuHeight + 31
                //menuHtm += "<div style=\"margin: 0px 0px 0px 0px;padding: 2px 1px 1px 1px;color: #000;background-color: #f0f0f0;cursor: pointer;height: 18px;\" " +
				//	"onmouseover=\"javascript:PopMenuOver(this)\" onmouseout=\"javascript:PopMenuOut(this)\" " +
				//	"onclick=\"javascript:PopMenuClick(" + i.toString() + ")\">" + zmenu[i].Name + "&nbsp;</div>";
                menuHtm += "<div style=\"margin: 1px 0px 1px 0px;padding: 1px 1px 1px 1px;color: #000;cursor: pointer;height: 18px;\" " +
					"onmouseover=\"javascript:PopMenuOver(this,'" + mi + "')\" onmouseout=\"javascript:PopMenuOut(this,'" + mi + "')\" " +
					"onclick=\"javascript:PopMenuClick(" + i.toString() + ")\">" + zmenu[i].Name + "&nbsp;</div>";
                menuHeight += 22;
                i0++;
            }
        }
        menuHeight += 4;

        menuWidth = 20 + 7 * maxLen;
        mLeft = pos.left + 1 + menuWidth;

        $("#oPopBody").css("margin", "0px 0px 0px 0px");
        $("#oPopBody").css("padding", "2px 5px 2px 5px");
        $("#oPopBody").css("background-color", "#f0f0f0");
        //$("#oPopBody").css("background-color", "#eaf9f5");
        $("#oPopBody").css("font-size", "10pt");
        $("#oPopBody").css("font-family", "微軟正黑體, Verdana, Arial");
        $("#oPopBody").css("border-left", "solid 2px #fff");
        $("#oPopBody").css("border-top", "solid 2px #fff");
        $("#oPopBody").css("border-bottom", "solid 2px #979797");
        $("#oPopBody").css("border-right", "solid 2px #979797");
        $("#oPopBody").html(menuHtm);
        $("#oPopBody").css("left", (pos.left + 1).toString() + "px");
        //$("#oPopBody").css("top", "46px");
        $("#oPopBody").css("top", Math.ceil($("#workfram").offset().top) + "px");
        $("#oPopBody").css("width", menuWidth + "px");
        //$("#oPopBody").css("heigth", menuHeight + "px");

        var max_menuHeight = document.documentElement.clientHeight-70;
        //2020/12/09 改成超過螢幕高度就會有捲軸
        if (menuHeight < max_menuHeight) {
            $("#oPopBody").height(menuHeight);
            $("#oPopBody").css("overflowY", "hidden");
        } else {
            $("#oPopBody").height(max_menuHeight);
            $("#oPopBody").css("overflowY", "scroll");
        }
        $("#oPopBody").show();
        e.stopPropagation();
        return;
    }

    function PopMenuOver(sObj, pV1) {
        $(".apcat[v1='" + pV1 + "']").addClass("tab-titleon").removeClass("tab-title");
        sObj.style.backgroundColor = "#898989";
        sObj.style.color = "#fff";
    }

    function PopMenuOut(sObj, pV1) {
        $(".apcat[v1='" + pV1 + "']").addClass("tab-title").removeClass("tab-titleon");
        sObj.style.backgroundColor = "#f0f0f0";
        sObj.style.color = "#000";
    }

    function PopMenuClick(ii) {
        var lnk = zmenu[ii].Link;

        var ifrm = $("#workfram").contents();
        //$(ifrm).find("[name='mainFrame']").attr("src", lnk);
        $("#Etop", ifrm).attr("src", lnk);
        //$(ifrm).find("[name='mainFrame']")[0].location.href = lnk;
        //workfram.mainFrame.location.href = lnk;
        $("#oPopBody").hide();
    }

    function MenuItem() {
        this.mIdx = 0;
        this.sIdx = 0;
        this.pTop = 0;
        this.Code = "";
        this.Cat = "";
        this.Name = "";
        this.Link = "";
        this.Bar = "N";
    }

    function gosite(pType) {
        switch (pType) {
            case "list"://回系統首頁
                reg.action = "default.aspx";
                reg.submit();
                break;
            case "menu"://回主功能表(各系統清單)
                reg.action = "http://<%#SiServer%>/system/sys_main.asp";
                reg.submit();
                break;
            case "home"://聖島人
                window.top.location.href = "http://<%#SiServer%>";
                break;
            default:
                var syspath = $("#goweb").val();
                if (syspath == "logout") {//登出
                    window.open("logout.aspx", "_top");
                }else if (syspath != "") {
                    var syscode = $("#goweb option:selected").attr("value1");
                    window.top.location.href = "http://" + syspath + "/checklogin.asp?tfx_scode=<%#Session["scode"]%>&sys_pwd=<%#Session["SeSysPwd"]%>&syscode=" + syscode;
                }
                break;
        }
    }

    //Eblank frame
$("#btnEblank").click(function () {
        var ifrm = $("#workfram").contents();

        if ($(this).attr("v1") != null) {
            if ($("#tt", ifrm).length>0) {
                if ($("#tt", ifrm).attr("rows") != $(this).attr("v1")) {
                    $("#tt", ifrm).attr("rows", $(this).attr("v1"))
                } else {
                    $("#tt", ifrm).attr("rows", $(this).attr("v2"))
                }
            }
        }
    });
</script>
