﻿<%@ Control Language="C#" ClassName="Brt11FormA9Z" %>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
    //A5分割案交辦內容
    //父控制項傳入的參數
    public Dictionary<string, string> Lock = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";

    protected string ar_form = "";
    protected string A9Z_end_type = "";
 
    private void Page_Load(System.Object sender, System.EventArgs e) {
        ar_form = (Request["ar_form"] ?? "").Trim();
        PageLayout();
        this.DataBind();
    }
    
    private void PageLayout() {
        //結案原因
        A9Z_end_type = Sys.getCustCode("Tend_type", "", "sortfld").Option("{cust_code}", "{code_name}");

        //交辦內容欄位畫面
        if (ar_form == "A3") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FFForm.ascx"));//註冊費
        } else if (ar_form == "A4") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FR1Form.ascx"));//延展
        } else if (ar_form == "A5") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FD1Form.ascx"));//分割
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FD2Form.ascx"));//分割
        } else if (ar_form == "A6") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FC1Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FC11Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FC2Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FC21Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FC3Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FC4Form.ascx"));//變更
        } else if (ar_form == "A7") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FL1Form.ascx"));//授權
        } else if (ar_form == "A8") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FT1Form.ascx"));//移轉
        } else if (ar_form == "A9") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FP1Form.ascx"));//質權
        } else if (ar_form == "AA") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FN1Form.ascx"));//各種證明書
        } else if (ar_form == "AB") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FI1Form.ascx"));//補(換)發證
        } else if (ar_form == "AC") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FV1Form.ascx"));//閲案
        } else if (ar_form.Left(1) == "B") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/DO1Form.ascx"));//申請異議
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/DR1Form.ascx"));//申請廢止
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/DI1Form.ascx"));//申請評定
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/BZZ1Form.ascx"));//無申請書之交辦內容案
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/B5C1Form.ascx"));//聽證
        } else {
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/ZZ1Form.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FOBForm.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/B5C1Form.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FOFForm.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/brtform/CaseForm/FB7Form.ascx"));
        }
    }
</script>
<script language="javascript" type="text/javascript">
    var br_form = {};
    br_form.init = function () {}
</script>
<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<!--div id="load_form"></div-->
<asp:PlaceHolder ID="tranHolder" runat="server"></asp:PlaceHolder><!--交辦內容.依ar_form動態載入form-->
<TABLE border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%" >
	<TR>
		<TD align=center colspan=4 class=lightbluetable1><font color=white>結&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;案&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;復&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;案&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;資&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;料</font></TD>
	</TR>
	<tr id="A9Ztr_endtype" style="display:none">
		<td class="lightbluetable" align="right">結案註記：</td>
		<td class="whitetablebg" >
            <input type="checkbox" name="A9Z_end_flag" id="A9Z_end_flag" value="Y" onclick="dmt_form.get_enddata('A9Z')"><font color=red>結案註記</font>(當此交辦需同時結案，請勾選)
		</td>
		<td class="lightbluetable" align="right">結案原因：</td>
		<td class="whitetablebg">
		    <select name="A9Z_end_type" id="A9Z_end_type" onchange="dmt_form.showendremark('A9Z')"><%#A9Z_end_type%></select>
            <input type=text name="A9Z_end_remark" id="A9Z_end_remark" size="60" maxlength=120 onblur="dmt_form.get_enddata('A9Z')" style="width:90%">
		</td>
	</tr>
	<tr id="A9Ztr_backflag" style="display:none">
		<td class="lightbluetable" align="right">復案註記：</td>
		<td class="whitetablebg" >
            <input type="checkbox" name="A9Z_back_flag" id="A9Z_back_flag" value="Y" onclick="dmt_form.get_backdata('A9Z')"><font color=red>復案註記</font>(當案件已結案且此交辦需復案，請勾選。<br>
            (注意：如有結案程序未完成，復案後系統將自動取消結案流程並銷管結案期限。))
		</td>
		<td class="lightbluetable" align="right">復案原因：</td>
		<td class="whitetablebg">
			<input type=text name="A9Z_back_remark" id="A9Z_back_remark" size="60" maxlength=120 onblur="dmt_form.get_backdata('A9Z')" style="width:90%">
		</td>
	</tr>
</table>	
<input type="hidden" id=tfzd_remark1 name=tfzd_remark1><!--附件-->
<input type="hidden" id="d_agt_no1" name="d_agt_no1"><!--預設出名代理人-->
<input type="hidden" id="tfzd_agt_no" name="tfzd_agt_no"><!--代理人-->
<INPUT TYPE="hidden" id=tfzd_remark3 name=tfzd_remark3><!--dmt_temp.remark3-->

<script language="javascript" type="text/javascript">
    //**交辦畫面之代理人資料丟到案件主檔
    //br_form.copycaseZZ('tfp1_agt_no')
    br_form.copycaseZZ = function (xy) {
        $("#tfzd_" + xy.substr(5)).val($("#" + xy).val());
        if (xy.substr(5, 6) == "S_Mark") {
            $("#tfyy_" + xy.substr(5)).val($("#" + xy).val());
        }
    }

    //檢查類別範圍0~45
    br_form.checkclass = function (xclass) {
        if (CInt(xclass) < 0 || CInt(xclass) > 45) {
            alert("商品類別需介於1~45之間,請重新輸入。");
            return false;
        }
    }
    
