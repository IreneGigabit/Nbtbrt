<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>

<script runat="server">
    protected string HTProgCap = "國內案收文作業-查詢本所編號畫面";//;//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = "brta21";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = "brta21";//(HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;
    protected string DebugStr = "";
    protected string StrFormBtnTop = "";
    protected string StrFormBtn = "";
    protected string SQL = "";
    protected string json = "";

    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string cust_seq = "";
    protected string cgrs = "";
    protected string seqnum = "";//客發用，第幾筆seq
    protected string tot_num = "";

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        json = (Request["json"] ?? "").Trim().ToUpper();
        cust_seq = (Request["cust_seq"] ?? "").Trim();
        cgrs = (Request["cgrs"] ?? "").Trim();
        seqnum = (Request["seqnum"] ?? "").Trim();//客發用，第幾筆seq
        tot_num = (Request["tot_num"] ?? "").Trim();

        TokenN myToken = new TokenN(HTProgCode);
        //HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        DebugStr = myToken.DebugStr;
        //if (HTProgRight >= 0) {
            if (json == "Y") {
                QueryData();
            } else {
                PageLayout();
            }
            this.DataBind();
        //}
    }

    private void PageLayout() {
        if (cust_seq != "") {
            Lock["QClass"] = "Lock";
        }
    }

    private void QueryData() {
        string seq = (Request["seq"] ?? "");
        string seq1 = (Request["seq1"] ?? "");
        string cust_seq = (Request["cust_seq"] ?? "");
        string ap_cname1 = (Request["ap_cname1"] ?? "");
        string s_mark = (Request["s_mark"] ?? "");
        string pul = (Request["pul"] ?? "");
        string appl_name = (Request["appl_name"] ?? "");
        string kind_no = (Request["kind_no"] ?? "");
        string ref_no = (Request["ref_no"] ?? "");
        string kind_date = (Request["kind_date"] ?? "");
        string sdate = (Request["sdate"] ?? "");
        string edate = (Request["edate"] ?? "");
        string tot_num = (Request["tot_num"] ?? "");
        using (DBHelper conn = new DBHelper(Conn.btbrt, false).Debug(Request["chkTest"] == "TEST")) {
            SQL = "select a.seq,a.seq1,a.in_date,appl_name,a.cust_area,a.cust_seq,apply_no,b.ap_cname1,''fseq ";
            SQL += " from dmt a ";
            SQL += " inner join apcust b on a.cust_area=b.cust_area and a.cust_seq=b.cust_seq ";
            SQL += " where 1=1 ";
            if (seq != "") {
                SQL += " and a.seq like '" + seq + "%'";
            }
            if (seq1 != "") {
                SQL += " and a.seq1 like '" + seq1 + "%'";
            }
            if (cust_seq != "") {
                SQL += " and a.cust_seq = '" + cust_seq + "'";
            }
            if (ap_cname1 != "") {
                SQL += " and b.ap_cname1 like '%" + ap_cname1 + "%'";
            }
            if (s_mark != "") {
                if (s_mark == "T") {
                    SQL += " and a.s_mark in ('T','') ";
                } else {
                    SQL += " and a.s_mark = '" + s_mark + "'";
                }
            }
            if (pul != "") {
                if (s_mark == "0") {
                    SQL += " and a.pul = ''";
                } else {
                    SQL += " and a.pul = '" + pul + "'";
                }
            }
            if (appl_name != "") {
                SQL += " and a.appl_name like '%" + appl_name + "%'";
            }
            if (kind_no != "") {
                SQL += " and a." + kind_no + " = '" + ref_no + "'";
            } else {
                if (ref_no != "") {
                    SQL += " and (a.Apply_No like '%" + ref_no + "%'";
                    SQL += " or a.Issue_No like '%" + ref_no + "%'";
                    SQL += " or a.Rej_No like '%" + ref_no + "%')";
                }
            }
            if (kind_date != "") {
                if (sdate != "") {
                    SQL += " and a." + kind_date + " >= '" + sdate + "'";
                }
                if (edate != "") {
                    SQL += " and a." + kind_date + " <= '" + edate + "'";
                }
            } else {
                if (sdate != "") {
                    SQL += " and (a.In_Date >= '" + sdate + "'";
                    SQL += "  or a.Apply_Date >= '" + sdate + "'";
                    SQL += "  or a.Issue_Date >= '" + sdate + "'";
                    SQL += "  or a.End_Date >= '" + sdate + "')";
                }
                if (edate != "") {
                    SQL += " and (a.In_Date <= '" + edate + "'";
                    SQL += "  or a.Apply_Date <= '" + edate + "'";
                    SQL += "  or a.Issue_Date <= '" + edate + "'";
                    SQL += "  or a.End_Date <= '" + edate + "')";
                }
            }
            SQL += " order by a.seq,a.seq1";
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            Paging page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                //組本所編號
                page.pagedTable.Rows[i]["fseq"] = Sys.formatSeq(
                    page.pagedTable.Rows[i].SafeRead("seq", "")
                    , page.pagedTable.Rows[i].SafeRead("seq1", "")
                    , ""
                    , ""
                    , "");
            }

            var settings = new JsonSerializerSettings()
            {
                Formatting = Formatting.None,
                ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
            };

            Response.Write(JsonConvert.SerializeObject(page, settings).ToUnicode());
            Response.End();
            //return JsonConvert.SerializeObject(dt, settings).ToUnicode().Replace("\\", "\\\\").Replace("\"", "\\\"");
        }
    }
