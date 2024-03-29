﻿<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.Data"%>
<%@ Register Src="~/brt1m/brtform/cust_form.ascx" TagPrefix="uc1" TagName="cust_form" %>
<%@ Register Src="~/brt1m/brtform/attent_form.ascx" TagPrefix="uc1" TagName="attent_form" %>
<%@ Register Src="~/brt1m/brtform/apcust_form.ascx" TagPrefix="uc1" TagName="apcust_form" %>
<%@ Register Src="~/brt1m/brtform/dmt_case_form.ascx" TagPrefix="uc1" TagName="dmt_case_form" %>
<%@ Register Src="~/brt1m/brtform/dmt_Form.ascx" TagPrefix="uc1" TagName="dmt_Form" %>
<%@ Register Src="~/commonForm/dmt_upload_Form.ascx" TagPrefix="uc1" TagName="dmt_upload_Form" %>
<%@ Register Src="~/brt1m/Brt11FormA9Z.ascx" TagPrefix="uc1" TagName="Brt11FormA9Z" %>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>



<script runat="server">
    protected string HTProgCap = "國內案編修暨交辦作業(後續案)";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brt11";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string formFunction = "";

    protected Dictionary<string, string> ReqVal = new Dictionary<string, string>();
    protected Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    protected Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string submitTask = "";
    protected string ar_form = "";
    protected string cust_area = "";
    protected string cust_seq = "";
    protected string in_scode = "";
    protected string in_no = "";
    protected string prt_code = "";
    protected string new_form = "";
    protected string case_stat = "";
    protected string code_type = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string code = "";

    protected string html_selectsign1 = "", html_selectsign2 = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        ReqVal = Util.GetRequestParam(Context, Request["chkTest"] == "TEST");
        submitTask = (Request["submittask"] ?? "").Trim();
        ar_form = (Request["ar_form"] ?? "").Trim();
        cust_area = (Request["cust_area"] ?? "").Trim();
        cust_seq = (Request["cust_seq"] ?? "").Trim();
        in_scode = (Request["in_scode"] ?? "").Trim();
        in_no = (Request["in_no"] ?? "").Trim();
        prt_code = (Request["prt_code"] ?? "").Trim();
        new_form = (Request["new_form"] ?? "").Trim();
        case_stat = (Request["case_stat"] ?? "").Trim();
        code_type = (Request["code_type"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        code = (Request["code"] ?? "").Trim();

        formFunction = (Request["formFunction"] ?? "").Trim();
        if (submitTask != "Show" && formFunction == "") {
            formFunction = "Edit";
        }

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        if (HTProgRight >= 0) {
            PageLayout();
            ChildBind();
            this.DataBind();
        }
    }

    private void PageLayout() {
        if (submitTask != "Show") {
            if ((HTProgRight & 8) > 0 || (HTProgRight & 16) > 0) {
                StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust11_edit.aspx") + "?cust_area=" + Request["cust_area"] + "&cust_seq=" + Request["cust_seq"] + "&submitTask=A&gs_dept=T&cust_att=A&Type=ap_nameaddr\" target=\"Brt11blankN\">[聯絡人新增]</a>\n";
                StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/cust/cust13.aspx") + "\" target=\"Brt11blankN\">[申請人新增]</a>\n";
                if ((Request["cust_seq"] ?? "") != "") {
                    //StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brt1m/brt1mFrame.aspx") + "?cust_area=" + Request["cust_area"] + "&cust_seq=" + Request["cust_seq"] + "\" target=\"Eblank\">[案件查詢]</a>\n";
                    StrFormBtnTop += "<a href=\"" + Page.ResolveUrl("~/brt1m/brt11_1.aspx") + "?prgid=" + prgid + "&cust_area=" + Request["cust_area"] + "&cust_seq=" + Request["cust_seq"] + "\" target=\"_blank\">[案件查詢]</a>\n";
                }
            }
        }
        if ((Request["homelist"] ?? "") != "homelist") {
            StrFormBtnTop += "<a class=\"imgCls\" href=\"javascript:void(0);\" >[關閉視窗]</a>\n";
        }

        //申請人欄位畫面
        if (ar_form == "A6") {//變更
            apcustHolder.Controls.Add(LoadControl("~/brt1m/brtform/apcust_FC_RE_form.ascx"));
            apcustHolder.Controls.Add(LoadControl("~/brt1m/brtform/apcust_FC_RE1_form.ascx"));
        }

        if (formFunction == "Edit") {
            if ((HTProgRight & 8) > 0) {
                if (prgid == "brt51") {//客收確認
                    StrFormBtn += "<input type=button value ='資料確認無誤' class='cbutton bsubmit' onclick='formModSubmit()'>\n";
                    StrFormBtn += "<input type=button value ='資料有誤退回營洽' class='c1button bsubmit' onclick='formModSubmit2()'>\n";
                } else {
                    StrFormBtn += "<input type=button value ='編修存檔' class='cbutton bsubmit' onclick='formModSubmit()'>\n";
                }
            }

            StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
        } else if (formFunction == "Add") {
            if ((HTProgRight & 4) > 0) {
                StrFormBtn += "<input type=button value ='新增存檔' class='cbutton bsubmit' onclick='formModSubmit()'>\n";
                StrFormBtn += "<input type=button value ='重　填' class='cbutton' onclick='this_init()'>\n";
            }
        }

        //簽核主管
        DataRow[] drx = Sys.getGrpidUp(Sys.GetSession("SeBranch"), "T000").Select("grplevel=2");
        html_selectsign1 = drx.Option("{master_scode}", "{master_type}--{master_nm}", "selected", false);
        //特殊處理
        DataRow[] drx1 = Sys.getGrpidUp(Sys.GetSession("SeBranch"), "000").Select("grplevel>=1");
        html_selectsign2 = drx1.Option("{master_scode}", "{master_type}--{master_nm}", false);
    }

    //將共用參數(鎖定/隱藏)傳給子控制項
    private void ChildBind() {
        if (prgid.ToLower() == "brt51") {//程序客收確認
            Lock["brt51"] = "Lock";
        }

        //案件客戶
        cust_form.Lock = Lock;
        cust_form.Hide = Hide;
        //案件聯絡人
        attent_form.Lock = Lock;
        attent_form.Hide = Hide;
        //案件申請人
        apcust_form.Lock = Lock;
        apcust_form.Hide = Hide;
        //收費與接洽事項
        dmt_case_form.formFunction = formFunction;
        dmt_case_form.HTProgRight = HTProgRight;
        //案件內容
        dmt_Form.Lock = Lock;
        dmt_Form.Hide = Hide;
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%=HTProgCap%></title>
<uc1:head_inc_form runat="server" ID="head_inc_form" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_agtno.js")%>"></script><!--檢查輸入出名代理人是否與預設出名代理人相同-->
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_doctype.js")%>"></script><!--檢查契約書種類與上傳文件-->
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk_custwatch.js")%>"></script><!--檢查是否為雙邊代理查照對象-->
<script type="text/javascript" src="<%=Page.ResolveUrl("~/brt1m/Oldcase_Data.js")%>"></script><!--新舊案控制-->
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
    main.submittask = "<%#submitTask%>";
    main.formFunction = "<%#formFunction%>";
    main.ar_form = "<%#ar_form%>";
    main.cust_area = "<%#cust_area%>";
    main.cust_seq = "<%#cust_seq%>";
    main.in_no = "<%#in_no%>";
    main.code_type = "<%#code_type%>";
    main.seq = "<%#seq%>";
    main.seq1 = "<%#seq1%>";
    jMain = {};
    oMain = {};
</script>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=HTProgCode%><%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
    <tr>
        <td colspan="2"><font color=blue>接洽序號：<span id="t_in_no"></span></font></td>
    </tr>
</table>
<br>
<form id="reg" name="reg" method="post">
	<input type="hidden" id="submittask" name="submittask" value="<%=submitTask%>">
	<input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <INPUT TYPE="hidden" id="ar_form" name="ar_form" value="<%=ar_form%>">
    <INPUT TYPE="hidden" id=prt_code name=prt_code value="<%=prt_code%>">
    <INPUT TYPE="hidden" id=new_form name=new_form value="<%=new_form%>">
    <INPUT TYPE="hidden" id=add_arcase name=add_arcase value="">
    <input type="hidden" id="draw_attach_file" name="draw_attach_file"><!--2013/11/25商標圖檔改虛擬路徑增加-->

    <table cellspacing="1" cellpadding="0" width="98%" border="0">
    <tr>
        <td>
        <table border="0" cellspacing="0" cellpadding="0">
            <tr id="CTab">
                <td class="tab" href="#cust">案件客戶</td>
                <td class="tab" href="#attent">案件聯絡人</td>
                <td class="tab" href="#apcust">案件申請人</td>
                <td class="tab" href="#case">收費與接洽事項</td>
                <td class="tab" href="#dmt">案件主檔</td>
                <td class="tab" href="#tran">交辦內容</td>
                <td class="tab" href="#upload">文件上傳</td>
            </tr>
        </table>
        </td>
    </tr>
    <tr>
        <td>
            <div class="tabCont" id="#cust">
                <uc1:cust_form runat="server" ID="cust_form" />
                <!--include file="../brt1m/brtform/cust_form.ascx"--><!--案件客戶-->
            </div>
            <div class="tabCont" id="#attent">
                <uc1:attent_form runat="server" ID="attent_form" />
                <!--include file="../brt1m/brtform/attent_form.ascx"--><!--案件聯絡人-->
            </div>
            <div class="tabCont" id="#apcust">
                <uc1:apcust_form runat="server" ID="apcust_form" />
                <!--include file="../brt1m/brtform/apcust_form.ascx"--><!--案件申請人-->
                <asp:PlaceHolder ID="apcustHolder" runat="server"></asp:PlaceHolder>
            </div>
            <div class="tabCont" id="#case">
                <uc1:dmt_case_form runat="server" id="dmt_case_form" />
                <!--include file="../brt1m/brtform/dmt_case_form.ascx"--><!--收費與接洽事項-->
            </div>
            <div class="tabCont" id="#dmt">
                <uc1:dmt_Form runat="server" id="dmt_Form" />
                <!--include file="../brt1m/brtform/dmt_Form.ascx"--><!--案件主檔-->
            </div>
            <div class="tabCont" id="#tran">
                <uc1:Brt11FormA9Z runat="server" ID="Brt11FormA9Z" />
                <!--include file="../brt1m/Brt11FormA9Z.ascx"--><!--交辦內容-->
            </div>
            <div class="tabCont" id="#upload">
                <uc1:dmt_upload_Form runat="server" ID="dmt_upload_Form" />
                <!--include file="../commonForm/dmt_upload_Form.ascx"--><!--文件上傳-->
            </div>
        </td>
    </tr>
    </table>
    <br />
	<INPUT TYPE="hidden" id=in_scode name=in_scode>
	<INPUT TYPE="hidden" id=in_no name=in_no>
    <INPUT TYPE="hidden" id=in_date name=in_date>
    <INPUT TYPE="hidden" id=tfgp_seq NAME=tfgp_seq>
    <INPUT TYPE="hidden" id=tfgp_seq1 NAME=tfgp_seq1>
    <%if (prgid == "brt51"){%><!--客收確認-->
        <br>
	    <div style="color:blue;text-align:center">退回營洽說明：<textarea name="back_remark" id="back_remark" cols=50 rows=2></textarea></div><br><br>
    <%}else if(prgid=="brt63"){%><!--承辦交辦作業[專案室發文]-->
        <br>
	    <INPUT TYPE=hidden NAME=brt18_seq value="<%=Request["seq"]%>">
	    <INPUT TYPE=hidden NAME=brt18_seq1 value="<%=Request["seq1"]%>">
	    <INPUT TYPE=hidden NAME=Case_no value="<%=Request["case_no"]%>">
	    <INPUT TYPE=hidden NAME=step_grade value="<%=Request["step_grade"]%>">
	    <INPUT TYPE=hidden NAME=step_date value="<%=Request["step_date"]%>">
	    <INPUT TYPE=hidden NAME=brt18_rs_no value="<%=Request["rs_no"]%>">
	    <INPUT TYPE=hidden NAME=brt18_prgid value="<%=Request["prgid"]%>">
	    <INPUT TYPE=hidden NAME=todo_sqlno value="<%=Request["todo_sqlno"]%>"><!--承辦交辦發文todo_dmt.sqlno-->
	    <INPUT TYPE=hidden NAME=contract_flag value="<%=Request["contract_flag"]%>"><!--契約書後補註記，N不需後補或後補已完成，Y尚需後補-->
	    <table id=tabar border=0 width="80%" cellspacing="1" cellpadding="1" class="bluetable" align="center">
		    <tr>
		        <td class="lightbluetable" align="right">承辦處理說明：</td>
		        <td class="whitetablebg" align="left">	
			        <textarea id="job_remark" name="job_remark" rows="5" cols="65" ></textarea>
		        </td>
	        </tr>
	    </table><br>
		<%if ((HTProgRight & 8) > 0) {%>
			<div style="color:blue;text-align:center"><input type=button value ="爭救案件交辦" class="cbutton bsubmit" onclick="formOptSubmit()" id=btnSubmit name=btnSubmit></div>
		<%}%>
    <%} else if (prgid == "brt1a") {%><!--國內爭救案交辦專案室抽件作業[抽件]-->
	    <br>
	     <INPUT TYPE=hidden NAME=opt_sqlno value="<%=Request["opt_sqlno"]%>">
	     <INPUT TYPE=hidden NAME=brt18_seq value="<%=Request["seq"]%>">
	     <INPUT TYPE=hidden NAME=brt18_seq1 value="<%=Request["seq1"]%>">
	     <INPUT TYPE=hidden NAME=Case_no value="<%=Request["case_no"]%>">
	     <INPUT TYPE=hidden NAME=step_grade value="<%=Request["step_grade"]%>">
	     <INPUT TYPE=hidden NAME=step_date value="<%=Request["step_date"]%>">
	     <INPUT TYPE=hidden NAME=brt18_rs_no value="<%=Request["rs_no"]%>">
	     <INPUT TYPE=hidden NAME=brt18_prgid value="<%=Request["prgid"]%>">
	    <table class="bluetable" border="0" cellspacing="1" cellpadding="0" width="98%">
	    <Tr>
	        <TD align="center" colspan="3" class=lightbluetable><font color=red>註&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;銷&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;處&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;理</font></TD>
	    </tr>
	    <Tr>
		    <TD align=center class=lightbluetable width="18%"><font color="red">註銷原因</font></TD>
		    <TD class=lightbluetable>
			    <textarea ROWS="6" COLS="82" id=Creason name=Creason></textarea>
		    </TD>
	    </tr>
	    </table>
	    <br>
	    <table border="0" width="98%" cellspacing="0" cellpadding="0">
		    <TR>
			    <td align="center">
				    <label><input type="radio" value="1" name="ap_type" checked onclick="ap_type_click()"><strong>簽核主管:</strong></label>
				    <select id='job_scode1' name='job_scode1'>
				        <option value="" style="color:blue">請選擇主管</option>
				        <%#html_selectsign1%>
				    </select>
                    <label><input type="radio" value="2" name="ap_type" onclick="ap_type_click()"><strong>特殊處理:</strong></label>
			        <select id='job_scode2' name='job_scode2'>
			            <%#html_selectsign2%>
			        </select>
			        <input type="hidden" name="signscode" id="signscode">
			     </td>
		    </tr>
	    </table>
        <br>
        <%if ((HTProgRight & 8) > 0) {%>
		    <div style="color:blue;text-align:center"><input type=button value ="註銷" class="redbutton bsubmit" onclick="formCancelSubmit()" id=btnSubmit name=btnSubmit></div>
	    <%}%>
    <%}%>

    <%#DebugStr%>
</form>

<table border="0" width="98%" cellspacing="0" cellpadding="0">
<tr>
    <td width="100%" align="center">
        <%#StrFormBtn%>
    </td>
</tr>
</table>

<div id="dialog"></div>

<iframe id="ActFrame" name="ActFrame" src="about:blank" width="100%" height="300" style="display:none"></iframe>
</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        if (window.parent.tt !== undefined) {
            if($("#prgid").val()!="brt51"){
                window.parent.tt.rows = "*,2*";
            }else{
                window.parent.tt.rows = "0%,100%";
            }
        }

        this_init();
    });

    // 切換頁籤
    $("#CTab td.tab").click(function (e) {
        settab($(this).attr('href'));
    });
    function settab(k) {
        $("#CTab td.tab").removeClass("seltab").addClass("notab");
        $("#CTab td.tab[href='" + k + "']").addClass("seltab").removeClass("notab");
        $("div.tabCont").hide();
        $("div.tabCont[id='" + k + "']").show();
    }

    function this_init() {
        if(main.ar_form=="A6"){//變更
            $("#CTab td.tab[href='#dmt']").after($("#CTab td.tab[href='#apcust']"));//[案件申請人]移到[案件主檔]後面
        }else{
            $("#CTab td.tab[href='#case']").before($("#CTab td.tab[href='#apcust']"));//[案件申請人]移到[收費與接洽事項]前面
        }
        //-----------------
        //取得交辦資料
        $.ajax({
            type: "get",
            url: getRootPath() + "/ajax/_case_dmt.aspx?prgid=" + main.prgid + "&right=" + main.right + "&formfunction=" + main.formFunction + "&submittask=" + $("#submittask").val() +
                "&cust_area=" + main.cust_area + "&cust_seq=" + main.cust_seq + "&in_no=" + main.in_no + "&code_type=" + main.code_type,
            async: false,
            cache: false,
            success: function (json) {
                if($("#chkTest").length>0) toastr.info("<a href='" + this.url + "' target='_new'>Debug(this_init)！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
                jMain = $.parseJSON(json);
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
        dmt_form.new_oldcase();

        //畫面準備
        cust_form.init();//案件客戶
        attent_form.init();//案件聯絡人
        apcust_form.init();//案件申請人
        case_form.init();//收費與接洽事項
        dmt_form.init();//案件主檔
        //br_form.init();//交辦內容
        upload_form.init();//文件上傳
        settab("#case");//收費與接洽事項

        //-----------------
        $("input.dateField").datepick();
        main.bind();//資料綁定
        //br_form.bind();//交辦內容資料綁定
        $(".Lock").lock();
        $(".Hide").hide();

        if($("#submittask").val()!="Edit"){//不是編輯模式全部鎖定
            if($("#prgid").val()=="brt63"){
                //爭救案交辦文件上傳不鎖
                $(".tabCont[id!='#upload'] select,.tabCont[id!='#upload'] textarea,.tabCont[id!='#upload'] input,.tabCont[id!='#upload'] button").lock();
            }else{
                $("select,textarea,input,button").lock();
                //例外開啟的物件
                $("#Qry_step1").unlock();//[查詢案件進度]
                $("#btnDisplay").unlock();//[商標圖檔檢視]
                $("input[id^=btnattach_S]").unlock();//[檢視]
            }
        }
        
        if($("#prgid").val()=="brt63"){//爭救案交辦用
            $("#span_step_last_date").show();//客收法定期限
            $("#step_last_date").val("<%=Request["ctrl_date"]%>");
            $("#dfy_last_date").unlock();//法定期限
            $("#job_remark").unlock();//承辦處理說明
            $("#btnSubmit,#chkTest").unlock();
        }

        if($("#prgid").val()=="brt1a"){//國內爭救案交辦專案室抽件作業用
            $("input[name='ap_type']").unlock();//簽核主管
            $("input[name='ap_type']:checked").triggerHandler("click");
            $("#Creason").unlock();//註銷原因
            $("#btnSubmit,#chkTest").unlock();
        }
    }

    //存檔
    function formModSubmit(){
        $.maskStart();
        var saveflag=main.savechk();
        $.maskStop();

        if(!saveflag) return false;

        $("#submittask").val("Edit");

        //$("select,textarea,input,span").unlock();
        $("input:disabled, select:disabled").unlock();
        $(".bsubmit").lock(!$("#chkTest").prop("checked"));

        var formData = new FormData($('#reg')[0]);
        ajaxByForm("<%=HTProgPrefix%>EditA9Z_Update.aspx",formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            if (main.prgid == "brt51")
                                window.parent.tt.rows="0%,100%";
                            else
                                window.parent.tt.rows="100%,0%";
                        }

                        if (main.prgid == "brt51"){
                            window.parent.Eblank.location.href=getRootPath() +"/brt5m/Brt51_Edit.aspx?prgid=brt51&submittask=A&in_scode=<%=in_scode%>&in_no=<%=in_no%>&cust_area=<%=cust_area%>&cust_seq=<%=cust_seq%>&code=<%=code%>&endflag51="+$("#endflag51").val()+"&end_date51="+$("#end_date51").val()+"&end_code51="+$("#end_code51").val()+"&end_type51="+$("#end_type51").val()+"&end_remark51="+$("#end_remark51").val()+"&seqend_flag="+$("#tfy_end_flag").val();
                        }
                    }
                }
            });
        });

        //reg.action = "<%=HTProgPrefix%>EditA9Z_Update.aspx";
        //if($("#chkTest").prop("checked"))
        //    reg.target = "ActFrame";
        //else
        //    reg.target = "_self";
        //reg.submit();
    }

    //退回營洽
    function formModSubmit2(){
        if ($("#back_remark").val()==""){
            alert("請輸入退回說明！");
            return false;
        }
        if(confirm("是否確定退回營洽!!!")){
            $("input:disabled, select:disabled").unlock();
            $(".bsubmit").lock(!$("#chkTest").prop("checked"));

            var formData = new FormData($('#reg')[0]);
            ajaxByForm(getRootPath() +"/brt5m/Brt51_Update3.aspx",formData)
            .complete(function( xhr, status ) {
                $("#dialog").html(xhr.responseText);
                $("#dialog").dialog({
                    title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                    ,buttons: {
                        確定: function() {
                            $(this).dialog("close");
                        }
                    }
                    ,close:function(event, ui){
                        if(status=="success"){
                            if(!$("#chkTest").prop("checked")){
                                window.parent.tt.rows="100%,0%";
                            }
                            window.parent.Etop.location.href= getRootPath() +'/brt5m/brt51_list.aspx?prgid=brt51';
                        }
                    }
                });
            });
        }
    }

    //[爭救案件交辦]
    function formOptSubmit(){
        if($("#dfy_last_date").val()==""){//法定期限
            if($("#step_last_date").val()!=""){
                alert("將依客收法定期限(" +$("#step_last_date").val()+ ")交辦專案室！");
                $("#dfy_last_date").val($("#step_last_date").val());
            }else{
                alert("此筆客收無管制法定期限，請先管制法定期限，再執行交辦專案室發文作業!!");
                settab("#case");//收費與接洽事項
                $("#dfy_last_date").focus();
                return false;
            }
        }

        if(CDate($('#step_last_date').val()).getTime()!=CDate($('#dfy_last_date').val()).getTime()){
            var ans=confirm("客收管制法定期限(" +$('#step_last_date').val()+ ")與營洽交辦法定期限(" +$('#dfy_last_date').val()+ ")不同，是否確定依客收法定期限交辦專案室？");
            if(ans==true){
                $("#dfy_last_date").val($("#step_last_date").val());
            }else{
                settab("#case");//收費與接洽事項
                $("#dfy_last_date").focus();
                return false;
            }
        }

        //2016/4/26依2016/4/7李協理Email要求增加提醒，契約書後補
        if ($("#contract_flag").val()=="Y"){
            msgbox("◎請儘速後補契約書，以利爭議組發文；倘於爭議組承辦完成官發前未後補，請mail進行簽核。");
        }
		
        //reg.btnSubmit.disabled=true
        //reg.action="../Brt18Update.aspx"	
        //reg.submitTask.value = "UPDATE"
        //reg.Submit

        var formData = new FormData($('#reg')[0]);
        ajaxByForm( getRootPath() + "/brt6m/Brt63_UpdateOpt.aspx",formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            window.parent.Etop.goSearch();
                        }
                    }
                }
            });
        });
    }

    //[註銷]
    function formCancelSubmit(){
        var a=confirm("是否確定註銷？？");
        if(a==false){
            return false;
        }

        if($("#Creason").val()==""){
            alert("請輸入註銷原因!!");
            $("#Creason").focus();
            return false;
        }

        //reg.action = getRootPath() + "/brt1m/Brt1a_Update.aspx";
        //reg.target = "ActFrame";
        //reg.submit();

        var formData = new FormData($('#reg')[0]);
        ajaxByForm( getRootPath() + "/brt1m/Brt1a_Update.aspx",formData)
        .complete(function( xhr, status ) {
            $("#dialog").html(xhr.responseText);
            $("#dialog").dialog({
                title: '存檔訊息',modal: true,maxHeight: 500,width: 800,closeOnEscape: false
                ,buttons: {
                    確定: function() {
                        $(this).dialog("close");
                    }
                }
                ,close:function(event, ui){
                    if(status=="success"){
                        if(!$("#chkTest").prop("checked")){
                            window.parent.Etop.goSearch();
                        }
                    }
                }
            });
        });
    }

    //簽核主管
    function ap_type_click(){
        $("#job_scode1,#job_scode2").lock();
        if ($("input[name='ap_type']:checked").val()=="1"){
            $("#job_scode1").unlock();
        }else{
            $("#job_scode2").unlock();
        }
    }
</script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/brt1m/brtform/CaseForm/Descript.js")%>"></script><!--欄位說明-->
