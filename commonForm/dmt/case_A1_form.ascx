<%@ Control Language="C#" ClassName="do1_form" %>

<script runat="server">
    protected string prgid = HttpContext.Current.Request["prgid"] ?? "";//功能權限代碼
    protected string SQL = "";
    protected string branch = "";
    protected string opt_sqlno = "";
    
    private void Page_Load(System.Object sender, System.EventArgs e) {
        branch = Request["branch"] ?? "";
        opt_sqlno = Request["opt_sqlno"] ?? "";
        
        this.DataBind();
    }
</script>

<%=Sys.GetAscxPath(this)%>
<table border="0" class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	<tr id="tr_Popt_show1" style="display:none">
		<td class="lightbluetable" valign="top"  align="right"><strong>案件編號：</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
			<input type="text" size="12" id="Popt_no" name="Popt_no" class="QLock">
		</td>
	</tr>
	<tr id="showPseq">
		<td class="lightbluetable" valign="top"  align="right"><strong>區所案件編號：</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
			<INPUT TYPE=text id=PBranch NAME=PBranch SIZE=1 MAXLENGTH=1 class="QLock">-<INPUT TYPE=text id=PBseq NAME=PBseq SIZE=5 MAXLENGTH=5 class="Lock">-<INPUT TYPE=text id=PBseq1 NAME=PBseq1 SIZE=1 MAXLENGTH=1 class="Lock">
		</td>
	</tr>	
	<tr>
		<td class="lightbluetable" valign="top"><strong>※、代理人</strong></td>
		<td class="whitetablebg" colspan="7" valign="top">
		    <select id=Pagt_no NAME=Pagt_no class="QLock"></select>
		</td>
	</tr>	
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" width="20%" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Appl_name)">
            <strong>壹、<u>異議標的(你要異議的標章)</u></strong>
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right >商標種類：</td>
		<td class=whitetablebg colspan="7">
			<input type=radio name=PS_Mark value="" class="QLock">商標
			<input type=radio name=PS_Mark value="S" class="QLock">92年修正前服務標章
			<input type=radio name=PS_Mark value="N" class="QLock">團體商標
			<input type=radio name=PS_Mark value="M" class="QLock">團體標章
			<input type=radio name=PS_Mark value="L" class="QLock">證明標章
		</TD>					
	</tr>
	<tr>
		<td class=lightbluetable align=right >註冊號數：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="Pissue_no" name="Pissue_no" size="20" maxlength="20"  class="QLock">
		</TD>
		<td class=lightbluetable align=right width="18%">商標/標章名稱：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="PAppl_name" name="PAppl_name" size="30" maxlength="100"  class="QLock">
		</TD>
	</tr>
	<tr>
		<td class=lightbluetable align=right >擬異議之類別種類：</td>
		<td class=whitetablebg colspan="3">
			<input type="radio" name=Pclass_type value="int" class="QLock">國際分類
			<input type="radio" name=Pclass_type value="old" class="QLock">舊類
		</TD>
		<td class=lightbluetable align=right width="18%">擬異議之類別：</td>
		<td class=whitetablebg colspan="3">
			<input type="text" id="Pclass" name="Pclass" size="30" maxlength="100" class="QLock">，
			共<input type="text" id="Pclass_count" name="Pclass_count" size=3 class="QLock">類(異議案依類別計算，請填具正確類別數)
		</TD>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" width="20%">　　<strong>你認為商標/標章圖樣那一部份違法請打勾並填寫：</strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right width="20%"></td>
		<td class=whitetablebg colspan=7>
            <input type="checkbox" name=Pcappl_name value="C" class="PLock">中文
            <input type="checkbox" name=Peappl_name value="E" class="PLock">英文
            <input type="checkbox" name=Pjappl_name value="J" class="PLock">日文
            <input type="checkbox" name=Pdraw value="D" class="PLock">圖形
            <input type="checkbox" name=Pzappl_name1 value="Z" class="PLock">其他（非英文或日文之外國文字、顏色、聲音、立體形狀等）
		</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right></td>
		<td class=whitetablebg colspan=7>
            <INPUT TYPE=text NAME=Premark3 id=Premark3 SIZE=30 MAXLENGTH=50 class="PLock">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Rapcust)"><strong>肆、<u>被異議人：</u></strong></td>
	</tr>
	<tr class='sfont9'>
		<td colspan="8">
		    <table border="0" id=DO1_tabap class="bluetable" cellspacing="1" cellpadding="2" width="100%">
	            <THEAD>
		        <TR>
			        <TD  class=whitetablebg colspan=2 align=right>
		                <input type=hidden id=DO1_apnum name=DO1_apnum value=0><!--進度筆數-->
				        <input type=button value ="增加一筆被異議人" class="cbutton PLock" id=DO1_AP_Add_button name=DO1_AP_Add_button>
				        <input type=button value ="減少一筆被異議人" class="cbutton PLock" id=DO1_AP_Del_button name=DO1_AP_Del_button>
			        </TD>
		        </TR>
	            </THEAD>
	            <TFOOT style="display:none">
		            <TR>
			            <TD class=lightbluetable align=right>
		                    <input type=text name='DO1_apnum_##' class="Lock" style='color:black;' size=2 value='##.'>名稱或姓名：
			            </TD>
			            <TD class=sfont9>
		                    <input TYPE=text ID="ttg2_mod_ap_ncname1_##" NAME="ttg2_mod_ap_ncname1_##" SIZE=60 MAXLENGTH=60 alt='『被異議人名稱或姓名』' onblur='fDataLen(this.value,this.maxLength,this.alt)' class="PLock">
                            <br />
                            <input TYPE=text id="ttg2_mod_ap_ncname2_##" NAME="ttg2_mod_ap_ncname2_##" SIZE=60 MAXLENGTH=60 alt='『被異議人名稱或姓名』' onblur='fDataLen(this.value,this.maxLength,this.alt)' class="PLock">
			            </TD>
		            </TR>
		            <TR>
			            <TD class=lightbluetable align=right>地　　　址：</TD>
			            <TD class=sfont9>
			            	<input TYPE=text id="ttg2_mod_ap_nzip_##" NAME="ttg2_mod_ap_nzip_##" SIZE=5 MAXLENGTH=5 class="PLock" />
		                    <input TYPE=text id="ttg2_mod_ap_naddr1_##" NAME="ttg2_mod_ap_naddr1_##" SIZE=30 MAXLENGTH=60 alt='『被異議人地址』' onblur='fDataLen(this.value,this.maxLength,this.alt)' class="PLock">
		                    <input TYPE=text id="ttg2_mod_ap_naddr2_##" NAME="ttg2_mod_ap_naddr2_##" SIZE=30 MAXLENGTH=60 alt='『被異議人地址』' onblur='fDataLen(this.value,this.maxLength,this.alt)' class="PLock">
                        </TD>
		            </TR>
		            <TR>
			            <TD class=lightbluetable align=right>代理人姓名：</TD>
			            <TD class=sfont9>
                            <input TYPE=text id="ttg2_mod_ap_ncrep_##" NAME="ttg2_mod_ap_ncrep_##" SIZE=20 MAXLENGTH=20 alt='『被異議代理人』' onblur='fDataLen(this.value,this.maxLength,this.alt)' class="PLock">
                        </TD>
		            </TR>
	            </TFOOT>
	            <TBODY>
	            </TBODY>
		    </table>
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1New_no)"><strong>伍、<u>異議聲明：</u></strong></td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top></td>
		<td class=whitetablebg colspan=7>第<INPUT TYPE=text NAME=P1mod_pul_new_no id=P1mod_pul_new_no SIZE=10 MAXLENGTH=10 class="PLock">號「<INPUT TYPE=text NAME=P1mod_pul_ncname1 id=P1mod_pul_ncname1 SIZE=30 MAXLENGTH=50 class="PLock">」<input type="radio" name="P1mod_pul_mod_type" value="Tmark" class="PLock">商標<input type="radio" name="P1mod_pul_mod_type" value="Lmark" class="PLock">標章</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" id=P2mod_pul_mod_type name=P2mod_pul_mod_type value="O1" class="PLock"></td>
		<td class=whitetablebg colspan=7>註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" id=P3mod_pul_mod_type name=P3mod_pul_mod_type value="O2" class="PLock"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=P3mod_pul_new_no id=P3mod_pul_new_no SIZE=3 MAXLENGTH=10 class="PLock">條第<INPUT TYPE=text NAME=P3mod_pul_mod_dclass id=P3mod_pul_mod_dclass SIZE=20 MAXLENGTH=20 class="PLock">類商品／服務之註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class=lightbluetable align=right valign=top><input type="checkbox" id=P4mod_pul_mod_type name=P4mod_pul_mod_type value="O3" class="PLock"></td>
		<td class=whitetablebg colspan=7>指定使用於商標法施行細則第<INPUT TYPE=text NAME=P4mod_pul_new_no id=P4mod_pul_new_no SIZE=3 MAXLENGTH=10 class="PLock">條第<INPUT TYPE=text NAME=P4mod_pul_mod_dclass id=P4mod_pul_mod_dclass SIZE=3 MAXLENGTH=3 class="PLock">類<br><INPUT TYPE=text NAME=P4mod_pul_ncname1 id=P4mod_pul_ncname1 SIZE=170 MAXLENGTH=200 class="PLock"><br>商品／服務之註冊應予撤銷。</td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Other_item1)"><strong>陸、<u>主張法條及據以異議商標/標章：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top">一、主張法條：</td>
		<td class=whitetablebg colspan="7" valign="top">
            商標法<input TYPE=text NAME=Pother_item1 id=Pother_item1 SIZE=50 MAXLENGTH=50 class="PLock">
		</td>
	</tr>
	<tr>
		<td class="lightbluetable" valign="top" colspan="8" >
            <strong>二、據以異議商標/標章：</strong>（你認為被異議商標/標章和那些商標/標章相衝突，請按照主張條款分別詳細列出，有號數者請務必依序填寫，以免延宕本案之審理）
		</td>
	</tr>
	<tr class='sfont9'>
	    <td colspan=8>
	        <TABLE id=DO1_tabapre border=0 class="bluetable"  cellspacing=1 cellpadding=2 width="100%">
                <thead>
    		        <tr>	
			            <td class="lightbluetable" align="right" width="18%">條款項目：</td>
			            <td class="whitetablebg" colspan="7" >
                            共<input type="text" id=Pmod_aprep_mod_count name=Pmod_aprep_mod_count size=2 class="PLock">項
                            <input type=hidden id=DO1_aprenum name=DO1_aprenum value=0>
			            </td>
		            </tr>
                </thead>
                <tfoot style="display:none">
		            <tr>	
			            <td class="lightbluetable" align="right">主張條款##：</td>
			            <td class="whitetablebg" colspan="7" >
                            <input type="text" id="Pmod_aprep_ncname1_##" name="Pmod_aprep_ncname1_##" size=30  maxlength=20 class="PLock">
			            </td>
		            </tr>
		            <tr>	
			            <td class="lightbluetable" align="right">據以異議商標號數##：</td>
			            <td class="whitetablebg" colspan="7">
                            <input type="text" id="Pmod_aprep_new_no_##" name="Pmod_aprep_new_no_##" size=60 class="PLock" maxlength=80>
			            </td>
		            </tr>
                </tfoot>
                <tbody></tbody>
	        </table>
	    </td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Tran_remark1)"><strong>柒、<u>事實及理由：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><textarea rows=9 cols=90 id=Ptran_remark1 name=Ptran_remark1 class="PLock"></textarea></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(zAttechd)"><strong>捌、<u>證據(附件)內容：</u></strong></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><textarea rows=9 cols=90 id=Ptran_remark2 name=Ptran_remark2 class="PLock"></textarea></td>
	</tr>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top" STYLE="cursor:pointer;COLOR:BLUE" onclick="PMARK(o1Other_item)"><strong>玖、<u>相關聯案件：</u></strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable align=right></TD>
		<TD class=whitetablebg colspan=7>本案與<input TYPE=text id=Pitem1 NAME=Pitem1 SIZE=10 MAXLENGTH=10 class="dateField PLock">
		(年/月/日)註冊第<input type="text" id="Pitem2" name="Pitem2" SIZE=10 class="PLock">號<input type="text" id="Pitem3" name="Pitem3" SIZE=10 class="PLock">案有關
		<input type="hidden" id="Pother_item" name="Pother_item">
		</TD>
	</TR>
	<tr>
		<td class="lightbluetable" colspan="8" valign="top"><strong>※異議商標及據以異議商標圖樣：</strong></td>
	</tr>
	<TR>
		<TD class=lightbluetable>一、異議標的圖樣：</TD>
		<TD class=whitetablebg colspan=7>
		    <input TYPE=text NAME=Pdraw_file id=Pdraw_file SIZE=50 MAXLENGTH=50 class="P1Lock">
			 <a id="Pdraw_icon" target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a>
		</TD>
	</TR>	
	<TR>
		<TD class=lightbluetable align=right>二、據以異議商標圖樣：</TD>
		<TD class=whitetablebg colspan=7>
		<input TYPE=text NAME=Pmod_dmt_ncname1 id=Pmod_dmt_ncname1 SIZE=50 MAXLENGTH=50 class="P1Lock"><a id="Pmod_dmt_ncname1_icon" style="display:none" target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		<input TYPE=text NAME=Pmod_dmt_ncname2 id=Pmod_dmt_ncname2 SIZE=50 MAXLENGTH=50 class="P1Lock"><a id="Pmod_dmt_ncname2_icon" style="display:none" target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		<input TYPE=text NAME=Pmod_dmt_nename1 id=Pmod_dmt_nename1 SIZE=50 MAXLENGTH=50 class="P1Lock"><a id="Pmod_dmt_nename1_icon" style="display:none" target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		<input TYPE=text NAME=Pmod_dmt_nename2 id=Pmod_dmt_nename2 SIZE=50 MAXLENGTH=50 class="P1Lock"><a id="Pmod_dmt_nename2_icon" style="display:none" target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		<input TYPE=text NAME=Pmod_dmt_ncrep id=Pmod_dmt_ncrep SIZE=50 MAXLENGTH=50 class="P1Lock"><a id="Pmod_dmt_ncrep_icon" style="display:none" target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		<span id="Pmod_dmt_nerep_icon" style="display:none">
		    <input TYPE=text NAME="Pmod_dmt_nerep" id="Pmod_dmt_nerep" SIZE=50 MAXLENGTH=50 class="P1Lock"><a target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		</span>
		<span id="Pmod_dmt_neaddr1_icon" style="display:none">
		    <input TYPE=text NAME=Pmod_dmt_neaddr1 id=Pmod_dmt_neaddr1 SIZE=50 MAXLENGTH=50 class="P1Lock"><a target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		</span>
		<span id="Pmod_dmt_neaddr2_icon" style="display:none">
		    <input TYPE=text NAME=Pmod_dmt_neaddr2 id=Pmod_dmt_neaddr2 SIZE=50 MAXLENGTH=50 class="P1Lock"><a target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		</span>
		<span id="Pmod_dmt_neaddr3_icon" style="display:none">
		    <input TYPE=text NAME=Pmod_dmt_neaddr3 id=Pmod_dmt_neaddr3 SIZE=50 MAXLENGTH=50 class="P1Lock"><a target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		</span>
		<span id="Pmod_dmt_neaddr4_icon" style="display:none">
		    <input TYPE=text NAME=Pmod_dmt_neaddr4 id=Pmod_dmt_neaddr4 SIZE=50 MAXLENGTH=50 class="P1Lock"><a target="_blank"><img border="0" src="../images/annex.gif" WIDTH="18" HEIGHT="18"></a><br>
		</span>
		</TD>
	</TR>