</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/inc/setstyle.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/toastr.css")%>" />
<link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.css")%>" />
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-1.12.4.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery-ui.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/jquery.datepick-zh-TW.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/lib/toastr.min.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/util.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.Snoopy.date.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/jquery.irene.form.js")%>"></script>
<script type="text/javascript" src="<%=Page.ResolveUrl("~/js/client_chk.js")%>"></script>
</head>

<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%#prgid%> <%#HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgQry" href="javascript:void(0);" >[查詢條件]</a>&nbsp;
		    <a class="imgRefresh" href="javascript:void(0);" >[重新整理]</a>
            <%#StrFormBtnTop%>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>

<form id="regPage" name="regPage" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>">
    <input type="hidden" id="cgrs" name="cgrs" value="<%=cgrs%>">
    <input type="hidden" id="seqnum" name="seqnum" value="<%=seqnum%>"><!--客發用，第幾筆seq-->
    <input type="hidden" id="tot_num" name="tot_num" value="<%=tot_num%>">

    <div id="id-div-slide">
        <table id="qryForm" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center">	
	        <TR>
		        <TD class=lightbluetable align=right>本所編號：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="text" id="seq" name="seq" size=6 maxlength=6>-
			        <input type="text" id="seq1" name="seq1" size=<%=Sys.DmtSeq1%> maxlength=<%=Sys.DmtSeq1%>>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>客戶編號：</TD>
		        <TD class=whitetablebg>
			        <INPUT type="text" id="cust_area" name="cust_area" size="1" class=SEdit readonly maxlength="1" value="<%=Session["seBranch"]%>">-
			        <INPUT type="text" id="cust_seq" name="cust_seq" size="6" maxlength="6"  value="<%#cust_seq%>" class="<%#Lock.TryGet("QClass")%>">
		        </TD>
		        <TD class=lightbluetable align=right>客戶名稱：</TD>
		        <TD class=whitetablebg>
			        <input type="text" id="ap_cname1" name="ap_cname1" size=45 maxlength=40>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>商標種類：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="hidden" id="hs_mark" name="hs_mark" value="">
			        <input type="radio" name="s_mark" value="T" onclick="regPage.hs_mark.value=this.value">商標
			        <input type="radio" name="s_mark" value="S" onclick="regPage.hs_mark.value=this.value">服務
			        <input type="radio" name="s_mark" value="L" onclick="regPage.hs_mark.value=this.value">證明
			        <input type="radio" name="s_mark" value="M" onclick="regPage.hs_mark.value=this.value">團體
			        <input type="radio" name="s_mark" value="" checked onclick="regPage.hs_mark.value = this.value">不指定
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>正聯防：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="radio" name="pul" value="0">正商標
			        <input type="radio" name="pul" value="1">聯合
			        <input type="radio" name="pul" value="2">防護
			        <input type="radio" name="pul" value="" checked>不指定
		        </TD>
	        </TR>
	        <TR>	
		        <TD class=lightbluetable align=right>商標名稱：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="text" id="appl_name" name="appl_name" size=40 maxlength=30>
		        </TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>文號種類：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="radio" name="kind_no" value="Apply_No">申請號碼
			        <input type="radio" name="kind_no" value="Issue_No">註冊號碼
			        <input type="radio" name="kind_no" value="Rej_No">核駁號碼
			        <input type="radio" name="kind_no" value="" checked>不指定</TD>
	        </TR>	
	        <TR>	
		        <TD class=lightbluetable align=right>官方文號：</TD>
		        <TD class=whitetablebg colspan=3><input type="text" id="ref_no" name="ref_no" size=20></TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期種類：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="radio" name="kind_date" value="In_Date" >立案日期
			        <input type="radio" name="kind_date" value="Apply_Date">申請日期
			        <input type="radio" name="kind_date" value="Issue_Date">註冊日期
			        <input type="radio" name="kind_date" value="End_Date">結案日期
			        <input type="radio" name="kind_date" value="" checked>不指定</TD>
	        </TR>
	        <TR>
		        <TD class=lightbluetable align=right>日期期間：</TD>
		        <TD class=whitetablebg colspan=3>
			        <input type="text" id="sdate" name="sdate" size="10" class="dateField">～
			        <input type="text" id="edate" name="edate" size="10" class="dateField">&nbsp;&nbsp;(YYYY/MM/DD)
		        </TD>
	        </TR>		
        </table>
        <br>
        <%#DebugStr%>
        <table id="tabBtn" border="0" width="100%" cellspacing="0" cellpadding="0" align="center">
	        <tr><td width="100%" align="center">
	            <input type=button class="cbutton" id="btnQuery" name="btnQuery" value ="查詢">
	            <input type=button class="cbutton" id="btnReset" name="btnReset" value ="重填">
	            <input type=button class="cbutton imgCls" id="btnClose" name="btnClose" value ="關閉">
	        </td></tr>
        </table>
    </div>

    <div id="divPaging" style="display:none">
    <TABLE border=0 cellspacing=1 cellpadding=0 width="98%" align="center">
	    <tr>
		    <td colspan=2 align=center>
			    <font size="2" color="#3f8eba">
				    第<font color="red"><span id="NowPage"></span>/<span id="TotPage"></span></font>頁
				    | 資料共<font color="red"><span id="TotRec"></span></font>筆
				    | 跳至第<select id="GoPage" name="GoPage" style="color:#FF0000"></select>頁
				    <span id="PageUp">| <a href="javascript:void(0)" class="pgU" v1="">上一頁</a></span>
				    <span id="PageDown">| <a href="javascript:void(0)" class="pgD" v1="">下一頁</a></span>
				    | 每頁筆數:<select id="PerPage" name="PerPage" style="color:#FF0000">
					    <option value="10" selected>10</option>
					    <option value="20">20</option>
					    <option value="30">30</option>
					    <option value="50">50</option>
				    </select>
                    <input type="hidden" name="SetOrder" id="SetOrder" />
			    </font>
		    </td>
	    </tr>
    </TABLE>
    </div>
