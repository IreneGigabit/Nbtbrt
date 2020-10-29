<%@ Control Language="C#" ClassName="Brt11FormA9Z" %>
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
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FFForm.ascx"));//註冊費
        } else if (ar_form == "A4") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FR1Form.ascx"));//延展
        } else if (ar_form == "A5") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FD1Form.ascx"));//分割
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FD2Form.ascx"));//分割
        } else if (ar_form == "A6") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC1Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC11Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC2Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC21Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC3Form.ascx"));//變更
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FC4Form.ascx"));//變更
        } else if (ar_form == "A7") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FL1Form.ascx"));//授權
        } else if (ar_form == "A8") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FT1Form.ascx"));//移轉
        } else if (ar_form == "A9") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FP1Form.ascx"));//質權
        } else if (ar_form == "AA") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FN1Form.ascx"));//各種證明書
        } else if (ar_form == "AB") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FI1Form.ascx"));//補(換)發證
        } else if (ar_form == "AC") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FV1Form.ascx"));//閲案
        } else if (ar_form == "B") {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/DO1Form.ascx"));//申請異議
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/DR1Form.ascx"));//申請廢止
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/DI1Form.ascx"));//申請評定
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/BZZ1Form.ascx"));//無申請書之交辦內容案
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/B5C1Form.ascx"));//聽證
        } else {
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/ZZ1Form.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FOBForm.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/B5C1Form.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FOFForm.ascx"));
            tranHolder.Controls.Add(LoadControl("~/brt1m/CaseForm/FB7Form.ascx"));
        }
    }
</script>
<script language="javascript" type="text/javascript">
    var br_form = {};
    br_form.init = function () {}
    br_form.bind = function () {}