</table>	

<script language="javascript" type="text/javascript">
    var tran_form = {};
    tran_form.init = function () {
        $("#Pagt_no").getOption({//代理人
            url: getRootPath() + "/ajax/LookupDataBranch.aspx",
            data: { type: "getagtdata", branch: "<%#branch%>" },
            valueFormat: "{agt_no}",
            textFormat: "{strcomp_name}{agt_name}"
        });

        var jOpt = br_opt.opt[0];
        $("#Popt_no").val(jOpt.opt_no);
        $("#PBranch").val(jOpt.branch);
        $("#PBseq").val(jOpt.bseq);
        $("#PBseq1").val(jOpt.bseq1);
        $("#Pagt_no").val(jOpt.agt_no);

        //異議標的
        $("input[name='PS_Mark'][value='" + jOpt.s_mark + "']").prop("checked", true);
        $("#Pissue_no").val(jOpt.issue_no);
        $("#PAppl_name").val(jOpt.appl_name);
        $("input[name='Pclass_type'][value='" + jOpt.class_type + "']").prop("checked", true);
        $("#Pclass").val(jOpt.class);
        $("#Pclass_count").val(jOpt.class_count);
        $("input[name='Pcappl_name'][value='" + jOpt.cappl_name + "']").prop("checked", true);
        $("input[name='Peappl_name'][value='" + jOpt.eappl_name + "']").prop("checked", true);
        $("input[name='Pjappl_name'][value='" + jOpt.jappl_name + "']").prop("checked", true);
        $("input[name='Pdraw'][value='" + jOpt.draw + "']").prop("checked", true);
        $("input[name='Pzappl_name1'][value='" + jOpt.zappl_name1 + "']").prop("checked", true);
        $("#Premark3").val(jOpt.remark3);

        //被異議人
        var jMod = br_opt.tran_mod_ap;
        $("#DO1_tabap>tbody").empty();
        if (jMod.length > 0) {
            $.each(jMod, function (i, item) {
                //增加一筆
                tran_form.appendModAp()
                //填資料
                var nRow = $("#apnum").val();
                $("#ttg2_mod_ap_ncname1_" + nRow).val(item.ncname1);
                $("#ttg2_mod_ap_ncname2_" + nRow).val(item.ncname2);
                $("#ttg2_mod_ap_nzip_" + nRow).val(item.nzip);
                $("#ttg2_mod_ap_naddr1_" + nRow).val(item.naddr1);
                $("#ttg2_mod_ap_naddr2_" + nRow).val(item.naddr2);
                $("#ttg2_mod_ap_ncrep_" + nRow).val(item.ncrep);
            });
        } else {
            alert("查無此交辦案件之對造當事人資料!!");
        }

        //異議聲明
        if (jOpt.mod_pul == "Y") {
            $.each(br_opt.tran_mod_pul, function (i, item) {
                switch (item.mod_type) {
                    case "Tmark":
                    case "Lmark":
                        $("input[name='P1mod_pul_mod_type'][value='" + item.mod_type + "']").prop("checked", true);
                        $("#P1mod_pul_new_no").val(item.new_no);
                        $("#P1mod_pul_ncname1").val(item.ncname1);
                        break;
                    case "O1":
                        $("#P2mod_pul_mod_type").prop("checked", true);
                        break;
                    case "O2":
                        $("#P3mod_pul_mod_type").prop("checked", true);
                        $("#P3mod_pul_new_no").val(item.new_no);
                        $("#P3mod_pul_mod_dclass").val(item.mod_dclass);
                        break;
                    case "O3":
                        $("#P4mod_pul_mod_type").prop("checked", true);
                        $("#P4mod_pul_new_no").val(item.new_no);
                        $("#P4mod_pul_mod_dclass").val(item.mod_dclass);
                        $("#P4mod_pul_ncname1").val(item.ncname1);
                        break;
                }
            });
        }
        //主張法條/據以異議商標/標章
        $("#Pother_item1").val(jOpt.other_item1);
        $("#DO1_tabapre>tbody").empty();
        if (jOpt.mod_aprep == "Y") {
            $.each(br_opt.tran_mod_aprep, function (i, item) {
                $("#Pmod_aprep_mod_count").val(item.mod_count).trigger("change");
                //填資料
                $("#Pmod_aprep_ncname1_" + (i+1)).val(item.ncname1);
                $("#Pmod_aprep_new_no_" + (i + 1)).val(item.new_no);
            });
		}

        //事實及理由
        $("#Ptran_remark1").val(jOpt.tran_remark1);

        //證據(附件)內容
        $("#Ptran_remark2").val(jOpt.tran_remark2);

        //相關聯案件
        if (jOpt.other_item != "") {
            var pitem = jOpt.other_item.split(';');
            $("#Pitem1").val(pitem[0]);
            $("#Pitem2").val(pitem[1]);
            $("#Pitem3").val(pitem[2]);
        }

        //異議商標
        $("#Pdraw_file").val(jOpt.draw_file);
        if (jOpt.draw_file != "") $("#Pdraw_icon").attr("href", jOpt.drfile).show();
        if (jOpt.mod_dmt == "Y") {
            var jModDmt = br_opt.tran_mod_dmt[0];
            $("#Pmod_dmt_ncname1").val(jModDmt.ncname1);
            $("#Pmod_dmt_ncname2").val(jModDmt.ncname2);
            $("#Pmod_dmt_nename1").val(jModDmt.nename1);
            $("#Pmod_dmt_nename2").val(jModDmt.nename2);
            $("#Pmod_dmt_ncrep").val(jModDmt.ncrep);
            $("#Pmod_dmt_nerep").val(jModDmt.nerep);
            $("#Pmod_dmt_neaddr1").val(jModDmt.neaddr1);
            $("#Pmod_dmt_neaddr2").val(jModDmt.neaddr2);
            $("#Pmod_dmt_neaddr3").val(jModDmt.neaddr3);
            $("#Pmod_dmt_neaddr4").val(jModDmt.neaddr4);
            if (jModDmt.ncname1 != "") $("#Pmod_dmt_ncname1_icon").attr("href", jModDmt.mod_dmt_ncname1).show();
            if (jModDmt.ncname2 != "") $("#Pmod_dmt_ncname2_icon").attr("href", jModDmt.mod_dmt_ncname2).show();
            if (jModDmt.nename1 != "") $("#Pmod_dmt_nename1_icon").attr("href", jModDmt.mod_dmt_nename1).show();
            if (jModDmt.nename2 != "") $("#Pmod_dmt_nename2_icon").attr("href", jModDmt.mod_dmt_nename2).show();
            if (jModDmt.ncrep != "") $("#Pmod_dmt_ncrep_icon").attr("href", jModDmt.mod_dmt_ncrep).show();
            if (jModDmt.nerep != "") $("#Pmod_dmt_nerep_icon").show().attr("href", jModDmt.mod_dmt_nerep);
            if (jModDmt.neaddr1 != "") $("#Pmod_dmt_neaddr1_icon").show().find("a").attr("href", jModDmt.mod_dmt_neaddr1);
            if (jModDmt.neaddr2 != "") $("#Pmod_dmt_neaddr1_icon").show().find("a").attr("href", jModDmt.mod_dmt_neaddr2);
            if (jModDmt.neaddr3 != "") $("#Pmod_dmt_neaddr1_icon").show().find("a").attr("href", jModDmt.mod_dmt_neaddr3);
            if (jModDmt.neaddr4 != "") $("#Pmod_dmt_neaddr1_icon").show().find("a").attr("href", jModDmt.mod_dmt_neaddr4);
        }

        //$("#tr_opt_show").showFor("<%#prgid%>" == "opt21");//分案作業要顯示 爭救案件編號
    }

    //據以異議商標/標章
    $("#Pmod_aprep_mod_count").change(function () { tran_form.appendModApRe(this.value); });
    tran_form.appendModApRe = function (totRow) {
        var nRow = parseInt($("#DO1_aprenum").val(), 10);
        while (nRow < totRow) {//增加
            nRow += 1;
            //複製樣板
            var copyStr = "";
            $("#DO1_tabapre>tfoot tr").each(function (i) {
                copyStr += "<tr name='tr_apre_" + nRow + "'>" + $(this).html().replace(/##/g, nRow) + "</tr>"
            });
            $("#DO1_tabapre>tbody").append(copyStr);
            $("#DO1_aprenum").val(nRow)
        }
        while (nRow > totRow) {//減少
            $("tr[name='tr_apre_" + nRow + "']").remove();
            nRow -= 1;
            $("#DO1_aprenum").val(Math.max(0, nRow));
        }
    }

    //增加一筆被異議人
    $("#DO1_AP_Add_button").click(function () { tran_form.appendModAp(); });
    tran_form.appendModAp = function () {
        var nRow = parseInt($("#DO1_apnum").val(), 10) + 1;
        //複製樣板
        var copyStr = "";
        $("#DO1_tabap>tfoot tr").each(function (i) {
            copyStr += "<tr name='tr_tran_" + nRow + "'>" + $(this).html().replace(/##/g, nRow) + "</tr>"
        });
        $("#DO1_tabap>tbody").append(copyStr);
        $("#DO1_apnum").val(nRow)
    }

    //減少一筆被異議人
    $("#DO1_AP_Del_button").click(function () { tran_form.deleteModAp(); });
    tran_form.deleteModAp = function () {
        var nRow = parseInt($("#DO1_apnum").val(), 10);
        $("tr[name='tr_tran_" + nRow + "']").remove();
        $("#DO1_apnum").val(Math.max(0, nRow - 1));
    }

</script>