</form>

<div align="center" class="noData" style="display:none">
	<font color="red">=== 目前無資料 ===</font>
</div>

<table style="display:none" border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	<thead>
      <Tr>
		<TD class=lightbluetable align=center>本所編號</TD>
		<TD class=lightbluetable align=center>立案日期</TD>
		<TD class=lightbluetable align=center>案件名稱</TD>
		<TD class=lightbluetable align=center>客戶</TD>
		<TD class=lightbluetable align=center>申請號碼</TD>
		<TD class=lightbluetable align=center>詳細資料</TD>
      </tr>
	</thead>
	<tfoot style="display:none">
	  <tr class='{{tclass}}' id='tr_data_{{nRow}}'>
        <td align=center style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" nowrap onclick="SeqClick('{{seq}}','{{seq1}}')">{{fseq}}</td>
		<td align=center nowrap>{{in_date}}</td>
		<td align=center nowrap>{{appl_name}}</td>
		<td align=center nowrap>{{ap_cname1}}</td>
		<td align=center nowrap>{{apply_no}}</td>
		<td align=center nowrap style="cursor: pointer;" onmouseover="this.style.color='red'" onmouseout="this.style.color='black'" onclick="CapplClick('{{seq}}', '{{seq1}}')">[詳細資料]</td>
      </tr>
	</tfoot>
	<tbody>
	</tbody>
