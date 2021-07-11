<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "Newtonsoft.Json"%>
<%@ Import Namespace = "Newtonsoft.Json.Linq"%>
<%@ Register Src="~/commonForm/head_inc_form.ascx" TagPrefix="uc1" TagName="head_inc_form" %>


<script runat="server">
    protected string HTProgCap = "國內案件狀態查詢作業-流程";//HttpContext.Current.Request["prgname"];//功能名稱
    protected string HTProgPrefix = HttpContext.Current.Request["prgid"] ?? "";//程式檔名前綴
    protected string HTProgCode = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string prgid = (HttpContext.Current.Request["prgid"] ?? "").ToLower();//程式代碼
    protected int HTProgRight = 0;

    protected string SQL = "";
    protected string json = "";
    protected string tlink = "";

    protected string seq = "";
    protected string seq1 = "";
    protected string fseq = "";
    protected string appl_name = "";
    protected string sc_name = "";
    protected string now_step_grade = "";
    protected string now_statnm = "";
    

    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        seq = Request["seq"] ?? "";
        seq1 = Request["seq1"] ?? "";
        json = Request["json"] ?? "";

        TokenN myToken = new TokenN(HTProgCode);
        HTProgRight = myToken.CheckMe();
        //HTProgCap = myToken.Title;
        if (HTProgRight >= 0) {
            if (json == "Y") {
                QueryData(true);
            } else {
                QueryData(false);
                tlink = Request.QueryString.ToString();//只在第一次載入時記錄參數,避免換頁submit參數重複
                PageLayout();
            }
            this.DataBind();
        }
    }

    private void PageLayout() {
        //StrFormBtnTop += "<a class=\"imgRefresh\" href=\"javascript:void(0);\" >[重新整理]</a>\n";
        if ((HTProgRight & 2) > 0) {
            //StrFormBtn += "<input type=\"button\" id=\"btnSrch\" value=\"查　詢\" class=\"cbutton bsubmit\" />\n";
            //StrFormBtn += "<input type=\"button\" id=\"btnRest\" value=\"重　填\" class=\"cbutton\" />\n";
        }
    }
    
    private void QueryData(bool isJson) {
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            SQL = "select a.*,c.appl_name,c.step_grade as now_step_grade,b.cg,b.rs,''pcgrs ";
            SQL += ",(select code_name from cust_code where code_type='tcase_stat' and cust_code=c.now_stat) as now_statnm ";
            SQL += ",(select code_name from cust_code where code_type='ttodo' and cust_code=a.dowhat) as dowhat_nm ";
            SQL += ",(select code_name from cust_code where code_type='tjob_status' and cust_code=a.job_status) as job_statnm ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=c.scode) as sc_name ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.job_scode) as jobsc_name ";
            SQL += ",(select sc_name from sysctrl.dbo.scode where scode=a.approve_scode) as apsc_name ";
            SQL += "from todo_dmt a ";
            SQL += "inner join dmt c on a.seq=c.seq and a.seq1=c.seq1 ";
            SQL += "left outer join step_dmt b on a.seq=b.seq and a.seq1=b.seq1 and a.step_grade=b.step_grade ";
            SQL += "where a.seq=" + seq + " and a.seq1='" + seq1 + "' ";
            SQL += "order by a.in_date desc";
    
            DataTable dt = new DataTable();
            conn.DataTable(SQL, dt);

            //處理分頁
            int nowPage = Convert.ToInt32(Request["GoPage"] ?? "1"); //第幾頁
            int PerPageSize = Convert.ToInt32(Request["PerPage"] ?? "10"); //每頁筆數
            Paging page = new Paging(nowPage, PerPageSize, SQL);
            page.GetPagedTable(dt);

            //分頁完再處理其他資料才不會虛耗資源
            for (int i = 0; i < page.pagedTable.Rows.Count; i++) {
                fseq = Sys.formatSeq(page.pagedTable.Rows[i].SafeRead("seq", "")
                    , page.pagedTable.Rows[i].SafeRead("seq1", "")
                    , page.pagedTable.Rows[i].SafeRead("country", "")
                    , Sys.GetSession("SeBranch")
                    , Sys.GetSession("dept"));
                appl_name = page.pagedTable.Rows[i].SafeRead("appl_name", "");
                sc_name = page.pagedTable.Rows[i].SafeRead("sc_name", "");
                now_step_grade = page.pagedTable.Rows[i].SafeRead("now_step_grade", "");
                now_statnm = page.pagedTable.Rows[i].SafeRead("now_statnm", "");
                
                string pcgrs="";
                switch (page.pagedTable.Rows[i].SafeRead("cg", ""))
	            {
                    case "C": pcgrs="(客"; break;
                    case "G": pcgrs="(官"; break;
                    case "Z": pcgrs="(本"; break;
	            }
                switch (page.pagedTable.Rows[i].SafeRead("rs", ""))
	            {
                    case "R": pcgrs+="收)"; break;
                    case "S": pcgrs+="發)"; break;
                    case "Z": pcgrs=""; break;
	            }
                page.pagedTable.Rows[i]["pcgrs"] = pcgrs;
            }
            
            var settings = new JsonSerializerSettings()
            {
                Formatting = Formatting.None,
                ContractResolver = new LowercaseContractResolver(),//key統一轉小寫
                Converters = new List<JsonConverter> { new DBNullCreationConverter(), new TrimCreationConverter() }//dbnull轉空字串且trim掉
            };

            if (isJson) {
                Response.Write(JsonConvert.SerializeObject(page, settings).ToUnicode());
                Response.End();
            }
        }
    }
