<%@ Control Language="C#" ClassName="dmt_CR_form" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public Dictionary<string, string> Hide = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    public int HTProgRight = 0;

    public string uploadfield = "attach";
    public string seq = "";
    public string seq1 = "";
    public string step_grade = "";
    public string in_no = "";
    public string case_no = "";
    public string erpt_code = "";

    protected string submitTask = "";
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string uploadtype = "";
    protected string source = "";
    protected string epath = "";
    protected string uploadsource = "";
    protected string StrFormRemark = "";
    
    protected string html_doc = "";
    private void Page_Load(System.Object sender, System.EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        submitTask = (Request["submittask"] ?? "").Trim();
        uploadtype = (Request["uploadtype"] ?? "").ToLower();
        source = Request["source"] ?? "";
        prgid = prgid.ToLower();
        seq = (Request["seq"] ?? "");
        seq1 = (Request["seq1"] ?? "");
        step_grade = (Request["step_grade"] ?? "");
        in_no = (Request["in_no"] ?? "");
        case_no = (Request["case_no"] ?? "");
        
        if (uploadtype == "case") {//表示從接洽記錄上傳
            epath = "doc/case";
            uploadsource = "CASE";
        } else {
            var efseq=seq.PadLeft(5,'0');
	        epath="doc/"+seq1+"/"+efseq.Left(3)+"/"+efseq;
            if (source != "") uploadsource = source;
        }
            
        if (submitTask == "D" || submitTask == "Q" || submitTask == "R") {
	        Lock["Qup"] = "Lock";
        } else {
            Lock["Qup"] = "";
        }

        string pwhere = "";
        if (submitTask != "Q") pwhere += "and (mark is null or mark<>'B')";//維護時只顯示區所文件種類
        if (erpt_code != "") pwhere += "and (remark is null or remark like '%" + erpt_code + "%'";
        html_doc = Sys.getCustCode("TDOC", pwhere, "sortfld").Option("{cust_code}", "{code_name}", " v1='{mark1}'", true);

        PageLayout();
        this.DataBind();
    }

    private void PageLayout() {
        //2010/7/26承辦交辦發文不需顯示 
        if (submitTask == "A" && prgid != "brt63") {
            StrFormRemark += "<div style='color:blue;'>\n";
            StrFormRemark += "<br>備註：\n";
            StrFormRemark += "　　※檔案上傳之後，最後記得按下「新增存檔」！\n";
            if (uploadsource == "CASE") {
                StrFormRemark += "<br>　　※若文件檔案要交辦專案室，請勾選「交辦專案室」；若不需，請取消勾選，則專案室即不會看到本項文件檔案\n";
            }
            StrFormRemark += "<br>　　※僅有以<font color=red>電子送件</font>之[<font color=red>官發</font>]且勾選「電子送件文件檔」會將文件檔更新至商標電子送件區\n";
            StrFormRemark += "<br>　　※若文件檔案為電子送件所需文件，請勾選「電子送件文件檔」；若不需，請取消勾選\n";
            StrFormRemark += "</div>\n";
        } else {
            if (uploadsource == "CASE" && prgid != "brt81") {
                StrFormRemark += "<div style='color:blue;'>\n";
                StrFormRemark += "<br>備註：<br>\n";
                StrFormRemark += "　　※若文件檔案要交辦專案室，請勾選「交辦專案室」；若不需，請取消勾選，則專案室即不會看到本項文件檔案\n";
                StrFormRemark += "</div>\n";
            }
        }
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<TABLE id=tabbr style="display:" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
	<TR>
		<TD align=center colspan=6 class=lightbluetable1><font color=white>收&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>進度序號：</TD>
		<TD class=whitetablebg>
			<input type="text" id="closewin" name="closewin" value="N">
			<input type="text" id="code" name="code" value="<%=code%>">
			<input type="text" id="in_no" name="in_no" value="<%=in_no%>">
			<input type="text" id="in_scode" name="in_scode" value="<%=in_scode%>">
			<input type="text" id="change" name="change" value="<%=change%>">
			<input type="text" id="cust_area1" name="cust_area1" value="<%=cust_area%>">
			<input type="text" id="cust_seq1" name="cust_seq1" value="<%=cust_seq%>">
			<input type="text" id="rs_no" name="rs_no" value=<%=rs_no%>>
			<input type="text" id="nstep_grade" name="nstep_grade" size="2" class="sedit" readonly value=<%=nstep_grade%>>
			<input type="text" id="cgrs" name="cgrs" value="<%=cgrs%>">
			<select id=scgrs name=scgrs <%=Qdisabled%>>
				<option value="CR">客收</option>
			</select>
		</TD>
		<TD class=lightbluetable align=right>收文日期：</TD>
		<TD class=whitetablebg ><input type="text" name="step_date" size="10" <%=QClass%> value="<%=step_date%>" class="dateField"></TD>
		<TD class=lightbluetable align=right>來文字號：</TD>
		<TD class=whitetablebg ><input type="text" name="receive_no" size=20 maxlength=20 <%=QClass%> value=<%=receive_no%>></TD>
	</TR>
	<TR>
		<TD class=lightbluetable align=right>收文代碼：</TD>
		<TD class=whitetablebg colspan=5>結構分類：
			<input type="hidden" name="rs_type" id="rs_type" value="<%=rs_type%>">
			<span id=span_rs_class>
			<input type="hidden" name="hrs_class" value="<%=rs_class%>">
			<select name="rs_class" id="rs_class" <%IF submitTask="Q" then%> disabled <%Else%><%IF prgid="brta22" and change="C" and rs_code<>arcase then%> <%Else%>disabled<%End IF%><%End IF%>>
				<%SQL="select cust_code,code_name from cust_code where code_type='" & rs_type & "' and mark is null" & _
				      " and cust_code in (select rs_class from vcode_act where cg ='C' and rs = 'R') order by cust_code"
				call ShowSelect3(conn,SQL,false,rs_class)%>			
			</select>
			</span>
			案性代碼：
			<span id=span_rs_code>
				<input type="hidden" name="hrs_code" value="<%=rs_code%>">
				<select name="rs_code" <%IF submitTask="Q" then%> disabled <%Else%><%IF prgid="brta22" and change="C" and rs_code<>arcase then%> onchange='rs_code_onchange1()' <%Else%>disabled<%End IF%><%End IF%>>
				<%SQL="select rs_code,rs_detail,rs_class from code_br where dept='" &session("dept")& "' and cr='Y' and rs_type = '" & rs_type & "'"
				  if submittask = "A" then
					SQL = SQL & " and (end_date is null or end_date = '' or end_date > getdate())"					
				  end if
				  SQL =  SQL & " order by rs_class,rs_code"
				call ShowSelect3(conn,SQL,false,rs_code)%>
				</select>
			</span><br>
			處理事項：
			<input type="hidden" name="act_sqlno" value="<%=act_sqlno%>">
			<span id=span_act_code>
				<input type="hidden" name="hact_code" value="<%=act_code%>">
				<select name="act_code" <%IF submitTask="Q" then%> disabled <%Else%> <%IF prgid="brta22" and change="C" and rs_code<>arcase then%><%Else%>disabled<%End IF%> <%End IF%>>
				<%SQL= "select distinct b.act_code, c.code_name ,c.sql from  code_br  a , code_act b, cust_code c" & _
				       " where a.dept = '" &session("dept")& "' and a.cr = 'Y'" & _
				       " and a.rs_type = '" & rs_type & "'" & _
				       " and a.sqlno = b.code_sqlno" & _
				       " and b.act_code = c.cust_code " & _
					   " and c.code_type = 'TACT_Code'"
						if submittask = "A" then
							SQL = SQL & " and (a.end_date is null or a.end_date = '' or a.end_date > getdate())"
							SQL = SQL & " and (b.end_date is null or b.end_date = '' or b.end_date > getdate())"
						end if
						if rs_class <> empty then
							SQL = SQL & " and a.rs_class = '" & rs_class & "'"
						end if
						if rs_code <> empty then
							SQL = SQL & " and a.rs_code = '" & rs_code & "'"
						end if
				SQL = SQL & " order by c.sql"
				call ShowSelect3(conn,SQL,false,act_code)%>
				</select>
			</span>
			&nbsp;&nbsp;&nbsp;&nbsp;本次狀態：
			<input type="hidden" name="ocase_stat" size="10" value="<%=ocase_stat%>">
			<input type="hidden" name="ncase_stat" size="10" value="<%=ncase_stat%>">
			<input type="text" name="ncase_statnm" size="10" <%=QClass%> value="<%=ncase_statnm%>" class=sedit readonly>
		</TD>
    </TR>
    <TR>
		<TD class=lightbluetable align=right>收文內容：</TD>
		<TD class=whitetablebg colspan=5><input type="text" name="rs_detail" size=60 <%=QClass%> value=<%=rs_detail%>></TD>
	</TR>
    <TR>
		<TD class=lightbluetable align=right>附件：</TD>
		<TD class=whitetablebg colspan=5><input type="text" name="doc_detail" size=60 maxlength=60 <%=QClass%> value=<%=doc_detail%>></TD>
	</tr>
	<TR>
		<TD class=lightbluetable align=right>承辦：</TD>
		<TD class=whitetablebg colspan=3>
			<SELECT name="pr_scode" value="<%=pr_scode%>" <%=Qdisabled%>>
			<%SQL="select a.scode,b.sc_name,a.sort "
			SQL = SQL & " from scode_roles a,scode b where a.scode=b.scode"
			SQL = SQL & " and a.dept = '" &ucase(session("dept"))& "' and syscode = '" &session("syscode")& "' and prgid = 'brta21' " & _ 
			            " and roles = 'process' and branch = '" & session("se_branch") & "'" & _
			            " order by sort"
			call ShowSelect4(cnn,SQL,true,pr_scode,"不需承辦")%>				
			</SELECT>			
		</TD>
		<TD class=lightbluetable align=right>官方號碼：</TD>
		<TD class=whitetablebg>
			<SELECT name=send_sel value="<%=send_sel%>" <%=Qdisabled%>>
			<%SQL="select cust_code,code_name from cust_code where code_type='SEND_SEL'"
			call ShowSelect3(conn,SQL,false,send_sel)%>
			</SELECT>
		</TD>		
	</TR>
	<TR id="show_optstat" style="display:none">
		<TD class=lightbluetable align=right><font color=darkblue>※爭救案交辦：</font></TD>
		<TD class=whitetablebg colspan=5>
			<input type=radio name="opt_stat" value="N" <%=Qdisabled_opt%> <%if opt_stat="N" or submitTask="A" then response.write " checked"%>>需交辦
			<input type=radio name="opt_stat" value="X" <%=Qdisabled_opt%> <%if opt_stat="X" then response.write " checked"%>>不需交辦				
			<span id="sp_optstat" style="display:none">
			<input type=radio name="opt_stat" value="Y" <%=Qdisabled_opt%> <%if opt_stat="Y" then response.write " checked"%>>已交辦
			</span>
		</TD>
	</tr>
	<%if ucase(prgid) = "BRT51" then%>	
	    <tr id="show_paytimes" style="display:none">
			    <td class="lightbluetable" align="right">註冊費繳納：</td>
			    <td class="whitetablebg" colspan=3 >
	   			    <Select NAME=pay_times id=pay_times SIZE=1 <%=Qdisabled%>>
					    <%SQL="SELECT cust_code, code_name FROM cust_code where code_type = '"&ucase(session("dept"))&"PAY_TIMES' ORDER BY sortfld"
					    call ShowSelect3(conn,SQL,false,"")
					    %>
				    </SELECT>						
			    </td>
			    <td class="lightbluetable"  align="right">繳納日期：</td>
			    <td class="whitetablebg"><input type="text" name="pay_date" size="10" <%=QClass%> class="dateField"></td>
	    </tr>
	    <TR id="show_endstat" style="display:none">
		    <TD class=lightbluetable align=right><font color=darkblue>結案處理：</font></TD>
		    <TD class=whitetablebg colspan=5>
			    <input type=radio name="end_stat" value="B61" <%=Qdisabled%> <%if submitTask="A" then response.write " checked"%> onclick="vbscript: end_stat_onclick">送會計確認
			    <input type=radio name="end_stat" value="B6" <%=Qdisabled%> onclick="vbscript: end_stat_onclick">待結案處理				
		    </TD>
	    </tr>
	<%end if%>
	<TR><!--20160923 增加維護發文方式-->
		<TD class=lightbluetable align=right>發文方式：</TD>
		<TD class=whitetablebg colspan=5><input type="hidden" id="old_send_way" name="old_send_way" value="<%=send_way%>">
		<SELECT id="send_way" name="send_way" onchange="javascript:setReceipt_type(this.value)">
		</select>
		</TD>
	</TR>
	<%if prgid="brta22" then%>
	<TR><!--20160923 增加維護發文方式-->
		<!--20180712 增加客收維護可修改收據種類-->
		<TD class=lightbluetable align=right>官發收據種類：</TD>
		<TD class=whitetablebg><input type="hidden" id="old_receipt_type" name="old_receipt_type" value="<%=receipt_type%>">
			<select id="receipt_type" name="receipt_type">
				<option value="" style="color:blue">請選擇</option>
				<option value="P" <%if receipt_type="P" then Response.Write "selected"%>>紙本收據</option>
				<option value="E" <%if receipt_type="E" then Response.Write "selected"%>>電子收據</option>
			</select>
		</TD>
		<TD class=lightbluetable align=right>收據抬頭：</TD>
		<TD class=whitetablebg colspan=3><input type="hidden" id="old_receipt_title" name="old_receipt_title" value="<%=receipt_title%>">
			<select id="receipt_title" name="receipt_title">
				<option value="" style="color:blue">請選擇</option>
				<option value="A" <%if receipt_title="A" then Response.Write "selected"%>>案件申請人</option>
				<option value="B" <%if receipt_title="B" or receipt_title="" then Response.Write "selected"%>>空白</option>
				<option value="C" <%if receipt_title="C" then Response.Write "selected"%>>案件申請人(代繳人)</option>
			</select>
		</TD>
	</TR>
	<%end if%>
</table>
<input type="hidden" name=tot_num value=0><!--一案多件筆數-->
<span id="span_seq" style="display:none" >
	<TABLE id=tabar1 style="display:" border=0 class="bluetable" cellspacing=1 cellpadding=2 width="100%">
		<TR>
			<TD class=whitetablebg colspan=7><span id="span_seqdesc">此次變更本所編號：</span></TD>
		</TR>
		<TR align=center class=lightbluetable>
			<%if mid(rs_code,1,2) = "FD" then %>
				<TD></TD><TD style="display:none">本所編號</TD><td>商標種類</TD><TD>類別</TD><TD>商標/案件名稱</TD>
				<TD><span id="span_no">申請號</span></TD>
			<%else%>
				<TD></TD><TD>本所編號</TD><td>商標種類</TD><TD>類別</TD><TD>商標/案件名稱</TD>
				<TD><span id="span_no">申請號</span></TD>
			<%end if%>
		</TR>
	</table>
</span>

<script language="javascript" type="text/javascript">
    var upload_form = {};
    upload_form.uploadtype = "<%#uploadtype%>";

    upload_form.init = function () {
        var fld = $("#uploadfield").val();

        if (upload_form.prgid == "brt81") {
            $("#uploadTitle").html("交&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;辦&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;相&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;關&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;件");
        } else {
            if (upload_form.prgid != "brt62" || (upload_form.prgid == "brt62" && main.submittask == "A")) {
                $("#tabfile" + fld + ">thead").append($("#upload_btn").text());//增加按鈕
            }
        }

        /*
        $("#tabfile" + fld + ">tbody").empty();
        //從接洽記錄上傳
        if (upload_form.uploadtype == "case") {
            //非異動上傳作業
            $.each(main.brdmt_attach, function (i, item) {
                //增加一筆
                upload_form.appendFile();
                //填資料
                var nRow = $("#brdmt_filenum").val();
                $("#" + fld + "_name_" + nRow).val(item.attach_name);
                $("#old_" + fld + "_name_" + nRow).val(item.attach_name);
                $("#" + fld + "_" + nRow).val(item.attach_path);
                $("#doc_type_" + nRow).val(item.doc_type);
                $("#" + fld + "_desc_" + nRow).val(item.attach_desc);
                $("#" + fld + "_size_" + nRow).val(item.attach_size);
                $("#attach_sqlno_" + nRow).val(item.attach_sqlno);
                $("#source_name_" + nRow).val(item.source_name);
                $("#attach_no_" + nRow).val(item.attach_no);
                $("#attach_flag_" + nRow).val("U");//維護時判斷是否要更名，即A表示新上傳的文件
                $("#attach_flagtran_" + nRow).val(item.attach_flagtran);//異動作業上傳註記Y
                $("#tran_sqlno_" + nRow).val(item.tran_sqlno);//異動作業流水號
                $("#" + fld + "_apattach_sqlno_" + nRow).val(item.apattach_sqlno);//總契約書/委任書流水號
                $("#btn" + fld + "_" + nRow).prop("disabled",true);
                $("input[name='" + fld + "_branch_" + nRow + "'][value='" + item.attach_branch + "']").prop("checked", true);//交辦專案室
                $("#bropen_path_" + nRow).val(item.preview_path);
                if (upload_form.prgid == "brt81") {
                    if (item.attach_flagtran == "Y") {//判斷異動作業上傳，非異動作業上傳不能修改
                        if (maine.aspname == "brt81tran") {//異動作業
                            upload_form.readonly(nRow);
                        } else if (maine.aspname == "brt81show") {//異動維護作業
                            if ($("#tran_sqlno_" + nRow).val() != $("#sqlno1").val()) {//異動流水序號不同，不能修改
                                upload_form.readonly(nRow);
                            }
                        }
                    } else {
                        upload_form.readonly(nRow);
                    }
                }

                if (i == 0) {
                    $("#attach_seq").val(item.seq);
                    $("#attach_seq1").val(item.seq1);
                    $("#attach_step_grade").val(item.step_grade);
                    $("#attach_in_no").val(item.in_no);
                    $("#attach_case_no").val(item.case_no);
                }
                $("#maxattach_no").val(item.attach_no);
            });


            if (main.prgid == "brt81") {
                //異動上傳作業
                $("#tabfile" + fld + ">tbody").append(
                "<TR><TD align=center colspan=5 class=lightbluetable1>"+
                "   <span style=\"color:white\">異&nbsp;&nbsp;&nbsp;動&nbsp;&nbsp;&nbsp;相&nbsp;&nbsp;&nbsp;關&nbsp;&nbsp;&nbsp;文&nbsp;&nbsp;&nbsp;件</span>" +
                "</TD></TR>");
            }
        } else {
            //案件附件
        }*/
    }


    //[多檔上傳]
    upload_form.mAppendFile = function (nRow) {
        var fld = $("#uploadfield").val();
        var tfolder = $("#" + fld + "_path").val();//存檔路徑
        var nfilename = "";//"KT-" + $("#opt_no").val() + "-{{attach_no}}m";//新檔名格式

        var urlasp = getRootPath() + "/sub/multi_upload_file.aspx?type=doc";
        urlasp += "&attach_tablename=dmt_attach&filename_flag=source_name";
        urlasp += "&folder_name=" + tfolder + "&nfilename=" + nfilename;
        urlasp += "&syscode=&branch=&dept=&seq=&seq1=&step_grade=";//attachtemp的key值
        urlasp += "&apcode=&prgid=<%=prgid%>";//remark用
        var mm = window.open(urlasp, "mupload", "width=700 height=600 top=50 left=150 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=yes scrollbars=yes");
        mm.focus();
        //$("#dialog").dialog({
        //    autoOpen: false, width: 700, height: 700,
        //    modal: true,
        //    open: function (ev, ui) {
        //        $('#myIframe').attr('src', urlasp);
        //    }
        //});
        //$('#dialog').dialog('open');
    }
    //多檔上傳後回傳資料顯示於畫面上
    function uploadSuccess(rvalue) {
        var fld = $("#uploadfield").val();
        if (rvalue.msg == "") {//沒有錯誤或警告
            upload_form.appendFile();
            //傳回:檔案名稱，虛擬完整路徑，原始檔名，檔案大小，attach_no
            var listno = $("#" + fld + "_filenum").val();
            var attach_no = rvalue.attach_no;
            if ((attach_no || "") == "") attach_no = CInt($("#maxattach_no").val()) + 1;
            $("#" + fld + "_maxAttach_no").val(attach_no);
            $("#" + fld + "_name_" + listno).val(rvalue.name);
            $("#" + fld + "_size_" + listno).val(rvalue.size);
            $("#" + fld + "_" + listno).val(rvalue.dir);
            $("#source_name_" + listno).val(rvalue.source);
            $("#" + fld + "_attach_no_" + listno).val(attach_no);
            $("#btn" + fld + "_" + listno).prop("disabled", true);

            //先判斷原本資料是否有attach_sqlno,若有表示修改,若沒有表示新增
            if ($("#attach_sqlno_" + listno).val() != "") {
                $("#attach_flag_" + listno).val("U");//修改
            } else {
                $("#attach_flag_" + listno).val("A");//新增
            }
        }
    }

    //[增加一筆]
    upload_form.appendFile = function () {
        var fld = $("#uploadfield").val();

        if (main.prgid == "brt62" && main.submittask == "A") {//文件上傳作業
            if ($("#step_grade").val() == "0" && $("#" + fld + "_filenum").val() == "0") {
                var ans = confirm("對應進度0，是否確定將文件上傳至進度0？若不是進度0，請先點選「否」再點選「查詢」以重新選取對應進度後再上傳");
                if (ans == false) {
                    $("#btnquery").focus();
                    return false;
                }
            }
        }

        var nRow = CInt($("#" + fld + "_filenum").val()) + 1;//畫面顯示NO
        $("#maxattach_no").val(CInt($("#maxattach_no").val()) + 1);//table+畫面顯示 NO
        //複製樣板
        //$("#tabfile" + fld + ">tfoot").each(function (i) {
        //    var strLine1 = $(this).html().replace(/##/g, nRow);
        //    $("#tabfile" + fld + ">tbody").append(strLine1);
        //});
        var copyStr = $("#tabfile" + fld + ">#upload_template").text() || "";
        copyStr = copyStr.replace(/##/g, nRow);
        $("#tabfile" + fld + ">tbody").append(copyStr);
        $("#" + fld + "_filenum").val(nRow);
        $("#attach_no_" + nRow).val($("#maxattach_no").val());//dmt_attach.attach_no

        if ($("#prgid").val() == "brta38") {
            $("#span_source_" + nRow).show();//原始檔名
        }
        if ($("#uploadsource").val() == "CASE") {
            $("#span_branch_" + nRow).show();//交辦專案室
        } else {
            //不是發文畫面會出錯,增加判斷
            if (document.getElementsByName("cgrs").length > 0 && document.getElementById("cgrs").value == "GS") {
                $("#span_edoc_" + nRow).show();//電子送件文件檔
            }
        }
    }

    //[減少一筆]
    upload_form.deleteFile = function () {
        var fld = $("#uploadfield").val();
        var tfilenum = CInt($("#" + fld + "_filenum").val());//畫面顯示NO
        if (tfilenum > 0) {
            if ($("#" + fld + "_name_" + tfilenum).val() == "") {
                $(".tr_brattach_" + tfilenum).remove();
                $("#" + fld + "_filenum").val(Math.max(0, tfilenum - 1));
            } else {
                //檔案已存在要刪除
                if (upload_form.DelAttach(tfilenum) == true) {
                    //先不刪除,而是使用隱藏方式
                    $(".tr_brattach_" + tfilenum).hide();
                }
            }
        }
    }

    //欄位鎖定
    upload_form.readonly = function (nRow) {
        $("#" + fld + "_desc_" + nRow).lock();
        $("#btn" + fld + "_" + nRow).hide();
        $("#btn" + fld + "_D_" + nRow).hide();
        $("#doc_type_" + nRow).lock();
        $("#"+fld+"_branch_" + nRow).lock();
    }

    //[上傳]
    upload_form.UploadAttach = function (nRow) {
        var tfolder = $("#" + $("#uploadfield").val() + "_path").val();
        var url = getRootPath() + "/sub/upload_win_file_new.aspx?type=doc" +
            "&attach_sqlno_name=attach_sqlno_" + nRow +
            "&folder_name=" + tfolder +
            "&file_name=" + $("#uploadfield").val() + "_name_" + nRow +
            "&size_name=" + $("#uploadfield").val() + "_size_" + nRow +
            "&dir_name=" + $("#uploadfield").val() + "_" + nRow +
            "&attach_flag_name=attach_flag_" + nRow +
            "&prgid=<%=prgid%>" +
            "&btnname=btn" + $("#uploadfield").val() + "_" + nRow +
            "&filename_flag=source_name";
        window.open(url, "dmtupload", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[刪除]
    upload_form.DelAttach = function (nRow) {
        var fld = $("#uploadfield").val();

        if (document.getElementById(fld + "_" + nRow).value == "") {
            alert("無檔案可刪除!!");
            return false;
        }
        var file = document.getElementById(fld + "_" + nRow).value;
        var tname = document.getElementById(fld + "_name_" + nRow).value;
        if (file.indexOf(".") > -1) {	//路徑包含檔案
            if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
                file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
            }
        } else {
            file += "\\" + tname;
        }
        
        //2015/12/25for總契約書/委任書增加檢查(只取消連結不刪實體檔)
        if (document.getElementById(fld + "_apattach_sqlno_" + nRow).value != "") {
            if (confirm("確定取消" + document.getElementById(fld + "_desc_" + nRow).value + "連結？")) {
                document.getElementById(fld + "_apattach_sqlno_" + nRow).value = "";
                document.getElementById(fld + "_name_" + nRow).value = "";
                document.getElementById("source_name_" + nRow).value = "";
                document.getElementById(fld + "_desc_" + nRow).value = "";
                document.getElementById(fld + "_" + nRow).value = "";
                document.getElementById(fld + "_size_" + nRow).value = "";
                document.getElementById("doc_type_" + nRow).value = "";
                document.getElementById("btn" + fld + "_" + nRow).disabled = false;
                document.getElementById("attach_flag_" + nRow).value = "D";
            }
            return false;
        }

        if (confirm("確定刪除上傳檔案？")) {
            $.ajax({
                url: getRootPath() + "/sub/del_draw_file_new.aspx?type=doc&draw_file=" + file,
                type: 'GET',
                dataType: "script",
                async: false,
                cache: false,
                success: function(data) {
                    document.getElementById(fld + "_name_" + nRow).value = "";
                    document.getElementById("source_name_" + nRow).value = "";
                    document.getElementById(fld + "_desc_" + nRow).value = "";
                    document.getElementById(fld + "_" + nRow).value = "";
                    document.getElementById(fld + "_size_" + nRow).value = "";
                    document.getElementById("doc_type_" + nRow).value = "";
                    document.getElementById("btn" + fld + "_" + nRow).disabled = false;
                    document.getElementById("attach_flag_" + nRow).value = "D";
                },
                error: function (xhr) { 
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>刪除檔案失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                    $("#dialog").dialog({ title: '刪除檔案失敗！', modal: true, maxHeight: 500,width: "90%" });
                }
            });
            
            //window.open(getRootPath() + "/sub/del_draw_file_new.aspx?type=doc&draw_file=" + file, "myWindowOneN", "width=10 height=10 top=1000 left=1000 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            //document.getElementById(fld + "_name_" + nRow).value = "";
            //document.getElementById("source_name_" + nRow).value = "";
            //document.getElementById(fld + "_desc_" + nRow).value = "";
            //document.getElementById(fld + "_" + nRow).value = "";
            //document.getElementById(fld + "_size_" + nRow).value = "";
            //document.getElementById("doc_type_" + nRow).value = "";
            //document.getElementById("btn" + fld + "_" + nRow).disabled = false;
            //document.getElementById("attach_flag_" + nRow).value = "D";
            
        } else {
            document.getElementById(fld + "_desc_" + nRow).focus();
            return false;
        }
    }

    //檢視
    upload_form.PreviewAttach = function (nRow) {
        var fld = $("#uploadfield").val();
        if ($("#" + fld + "_name_" + nRow).val() == "") {
            alert("請先上傳附件 !!");
            return false;
        }

        var file = document.getElementById(fld + "_" + nRow).value;
        var tname = document.getElementById(fld + "_name_" + nRow).value;
        if (file.indexOf(".") > -1) {	//路徑包含檔案
            if (file.indexOf("/") > -1) {	//當檔名前的符號為/，將檔名前/改為\
                file = file.substr(0, file.lastIndexOf("/")) + "\\" + tname;
            }
        } else {
            file += "\\" + tname;
        }

        window.open(file);
    }

    //檔案說明
    upload_form.getfiledoc = function (nRow) {
        var fld = $("#uploadfield").val();
        if ($("#doc_type_" + nRow).val() == "") {
            $("#doc_type_mark_" + nRow).val("");
            return false;
        }

        var dname = $("#" + fld + "_desc_" + nRow).val().trim();
        if (dname != "") dname += "、";
        dname += $("#doc_type_" + nRow + " :selected").text();
        $("#" + fld + "_desc_" + nRow).val(dname);

        //抓取文件種類之mark1說明，for電子送件copy時用原始檔名或更名
        $("#doc_type_mark_" + nRow).val($("#doc_type_" + nRow + " :selected").attr("v1"));
    }
</script>