</TABLE>
<br />
<div class="haveData" style="display:none">
	<center><font color='blue'>*** 請點選本所編號將資料帶回收發文作業 ***</font></center>
</div>

<div id="dialogW">
    <!--iframe id="myIframe" src="about:blank" width="100%" height="97%" style="border:none""></iframe-->
</div>

</body>
</html>


<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        }

        $("input.dateField").datepick();
        $(".Lock").lock();
    }

    //[查詢]
    $("#btnQuery").click(function (e) {
        if ($("#seq").val() == "" && $("#cust_seq").val() == ""
             && $("#ap_cname1").val() == "" && $("#hs_mark").val() == "" && $("#appl_name").val() == ""
             && $("#ref_no").val() == "" && $("#sdate").val() == "" && $("#edate").val() == "") {
            alert("請輸入任一查詢條件!!");
            return false;
        }

        if ($("#seq").val() != "" && IsNumeric($("#seq").val()) == false) {
            alert("本所序號輸入的資料必須為數值!!");
            return false;
        }
        //if ($("#seq1").val() != "" && IsNumeric($("#seq1").val()) == false) {
        //    alert("本所序號輸入的資料必須為數值!!");
        //    return false;
        //}
        if ($("#cust_seq").val() != "" && IsNumeric($("#cust_seq").val()) == false) {
            alert("客戶編號輸入的資料必須為數值!!");
            return false;
        }
        if ($("#ref_no").val() != "" && IsNumeric($("#ref_no").val()) == false) {
            alert("官方文號輸入的資料必須為數值!!");
            return false;
        }
        if ($("#sdate").val() != "" && $.isDate($("#sdate").val()) == false) {
            alert("日期期間起始資料必須為日期型態!!");
            return false;
        }
        if ($("#edate").val() != "" && $.isDate($("#edate").val()) == false) {
            alert("日期期間終止資料必須為日期型態!!");
            return false;
        }

        $("#dataList>thead tr .setOdr span").remove();
        $("#SetOrder").val("");

        //regPage.action = "brta21QList.aspx";
        //regPage.submit();
        goSearch();
    });

    //[重填]
    $("#btnReset").click(function (e) {
        regPage.reset();
        this_init();
    });

    //執行查詢
    function goSearch() {
        $("#divPaging,#dataList,.noData,.haveData").hide();
        $("#dataList>tbody tr").remove();
        nRow = 0;

        $.ajax({
            url: "brta21Query.aspx?json=Y",
            type: "get",
            async: false,
            cache: false,
            data: $("#regPage").serialize(),
            success: function (json) {
                if (!isJson(json) || $("#chkTest").prop("checked")) {
                    $("#dialogW").html("<a href='" + this.url + "' target='_new'>Debug！<u>(點此顯示詳細訊息)</u></a><hr>" + json);
                    $("#dialogW").dialog({ title: 'Debug！', modal: true, maxHeight: 500, width: "90%" });
                    return false;
                }
                var JSONdata = $.parseJSON(json);
                //////更新分頁變數
                var totRow = parseInt(JSONdata.totrow, 10);
                if (totRow > 0) {
                    $("#divPaging").show();
                    $("#dataList").show();
                    $(".haveData").show();
                } else {
                    $(".noData").show();
                }

                var nowPage = parseInt(JSONdata.nowpage, 10);
                var totPage = parseInt(JSONdata.totpage, 10);
                $("#NowPage").html(nowPage);
                $("#TotPage").html(totPage);
                $("#TotRec").html(totRow);
                var i = totPage + 1, option = new Array(i);
                while (--i) {
                    option[i] = ['<option value="' + i + '">' + i + '</option>'].join("");
                }
                $("#GoPage").replaceWith('<select id="GoPage" name="GoPage" style="color:#FF0000">' + option.join("") + '</select>');
                $("#GoPage").val(nowPage);
                nowPage > 1 ? $("#PageUp").show() : $("#PageUp").hide();
                nowPage < totPage ? $("#PageDown").show() : $("#PageDown").hide();
                $("a.pgU").attr("v1", nowPage - 1);
                $("a.pgD").attr("v1", nowPage + 1);
                $("#id-div-slide").slideUp("fast");

                $.each(JSONdata.pagedtable, function (i, item) {
                    nRow++;
                    //複製一筆
                    $("#dataList>tfoot").each(function (i) {
                        var strLine1 = $(this).html().replace(/##/g, nRow);
                        var tclass = "";
                        if (nRow % 2 == 1) tclass = "sfont9"; else tclass = "lightbluetable3";
                        strLine1 = strLine1.replace(/{{tclass}}/ig, tclass);
                        strLine1 = strLine1.replace(/{{nRow}}/ig, nRow);

                        strLine1 = strLine1.replace(/{{fseq}}/ig, item.fseq);
                        strLine1 = strLine1.replace(/{{seq}}/ig, item.seq);
                        strLine1 = strLine1.replace(/{{seq1}}/ig, item.seq1);
                        strLine1 = strLine1.replace(/{{in_date}}/ig, dateReviver(item.in_date, "yyyy/M/d"));
                        strLine1 = strLine1.replace(/{{appl_name}}/ig, item.appl_name);
                        strLine1 = strLine1.replace(/{{ap_cname1}}/ig, item.ap_cname1);
                        strLine1 = strLine1.replace(/{{apply_no}}/ig, item.apply_no);
                        $("#dataList>tbody").append(strLine1);
                    });
                });
            },
            error: function (xhr) {
                $("#dialogW").html("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialogW").dialog({ title: '案件資料載入失敗！', modal: true, maxHeight: 500, width: "90%" });
            }
        });
    };

    //每頁幾筆
    $("#PerPage").change(function (e) {
        goSearch();
    });
    //指定第幾頁
    $("#divPaging").on("change", "#GoPage", function (e) {
        goSearch();
    });
    //上下頁
    $(".pgU,.pgD").click(function (e) {
        $("#GoPage").val($(this).attr("v1"));
        goSearch();
    });
    //排序
    $(".setOdr").click(function (e) {
        $("#dataList>thead tr .setOdr span").remove();
        $(this).append("<span>▲</span>");
        $("#SetOrder").val($(this).attr("v1"));
        goSearch();
    });
    //重新整理
    $(".imgRefresh").click(function (e) {
        goSearch();
    });
    //查詢條件
    $(".imgQry").click(function (e) { $("#id-div-slide").slideToggle("fast"); });
    //關閉視窗
    $(".imgCls").click(function (e) {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "100%,0%";
        } else {
            if (window.parent.$('#dialog').length > 0) {
                window.parent.$('#dialog').dialog('close');
            } else {
                window.close();
            }
        }
    });
    //帶回資料
    function SeqClick(x1, x2) {
        var fld = $("#tot_num").val() || "";
        if (fld == "" || fld == "a_1" || fld == "b_1") {
            //window.opener.reg.old_seq.value = x1;
            //window.opener.reg.old_seq1.value = x2;
            //window.opener.reg.keyseq.value = "N";
            //window.opener.reg.btnseq_ok.disabled = false;
            //window.opener.reg.old_seq.focus();
            $("#old_seq", opener.document).val(x1);
            $("#old_seq1", opener.document).val(x2);
            $("#keyseq", opener.document).val("N");
            $("#btnseq_ok", opener.document).triggerHandler("click");
        } else {
            $("#dseq" + fld, opener.document).val(x1)
            $("#dseq1" + fld, opener.document).val(x2);
            $("#keydseq" + fld, opener.document).val("N");
            $("#btndseq_ok" + fld, opener.document).triggerHandler("click");
        }
        window.close();
    }
    //[詳細資料]
    function CapplClick(x1, x2) {
        var url = getRootPath() + "/brt5m/brt15ShowFP.aspx?seq=" + x1+ "&seq1=" + x2 + "&submittask=Q";
        window.showModalDialog(url, "", "dialogHeight: 520px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
    }
</script>
