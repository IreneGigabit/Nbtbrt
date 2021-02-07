<%@ Control Language="C#" ClassName="Brt52FormA11_back" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Register Src="~/brt1m/brtform/CaseForm/FA1Form.ascx" TagPrefix="uc1" TagName="FA1Form" %>


<script runat="server">
    private void Page_Load(System.Object sender, System.EventArgs e) {
    }
</script>

<%=Sys.GetAscxPath(this.AppRelativeVirtualPath)%>
<uc1:FA1Form runat="server" ID="FA1Form" />

<INPUT TYPE="text" id=Update_dmt name=Update_dmt><!--是否要更新案件主檔-->

<script language="javascript" type="text/javascript">
    //依案性切換要顯示的欄位
    main.changeTag = function (T1) {
        var code3 = T1.substr(2, 1).toUpperCase();//案性第3碼
        //壹、商標圖樣(依案性第3碼切換顯示)
        $("#td_br_appl").empty();
        var copyStr = $("script.tabbr_appl_" + code3).text() || "";
        $("#td_br_appl").append(copyStr);
        //$(".tabbr_appl_0").hide();
        //$(".tabbr_appl_"+code3).show();

        //參、展覽會優先權聲明(依案性第3碼切換顯示)
        if ($("#td_br_show .tabbrshow_" + code3).length == 0) {
            $("#td_br_show").empty();
            var copyStr = $("script.tabbrshow_" + code3).text() || "";
            $("#td_br_show").append(copyStr);
            if (copyStr == "") {
                $("#td_br_show").closest("tr").hide();
            } else {
                $("#td_br_show").closest("tr").show();
            }
        }
        //$(".tabbrshow_0").hide();
        //$(".tabbrshow_"+code3).show();

        //伍、團體標章表彰之內容
        //陸、標章證明標的及內容(依案性第3碼切換顯示)
        if ($("#td_br_good .tabbrgood_" + code3).length == 0) {
            $("#td_br_good").empty();
            var copyStr = $("script.tabbrgood_" + code3).text() || "";
            $("#td_br_good").append(copyStr);
            if (copyStr == "") {
                $("#td_br_good").closest("tr").hide();
            } else {
                $("#td_br_good").closest("tr").show();
            }
        }
        //$(".tabbrgood_0").hide();
        //$(".tabbrgood_"+code3).show();

        //陸、指定使用商品／服務類別及名稱(依案性第3碼切換顯示)
        if ($("#td_br_class .tabbrclass_" + code3).length == 0) {
            $("#td_br_class").empty();
            var copyStr = $("script.tabbrclass_" + code3).text() || "";
            $("#td_br_class").append(copyStr);
            if (copyStr == "") {
                $("#td_br_class").closest("tr").hide();
            } else {
                $("#td_br_class").closest("tr").show();
                br_form.Add_class(1);//預設顯示第1筆
            }
        }
        //$(".tabbrclass_0").hide();
        //$(".tabbrclass_"+code3).show();

        //附件(以案性第3碼判斷要show哪個附件)
        $("#td_br_remark1").empty();
        $("#tfz1_remark1").val("");
        var copyStr = $("script#tabbr_remark1_" + code3).text() || "";
        $("#td_br_remark1").append(copyStr);


        //***商標種類及畫面顯示
        var txtType0 = "", txtType1 = "";
        switch (code3) {
            case '5': case '6': case '7': case '8':
                txtType0 = "團體商標";
                txtType1 = "商標";
                $("input[name=span_mark1][value='N']").prop("checked", true);//團體商標
                break;
            case '9': case 'A': case 'B': case 'C':
                txtType0 = "團體標章";
                txtType1 = "標章";
                $("input[name=span_mark1][value='M']").prop("checked", true);//團體標章
                break;
            case 'D': case 'E': case 'F': case 'G':
                txtType0 = "證明標章";
                txtType1 = "標章";
                $("input[name=span_mark1][value='L']").prop("checked", true);//證明標章
                break;
            default:
                txtType0 = "商標";
                txtType1 = "商標";
                $("input[name=span_mark1][value='']").prop("checked", true);//商標
                break;
        }
        $(".txtMark0").html(txtType0);
        $(".txtMark1").html(txtType1);
        $("#tfz1_S_Mark").val($("input[name='span_mark1']:checked").val());

        //***商標種類2
        switch (code3) {
            case '4': case '8': case 'C': case 'G'://立體
                $("input[name=tfz1_s_mark2][value='B']").prop("checked", true);
                if (code3 == "8") {
                    $("#span_FA151").html("詳細說明所欲註冊之內容，不屬於立體商標之虛線部份應一併說明");
                } else if (code3 == "C") {
                    $("#span_FA151").html("標章");
                } else if (code3 == "G") {
                    $("#span_FA151").html("標章");
                } else {
                    $("#span_FA151").html("詳細說明所欲註冊之內容，不屬於立體商標之虛線部份應一併說明");
                }
                break;
            case '3': case '7': case 'B': case 'F'://聲音
                $("input[name=tfz1_s_mark2][value='C']").prop("checked", true);
                break;
            case '2': case '6': case 'A': case 'E'://顏色
                $("input[name=tfz1_s_mark2][value='D']").prop("checked", true);
                if (code3 == "6") {
                    $("#span_FA151").html("<INPUT TYPE=radio NAME=tfz1_remark3 value=商品>商品、<INPUT TYPE=radio NAME=tfz1_remark3 value=包裝>包裝、<INPUT TYPE=radio NAME=tfz1_remark3 value=容器>容器之形狀、或<INPUT TYPE=radio NAME=tfz1_remark3 value=營業物>營業相關物品之形狀，不屬於團體商標");
                } else if (code3 == "A") {
                    $("#span_FA151").html("<INPUT TYPE=radio NAME=tfz1_remark3 value=相關物品>相關物品或<INPUT TYPE=radio NAME=tfz1_remark3 value=文書>文書之形狀，不屬於團體標章");
                } else if (code3 == "E") {
                    $("#span_FA151").html("<INPUT TYPE=radio NAME=tfz1_remark3 value=商品>商品、<INPUT TYPE=radio NAME=tfz1_remark3 value=包裝>包裝、<INPUT TYPE=radio NAME=tfz1_remark3 value=容器>容器之形狀、或<INPUT TYPE=radio NAME=tfz1_remark3 value=營業物>營業相關物品之形狀，不屬於顏色標章");
                } else {
                    $("#span_FA151").html("<INPUT TYPE=radio NAME=tfz1_remark3 value=商品>商品、<INPUT TYPE=radio NAME=tfz1_remark3 value=包裝>包裝、<INPUT TYPE=radio NAME=tfz1_remark3 value=容器>容器之形狀、或<INPUT TYPE=radio NAME=tfz1_remark3 value=營業物>營業相關物品之形狀，不屬於顏色商標");
                }
                break;
            case 'I'://全像圖
                $("input[name=tfz1_s_mark2][value='E']").prop("checked", true);
                $("#span_FA150").html("及樣本");
                $("#span_FA151").html("詳細說明全像圖的全像效果，如因視角差異產生圖像變化，應說明各視圖的變化情形，不屬於全像圖商標之虛線部份應一併說明，並得檢送商標樣本");
                break;
            case 'J'://動態
                $("input[name=tfz1_s_mark2][value='F']").prop("checked", true);
                $("#span_FA150").html("及樣本");
                $("#span_FA151").html("詳細說明個別靜止圖像的排列順序及變化過程，如包含聲音及不屬於動態商標之虛線部分者，應一併說明，並應檢送圖像變化之AVI或MPEG檔光碟片");
                break;
            case 'K'://其他商標不可預設
                $("input[name=tfz1_s_mark2]").prop("checked", false);
                $("#span_FA150").html("及樣本");
                $("#span_FA151").html("對商標本身及其使用於商品或服務情形所為之相關說明，並提供商標樣本供審查參考");
                break;
            default://平面
                $("input[name=tfz1_s_mark2][value='A']").prop("checked", true);
                break;
        }

        //***表彰預設申請人
        var tfap_cname = "";
        for (var papnum = 1; papnum <= CInt($("#apnum").val()) ; papnum++) {
            tfap_cname += $("#ap_cname1_" + papnum).val() + $("#ap_cname2_" + papnum).val() + "、";
        }
        $("#tf91_good_name").val(tfap_cname.substring(0, tfap_cname.length - 1));

        //切換後重新綁資料
        br_form.bind();
    }

    //資料綁定
    main.bind = function () {
        //console.log("main.bind");
        if (jMain.case_main.length == 0) {
            $("select,textarea,input,span,button").lock();//抓不到資料就全部鎖定
        } else {
            //標題
            $("#t_in_no").html(jMain.case_main[0].in_scode+"-"+jMain.case_main[0].in_no);
            $("#t_seq").html(jMain.case_main[0].seq+(jMain.case_main[0].seq1!="_"?"-"+jMain.case_main[0].seq1:""));
            $("#t_case_no").html(jMain.case_main[0].case_no);
            $("#t_ar_curr").html(CInt(jMain.case_main[0].ar_curr)==0?"未請款":"已請款");

            //main.changeTag(jMain.case_main[0].arcase);
            $("#in_scode").val(jMain.case_main[0].in_scode);
            $("#in_no").val(jMain.case_main[0].in_no);
            $("#in_date").val(dateReviver(jMain.case_main[0].in_date, "yyyy/M/d"));//欄位同名會順便序號
            //案性
            $("#code_type").val(jMain.case_main[0].arcase_type);
            $("#nfy_tot_case").val(jMain.case_main[0].nfy_tot_case);
            //　洽案營洽
            $("#F_tscode").val(jMain.br_in_scode);
            $("#span_tscode").html(jMain.br_in_scname);
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
            $("#Discount").val(jMain.case_main[0].discount + "%");
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
            $("#oth_money").val(jMain.case_main[0].casefee_oth_money);//轉帳金額合計
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

    //存檔檢查
    main.savechk = function () {
        //2014/4/22增加檢查是否為雙邊代理查照對象,客戶名稱
        if (cust_name_chk($("#F_ap_cname1").val() + $("#F_ap_cname2").val(), $("#F_ap_ename1").val() + $("#F_ap_ename2").val())) {
            settab("#cust");
            return false;
        }

        //2014/4/22增加檢查是否為雙邊代理查照對象,客戶代表人名稱
        if (aprep_name_chk($("#F_ap_crep").val(), $("#F_ap_erep").val())) {
            settab("#cust");
            return false;
        }

        //聯絡人檢查
        if (IsEmpty($("#tfy_att_sql").val())) {
            alert("聯絡人資料不得為空白！");
            settab("#attent");
            $("#tfy_att_sql").focus();
            return false;
        }

        //申請人檢查
        if ($("#apnum").val() == "0") {
            alert("請輸入申請人資料！");
            settab("#apcust");
            $("#AP_Add_button").focus();
            return false;
        }
        for (var tapnum = 1; tapnum <= CInt($("#apnum").val()) ; tapnum++) {
            if (IsEmpty($("#apcust_no_" + tapnum).val())) {
                alert("申請人編號不得為空白！");
                settab("#apcust");
                $("#apcust_no_" + tapnum).focus();
                return false;
            }
            $("#ap_cname_" + tapnum).val($("#ap_cname1_" + tapnum).val() + $("#ap_cname2_" + tapnum).val());
            $("#ap_ename_" + tapnum).val($("#ap_ename1_" + tapnum).val() + " " + $("#ap_ename2_" + tapnum).val());
            if ($("#ap_cname1_" + tapnum).val() != "") {
                if (fDataLen($("#ap_cname1_" + tapnum))) {
                    settab("#apcust");
                    $("#ap_cname1_" + tapnum).focus();
                    return false;
                }
            }
            if ($("#ap_cname2_" + tapnum).val() != "") {
                if (fDataLen($("#ap_cname2_" + tapnum))) {
                    settab("#apcust");
                    $("#ap_cname2_" + tapnum).focus();
                    return false;
                }
            }
            if ($("#ap_ename1_" + tapnum).val() != "") {
                if (fDataLen($("#ap_ename1_" + tapnum))) {
                    settab("#apcust");
                    $("#ap_ename1_" + tapnum).focus();
                    return false;
                }
            }
            if ($("#ap_ename2_" + tapnum).val() != "") {
                if (fDataLen($("#ap_ename2_" + tapnum))) {
                    settab("#apcust");
                    $("#ap_ename2_" + tapnum).focus();
                    return false;
                }
            }
            //2014/4/22增加檢查是否為雙邊代理查照對象
            if (cust_name_chk($("#ap_cname_" + tapnum).val(), $("#ap_ename_" + tapnum).val())) {
                settab("#apcust");
                return false;
            }
            if (aprep_name_chk($("#ap_crep_" + tapnum).val(), $("#ap_erep_" + tapnum).val())) {
                settab("#apcust");
                return false;
            }
        }
        //收費與接洽事項檢查
        if (IsEmpty($("#tfy_Arcase").val())) {
            alert("客收/請款案性不得為空白！");
            settab("#case");
            $("#tfy_Arcase").focus();
            return false;
        }
        //次委辦案性與金額檢查
        for (var q = 1; q <= CInt($("#TaCount").val()) ; q++) {
            //檢查沒選案性但有輸金額
            if (IsEmpty($("#nfyi_item_Arcase_" + q).val())) {
                if (CInt($("#nfyi_Service_" + q).val()) != 0) {
                    alert(q + ".其他費用服務費不為0，請輸入" + q + ".其他費用之案性！");
                    settab("#case");
                    $("#nfyi_item_Arcase_" + q).focus();
                    return false;
                }

                if (CInt($("#nfyi_fees_" + q).val()) != 0) {
                    alert(q + ".其他費用規費不為0，請輸入" + q + ".其他費用之案性！");
                    settab("#case");
                    $("#nfyi_item_Arcase_" + q).focus();
                    return false;
                }
            }
        }

        if (IsEmpty($("#tfy_Ar_mark").val())) {
            alert("請款註記不得為空白！");
            settab("#case");
            $("#tfy_Ar_mark").focus();
            return false;
        }

        if (IsEmpty($("#F_tscode").val())) {
            alert("洽案營洽不得為空白！");
            settab("#case");
            $("#F_tscode").focus();
            return false;
        }

        //案源代碼檢查
        if (IsEmpty($("#tfy_source").val())) {
            alert("案源代碼不得為空白！");
            settab("#case");
            $("#tfy_source").focus();
            return false;
        }

        //20160910 增加發文方式檢查
        if (IsEmpty($("#tfy_send_way").val())) {
            alert("發文方式不得為空白！");
            settab("#case");
            $("#tfy_send_way").focus();
            return false;
        }

        //20180221 增加電子收據檢查
        //20180619 若規費不是0才要檢查
        if (CInt($("#nfy_fees").val()) != 0) {
            if (IsEmpty($("#tfy_receipt_type").val())) {
                alert("收據種類不得為空白！");
                settab("#case");
                $("#tfy_receipt_type").focus();
                return false;
            }
            if (IsEmpty($("#tfy_receipt_title").val())) {
                alert("收據抬頭不得為空白！");
                settab("#case");
                $("#tfy_receipt_title").focus();
                return false;
            }
        }

        //20180412 增加總契約書檢查
        if ($("#Contract_no_Type_M").prop("checked")) {
            if (IsEmpty($("#Mcontract_no").val())) {
                alert("請選擇總契約書！");
                settab("#case");
                return false;
            }
        }

        var code3 = $("#tfy_Arcase").val().substr(2, 1).toUpperCase();//案性第3碼
        var prt_code = $("#tfy_Arcase option:selected").attr("v1");

        //***其他商標
        if (code3 == "K") {
            var mark2 = $("input[name='tfz1_s_mark2']:checked").val();
            if (mark2 != "H" && mark2 != "I" && mark2 != "J") {
                alert("案性為『其他』時，商標種類只能選『位置、氣味、觸覺』其一");
                return false;
            }
        }

        //***證明標章之證明標的
        if (code3 == "D" || code3 == "E" || code3 == "F" || code3 == "G") {
            var pul = $("input[name='pul']:checked").val();
            if (pul == null) {
                alert("請輸入標章證明標的及內容");
                settab("#tran");
                return false;
            } else {
                $("#tfz1_pul").val(pul);
            }
        }

        //****團體標章表彰之內容	
        if (code3 == "9" || code3 == "A" || code3 == "B" || code3 == "C") {
            if (IsEmpty($("#tf91_good_name").val())) {
                alert("請輸入團體標章表彰之內容");
                settab("#tran");
                return false;
                $("#tf91_good_name").focus();
            }
        }

        //****優先權申請日檢查	
        if (!IsEmpty($("#pfz1_prior_date").val()) && !$.isDate($("#pfz1_prior_date").val())) {
            alert("請檢查優先權申請日，日期格式是否正確!!");
            settab("#tran");
            return false;
            $("#pfz1_prior_date").focus();
        }

        //折扣請核單檢查2005/10/11雄商平淑提出與李經理確認修改如下
        //折扣率>=30檢查需附折扣請核單，為因應折扣率21~29仍需附折扣請款單，不控制>=30勾選材存檔，營洽勾選即存檔	
        //2005/11/22李經理指示折扣率>30需簽折扣請核單，服務費等於七折不用簽折扣請核單
        //2016/5/30修改，因折扣請核改為線上，所以不需檢復折扣請核單，判斷>20需填寫折扣理由
        if ($("#nfy_Discount").val() != "" && CInt($("#nfy_Discount").val()) > 20) {
            if ($("#tfy_discount_remark").val() == "") {
                alert("折扣低於8折，應填寫折扣理由，請輸入！");
                settab("#case");
                $("#tfy_discount_remark").focus();
                return false;
            }
        }
        //轉帳費用檢查
        if ($("#tfy_oth_arcase").val() != "") {
            if ($("#nfy_oth_money").val() == "0") {
                alert("有轉帳費用，請輸入轉帳金額，如無轉帳金額，請將轉帳費用修改為”請選擇”!!");
                settab("#case");
                $("#nfy_oth_money").focus();
                return false;
            }
            if ($("#tfy_oth_code").val() == "") {
                alert("有轉帳費用，請輸入轉帳單位，如無轉帳單位，請將轉帳費用修改為”請選擇”!!");
                settab("#case");
                $("#tfy_oth_code").focus();
                return false;
            }
        }
        if (IsNumeric($("#nfy_oth_money").val())) {
            if (CInt($("#nfy_oth_money").val()) > 0) {
                if ($("#tfy_oth_code").val() == "") {
                    alert("有轉帳金額，請輸入轉帳單位!!");
                    settab("#case");
                    $("#tfy_oth_code").focus();
                    return false;
                }
            } else if (CInt($("#nfy_oth_money").val()) < 0) {
                alert("轉帳費用不可為負數，請重新輸入!!");
                settab("#case");
                $("#nfy_oth_money").focus();
                return false;
            }
        } else {
            alert("轉帳費用不為數值，請重新輸入!!");
            settab("#case");
            $("#nfy_oth_money").focus();
            return false;
        }

        if ($("#tfy_oth_code").val() != "") {
            if ($("#nfy_oth_money").val() == "0") {
                alert("有轉帳單位，無轉帳金額，請檢查!!");
                settab("#case");
                $("#nfy_oth_money").focus();
                return false;
            }
        }

        //*******客戶期限與承辦期限控制
        if ($("#dfy_cust_date").val() != "") {
            if ($.isDate($("#dfy_cust_date").val()) && $.isDate($("#dfy_pr_date").val())) {
                if (Date.parse($("#dfy_cust_date").val()) < Date.parse($("#dfy_pr_date").val())) {
                    $("#dfy_pr_date").val($("#dfy_cust_date").val());
                }
            } else {
                if ($("#dfy_cust_date").val() != "" && !$.isDate($("#dfy_cust_date").val())) {
                    alert("客戶期限日期格式錯誤，請重新輸入!!");
                    settab("#case");
                    $("#dfy_cust_date").focus();
                    return false;
                }
                if ($("#dfy_pr_date").val() != "" && !$.isDate($("#dfy_pr_date").val())) {
                    alert("承辦期限日期格式錯誤，請重新輸入!!");
                    settab("#case");
                    $("#dfy_pr_date").focus();
                    return false;
                }
            }
        }

        //*****法定期限控制2011/9/26新增
        if ($("#dfy_last_date").val() != "") {
            if (!$.isDate($("#dfy_last_date").val())) {
                alert("法定期限日期格式錯誤，請重新輸入!!");
                settab("#case");
                $("#dfy_last_date").focus();
                return false;
            }
            if ($("#tfy_case_stat").val() == "OO" || $("#spe_ctrl3").val() == "N") {
                var msg = "提醒您！在此輸入法定期限，系統不會自動管制或檢核程序管制法定期限是否一致，是否確定輸入？";
                if (confirm(msg)) {
                    alert("請自行通知程序於客收時加管此法定期限！");
                } else {
                    $("#dfy_last_date").val("");
                }
            }
        }

        //*****契約號碼控制
        var cont_type = $("input[name='Contract_no_Type']:checked").val();
        $("#tfy_contract_type").val(cont_type);
        if (cont_type == "A" || cont_type == "B" || cont_type == "C")//後續案無契約書/特案簽報/其他契約書無編號/特案簽報
            $("#tfy_Contract_no").val(cont_type);
        else if (cont_type == "M")//總契約書
            $("#tfy_Contract_no").val($("#Mcontract_no").val());
        else if (cont_type == "N") {//一般契約書
            if ($("#tfy_Contract_no").val() != "") {
                if (!IsNumeric($("#tfy_Contract_no").val())) {
                    alert("契約號碼請輸入數值!!");
                    settab("#case");
                    $("#tfy_Contract_no").focus();
                    return false;
                }
            }
        }

        if (main.prgid == "brt52") {//交辦維護
            if ($("input[name='Contract_no_Type']:checked").length == 0) {
                alert("請輸入契約書種類！！！");
                settab("#case");
                $("input[name='Contract_no_Type']")[0].focus();
                return false;
            } else {
                var cont_type = $("input[name='Contract_no_Type']:checked").val();
                if (cont_type == "N") {//一般契約書
                    if ($("#tfy_Contract_no").val() == "") {
                        alert("請輸入契約號碼!!");
                        settab("#case");
                        $("#tfy_Contract_no").focus();
                        return false;
                    } else if (!IsNumeric($("#tfy_Contract_no").val())) {
                        alert("契約號碼請輸入數值!!");
                        settab("#case");
                        $("#tfy_Contract_no").focus();
                        return false;
                    }
                }
                if (cont_type == "M" && $("#tfy_Contract_no").val() == "") {//總契約書但無契約書號
                    if ($("#tfy_contract_flag").pdop("checked") == false) {//無勾選契約書後補
                        alert("無總契約書號，請檢查！");
                        settab("#case");
                        $("input[name='Contract_no_Type'][value='M']").focus();
                        return false;
                    }
                }
            }
        }

        //***契約書種類與對應文件種類檢查
        if ($("#tfy_contract_flag").prop("checked") == false) {
            var pchktype = "B"
            if (main.prgid == "brt51") pchktype = "A";
            if (check_doctype("T", $("#tfy_contract_type").val(), pchktype) == true) {
                settab("#case");
                return false;
            }
        } else {
            if ($("#tfy_contract_remark").val() == "") {
                alert("契約書相關文件後補，需填寫尚缺文件說明！");
                settab("#case");
                $("#tfy_contract_remark").focus();
                return false;
            }
        }
        //***交辦內容
        //大陸案請款註記檢查.請款註記:大陸進口案
        if ($("#tfz1_seq1").val() == "M" && $("#tfy_Ar_mark").val() != "X") {
            alert("本案件為大陸案, 請款註記請設定為大陸進口案!!");
            settab("#case");
            $("#tfy_Ar_mark").focus();
            return false;
        } else if ($("#tfz1_seq1").val() != "M" && $("#tfy_Ar_mark").val() == "X") {
            alert("請款註記設定為大陸進口案，案件編號副碼請設定為M_大陸案 !!");
            settab("#tran");
            $("#tfz1_seq1").focus();
            return false;
        }
        //商標名稱檢查
        if ($("#tfz1_Appl_name").val() == "") {
            alert("需填寫商標名稱！");
            settab("#tran");
            $("#tfz1_Appl_name").focus();
            return false;
        }
        //2014/4/22增加檢查是否為雙邊代理查照對象,案件名稱
        if (check_CustWatch("appl_name", $("#tfz1_Appl_name").val()) == true) {
            settab("#tran");
            $("#tfz1_Appl_name").focus();
            return false;
        }
        //檢查備註,有選擇radio則須輸入內容
        var z = $('input[name=ttz1_RCode]:checked').val();
        if (z !== undefined && $("#ttz1_" + z).val() == "") {
            alert("請確認備註是否錯誤!");
            settab("#tran");
            return false;
        }
        //出名代理人檢查
        var apclass_flag = "N";
        for (var capnum = 1; capnum <= CInt($("#apnum").val()) ; capnum++) {
            if ($("#apclass_" + capnum).val().Left(1) == "C") {
                //申請人為外國人則為涉外案
                apclass_flag = "C";
            }
        }
        if (apclass_flag == "C") {
            //2015/10/21修改抓取cust_code.code_type=Tagt_no and mark=C及用function放置於sub/client_chk_agtno.vbs
            if (check_agtno("C", $("#tfz1_agt_no").val()) == true) {
                settab("#tran");
                $("#tfz1_agt_no").focus();
                return false;
            }
        } else {
            var pagt_no = $("#tfy_Arcase option:selected").attr("v2");//案性預設出名代理人
            if (pagt_no == "") {
                //2015/10/21因應104年度出名代理人修改並改抓取cust_code.code_type=Tagt_no and mark=N預設出名代理人
                pagt_no = get_tagtno("N").no;
            }

            if ($("#tfz1_agt_no").val().trim() != pagt_no.trim()) {
                if (!confirm("出名代理人與案性預設出名代理人不同，是否確定交辦？")) {
                    settab("#tran");
                    $("#tfz1_agt_no").focus();
                    return false;
                }
            }
        }


        //*****商品類別檢查
        if ($("#tabbr1").length > 0) {//有載入才要檢查
            var inputCount = 0;
            for (var j = 1; j <= CInt($("#num1").val()) ; j++) {
                if ($("#good_name1_" + j).val() != "" && $("#class1_" + j).val() == "") {
                    //有輸入商品名稱,但沒輸入類別
                    alert("請輸入類別!");
                    settab("#tran");
                    $("#class1_" + j).focus();
                    return false;
                }

                if ($("input[name='tfz1_class_type']:checked").val() == "int") {
                    if (br_form.checkclass($("#class1_" + j).val()) == false) {//檢查類別範圍0~45
                        $("#class1_" + j).focus();
                        return false;
                    }
                }
                if ($("#class1_" + j).val() != "") {
                    inputCount++;//實際有輸入才要+
                }
            }
            $("#ctrlcount1").val(inputCount == 0 ? "" : inputCount);

            if (CInt($("#tfz1_class_count").val()) != CInt($("#num1").val())) {
                var answer = "指定使用商品類別項目(共 " + CInt($("#tfz1_class_count").val()) + " 類)與輸入指定使用商品(共 " + CInt($("#num1").val()) + " 類)不符，\n是否確定指定使用商品共 " + CInt($("#num1").val()) + " 類？";
                if (confirm(answer)) {
                    $("#tfz1_class_count").val($("#num1").val());
                } else {
                    settab("#tran");
                    $("#tfz1_class_count").focus();
                    return false;
                }
            }
        }

        if (code3 == "9" || code3 == "A" || code3 == "B" || code3 == "C" || code3 == "D" || code3 == "E" || code3 == "F" || code3 == "G") {
            $("#tfz1_class").val("");
            $("#tfz1_class_count").val("");
            $("input[name='tfz1_class_type']").prop("checked", false);
        }

        //檢查指定類別有無重覆
        var objClass = {};
        for (var r = 1; r <= CInt($("#num1").val()) ; r++) {
            var lineTa = $("#class1_" + r).val();
            if (lineTa != "" && objClass[lineTa]) {
                alert("商品類別重覆,請重新輸入!!!");
                $("#class1_" + r).focus();
                return false;
            } else {
                objClass[lineTa] = { flag: true, idx: r };
            }
        }

        //***表彰內容
        if ($("#tf91_good_name").length > 0)
            $("#tfz1_good_name").val($("#tf91_good_name").val());
        //***證明內容
        if ($("#tfd1_good_name").length > 0)
            $("#tfz1_good_name").val($("#tfd1_good_name").val());

        //****請款註記	
        if ($("#tfz1_seq1").val() == "M") {
            $("#tfy_ar_code").val("M");
        } else if ($("#nfy_service").val() == 0 && $("#nfy_fees").val() == 0 && $("#nfy_oth_money").val() == 0 && $("#tfy_Ar_mark").val() == "N") {
            $("#tfy_ar_code").val("X");
        } else {
            $("#tfy_ar_code").val("N");
        }

        //****總計案性數
        var nfy_tot_case = 0;
        if (!IsEmpty($("#tfy_Arcase").val())) {
            nfy_tot_case += 1;
        }
        for (var r = 1; r <= CInt($("#TaCount").val()) ; r++) {
            if (!IsEmpty($("#nfyi_item_Arcase_" + r).val())) {
                nfy_tot_case += 1;
            }
        }
        $("#nfy_tot_case").val(nfy_tot_case);

        //****當無收費標準時，把值清空
        if (reg.anfees.value == "N") {
            $("#nfy_Discount").val("");
            $("#tfy_dicount_remark").val("");//2016/5/30增加折扣理由
        }

        return true;
    }
</script>