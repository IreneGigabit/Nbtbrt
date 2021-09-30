<%@ Page Language="C#"%>
<%@ Import Namespace = "System.Data" %>
<%@ Import Namespace = "System.Data.SqlClient" %>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "System.Linq"%>
<%@ Import Namespace = "System.Collections.Generic"%>

<script runat="server">
	protected string in_scode = "";
	protected string in_no = "";
	protected string case_sqlno = "";
	
	protected IPOReport ipoRpt = null;

	private void Page_Load(System.Object sender, System.EventArgs e) {
		Response.CacheControl = "Private";
		Response.AddHeader("Pragma", "no-cache");
		Response.Expires = -1;
		Response.Clear();

        
		in_scode = (Request["in_scode"] ?? "").ToString();//n428
		in_no = (Request["in_no"] ?? "").ToString();//20160902001
		case_sqlno = (Request["case_sqlno"] ?? "").ToString();//16090001
        
		try {
			ipoRpt = new IPOReport(Conn.btbrt, in_scode, in_no, case_sqlno)
			{
				ReportCode = "DI1",
				RectitleFlag = (Request["rectitle_flag"] ?? "").ToString(),//Y
				RectitleTitle = (Request["receipt_title"] ?? "").ToString(),//A
				RectitleName = (Request["rectitle_name"] ?? "").ToString(),//英業達股份有限公司
                BaseRptAPTag = "申請評定人",
                BaseRptModTag = "註冊人"
			};
			WordOut();
		}
		finally {
			if (ipoRpt != null) ipoRpt.Close();
		}
	}

	protected void WordOut() {
        string docFileName = "[評定]-" + ipoRpt.Seq + ".docx";

		Dictionary<string, string> _tplFile = new Dictionary<string, string>(){
			{"apply", Server.MapPath("~/ReportTemplate/申請書/302評定申請書DI1.docx")},
			{"base", Server.MapPath("~/ReportTemplate/申請書/00基本資料表.docx")}
		};
		ipoRpt.CloneFromFile(_tplFile, true);

		DataTable dmt = ipoRpt.Dmt;
		if (dmt.Rows.Count > 0) {
			//標題區塊
			ipoRpt.CopyBlock("b_title");
			//註冊號
			ipoRpt.ReplaceBookmark("issue_no", dmt.Rows[0]["issue_no"].ToString().Trim());
			//事務所或申請人案件編號
			ipoRpt.ReplaceBookmark("seq", ipoRpt.Seq + "(" + DateTime.Today.ToString("yyyyMMdd") + ")");
			//商標或標章名稱
			ipoRpt.ReplaceBookmark("appl_name", dmt.Rows[0]["appl_name"].ToString().ToXmlUnicode());
			//商標或標章種類
            ipoRpt.ReplaceBookmark("s_mark", dmt.Rows[0]["s_marknm"].ToString());
            //主張圖樣違法部分
            if(dmt.Rows[0]["cappl_name"].ToString()=="C")
                ipoRpt.ReplaceBookmark("appl_name_type", "中文");
            else if (dmt.Rows[0]["eappl_name"].ToString() == "E")
                ipoRpt.ReplaceBookmark("appl_name_type", "英文");
            else if (dmt.Rows[0]["jappl_name"].ToString() == "J")
                ipoRpt.ReplaceBookmark("appl_name_type", "日文");
            else if (dmt.Rows[0]["draw"].ToString() == "D")
                ipoRpt.ReplaceBookmark("appl_name_type", "圖形");
            else if (dmt.Rows[0]["zappl_name1"].ToString() == "Z")
                ipoRpt.ReplaceBookmark("appl_name_type", "其他");
            else
                ipoRpt.ReplaceBookmark("appl_name_type", "中文/英文/日文/圖形/其他");
            
            ipoRpt.ReplaceBookmark("remark3", dmt.Rows[0]["remark3"].ToString());
        
			//申請人
			using (DataTable dtAp = ipoRpt.Apcust) {
				for (int i = 0; i < dtAp.Rows.Count; i++) {
					ipoRpt.CopyBlock("b_apply");
                    ipoRpt.ReplaceBookmark("apply_type", ipoRpt.BaseRptAPTag);
                    ipoRpt.ReplaceBookmark("apply_num", (i + 1).ToString());
					ipoRpt.ReplaceBookmark("ap_country", dtAp.Rows[i]["Country_name"].ToString());
					ipoRpt.ReplaceBookmark("ap_cname_title", dtAp.Rows[i]["Title_cname"].ToString());
					ipoRpt.ReplaceBookmark("ap_ename_title", dtAp.Rows[i]["Title_ename"].ToString());
					ipoRpt.ReplaceBookmark("ap_cname", dtAp.Rows[i]["Cname_string"].ToString().ToXmlUnicode());
					ipoRpt.ReplaceBookmark("ap_ename", dtAp.Rows[i]["Ename_string"].ToString().ToXmlUnicode(true), true);
				}
			}
            //代理人
			ipoRpt.CopyBlock("b_agent");
			using (DataTable dtAgt = ipoRpt.Agent) {
                ipoRpt.ReplaceBookmark("agent_type1", ipoRpt.BaseRptAPTag);
                ipoRpt.ReplaceBookmark("agent_type2", ipoRpt.BaseRptAPTag);
				ipoRpt.ReplaceBookmark("agt_name1", dtAgt.Rows[0]["agt_name1"].ToString());
				ipoRpt.ReplaceBookmark("agt_name2", dtAgt.Rows[0]["agt_name2"].ToString());
			}
            //關係人
            using (DataTable dtModAp = ipoRpt.TranListAP) {
                for (int i = 0; i < dtModAp.Rows.Count; i++) {
                    ipoRpt.CopyBlock("b_apply");
                    ipoRpt.ReplaceBookmark("apply_type", ipoRpt.BaseRptModTag);
                    ipoRpt.ReplaceBookmark("apply_num", (i + 1).ToString());
                    ipoRpt.ReplaceBookmark("ap_country", "",true);
                    ipoRpt.ReplaceBookmark("ap_cname_title", "中文名稱");
                    ipoRpt.ReplaceBookmark("ap_ename_title", "",true);
                    ipoRpt.ReplaceBookmark("ap_cname", dtModAp.Rows[i]["ncname1"].ToString().ToXmlUnicode());
                }
            }
            //評定聲明
            ipoRpt.CopyBlock("b_pul");
            string line1="",line2="";
            var pul1 = ipoRpt.TranListE.Where(a => a["mod_field"].ToString() == "mod_pul" && a["mod_type"].ToString().Trim().Left(1) != "I");
            foreach (var r in pul1) {
                string mod_type="";
                if(r["mod_type"].ToString().Trim()=="Tmark")mod_type="商標";
                if(r["mod_type"].ToString().Trim()=="Lmark")mod_type="標章";
                line1=string.Format("第{0}號「{1}」{2}",r["new_no"].ToString().Trim(),r["ncname1"].ToString().Trim(),mod_type);
            }
            var pul2 = ipoRpt.TranListE.Where(a => a["mod_field"].ToString() == "mod_pul" && a["mod_type"].ToString().Trim().Left(1) == "I");
            foreach (var r in pul2) {
                if (r["mod_type"].ToString().Trim() == "I1") {
                    line2 += "\n" + line1 + "註冊應予撤銷。";
                } else if (r["mod_type"].ToString().Trim() == "I2") {
                    line2 += "\n" + line1 + string.Format("指定使用於商標法施行細則第{0}條第{1}類商品／服務之註冊應予撤銷。", r["new_no"].ToString().Trim(), r["mod_dclass"].ToString().Trim());
                } else if (r["mod_type"].ToString().Trim() == "I3") {
                    line2 += "\n" + line1 + string.Format("指定使用於商標法施行細則第{0}條第{1}類{2}商品／服務之註冊應予撤銷。", r["new_no"].ToString().Trim(), r["mod_dclass"].ToString().Trim(), r["ncname1"].ToString().Trim());
                }
            }
            ipoRpt.ReplaceBookmark("pul_line", line2);

            //主張條款
            ipoRpt.CopyBlock("b_aprep");
            var mod_oitem1 = ipoRpt.Tran.Rows[0].SafeRead("other_item1", "").Split(';');
            if (mod_oitem1.Length > 0) {
                if (mod_oitem1[0] == "I")
                    ipoRpt.ReplaceBookmark("other_item1", "註冊");
                else if (mod_oitem1[0] == "R")
                    ipoRpt.ReplaceBookmark("other_item1", "延展註冊");
                else
                    ipoRpt.ReplaceBookmark("other_item1", "");
                
                if (mod_oitem1.Length > 1) {
                    string[] oitem = mod_oitem1[1].Split('|');
                    if (oitem.Length > 0 && oitem[0] != "")
                        ipoRpt.ReplaceBookmark("other_item1_1", oitem[0]);
                    else if (oitem.Length > 1 && oitem[1] != "")
                        ipoRpt.ReplaceBookmark("other_item1_1", oitem[1]);
                    else
                        ipoRpt.ReplaceBookmark("other_item1_1", "");
                }
            }
            //據以評定商標或標章
            var aprep = ipoRpt.TranListE.Where(a => a["mod_field"].ToString() == "mod_aprep");
            string mod_aprep = "";
            foreach (var r in aprep) {
                mod_aprep += "\n商標法" + r["ncname1"].ToString();
                if (r["new_no"].ToString() != "")
                    mod_aprep += "\n註冊第" + r["new_no"].ToString() + "號";
            }
            ipoRpt.ReplaceBookmark("mod_aprep", mod_aprep);
            
            ipoRpt.CopyBlock("b_content");
            using (DataTable dtTran = ipoRpt.Tran) {
                if (dtTran.Rows.Count > 0) {
                    //具利害關係人身分之事實及理由
                    ipoRpt.ReplaceBookmark("tran_remark3", dtTran.Rows[0]["tran_remark3"].ToString());
                    //註冊已滿3年之使用情形說明
                    ipoRpt.ReplaceBookmark("tran_remark4", dtTran.Rows[0]["tran_remark4"].ToString());
                    //事實及理由
                    ipoRpt.ReplaceBookmark("tran_remark1", dtTran.Rows[0]["tran_remark1"].ToString());
                    //相關聯案件
                    string[] oitem = dtTran.Rows[0]["other_item"].ToString().Trim().Split(';');
                    if(oitem.Length>0){
                        DateTime dateValue;
                        if (DateTime.TryParse(oitem[0].ToString(), out dateValue)){
                            ipoRpt.ReplaceBookmark("O1", dateValue.ToLongTwDate().Replace("民國",""));
                        }
			        }
			        if (oitem.Length>1) ipoRpt.ReplaceBookmark("O1", oitem[1].ToString());
			        if (oitem.Length>2) ipoRpt.ReplaceBookmark("O2", oitem[2].ToString());
                }
            }

			//繳費資訊
			ipoRpt.CreateFees();
            
			//附送書件
            //ipoRpt.CreateAttach();
            List<AttachMapping> mapList = new List<AttachMapping>();
            string remark1 = ipoRpt.Dmt.Rows[0]["remark1"].ToString();//文件勾選值
            mapList.Add(new AttachMapping { mapValue = "*", docType = "02" });//委任書(*表必備文件)
            mapList.Add(new AttachMapping { mapValue = "*", docType = "17" });//基本資料表(*表必備文件)
            ipoRpt.CreateAttach(mapList);
            
            //具結
			ipoRpt.CopyBlock("b_sign");

            //評定標的圖樣
            ipoRpt.CopyBlock("b_view1");
            if (dmt.Rows[0]["draw_file"].ToString() != "") {
                try {
                    ipoRpt.AppendImage(new ImageFile(Server.MapPath(dmt.Rows[0]["draw_file"].ToString())));
                }
                catch (FileNotFoundException) {
                    ipoRpt.AddParagraph();
                    ipoRpt.AddText("找不到檔案(" + dmt.Rows[0]["draw_file"].ToString() + ")！！", System.Drawing.Color.Red);
                    ipoRpt.AddParagraph();
                }
                catch (DirectoryNotFoundException) {
                    ipoRpt.AddParagraph();
                    ipoRpt.AddText("找不到路徑(" + dmt.Rows[0]["draw_file"].ToString() + ")！！", System.Drawing.Color.Red);
                    ipoRpt.AddParagraph();
                }
            }
            //據以評定商標或標章圖樣
            using (DataTable dtTran = ipoRpt.Tran) {
                if (dtTran.Rows.Count > 0 && dtTran.Rows[0]["mod_dmt"].ToString() == "Y") {
                    var mod_dmt = ipoRpt.TranListE.Where(a => a["mod_field"].ToString() == "mod_dmt");
                    foreach (var r in mod_dmt) {
                        //ncname1,ncname2,nename1,nename2,ncrep,nerep,neaddr1,neaddr2,neaddr3,neaddr4
                        string[] fileArr = { "ncname1", "ncname2", "nename1", "nename2", "ncrep", "nerep", "neaddr1", "neaddr2", "neaddr3", "neaddr4" };
                        foreach (string file in fileArr) {
                            if (!r.IsNull(file)) {
                                ipoRpt.CopyBlock("b_view2");
                                string drawPath = r[file].ToString();
                                try {
                                    if (drawPath.IndexOf(@"/btbrt/") == 0) {//『/btbrt/』開頭要換掉
                                        drawPath = "~/" + drawPath.Substring(7);
                                    } else if (drawPath.ToString().ToLower().IndexOf(@"d:\data\document\") == 0) {//『D:\Data\document\』開頭要換掉
                                        drawPath = "~/" + drawPath.Substring(17).Replace("\\", "/");
                                    }
                                    ipoRpt.AppendImage(new ImageFile(Server.MapPath(drawPath)));
                                }
                                catch (FileNotFoundException) {
                                    ipoRpt.AddParagraph();
                                    ipoRpt.AddText("找不到檔案[" + file + "](" + drawPath + ")！！", System.Drawing.Color.Red);
                                    ipoRpt.AddParagraph();
                                }
                                catch (DirectoryNotFoundException) {
                                    ipoRpt.AddParagraph();
                                    ipoRpt.AddText("找不到路徑[" + file + "](" + Server.MapPath(drawPath) + ")！！", System.Drawing.Color.Red);
                                    ipoRpt.AddParagraph();
                                }
                            }
                        }
                    }
                }
            }
            
			bool baseflag = true;//是否產生基本資料表
			ipoRpt.CopyPageFoot("apply", baseflag);//申請書頁尾
			if (baseflag) {
				ipoRpt.AppendBaseData("base");//產生基本資料表
			}
		}
		ipoRpt.Flush(docFileName);
		ipoRpt.SetPrint();
	}
</script>