</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><%#HTProgCap%></title>
    <uc1:head_inc_form runat="server" ID="head_inc_form" />
</head>
<script language="javascript" type="text/javascript">
    var main = {};
    main.branch = "<%#Session["SeBranch"]%>";
    main.prgid = "<%#prgid%>";
    main.right = <%#HTProgRight%>;
</script>
<body>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
    <tr>
        <td class="text9" nowrap="nowrap">&nbsp;【<%=prgid%> <%=HTProgCap%>】</td>
        <td class="FormLink" valign="top" align="right" nowrap="nowrap">
            <a class="imgCls" href="javascript:void(0);" >[關閉視窗]</a>
        </td>
    </tr>
    <tr>
        <td colspan="2"><hr class="style-one"/></td>
    </tr>
</table>
<table cellspacing="1" cellpadding="0" width="98%" border="0" align="center">
	<tr>
		<td class="text9" style="color:blue" width="20%">
            案件編號：<%#fseq%>
		</td>
		<td class="text9" style="color:blue">案件名稱：<%#appl_name%>
		</td>
	</tr>
	<tr>	
		<td class="text9" style="color:blue">
            營洽：<%#sc_name%>
		</td>
		<td class="text9" style="color:blue">
            目前進度：<%#now_step_grade%>&nbsp;&nbsp;案件狀態：<%#now_statnm%>
		</td>
	</tr>
</table>
<br>
<!--form id="regPage" name="regPage" method="post">
    <input type="hidden" id="prgid" name="prgid" value="<%=prgid%>"-->

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
<!--/form-->

<div align="center" id="noData" style="display:none">
	<font color="red">=== 目前無資料 ===</font>
</div>

<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="98%" align="center" id="dataList">
	<thead>
      <Tr>
		<TD class="lightbluetable" align=center>進度</TD>
		<TD class="lightbluetable" align=center>交辦單號</TD>
		<TD class="lightbluetable" align=center>分派日期</TD>
		<TD class="lightbluetable" align=center>預計<br>處理人員</TD>
		<TD class="lightbluetable" align=center>管制日期</TD>
		<TD class="lightbluetable" align=center>實際<br>處理人員</td>
		<TD class="lightbluetable" align=center>實際處理日期</TD>
		<TD class="lightbluetable" align=center>狀態</TD>
		<TD class="lightbluetable" align=center>處理情形</TD>
		<TD class="lightbluetable" align=center>處理說明</TD>
      </tr>
	</thead>
	<tbody></tbody>
    <script type="text/html" id="data_template"><!--清單樣板-->
        <tr class='{{tclass}}' id='tr_data_{{nRow}}'>
			<td align=center nowrap>{{step_grade}}{{pcgrs}}</td>
			<td align=center nowrap>{{case_no}}</td>
			<td align=center>{{in_date}}</td>
			<td align=center nowrap>{{jobsc_name}}</td>
			<td align=center nowrap>{{ctrl_date}}</td>
			<td align=center nowrap>{{apsc_name}}</td>
			<td align=center>{{resp_date}}</td>
			<td align=center nowrap >{{dowhat_nm}}</td>
			<td align=center nowrap><span id="stat_color_{{nRow}}">{{job_statnm}}</span></td>
			<td align=center >{{approve_desc}}</td>
		</tr>
    </script>