</script>
<%=Sys.GetAscxPath(this)%>
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

        $(selector + " :checkbox").each(function (index) {
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
    
    //爭救案-異議、評定、廢止提供新案指定編號功能2011/6/27新增
    br_form.new_oldcaseB=function(pfldname){
        if ($("#"+pfldname+"_case_stat").val() == "NN") {//新案
            $("#showseq_"+pfldname).show();
            $("#ShowNewAssign_"+pfldname).hide();
            if(main.prgid=="brt52"){
                $("#New_seq,#tfzb_seq,#"+pfldname+"_seq").val(jMain.case_main[0].seq);
                $("#New_seq1,#tfzb_seq1,#"+pfldname+"_seq1").val(jMain.case_main[0].seq1);
            }else{
                $("#New_seq,#"+pfldname+"_seq").val("");
            }
            Filecanput();
            $("#F_cust_seq").unlock();
            $("#btncust_seq").show();
        } else if ($("#"+pfldname+"_case_stat").val() == "SN") {//新案(指定編號)
            $("#showseq_"+pfldname).hide();
            $("#ShowNewAssign_"+pfldname).show();
            Filecanput();
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

    //*****據以異議/評定/廢止商標圖樣
    //商標圖檔上傳--for爭救案之據以異議商標圖樣,pfld=欄位名,pbtn=上傳button名稱
    br_form.UploadAttach_photo_mod = function (pfld,pbtn) {
        var tfolder = "temp";
        var nfilename = "";
        if (main.formFunction == "Edit") {
            nfilename = reg.in_no.value
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
            var url = getRootPath() + "/sub/del_draw_file_new.aspx?type=dmt_photo&folder_name=&draw_file=" + $("#draw_attach_file").val() +
                "&btnname=butUpload" + pbtn;
            window.open(url, "myWindowOne1", "width=700 height=600 top=10 left=10 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            //window.open(url, "myWindowOne1", "width=1 height=1 top=1000 left=1000 toolbar=no, menubar=no, location=no, directories=no resizeable=no status=no scrollbar=no");
            $("#draw_attach_file_"+pbtn).val("");
            $("#" + pfld).val("");
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
                main.changeTagZZ(T1, code3, arcase, prt_code, pagt_no);
                break;
        }

        //切換後重新綁資料
        br_form.bind();
    }

    //依案性切換要顯示的欄位
    main.changeTagA3 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FF").show();
        br_form.bind = br_form.bindFF;
        switch (code3) {
            case "FF0": case "FF4":
                $("#smark2,#smark").hide();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                if (code3 == "FF0") {
                    $("#span_issue_money").html("自審定書送達之次日起2個月內，應繳納");
                } else {
                    $("#span_issue_money").html("自審定書送達之次日起2個月期限屆期後6個月內，應繳納2倍");
                    $("#tabrem4").show();
                }
                $("#no1,no2").show();
                $("#no3,no4").hide();
                break;
            case "FF1":
                $("#smark2,#smark").hide();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                $("#span_issue_money").html("第一期(第一至第三年)");
                $("#no1,no2").show();
                $("#no3,no4").hide();
                break;
            case "FF2":
                $("#smark2,#smark").show();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                $("#span_issue_money").html("第二期(第四至第十年)");
                $("#no1,no2").hide();
                $("#no3,no4").show();
                break;
            case "FF3":
                $("#smark2,#smark").show();
                $("#tabrem4").hide();//2015/1/30修改FF4商標復權申請之附件選項
                $("#span_issue_money").html("第一加倍繳納第二期(第四至第十年)");
                $("#no1,no2").hide();
                $("#no3,no4").show();
                break;
        }
    }

    main.changeTagA4 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FR").show();
        br_form.bind = br_form.bindFR;
    }

    //依案性切換要顯示的欄位
    main.changeTagA5 = function (T1, code3, arcase, prt_code, pagt_no) {
        switch (code3) {
            case "FD1":
                $("#div_Form_FD1").show();
                br_form.bind = br_form.bindFD1;
                $("#smark").hide();
                $("#fr_smark1,#fr_smark3").show();
                $("#fr_smark2").hide();
                break;
            case "FD2": case "FD3":
                $("#div_Form_FD2").show();
                br_form.bind = br_form.bindFD2;
                $("#smark").show();
                $("#fr_smark1,#fr_smark3").show();
                $("#fr_smark2").hide();
                break;
        }
        $('#tfy_case_stat option:eq(1)').val("").text("");//案件種類
    }

    //依案性切換要顯示的欄位
    main.changeTagA6 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#tabap,#FC0_tabap,#FC1_tabap").hide();
        $("#CTab td.tab[href='#apcust']").html("案件申請人(變更)");

        switch (arcase) {
            case "FC1": case "FC10": case "FC9": case "FCA": case "FCB": case "FCF":
                $("#FC1_tabap,#div_Form_FC1").show();
                br_form.bind = br_form.bindFC1;
                $("#smark").hide();
                if (arcase == "FCA") {
                    $("#FC1_tr_addagtno").show();//新增代理人
                } else {
                    $("#FC1_tr_addagtno").hide();
                }
                break;
            case "FC11": case "FC15": case "FC7": case "FCH":
                $("#FC1_tabap,#div_Form_FC11").show();
                br_form.bind = br_form.bindFC11;
                $("#smark").hide();
                $("#dseqa_1").lock().val("");
                $("#dseq1a_1").lock().val("_");
                $("#btndseq_oka_1,#btncasea_1").hide();
                $("#s_marka_1").val("");
                $("#appl_namea_1,#apply_noa_1").val("");
                $("#case_stat1a_1NN").prop("checked", true);
                break;
            case "FC2": case "FC20": case "FC0": case "FCC": case "FCD": case "FCG":
                $("#FC0_tabap,#div_Form_FC2").show();
                br_form.bind = br_form.bindFC2;
                $("#smark").hide();
                $("#tabbr2").show();
                if (arcase == "FCC") {
                    $("#FC2_tr_addagtno").show();//新增代理人
                } else {
                    $("#FC2_tr_addagtno").hide();
                }
                break;
            case "FC21": case "FC6": case "FC8": case "FCI":
                $("#FC0_tabap,#div_Form_FC21").show();
                br_form.bind = br_form.bindFC21;
                $("#smark").show();
                $("#dseqb_1").lock().val("");
                $("#dseq1b_1").lock().val("_");
                $("#btndseq_okb_1,#btncaseb_1").hide();
                $("#s_markb_1").val("");
                $("#appl_nameb_1,#issue_nob_1").val("");
                $("#case_stat1b_1NN").prop("checked", true);
                break;
            case "FC3":
                $("#tabap,#div_Form_FC3").show();
                br_form.bind = br_form.bindFC3;
                $("#CTab td.tab[href='#apcust']").html("案件申請人");
                $("#span_FC").html("貳、申請人");
                $("#smark").show();
                break;
            case "FC4":
                $("#tabap,#div_Form_FC4").show();
                br_form.bind = br_form.bindFC4;
                $("#span_FC").html("參、申請人(填寫變更後之正確資料)");
                $("#smark").show();
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
        br_form.bind = br_form.bindFL1;
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
                break;
            case "FL3":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").hide();
                $("#term").html("柒、<u>終止授權日期：</u>");
                $("#tg_term1").html("終止日期");
                $("#tg_term2").html("起廢止授權");
                $("#term1").attr("colspan", 7);
                $("#term2").hide();
                $("#td_tm1").attr("rowspan", 1);
                $("#tr_claim1").hide();//授權期間無迄日
                $("#markA").html("授權人(商標權人)");
                $("#markB").html("");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").hide();
                $("#tg_attech").html("<u>附件：</u>");
                break;
            case "FL4":
                $("#tg_FL1,#tg_FL2").hide();
                $("#mark1,#mark2").hide();
                $("#term").html("柒、<u>廢止再授權日期：</u>");
                $("#tg_term1").html("終止日期");
                $("#tg_term2").html("起廢止再授權");
                $("#term1").attr("colspan", 7);
                $("#term2").hide();
                $("#td_tm1").attr("rowspan", 1);
                $("#tr_claim1").hide();//授權期間無迄日
                $("#markA").html("授權人(係原再授權登記案之授權人)");
                $("#markB").html("(再授權使用人)");
                //授權性質/授權區域/授權商品或服務
                $("#tr_type,#tr_type1,#tr_area,#tr_area1,#remark,#remark1").hide();
                $("#tg_attech").html("<u>附件：</u>");
                break;
        }
    }

    //依案性切換要顯示的欄位
    main.changeTagA8 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FT1").show();
        br_form.bind = br_form.bindFT1;
        if (code3 == "FT1") {
            $("#tabft2").hide();
        } else if (code3 == "FT2") {
            $("#tabft2").show();
        }
    }

    //依案性切換要顯示的欄位
    main.changeTagA9 = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FP1").show();
        br_form.bind = br_form.bindFP1;
        if (code3 == "FP1") {
            $("#smark1,#smark2,#smark3").hide();
            $("#tabrem1").show();
            $("#tabrem2").hide();
            $("#tfzd_remark1").val("");
        } else if (code3 == "FP2") {
            $("#smark1,#smark2,#smark3").hide();
            $("#tabrem1").hide();
            $("#tabrem2").show();
            $("#tfzd_remark1").val("");
        }
    }

    //依案性切換要顯示的欄位
    main.changeTagAA = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FN1").show();
        br_form.bind = br_form.bindFN1;
    }

    //依案性切換要顯示的欄位
    main.changeTagAB = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FI1").show();
        br_form.bind = br_form.bindFI1;
    }

    //依案性切換要顯示的欄位
    main.changeTagAC = function (T1, code3, arcase, prt_code, pagt_no) {
        $("#div_Form_FV1").show();
        br_form.bind = br_form.bindFV1;
    }

    //依案性切換要顯示的欄位
    main.changeTagB = function (T1, code3, arcase, prt_code, pagt_no) {
        //動態載入form
        if (prt_code == "DO1") {
            $("#div_Form_DO1").show();
            br_form.bind = br_form.bindDO1;
        } else if (prt_code == "DR1") {
            $("#div_Form_DR1").show();
            br_form.bind = br_form.bindDR1;
        } else if (prt_code == "DI1") {
            $("#div_Form_DI1").show();
            br_form.bind = br_form.bindDI1;
        } else if (prt_code == "B5C1") {
            $("#div_Form_B5C1").show();
            br_form.bind = br_form.bindB5C1;
        } else {
            $("#div_Form_BZZ1").show();
            br_form.bind = br_form.bindBZZ1;
        }

        var d_agt_no1 = "";
        switch (main.branch) {
            case 'N': d_agt_no1 = "034"; break;
            case 'C': d_agt_no1 = "027"; break;
            case 'S': d_agt_no1 = "006"; break;
            case 'K': d_agt_no1 = "006"; break;
        }

        //有案性預設出名代理人
        if (pagt_no != "") {
            $("#tfp4_agt_no").val(pagt_no);
        } else {
            $("#tfp4_agt_no").val(d_agt_no1);
        }

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
        if (prt_code == "FOB" || prt_code == "FOF" || prt_code == "FB7" || prt_code == "B5C1") {
            $("#div_Form_" + prt_code).show();
            eval("br_form.bind = br_form.bind" + prt_code);
        } else {
            $("#div_Form_ZZ1").show();
            br_form.bind = br_form.bindZZ1;
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

    //資料綁定
    main.bind = function () {
        //console.log("main.bind");
        if (jMain.case_main.length == 0) {
            //main.changeTag("000");//交辦內容顯示預設項目
            main.changeTag($("#tfy_Arcase option[value!='']").eq(0).val());//交辦內容顯示預設項目用第一個案性

            //無交辦資料則帶基本設定
            $("#in_date").val(Today().format("yyyy/M/d"));
            //***聯絡人與客戶資料	
            //$("#F_cust_area").val(jMain.case_main[0].cust_area);
            //$("#F_cust_seq").val(jMain.case_main[0].cust_seq);
            $("#F_cust_area").val(jMain.cust[0].cust_area);
            $("#F_cust_seq").val(jMain.cust[0].cust_seq);
            $("#btncust_seq").click();
            //取得客戶聯人清單
            attent_form.getatt(jMain.cust[0].cust_area, jMain.cust[0].cust_seq);
            //$("#tfy_att_sql").val(jMain.case_main[0].att_sql);
            $("#tfy_att_sql").val(jMain.cust[0].att_sql).triggerHandler("change");;
            //申請人
            apcust_form.getapp(jMain.cust[0].apcust_no, main.in_no);
            //收費與接洽事項
            //　洽案營洽
            $("#F_tscode").val(jMain.br_in_scode);
            $("#span_tscode").html(jMain.br_in_scname);
            //　案件主檔請款註記
            $("#tfy_Ar_mark").val("N");
            $("#dfy_cust_date").val("");
            $("#dfy_pr_date").val(new Date().addDays(15).format("yyyy/M/d"));
            $("#nfy_tot_case").val("0");
            $("#nfy_oth_money").val("0");
            $("#tfz1_seq1").val("_");
            $("#showseq1").hide();
        } else {
            //main.changeTag(jMain.case_main[0].arcase);
            $("#in_scode").val(jMain.case_main[0].in_scode);
            $("#in_no").val(jMain.case_main[0].in_no);
            $("#in_date").val(dateReviver(jMain.case_main[0].in_date3, "yyyy/M/d"));//欄位同名會順便序號
            //　洽案營洽
            $("#F_tscode").val(jMain.br_in_scode);
            $("#span_tscode").html(jMain.br_in_scname);
            //$("#code_type").val(jMain.case_main[0].arcase_type);
            //***聯絡人與客戶資料	
            $("#F_cust_area").val(jMain.case_main[0].cust_area);
            $("#F_cust_seq").val(jMain.case_main[0].cust_seq);
            $("#btncust_seq").click();
            $("#O_cust_area").val(jMain.case_main[0].cust_area);
            $("#O_cust_seq").val(jMain.case_main[0].cust_seq);
            //取得客戶聯人清單
            attent_form.getatt(jMain.case_main[0].cust_area, jMain.case_main[0].cust_seq);
            $("#tfy_att_sql").val(jMain.case_main[0].att_sql).triggerHandler("change");;
            $("#oatt_sql").val(jMain.case_main[0].att_sql);
            //****申請人
            apcust_form.getapp("", jMain.case_main[0].in_no);
            for (var r = 1; r <= CInt($("#apnum").val()) ; r++) {
                $("#queryap_" + r).val("重新取得申請人資料");
            }
            //Table(case_dmt)案件主檔
            $("#tfz1_seq").val(jMain.case_main[0].seq);
            $("#tfz1_seq1").val(jMain.case_main[0].seq1);
            //案性
            $("#code_type").val(jMain.case_main[0].arcase_type);
            $("#nfy_tot_case").val(jMain.case_main[0].nfy_tot_case);
            //接洽費用
            $("tr[id^='tr_ta_']").remove();
            $.each(jMain.case_item, function (i, item) {
                if (item.item_sql == "0") {
                    $("#tfy_Arcase").val(item.item_arcase).triggerHandler("change");
                    $("#nfyi_Service").val(item.item_service);
                    $("#nfyi_Fees").val(item.item_fees);
                    $("#Service").val(item.service == "" ? "0" : item.service);//收費標準
                    $("#Fees").val(item.fees == "" ? "0" : item.fees);//收費標準
                } else {
                    case_form.ta_display('Add');
                    $("#nfyi_item_Arcase_" + item.item_sql).val(item.item_arcase);
                    $("#nfyi_item_count_" + item.item_sql).val(item.item_count);//項目
                    $("#nfyi_Service_" + item.item_sql).val(item.item_service);
                    $("#nfyi_fees_" + item.item_sql).val(item.item_fees);
                    $("#nfzi_Service_" + item.item_sql).val(item.service == "" ? "0" : item.service);;//收費標準
                    $("#nfzi_fees_" + item.item_sql).val(item.fees == "" ? "0" : item.fees);//收費標準
                }
                $("#TaCount").val(item.item_sql);//請款案性數
            });
            //費用小計
            $("#nfy_service").val(jMain.case_main[0].service);
            $("#nfy_fees").val(jMain.case_main[0].fees);
            //收費標準
            $("#Service").val(jMain.case_main[0].p_service);
            $("#Fees").val(jMain.case_main[0].p_fees);
            //折扣率
            $("#nfy_Discount").val(jMain.case_main[0].discount);
            $("#Discount").val(jMain.case_main[0].discount);
            $("#tfy_dicount_remark").val(jMain.case_main[0].discount_remark);//***折扣理由

            //***折扣低於8折顯示折扣理由
            if (CInt($("#nfy_Discount").val()) > 20) {
                $("#span_discount_remark").show();
            }
            //***判斷收費標準
            if (jMain.case_main[0].p_service == "0" && jMain.case_main[0].p_fees == "0") {
                $("#anfees").val("N");
            } else {
                $("#anfees").val("Y");
            }
            //合計
            $("#OthSum").val(jMain.case_main[0].othsum);
            //案源代碼
            $("#tfy_source").val(jMain.case_main[0].source);
            $("#osource").val(jMain.case_main[0].source);
            //請款註記
            $("#tfy_Ar_mark").val(jMain.case_main[0].ar_mark);
            $("#tfy_ar_code").val(jMain.case_main[0].ar_code);
            br_form.seq1_conctrl();

            //*****契約號碼,2015/12/29修改，增加契約書種類，契約書後補註記及說明
            $("#contract_type").hide();//***後續案無契約書
            if (jMain.case_main[0].contract_flag == "Y") {
                $("#tfy_contract_flag").prop('checked', true).triggerHandler("click");
                $("#tfy_contract_remark").val(jMain.case_main[0].contract_remark);
            }
            $("#tfy_contract_type").val(jMain.case_main[0].contract_type);
            $("input[name='Contract_no_Type'][value='" + jMain.case_main[0].contract_type + "']").prop('checked', true).triggerHandler("click");
            if (jMain.case_main[0].contract_type == "M") {
                $("#Mcontract_no").val(jMain.case_main[0].contract_no);
            } else if (jMain.case_main[0].contract_type == "N") {
                $("#tfy_Contract_no").val(jMain.case_main[0].contract_no);
            }
            $("#ocontract_no").val(jMain.case_main[0].contract_no);
            if (main.prgid != "brt52") {//不是交辦維護
                case_form.display_caseform("T", $("#tfy_Arcase").val());//抓案性特殊控制
            }
            //期限
            $("#dfy_cust_date").val(dateReviver(jMain.case_main[0].cust_date, "yyyy/M/d"));
            $("#dfy_pr_date").val(dateReviver(jMain.case_main[0].pr_date, "yyyy/M/d"));
            $("#dfy_last_date").val(dateReviver(jMain.case_main[0].last_date, "yyyy/M/d"));
            //其他接洽事項記錄
            $("#tfy_Remark").val(jMain.case_main[0].remark);
            //20160910增加發文方式欄位
            case_form.setSendWay($("#tfy_Arcase").val());
            $("#tfy_send_way").val(jMain.case_main[0].send_way);
            //20180221增加電子收據欄位
            $("#tfy_receipt_type").val(jMain.case_main[0].receipt_type);
            $("#tfy_receipt_title").val(jMain.case_main[0].receipt_title);
            $("#tfy_rectitle_name").val(jMain.case_main[0].rectitle_name);
            //20200207若規費為0則收據抬頭預設為空白
            if (jMain.case_main[0].fees == 0) {
                $("#tfy_receipt_title").val("B");
            }

            $("#xadd_service").val(jMain.case_main[0].add_service); //追加服務費
            $("#xadd_fees").val(jMain.case_main[0].add_fees);       //追加規費
            $("#xar_service").val(jMain.case_main[0].ar_service);   //已請款服務費
            $("#xar_fees").val(jMain.case_main[0].ar_fees);         //已請款規費
            $("#xar_curr").val(jMain.case_main[0].ar_curr);         //已請款次數
            $("#xgs_fees").val(jMain.case_main[0].gs_fees);         //已支出規費
            if (jMain.case_main[0].ar_code == "X") {
                $("#chkar_code").prop("checked", true);
            } else {
                $("#chkar_code").prop("checked", false);
            }
            $("#ochkar_code").val(jMain.case_main[0].ar_code);
            //****轉帳費用
            $("#tfy_oth_arcase").val(jMain.case_main[0].oth_arcase);//轉帳費用
            $("#tfy_oth_code").val(jMain.case_main[0].oth_code);//轉帳單位
            $("#nfy_oth_money").val(jMain.case_main[0].oth_money);//轉帳金額
            //轉帳金額合計抓收費標準
            $.ajax({
                type: "get",
                url: getRootPath() + "/ajax/json_Fee.aspx?type=Fee&country=T&Arcase=" + jMain.case_main[0].oth_arcase,
                async: false,
                cache: false,
                success: function (json) {
                    var jFee = $.parseJSON(json);
                    if (jFee.length != 0) {
                        $("#oth_money").val(jFee[0].service);
                    } else {
                        $("#oth_money").val("0");//轉帳金額
                    }
                },
                error: function (xhr) {
                    $("#dialog").html("<a href='" + this.url + "' target='_new'>轉帳金額合計抓收費標準失敗！<u>(點此顯示詳細訊息)</u></a><hr>" + xhr.responseText);
                    $("#dialog").dialog({ title: '轉帳金額合計抓收費標準失敗！', modal: true, maxHeight: 500, width: "90%" });
                }
            });
            //****折扣請核單
            $("#tfy_discount_chk[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");
            //*****請款單	
            $("#tfy_ar_chk[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");
            $("#tfy_ar_chk1[value='" + jMain.case_main[0].discount_chk + "']").prop('checked', true).triggerHandler("click");

            //文件上傳
            $("#tabfile" + $("#uploadfield").val() + ">tbody").empty();
            $.each(jMain.case_attach, function (i, item) {
                var fld = $("#uploadfield").val();
                upload_form.appendFile();//增加一筆
                var nRow = $("#" + fld + "_filenum").val();
                $("#" + fld + "_name_" + nRow).val(item.attach_name);
                $("#old_" + fld + "_name_" + nRow).val(item.attach_name);
                $("#" + fld + "_" + nRow).val(item.attach_path);
                $("#doc_type_" + nRow).val(item.doc_type);
                $("#" + fld + "_desc_" + nRow).val(item.attach_desc);
                $("#" + fld + "_size_" + nRow).val(item.attach_size);
                $("#attach_sqlno_" + nRow).val(item.attach_sqlno);
                $("#" + fld + "_apattach_sqlno_" + nRow).val(item.apattach_sqlno);//總契約書/委任書流水號
                $("#attach_flag_" + nRow).val("U");//維護時判斷是否要更名，即A表示新上傳的文件
                $("#btn" + fld + "_" + nRow).prop("disabled", true);
                $("input[name='" + fld + "_branch_" + nRow + "'][value='" + item.attach_branch + "']").prop("checked", true);//交辦專案室
                $("#source_name_" + nRow).val(item.source_name);
                $("#attach_no_" + nRow).val(item.attach_no);
                $("#attach_flagtran_" + nRow).val(item.attach_flagtran);//異動作業上傳註記Y
                $("#tran_sqlno_" + nRow).val(item.tran_sqlno);//異動作業流水號
                $("#maxattach_no").val(Math.max(CInt(item.attach_no), CInt($("#maxattach_no").val())));
            });

            settab("#tran");
        }
    }
</script>