/*
    //classCount:要改成幾筆,countTar:儲存畫面有上幾筆的欄位,template:樣板,appendTar:要append的位置
    br_form.Add_class = function (classCount, countTar, template, appendTar) {
        var doCount = Math.max(0, CInt(classCount));//要改為幾筆,最少是0
        var num = CInt($(countTar).val());//目前畫面上有幾筆
        if (doCount > num) {//要加
            for (var nRow = num; nRow < doCount ; nRow++) {
                var copyStr = $(template).text() || "";
                copyStr = copyStr.replace(/##/g, nRow + 1);
                $(appendTar).append(copyStr);
                $(countTar).val(nRow + 1);
            }
        } else {
            //要減
            for (var nRow = num; nRow > doCount ; nRow--) {
                $('.' + template.replace('#', '') + "_" + +nRow, $(appendTar)).remove();
                $(countTar).val(nRow - 1);
            }
        }
    }
*/
    //依商品名稱計算商品項目數
    br_form.good_name_count = function (pVal, pTar) {
        var MyString = $("#" + pVal).val().trim();
        MyString = MyString.replace(/;/gm, "；");
        MyString = MyString.replace(/,/gm, "，");

        if (MyString.Right(1) == "；" || MyString.Right(1) == "，" || MyString.Right(1) == "、") {
            MyString = MyString.substring(0, MyString.length - 1);
        }

        if (MyString != "") {
            var myarray = MyString.split(/[；，、]/);
            $("#" + pVal).val(MyString);
            var aKind = myarray.length;//共幾類
            alert("商品內容共" + aKind + "項");
            if (pTar != "") {
                $("#" + pTar).val(aKind);
            }

            if (MyString.indexOf("及") > -1 || MyString.indexOf("或") > -1) {
                alert("【商品服務項目中包含有「及」、「或」等用語，請留意商品項目數。】");
            }
        }
    }
    
    //附件
    //selector:物件範圍,pfld:附件欄位名,tar:目的欄位
    br_form.AttachStr = function (selector, pfld, tar) {
        var strRemark1 = "";

        $(selector + " input:checkbox").each(function (index) {
            var $this = $(this);
            if ($this.prop("checked")) {
                strRemark1 += $this.val()
                //其他文件輸入框
                if ($("#" + pfld + $this.val() + "t").length > 0) {
                    if ($("#" + pfld + $this.val() + "t").val() != "") {
                        strRemark1 += "|Z9-" + $("#" + pfld + $this.val() + "t").val() + "-Z9";
                    }
                }
                strRemark1 += "|";
            }
        });
        tar.value = strRemark1;
    }
    
    //*****for一案多件
    //新/舊案畫面控制
    br_form.case_stat1_control = function (stat, fld) {
        if (stat == "NN") {
            $("#btndseq_ok" + fld).hide();//[確定]
            $("#btnQuery" + fld).hide();//[查詢本所編號]
            $("#btncase" + fld).hide();//[案件主檔查詢]
            if (fld != "a_1" && fld != "b_1") {//不是主案
                $("#btndmt_temp" + fld).show();//[案件主檔新增]
            }
            if (CInt(fld.substr(2)) % 2 == 0) {
                $("#dseq" + fld).attr("class", "sedit2").prop("readonly", true).val("");
                $("#dseq1" + fld).attr("class", "sedit2").prop("readonly", true).val("_");
            } else {
                $("#dseq" + fld).attr("class", "SEdit").prop("readonly", true).val("");
                $("#dseq1" + fld).attr("class", "SEdit").prop("readonly", true).val("_");
            }
            $("#apply_no" + fld).val("");
            $("#issue_no" + fld).val("");
            $("#s_mark" + fld).val("");
            $("#appl_name" + fld).val("");
            if (fld == "a_1" || fld == "b_1") {//是主案
                $("#tfy_case_stat").val("NN");
                $("#keyseq").val("N");
                $("#btnseq_ok").unlock();
                $("#old_seq").val("");
                $("#old_seq1").val("_");
                dmt_form.new_oldcase();
                alert("請至案件主檔填寫新案內容!!");
                settab("#dmt");
            }
        } else if (stat == "OO") {
            if (fld != "a_1" && fld != "b_1") {//不是主案
                $("#btndmt_temp" + fld).hide();//[案件主檔新增]
            }
            $("#btndseq_ok" + fld).show();//[確定]
            $("#btnQuery" + fld).show();//[查詢本所編號]
            $("#btncase" + fld).show();//[案件主檔查詢]
            $("#dseq" + fld).attr("class", "").prop("readonly", false).val("");
            $("#dseq1" + fld).attr("class", "").prop("readonly", false).val("_");
            $("#apply_no" + fld).val("");
            $("#issue_no" + fld).val("");
            $("#s_mark" + fld).val("");
            $("#appl_name" + fld).val("");
            if (fld == "a_1" || fld == "b_1") {//是主案
                $("#tfy_case_stat").val("OO");
                dmt_form.new_oldcase();
            }
        }
    }

    //[確定]
    br_form.btnseqclick = function (nRow, fld) {
        var value1 = $("#dseq" + fld + nRow).val();
        var value2 = $("#dseq1" + fld + nRow).val();
        if (value1 != "") {
            $("#case_stat1" + fld + nRow + "OO").prop("checked", true);//舊案
            $("#btndmt_temp" + fld + nRow).hide();//[案件主檔新增]
            $("#btncase" + fld + nRow).show();//[案件主檔查詢]
            $("#btnQuery" + fld + nRow).show();//[查詢本所編號]
            var objCase = {};
            for (var r = 2; r <= CInt($("#nfy_tot_num").val()) ; r++) {
                var vdseq = $("#dseq" + fld + r).val();
                var vdseq1 = $("#dseq1" + fld + r).val();
                var lineCase = vdseq + vdseq1;
                if (lineCase != "_" && objCase[lineCase]) {
                    alert("本所編號(" + r + ")重覆,請重新輸入！！");
                    settab("#tran");

                    $("#keydseq" + fld + r).val("N");
                    $("#btndseq_ok" + fld + r).prop("disabled", false);
                    $("#dseq" + fld + r).focus();
                    return false;
                } else {
                    objCase[lineCase] = { flag: true, idx: r };
                }

                var lname = $("#old_seq").val() + $("#old_seq1").val();
                var kname = vdseq + vdseq1;
                if (lname != "_" && kname != "_") {
                    if (lname == kname) {
                        alert("本所編號(" + r + ")與主要的本所編號重覆,請重新輸入!!!");
                        settab("#tran");
                        $("#keydseq" + fld + r).val("N");
                        $("#btndseq_ok" + fld + r).prop("disabled", false);
                        $("#dseq" + fld + r).focus();
                        return false;
                    }
                }
                $("#keydseq" + fld + r).val("Y");
                $("#btndseq_ok" + fld + r).prop("disabled", true);
            }
        }
        if (value1 != "") {
            if (chkNum(value1, "本所編號")) return false;
            var purl = getRootPath() + "/ajax/json_dmt.aspx?seq=" + value1 + "&seq1=" + value2 + "&cust_area=" + $("#tfy_cust_area").val() + "&cust_seq=" + $("#tfy_cust_seq").val();
            $.ajax({
                type: "get",
                url: purl,
                async: false,
                cache: false,
                success: function (json) {
                    var dmt_list = $.parseJSON(json);
                    if (dmt_list.length > 0) {
                        var backflag_fldname = "A9Z";
                        $("#s_mark" + fld + nRow).val(dmt_list[0].smarknm);
                        $("#appl_name" + fld + nRow).val(dmt_list[0].appl_name);
                        $("#apply_no" + fld + nRow).val(dmt_list[0].apply_no);
                        $("#issue_no" + fld + nRow).val(dmt_list[0].issue_no);
                        //2011/2/8因應復案修改，提醒結案是否要復案
                        if (dmt_list[0].end_date != "") {
                            if ($("#" + backflag_fldname + "_end_flag").prop("checked") == true) {
                                alert("該案(" + value1 + "-" + value2 + ")已結案且主案要復案，程序客收確認後將會一併復案。");
                            } else {
                                if (confirm("該案件已結案，如確定要交辦則需註記是否復案，請問是否復案？")) {
                                    $("#" + backflag_fldname + "_back_flag").prop("checked", true);
                                } else {
                                    $("#" + backflag_fldname + "_back_flag").prop("checked", false);
                                }
                                dmt_form.get_backdata(backflag_fldname);
                            }
                        }
                    } else {
                        alert("該客戶無此案件編號");
                        $("#dseq" + fld + nRow).unlock().val("").focus();
                        $("#dseq1" + fld + nRow).unlock().val("_");
                        $("#s_mark" + fld + nRow).val("");
                        $("#appl_name" + fld + nRow).val("");
                        $("#apply_no" + fld + nRow).val("");
                        $("#issue_no" + fld + nRow).val("");
                    }
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>check案件結案資料失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: 'check案件結案資料失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });
            $("#keydseq" + fld + nRow).val("Y");
            $("#btndseq_ok" + fld + nRow).prop("disabled", true);
        } else {
            alert("請先輸入本所編號!!!");
            $("#dseqb_" + nRow).focus();
            return false;
        }
    }

    //[案件主檔新增]
    br_form.btndmt_tempclick = function (num) {
        var cust_area = $("#F_cust_area").val();
        var cust_seq = $("#F_cust_seq").val();
        var in_scode = $("#F_tscode").val();
        var case_sqlno = $("#case_sqlno" + num).val();
        var task = $("#submitTask" + num).val();
        var arcase = $("#tfy_Arcase").val();
        if (in_scode == "") {
            alert("請先輸入洽案營洽!!!");
            settab("#case");
            $("#F_tscode").focus();
            return false;
        } else {
            var tot_num = $("#tot_num21").val();
            if ($("#prgid").val() != "brt52") {
                //***todo
                window.open("Brt11Addtemp.asp?tot_num=" + tot_num + "&cust_area=" + cust_area + "&cust_seq=" + cust_seq + "&in_scode=" + in_scode + "&num=" + num + "&SubmitTask=" + task + "&arcase=" + arcase, "myWindowOneN", "width=700 height=450 top=40 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
            } else {
                window.open("Brt11Addtemp.asp?cust_area=" + cust_area + "&cust_seq=" + cust_seq + "&in_scode=" + in_scode + "&num=" + num + "&SubmitTask=&case_sqlno=" + case_sqlno + "&Lock=show&arcase=" + arcase, "myWindowOneN", "width=700 height=450 top=40 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
            }
        }
    }

    //[查詢本所編號]
    br_form.btnQueryclick = function (tot_num, cust_seq) {
        $("#dseq" + tot_num).attr("class", "").prop("readonly", false);
        $("#dseq1" + tot_num).attr("class", "").prop("readonly", false);
        $("#btndseq_ok" + tot_num).show();//[確定]
        $("#case_stat1" + tot_num + "OO").prop("checked", true);//舊案
        if (tot_num == "a_1" || tot_num == "b_1") {//是主案
            Filereadonly();
        }
        window.open(getRootPath() + "/brtam/brta21Query.aspx?cust_seq=" + cust_seq + "&tot_num=" + tot_num, "myWindowOneN", "width=650 height=420 top=40 left=80 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //[案件主檔查詢]
    br_form.btncaseclick = function (nRow) {
        var value1 = $("#dseq" + nRow).val();
        var value2 = $("#dseq1" + nRow).val();
        if (value1 == "") {
            alert("請先輸入本所編號!!!");
            $("#dseq" + nRow).focus();
            return false;
        } else {
            var url = getRootPath() + "/brt5m/brt15ShowFP.aspx?prgid=<%=prgid%>&seq=" + value1 + "&seq1=" + value2 + "&submittask=Q";
            window.showModalDialog(url, "", "dialogHeight: 540px; dialogWidth: 800px; center: Yes;resizable: No; status: No;scrollbars:yes");
        }
    }

    br_form.seqChange = function (nRow) {
        $("#keydseq" + nRow).val("N")//有變動給N
        $("#btndseq_ok" + nRow).prop("disabled", false);
    }

    //*****for異議/評定/廢止
    //爭救案-異議、評定、廢止提供新案指定編號功能2011/6/27新增
    br_form.new_oldcaseB=function(pfldname,clean){
        if ($("#"+pfldname+"_case_stat").val() == "NN") {//新案
            $("#showseq_"+pfldname).show();
            $("#ShowNewAssign_"+pfldname).hide();
            if(main.prgid=="brt52"){
                $("#New_seq,#tfzb_seq,#"+pfldname+"_seq").val(jMain.case_main[0].seq);
                $("#New_seq1,#tfzb_seq1,#"+pfldname+"_seq1").val(jMain.case_main[0].seq1);
            }else{
                $("#New_seq,#"+pfldname+"_seq").val("");
            }
            if(clean){
                Filecanput();
            }
            $("#F_cust_seq").unlock();
            $("#btncust_seq").show();
        } else if ($("#"+pfldname+"_case_stat").val() == "SN") {//新案(指定編號)
            $("#showseq_"+pfldname).hide();
            $("#ShowNewAssign_"+pfldname).show();
            if(clean){
                Filecanput();
            }
            $("#F_cust_seq").unlock();
            $("#btncust_seq").show();
        }
    }

    //爭議案-副號選擇
    br_form.seq1_conctrl = function () {
        var arcase=$("#tfy_Arcase").val();
        if ($("#tfy_Arcase").val() != "") {
            var e="";
            switch (arcase){
                case "DR1": e="1";break;
                case "DO1": e="2";break;
                case "DI1": e="3";break;
                case "DE1": case "DE2":e="4";break;
            }

            if ($("#tfz1_seq1").val() == "M"||$("#tfp"+e+"_seq1").val()=="M") {
                $("#tfy_Ar_mark").val("X");//請款註記:大陸進口案
                old_ar_mark = "X";
            } else {
                if (old_ar_mark == "X") {
                    $("#tfy_Ar_mark").val("");
                    old_ar_mark = "";
                }
            }
        } else {
            alert("請選擇交辦案性!!");
            settab("#case");
            $("#tfy_Arcase").focus();
        }
    }

    //增加一筆圖檔--for爭救案之據以異議商標圖樣，pfld=欄位名
    br_form.drawadd = function (pfld) {
        var pnum = CInt($("#draw_num_" + pfld).val()) + 1;
        if (pnum > 10) {
            alert("商標圖檔已超過10筆！");
            pnum -= 1;
            return false;
        }
        $("#draw_num_" + pfld).val(pnum);
        $("#sp_" + pfld + "_" + pnum).show();
    }

    //商標圖檔上傳--for爭救案之據以異議商標圖樣,pfld=欄位名,pbtn=上傳button名稱,suffix=後綴名
    br_form.UploadAttach_photo_mod = function (pfld,pbtn,suffix) {
        var tfolder = "temp";
        var nfilename = "";
        if (main.formFunction == "Edit") {
            nfilename = reg.in_no.value+suffix;
        }
        var url = getRootPath() + "/sub/upload_win_file_new.aspx?type=dmt_photo" +
            "&nfilename=" + nfilename +
            "&draw_file=" + ($("#" + pfld).val() || "") +
            "&folder_name=temp" +
            "&form_name=draw_attach_file_" +pbtn+
            "&file_name=" + pfld +
            "&prgid=<%=prgid%>" +
            "&btnname=butUpload"+pbtn +
            "&filename_flag=source_name";
        window.open(url, "dmtupload", "width=700 height=600 top=50 left=50 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbars=yes");
    }

    //商標圖檔刪除--for爭救案之據以異議商標圖樣,pfld=欄位名,pbtn=上傳button名稱
    br_form.DelAttach_photo_mod = function (pfld,pbtn) {
        if ($("#" + pfld).val() == "") {
            alert("無圖檔可刪除 !!");
            return false;
        }
        var draw_attach_file=$("#draw_attach_file_" +pbtn).val();
        if (draw_attach_file == "") {
            alert("無圖檔可刪除 !!");
            return false;
        }

        if (confirm("確定刪除上傳圖檔？")) {
            $.ajax({
                url: getRootPath() + "/sub/del_draw_file_new.aspx?type=dmt_photo&folder_name=&btnname=butUpload" + pbtn,
                data: { draw_file: $("#draw_attach_file_"+pbtn).val() },
                type: 'GET',
                dataType: "script",
                async: false,
                cache: false,
                success: function(data) {
                    $("#draw_attach_file_"+pbtn).val("");
                    $("#" + pfld).val("");
                },
                error: function (xhr) { 
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>刪除檔案失敗！<u>(點此顯示詳細訊息)</u></a><hr>"+xhr.responseText);
                    $("#dialog").dialog({ title: '刪除檔案失敗！', modal: true, maxHeight: 500,width: "90%" });
                }
            });

            //var url = getRootPath() + "/sub/del_draw_file_new.aspx?type=dmt_photo&folder_name=&draw_file=" + $("#draw_attach_file_"+pbtn).val() + "&btnname=butUpload" + pbtn;
            //window.open(url, "myWindowOneN", "width=700 height=600 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            ////window.open(url, "myWindowOneN", "width=1 height=1 top=1000 left=1000 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            //$("#draw_attach_file_"+pbtn).val("");
            //$("#" + pfld).val("");
        }
    }

    //商標圖檔檢視--for爭救案之據以異議商標圖樣,pfld=欄位名,pbtn=上傳button名稱
    br_form.PreviewAttach_photo_mod = function (pfld, pbtn) {
        if ($("#" + pfld).val() == "") {
            alert("請先上傳圖檔 !!");
            return false;
        }
        var draw_attach_file = $("#draw_attach_file_" + pbtn).val();
        if (draw_attach_file == "") {
            alert("請先上傳圖檔 !!");
            return false;
        }

        var url = getRootPath() + "/sub/display_draw.aspx?draw_file=" + draw_attach_file;
        window.open(url);
    }

    ////////////////////////////////////////////////////////////////////////////////
    //依案性切換要顯示的欄位
    main.changeTag = function (T1) {
        var code3 = T1.Left(3).toUpperCase();//案性前3碼
        var arcase = T1;//案性
        var prt_code = $("#tfy_Arcase option:selected").attr("v1") || "";//載入form(code_br.prt_code)
        var pagt_no = $("#tfy_Arcase option:selected").attr("v2") || "";//案性預設出名代理人(code_br.remark)

        $("[id^='div_Form_'").hide();//隱藏所有交辦form
        //console.log(code3, arcase, prt_code, pagt_no);
        //依ar_form執行對應的function
        switch (main.ar_form) {
            case "A3": case "A4": case "A5": case "A6": case "A7": case "A8": case "A9": case "AA": case "AB": case "AC": case "B":
                eval("main.changeTag" + main.ar_form + "('" + T1 + "','" + code3 + "','" + arcase + "','" + prt_code + "','" + pagt_no + "')");
                break;
            default:
                if(main.ar_form.Left(1)=="B")
                    main.changeTagB(T1, code3, arcase, prt_code, pagt_no);
                else
                    main.changeTagZZ(T1, code3, arcase, prt_code, pagt_no);
                break;
        }

        //切換後重新綁資料
        //main.bind();
    }

    //依案性切換要顯示的欄位
    main.changeTagA3 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FF").show();
        $("#smark2,#smark").hide();
        $("#no1,#no2,#no3,#no4").hide();
        switch (code3) {
            case "FF0": case "FF4":
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                if (code3 == "FF0") {
                    $("#span_issue_money").html("自審定書送達之次日起2個月內，應繳納");
                } else {
                    $("#span_issue_money").html("自審定書送達之次日起2個月期限屆期後6個月內，應繳納2倍");
                    $("#tabrem4").show();//附件
                }
                $("#no1,#no2").show();
                break;
            case "FF1":
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                $("#span_issue_money").html("第一期(第一至第三年)");
                $("#no1,#no2").show();
                break;
            case "FF2":
                $("#smark2,#smark").show();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                $("#span_issue_money").html("第二期(第四至第十年)");
                $("#no3,#no4").show();
                break;
            case "FF3":
                $("#smark2,#smark").show();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                $("#span_issue_money").html("第一加倍繳納第二期(第四至第十年)");
                $("#no3,#no4").show();
                break;
        }

        br_form.AttachStr('#tabrem4','FF4_',reg.tfzd_remark1);
    }

    main.changeTagA4 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FR1").show();
        $("#tabdmt1").hide();//案件主檔類別

        br_form.AttachStr('.br_attchstr','ttzd_',reg.tfzd_remark1);
    }

    //依案性切換要顯示的欄位
    main.changeTagA5 = function (T1, code3, arcase, prt_code, pagt_no) {
        switch (code3) {
            case "FD1":
                $("#div_Form_FD1").show();
                $("#smark").hide();
                $("#fr_smark1,#fr_smark3").show();
                $("#fr_smark2").hide();
                br_form.AttachStr1('.br_attchstrFD1','ttz1_',reg.tfzd_remark1);
                break;
            case "FD2": case "FD3":
                $("#div_Form_FD2").show();
                $("#smark").show();
                $("#fr_smark1,#fr_smark3").show();
                $("#fr_smark2").hide();
                br_form.AttachStr1('.br_attchstrFD2', 'ttz2_', reg.tfzd_remark1);
                break;
        }
        $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
    }

    //依案性切換要顯示的欄位
    main.changeTagA6 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#tabap,#FC0_tabap,#FC2_tabap,#FC1_tabap,#tr_tg_arf_fc").hide();
        $("#CTab td.tab[href='#apcust']").html("案件申請人(變更)");
        $("#tfy_div_arcase").val("");

        switch (arcase) {
            case "FC1": case "FC10": case "FC9": case "FCA": case "FCB": case "FCF":
                $("#FC2_tabap,#FC1_tabap,#div_Form_FC1").show();
                $("#smark").hide();
                if (arcase == "FCA") {
                    $("#FC1_tr_addagtno").show();//新增代理人
                } else {
                    $("#FC1_tr_addagtno").hide();
                }
                br_form.AttachStr('.br_attchstrFC1','ttz1_',reg.tfzd_remark1);
                break;
            case "FC11": case "FC5": case "FC7": case "FCH":
                $("#FC2_tabap,#FC1_tabap,#div_Form_FC11").show();
                $("#smark").hide();
                $("#dseqa_1").lock().val("");
                $("#dseq1a_1").lock().val("_");
                $("#btndseq_oka_1,#btncasea_1").hide();
                $("#s_marka_1").val("");
                $("#appl_namea_1,#apply_noa_1").val("");
                $("#case_stat1a_1NN").prop("checked", true);
                br_form.AttachStr('.br_attchstrFC11','ttz11_',reg.tfzd_remark1);
                break;
            case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
                $("#FC0_tabap,#div_Form_FC2").show();
                $("#smark").show();
                $("#tabbr2").show();
                if (arcase == "FCC") {
                    $("#FC2_tr_addagtno").show();//新增代理人
                } else {
                    $("#FC2_tr_addagtno").hide();
                }
                br_form.AttachStr('.br_attchstrFC2','ttz2_',reg.tfzd_remark1);
                break;
            case "FC21": case "FC6": case "FC8": case "FCI":
                $("#FC0_tabap,#div_Form_FC21").show();
                $("#smark").show();
                $("#dseqb_1").lock().val("");
                $("#dseq1b_1").lock().val("_");
                $("#btndseq_okb_1,#btncaseb_1").hide();
                $("#s_markb_1").val("");
                $("#appl_nameb_1,#issue_nob_1").val("");
                $("#case_stat1b_1NN").prop("checked", true);
                br_form.AttachStr('.br_attchstrFC21','ttz21_',reg.tfzd_remark1);
                break;
            case "FC3":
                $("#tabap,#div_Form_FC3,#tr_tg_arf_fc").show();
                $("#CTab td.tab[href='#apcust']").html("案件申請人");
                $("#span_FC").html("貳、申請人");
                $("#smark").show();
                $("#tabdmt1").hide();//案件主檔類別
                br_form.AttachStr('.br_attchstrFC3','ttz3_',reg.tfzd_remark1);
                break;
            case "FC4":
                $("#tabap,#div_Form_FC4,#tr_tg_arf_fc").show();
                $("#span_FC").html("參、申請人(填寫變更後之正確資料)");
                $("#smark").show();
                br_form.AttachStr('.br_attchstrFC4', 'ttz4_', reg.tfzd_remark1);
                break;
        }
        if (arcase == "FC11" || arcase == "FC21" || arcase == "FC5" || arcase == "FC6" || arcase == "FC7" || arcase == "FC8" || arcase == "FCH" || arcase == "FCI") {
            $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
        } else {
            $('#tfy_case_stat option:eq(1)').val("SN").text("新案(指定編號)");//案件種類
        }
    }

    //依案性切換要顯示的欄位
    main.changeTagA7 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FL1").show();
        $("[id^='tabrem']").hide();
        var tabid = arcase.substr(2, 1);
        if (arcase == "FL5")//授權一案多件同FL1
            tabid = "1";
        else if (arcase == "FL6")//再授權一案多件同FL2
            tabid = "2";
        $("#tabrem" + tabid).show();

        $("input[id^='v2'").val("");//清除專用權人資料
        //附件清空
        $("input[name^='ttz1_'").prop("checked", false);
        $("input[name^='ttz2_'").prop("checked", false);
        $("input[name^='ttz3_'").prop("checked", false);
        $("input[name^='ttz4_'").prop("checked", false);
        $("#tfzd_remark1").val("");

        $("#tabfl5").hide();//FL5,FL6一案多件表格畫面
        switch (code3) {
            case "FL1": case "FL5":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").show();//2012/7/1新申請書增加
                $("#term").html("柒、<u>授權期間：</u>");
                $("#tg_term1").html("授權期間");
                $("#tg_term2").html("");
                $("#term1").attr("colspan", 3);
                $("#term2").show();
                $("#td_tm1").attr("rowspan", 2);
                $("#tr_claim1").show();//授權期間無迄日
                $("#markA").html("授權人(商標權人)");
                $("#markB").html("");
                $("#span_FL").html("貳、申請人(專用權人)");
                $("#tg_type").html("捌、授權性質");
                $("#tg_area").html("玖、授權區域");
                $("#tg_good").html("拾、<u>授權商品或服務：</u>");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").show();
                $("#tg_attech").html("<u>附件：</u>");
                $("#oth_FL").html("再授權案");
                $("#O_item2FL2").val("FL2");
                if (code3 == "FL5") {
                    $("#tabfl5").show();
                    $("#sp_titlecnt").html("授權");
                }
                br_form.AttachStr('#tabrem1', 'ttz1_', reg.tfzd_remark1);
                break;
            case "FL2": case "FL6":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").show();//2012/7/1新申請書增加
                $("#term").html("柒、<u>再授權期間：</u>");
                $("#tg_term1").html("授權期間");
                $("#tg_term2").html("");
                $("#term1").attr("colspan", 3);
                $("#term2").show();
                $("#td_tm1").attr("rowspan", 2);
                $("#tr_claim1").show();//授權期間無迄日
                $("#markA").html("授權人");
                $("#markB").html("");
                $("#span_FL").html("貳、申請人(授權人)");
                $("#tg_type").html("捌、再授權性質");
                $("#tg_area").html("玖、再授權區域");
                $("#tg_good").html("拾、<u>再授權商品或服務：</u>");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").show();
                $("#tg_attech").html("<u>附件：</u>");
                //FL2_AP_Add_button_onclick
                $("#oth_FL").html("授權案");
                $("#O_item2FL2").val("FL1");
                if (code3 == "FL6") {
                    $("#tabfl5").show();
                    $("#sp_titlecnt").html("再授權");
                }
                br_form.AttachStr('#tabrem2','ttz2_',reg.tfzd_remark1);
                break;
            case "FL3":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").hide();
                $("#term").html("柒、<u>終止授權日期：</u>");
                $("#tg_term1").html("終止日期");
                $("#tg_term2").html("起終止授權使用");
                $("#term1").attr("colspan", 7);
                $("#term2").hide();
                $("#td_tm1").attr("rowspan", 1);
                $("#tr_claim1").hide();//授權期間無迄日
                $("#markA").html("授權人(商標權人)");
                $("#markB").html("");
                $("#span_FL").html("貳、申請人(商標權人)");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").hide();
                $("#tg_attech").html("捌、<u>附件：</u>");
                br_form.AttachStr('#tabrem3','ttz3_',reg.tfzd_remark1);
                break;
            case "FL4":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").hide();
                $("#term").html("柒、<u>終止再授權日期：</u>");
                $("#tg_term1").html("終止日期");
                $("#tg_term2").html("起終止授權使用");
                $("#term1").attr("colspan", 7);
                $("#term2").hide();
                $("#td_tm1").attr("rowspan", 1);
                $("#tr_claim1").hide();//授權期間無迄日
                $("#markA").html("授權人(係原再授權登記案之授權人)");
                $("#markB").html("(再授權使用人)");
                $("#span_FL").html("參、申請人(授權人)");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").hide();
                $("#tg_attech").html("捌、<u>附件：</u>");
                br_form.AttachStr('#tabrem4','ttz4_',reg.tfzd_remark1);
                break;
        }
    }

    //依案性切換要顯示的欄位
    main.changeTagA8 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FT1").show();
        $("#CTab td.tab[href='#apcust']").html("申請人(受讓人)");

        if (code3 == "FT1") {
            $("#tabft2").hide();
        } else if (code3 == "FT2") {
            $("#tabft2").show();
        }
        br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1);
    }

    //依案性切換要顯示的欄位
    main.changeTagA9 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FP1").show();
        if (code3 == "FP1") {
            $("#smark1,#smark2,#smark3").hide();
            $("#tabrem1").show();
            $("#tabrem2").hide();
            $("#tfzd_remark1").val("");
            br_form.AttachStr('.br_attchstrFP1','ttz1_',reg.tfzd_remark1);
        } else if (code3 == "FP2") {
            $("#smark1,#smark2,#smark3").hide();
            $("#tabrem1").hide();
            $("#tabrem2").show();
            $("#tfzd_remark1").val("");
            br_form.AttachStr('.br_attchstrFP2', 'ttz2_', reg.tfzd_remark1);
        }
    }

    //依案性切換要顯示的欄位
    main.changeTagAA = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FN1").show();
        br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1);
    }

    //依案性切換要顯示的欄位
    main.changeTagAB = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FI1").show();
        br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1);
    }

    //依案性切換要顯示的欄位
    main.changeTagAC = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FV1").show();
        br_form.AttachStr('.br_attchstr','ttz1_',reg.tfzd_remark1);
    }

    //依案性切換要顯示的欄位
    main.changeTagB = function (T1, code3, arcase, prt_code, pagt_no) {
        //動態載入form
        $("#CTab td.tab[href='#dmt']").show();
        if (prt_code == "DO1") {
            $("#CTab td.tab[href='#dmt']").hide();
            $("#div_Form_DO1").show();
        } else if (prt_code == "DR1") {
            $("#CTab td.tab[href='#dmt']").hide();
            $("#div_Form_DR1").show();
        } else if (prt_code == "DI1") {
            $("#CTab td.tab[href='#dmt']").hide();
            $("#div_Form_DI1").show();
        } else if (prt_code == "B5C1") {
            $("#div_Form_B5C1").show();
        } else {
            $("#div_Form_BZZ1").show();
        }

        //var d_agt_no1 = "";
        //switch (main.branch) {
        //    case 'N': d_agt_no1 = "034"; break;
        //    case 'C': d_agt_no1 = "027"; break;
        //    case 'S': d_agt_no1 = "006"; break;
        //    case 'K': d_agt_no1 = "006"; break;
        //}

        //有案性預設出名代理人
        //if (pagt_no != "") {
            $("#tfp4_agt_no").val(pagt_no);
        //} else {
        //    $("#tfp4_agt_no").val(d_agt_no1);
        //}

        //聽證B5C1控制
        if (code3 == "AD7" || code3 == "DE1") {
            $("#tr_remark3,#tr_tran_mark,#tr_de1_ap").show();
            $("#tr_de2_item,#tr_de2_item1").hide();
            $("#span_dmttemp_mark").html("評定案件或異議案件或廢止案件之<input type=radio name=fr4_Mark value='A'>申請人<input type=radio name=fr4_Mark value='I'>註冊人");
            $("#span_case").html("舉行");
            $("#span_case1").html("肆、對造當事人");
            $("#span_other_item2").html("代 理 人");
            $("#span_tran_remark1").html("<strong>伍、應舉行聽證之理由：</strong><font size='-2'>（請羅列聽證爭點要旨，逐項敘明理由，並檢附正副本各一份）</font>");
        } else if (code3 == "AD8" || code3 == "DE2") {
            $("#tr_remark3,#tr_de2_item,#tr_de2_item1").show();
            $("#tr_tran_mark,#tr_de1_ap").hide();
            $("#span_dmttemp_mark").html("<input type=radio name=fr4_Mark value='B'>爭議案申請人或異議人<input type=radio name=fr4_Mark value='I'>系爭商標商標權人<input type=radio name=fr4_Mark value='R'>利害關係人");
            $("#span_case").html("出席");
            $("#span_case1").html("參、出席代表姓名或代理姓名");
            $("#span_other_item").html("指定發言姓名");
            $("#span_other_item1").html("職　　稱");
            $("#span_other_item2").html("聯絡電話");
            $("#span_tran_remark1").html("<strong>附註：新事證及陳述意見書</strong>");
        }
    }

    main.changeTagZZ = function (T1, code3, arcase, prt_code, pagt_no) {
        //動態載入form
        if (prt_code == "FOB") {
            $("#div_Form_FOB").show();
            br_form.CopyStr('input[name^=ttz1_]',reg.tfg1_other_item,reg.ttz1_P1);
        }else if (prt_code == "FOF" ) {
            $("#div_Form_FOF").show();
        }else if (prt_code == "FB7") {
            $("#div_Form_FB7").show();
            br_form.AttachStr('.br_attchstrFB7','tfb7_',reg.tfb7_other_item);
        }else if (prt_code == "B5C1") {
            $("#div_Form_B5C1").show();
        } else {
            br_form.AttachStr('.br_attchstrZZ1','tfw1_',reg.tfw1_other_item);
            $("#div_Form_ZZ1").show();
        }

        //預設代理人
        if ($("#d_agt_no1").val() == "") {
            //2015/10/21改抓cust_code
            $("#d_agt_no1").val(get_tagtno("N").no)
        }

        //有案性預設出名代理人
        if (pagt_no != "") {
            $("#tfg1_agt_no1").val(pagt_no);
            $("#tfp4_agt_no").val(pagt_no);
        } else {
            $("#tfg1_agt_no1").val($("#d_agt_no1").val());
            $("#tfp4_agt_no").val($("#d_agt_no1").val());
        }

        //申請撤回畫面控制
        if (arcase == "FW1") {
            $("#tr_zz").hide();
            $("#tr_fw1").show();
        } else {
            $("#tr_zz").show();
            $("#tr_fw1").hide();
        }

        //聽證B5C1控制
        if (code3 == "AD7") {
            $("#tr_remark3,#tr_tran_mark,#tr_de1_ap").show();
            $("#tr_de2_item,#tr_de2_item1").hide();
            $("#span_dmttemp_mark").html("評定案件或異議案件或廢止案件之<input type=radio name=fr4_Mark value='A'>申請人<input type=radio name=fr4_Mark value='I'>註冊人");
            $("#span_case").html("舉行");
            $("#span_case1").html("肆、對造當事人");
            $("#span_other_item2").html("代 理 人");
            $("#span_tran_remark1").html("<strong>伍、應舉行聽證之理由：</strong><font size='-2'>（請羅列聽證爭點要旨，逐項敘明理由，並檢附正副本各一份）</font>");
        } else if (code3 == "AD8") {
            $("#tr_remark3,#tr_de2_item,#tr_de2_item1").show();
            $("#tr_tran_mark,#tr_de1_ap").hide();
            $("#span_dmttemp_mark").html("<input type=radio name=fr4_Mark value='B'>爭議案申請人或異議人<input type=radio name=fr4_Mark value='I'>系爭商標商標權人<input type=radio name=fr4_Mark value='R'>利害關係人");
            $("#span_case").html("出席");
            $("#span_case1").html("參、出席代表姓名或代理姓名");
            $("#span_other_item").html("指定發言姓名");
            $("#span_other_item1").html("職　　稱");
            $("#span_other_item2").html("聯絡電話");
            $("#span_tran_remark1").html("<strong>附註：新事證及陳述意見書</strong>");
        }

        //影印內容
        $("input[name^='ttz1_P'").prop("checked", false);
        $("[id^='P'][id$='_new_no']").val("");
        $("[id^='P'][id$='_mod_dclass']").val("");
        $("input[name='fr_mark']").prop("checked", false);//程序種類
    }

    <!--#include virtual="~\brt1m\A9Z_bind.js" -->//資料綁定(main.bind)

    <!--#include virtual="~\brt1m\A9Z_savechk.js" -->//存檔檢查(main.savechk)
</script>