</TABLE>
<br />

<div id="dialog"></div>

</body>
</html>

<script language="javascript" type="text/javascript">
    $(function () {
        this_init();
    });

    function this_init() {
        if (window.parent.tt !== undefined) {
            window.parent.tt.rows = "30%,*";
        }
        goSearch();
    }

    //執行查詢
    function goSearch() {
        $("#divPaging,#dataList,.noData,.haveData").hide();
        $("#dataList>tbody tr").remove();
        nRow = 0;

        $.ajax({
            url: "brta61List2.aspx?json=Y&GoPage="+($("#GoPage").val()||"1")+
                "&PerPage="+($("#PerPage").val()||"")+"&SetOrder="+($("#SetOrder").val()||"")+"&<%=tlink%>",
            type: "get",
            async: false,
            cache: false,
            //data: $("#regPage").serialize(),
            success: function (json) {
                if (!isJson(json) || $("#chkTest").prop("checked")) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>Debug！<u>(點此顯示詳細訊息)</u></a><hr>" + json);
                    $("#dialog").dialog({ title: 'Debug！', modal: true, maxHeight: 500, width: "90%" });
                    return false;
                }
                var JSONdata = $.parseJSON(json);
                //////更新分頁變數
                var totRow = parseInt(JSONdata.totrow, 10);
                if (totRow > 0) {
                    $("#divPaging,#dataList,.haveData").show();
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
                //$("#id-div-slide").slideUp("fast");

                $.each(JSONdata.pagedtable, function (i, item) {
                    nRow++;
                    //複製樣板
                    var copyStr = $("#data_template").text() || "";
                    copyStr = copyStr.replace(/##/g, nRow);
                    var tclass = "";
                    if (nRow % 2 == 1) tclass = "sfont9"; else tclass = "lightbluetable3";
                    copyStr = copyStr.replace(/{{tclass}}/g, tclass);
                    copyStr = copyStr.replace(/{{nRow}}/g, nRow);

                    copyStr = copyStr.replace(/{{step_grade}}/gi, item.step_grade);
                    copyStr = copyStr.replace(/{{pcgrs}}/gi, item.pcgrs);
                    copyStr = copyStr.replace(/{{case_no}}/gi, item.case_no);
                    copyStr = copyStr.replace(/{{in_date}}/gi, dateReviver(item.in_date, "yyyy/M/d t HH:mm:ss"));
                    copyStr = copyStr.replace(/{{jobsc_name}}/gi, item.jobsc_name);
                    copyStr = copyStr.replace(/{{ctrl_date}}/gi, dateReviver(item.ctrl_date, "yyyy/M/d"));
                    copyStr = copyStr.replace(/{{apsc_name}}/gi, item.apsc_name);
                    copyStr = copyStr.replace(/{{resp_date}}/gi, dateReviver(item.resp_date, "yyyy/M/d t HH:mm:ss"));
                    copyStr = copyStr.replace(/{{dowhat_nm}}/gi, item.dowhat_nm);
                    copyStr = copyStr.replace(/{{job_statnm}}/gi, item.job_statnm);
                    copyStr = copyStr.replace(/{{approve_desc}}/gi, item.approve_desc);

                    $("#dataList>tbody").append(copyStr);

                    if(item.job_status=="NN")$("#stat_color_"+nRow).css("color","red");
                });
            },
            beforeSend: function (jqXHR, settings) {
                jqXHR.url = settings.url;
            },
            error: function (xhr) {
                $("#dialog").html("<a href='" + this.url + "' target='_new'>資料擷取剖析錯誤！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                $("#dialog").dialog({ title: '資料擷取剖析錯誤！', modal: true, maxHeight: 500, width: 800 });
                //toastr.error("<a href='" + this.url + "' target='_new'>案件資料載入失敗！<BR><b><u>(點此顯示詳細訊息)</u></b></a>");
            }
        });
    };
    //////////////////////
</script>
