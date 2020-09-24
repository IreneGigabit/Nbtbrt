using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Web;

/// <summary>
/// 產生智慧局電子申請書用
/// </summary>
public class IPOReport : OpenXmlHelper {
	private string _connStr = null;
	private string _in_no = "";
	private string _in_scode = "";
	private string _case_sqlno = "";
	private DBHelper _conn = null;

	private string _seq = "";
	private string _sound = "";
	private string _movie = "";
	private DataTable _dtDmt = null;
	private DataTable _dtApcust = null;
	private DataTable _dtAgt = null;
	private DataTable _dtAnt = null;
	private DataTable _dtShow = null;
	private DataTable _dtGoods = null;
	private DataTable _dtAttach = null;
	private DataTable _dtTran = null;
	private DataTable _dtTranList = null;
	private DataTable _dtTranListClass = null;

	/// <summary>
	/// 報表代碼
	/// </summary>
	public string ReportCode { get; set; }

	/// <summary>
	/// 是否有收據抬頭
	/// </summary>
	public string RectitleFlag { get; set; }

	/// <summary>
	/// 收據抬頭種類→A:案件申請人/B:空白/C:案件申請人(代繳人)
	/// </summary>
	public string RectitleTitle { get; set; }

	/// <summary>
	/// 收據抬頭名稱
	/// </summary>
	public string RectitleName { get; set; }

	/// <summary>
	/// 基本資料表的申請人Tag值,若未指定則預設為【申請人】
	/// </summary>
	public string BaseRptAPTag { get; set; }

	/// <summary>
	/// 基本資料表的關係人Tag值
	/// </summary>
	public string BaseRptModTag { get; set; }

	/// <summary>
	/// 組合後的本所編號
	/// </summary>
	public string Seq {
		get { return _seq; }
		protected set { _seq = value; }
	}

	/// <summary>
	/// 案件資料
	/// </summary>
	public DataTable Dmt {
		get { return _dtDmt; }
		protected set { _dtDmt = value; }
	}

	/// <summary>
	/// 申請人資料
	/// </summary>
	public DataTable Apcust {
		get { return _dtApcust; }
		protected set { _dtApcust = value; }
	}

	/// <summary>
	/// 聲音檔
	/// </summary>
	public string Sound {
		get { return _sound; }
		protected set { _sound = value; }
	}

	/// <summary>
	/// 影像檔
	/// </summary>
	public string Movie {
		get { return _movie; }
		protected set { _movie = value; }
	}

	/// <summary>
	/// 代理人資料
	/// </summary>
	public DataTable Agent {
		get { return _dtAgt; }
		protected set { _dtAgt = value; }
	}

	/// <summary>
	/// 主張展覽會優先權資料
	/// </summary>
	public DataTable Show {
		get { return _dtShow; }
		protected set { _dtShow = value; }
	}

	/// <summary>
	/// 商品服務類別資料
	/// </summary>
	public DataTable Goods {
		get { return _dtGoods; }
		protected set { _dtGoods = value; }
	}

	/// <summary>
	/// 附送書件
	/// </summary>
	public DataTable Attach {
		get { return _dtAttach; }
		protected set { _dtAttach = value; }
	}

	/// <summary>
	/// 異動資料
	/// </summary>
	public DataTable Tran {
		get { return _dtTran; }
		protected set { _dtTran = value; }
	}

	/// <summary>
	/// 異動明細資料
	/// </summary>
	public DataTable TranList {
		get { return _dtTranList; }
		protected set { _dtTranList = value; }
	}

	/// <summary>
	/// 異動類別明細資料
	/// </summary>
	public DataTable TranListClass {
		get { return _dtTranListClass; }
		protected set { _dtTranListClass = value; }
	}

	/// <summary>
	/// 異動關係人
	/// </summary>
	public DataTable TranListAP { get; set; }

	/// <summary>
	/// 異動檔
	/// </summary>
	public EnumerableRowCollection<DataRow> TranListE { get; set; }

	/// <summary>
	/// 申請人身分類別對應
	/// </summary>
	public Dictionary<string, string> AP_marknm { get; set; }

	public IPOReport() {

	}

	public IPOReport(string connStr, string in_scode, string in_no, string case_sqlno) {
		this._connStr = connStr;
		this._in_no = in_no;
		this._in_scode = in_scode;
		this._case_sqlno = case_sqlno;
		this._conn = new DBHelper(connStr, false).Debug(false);

		this._dtDmt = new DataTable();
		string SQL = "SELECT a.* ";
		SQL += ",c.fees,c.arcase,c.div_arcase,c.cust_area,t.tran_remark1,c.tot_num,c.send_way,c.receipt_type,c.receipt_title ";
		SQL += ",(SELECT b.coun_c FROM sysctrl.dbo.country b WHERE b.coun_code = a.zname_type and b.markb<>'X') AS nzname ";
		SQL += ",(SELECT c.coun_code+c.coun_cname FROM sysctrl.dbo.ipo_country c WHERE c.ref_coun_code = a.prior_country ) AS ncountry ";
		SQL += ",''colornm,''s_marknm ";
		SQL += " FROM dmt_temp A";
		SQL += " inner join case_dmt c on a.in_no = c.in_no and a.in_scode = c.in_scode";
		SQL += " left join dmt_tran t on a.in_no = t.in_no and a.in_scode = t.in_scode";
		SQL += " WHERE A.in_no ='" + _in_no + "' and a.in_scode='" + _in_scode + "'";
		SQL += " and case_sqlno=" + (_case_sqlno == "" ? "0" : _case_sqlno) + " ";
		_conn.DataTable(SQL, _dtDmt);//抓案件資料

		string drawPath = _dtDmt.Rows[0]["draw_file"].ToString();
		if (_dtDmt.Rows[0]["draw_file"].ToString().IndexOf(@"/btbrt/") == 0) {//『/btbrt/』開頭要換掉
			_dtDmt.Rows[0]["draw_file"] = "~/"+drawPath.Substring(7);
		} else if (_dtDmt.Rows[0]["draw_file"].ToString().ToLower().IndexOf(@"d:\data\document\") == 0) {//『D:\Data\document\』開頭要換掉
			_dtDmt.Rows[0]["draw_file"] = "~/" + drawPath.Substring(17).Replace("\\","/");
		}

		//商標顏色
		if (_dtDmt.Rows[0]["color"].ToString()=="C" ||_dtDmt.Rows[0]["color"].ToString()=="M"){
			_dtDmt.Rows[0]["colornm"]="彩色";
		} else if (_dtDmt.Rows[0]["color"].ToString() == "B") {
			_dtDmt.Rows[0]["colornm"] = "墨色";
		}

		//商標或標章種類
		if (_dtDmt.Rows[0]["s_mark"].ToString().Trim() == "S") {
			_dtDmt.Rows[0]["s_marknm"] = "商標(92年修正前服務標章)";
		} else if (_dtDmt.Rows[0]["s_mark"].ToString().Trim() == "N") {
			_dtDmt.Rows[0]["s_marknm"] = "團體商標";
		} else if (_dtDmt.Rows[0]["s_mark"].ToString().Trim() == "M") {
			_dtDmt.Rows[0]["s_marknm"] = "團體標章";
		} else if (_dtDmt.Rows[0]["s_mark"].ToString().Trim() == "L") {
			_dtDmt.Rows[0]["s_marknm"] = "證明標章";
		} else {
			_dtDmt.Rows[0]["s_marknm"] = "商標";
		}

		SetSeq();//組案件編號
		SetSound();//抓聲音檔
		SetMovie();//抓影像檔
		SetApcust();//抓申請人
		SetAgent();//抓代理人
		SetShow();//抓主張展覽會優先權
		SetGoods();//抓商品服務類別
		SetAttach();//抓附送書件
		SetTran();//抓異動資料
		SetModAP();//抓關係人

		_dtDmt.ShowTable();
		_dtTran.ShowTable();
	}

	#region 關閉 +void Close()
	/// <summary>
	/// 關閉
	/// </summary>
	public void Close() {
		if (_conn != null) _conn.Dispose();
		this.Dispose();
	}
	#endregion

	#region 組本所編號 -void SetSeq()
	/// <summary>
	/// 組本所編號
	/// </summary>
	private void SetSeq() {
		string lseq = _dtDmt.Rows[0]["cust_area"].ToString() + "T" + _dtDmt.Rows[0]["seq"];
		if (_dtDmt.Rows[0]["seq1"].ToString() != "_") {
			lseq += "-" + _dtDmt.Rows[0]["seq1"];
		}
		this.Seq = lseq;
	}
	#endregion

	#region 抓聲音檔 -void SetSound()
	/// <summary>
	/// 抓聲音檔
	/// </summary>
	private void SetSound() {
		string SQL = "select b.source_name ";
		SQL += " from attcase_dmt a ";
		SQL += " inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' and b.doc_type='E19' ";	//抓取電子送件且為doc_type=E19聲音檔
		SQL += " where a.sign_stat='NN' and a.in_no='" + _in_no + "' ";
		DataTable dt = new DataTable();
		_conn.DataTable(SQL, dt);

		this.Sound = "";
		if (dt.Rows.Count != 0) {
			this.Sound = dt.Rows[0]["source_name"].ToString().Trim();
		}
	}
	#endregion

	#region 抓影像檔 -void SetMovie()
	/// <summary>
	/// 抓影像檔
	/// </summary>
	private void SetMovie() {
		string SQL = "select b.source_name ";
		SQL += " from attcase_dmt a ";
		SQL += " inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' and b.doc_type='E20' ";	//抓取電子送件且為doc_type=E20影像檔
		SQL += " where a.sign_stat='NN' and a.in_no='" + _in_no + "' ";
		DataTable dt = new DataTable();
		_conn.DataTable(SQL, dt);

		this.Movie = "";
		if (dt.Rows.Count != 0) {
			this.Movie = dt.Rows[0]["source_name"].ToString().Trim();
		}
	}
	#endregion

	#region 抓申請人 -void SetApcust()
	/// <summary>
	/// 抓申請人
	/// </summary>
	private void SetApcust() {
		string SQL = "SELECT a.*,b.ap_country,b.apcust_no,b.apclass,b.ap_crep,b.ap_erep ";
		SQL += ",b.ap_zip as ap_ap_zip,b.ap_addr1 as ap_ap_addr1,b.ap_addr2 as ap_ap_addr2 ";
		SQL += ",b.ap_eaddr1 as ap_ap_eaddr1,b.ap_eaddr2 as ap_ap_eaddr2,b.ap_eaddr3 as ap_ap_eaddr3,b.ap_eaddr4 as ap_ap_eaddr4 ";
		SQL += ",(SELECT c.coun_code+c.coun_cname FROM sysctrl.dbo.ipo_country c WHERE c.ref_coun_code = b.ap_country ) AS apcountry ";
		SQL += ",b.ap_cname1 ap_ap_cname1,b.ap_cname2 ap_ap_cname2,b.ap_ename1 ap_apename1,b.ap_ename2 ap_ap_ename2 ";
		SQL += ",b.ap_fcname ap_ap_fcname,b.ap_lcname ap_ap_lcname,b.ap_fename ap_ap_fename,b.ap_lename ap_ap_lename ";
		SQL += ",''apclass_name,''Country_name,''Title_cname,''Cname_string,''Title_ename,''Ename_string ";
		SQL += ",''c_id,''c_zip,''c_addr,''e_addr ";
		SQL += " FROM dmt_temp_ap a";
		SQL += " INNER JOIN apcust b ON a.apsqlno=b.apsqlno";
		SQL += " WHERE a.in_no = '" + _in_no + "' ";
		SQL += " and a.case_sqlno=" + (_case_sqlno == "" ? "0" : _case_sqlno) + " ";
		SQL += " order by a.server_flag desc,a.temp_ap_sqlno ";
		DataTable dt = new DataTable();
		_conn.DataTable(SQL, dt);

		for (int i = 0; i < dt.Rows.Count; i++) {
			string PersonCname = (dt.Rows[i]["ap_fcname"].ToString().Trim() + "," + dt.Rows[i]["ap_lcname"].ToString().Trim()).Replace("’", "'");
			string PersonEname = (dt.Rows[i]["ap_fename"].ToString().Trim() + "," + dt.Rows[i]["ap_lename"].ToString().Trim()).Replace("’", "'");
			string CompanyCname = (dt.Rows[i]["ap_cname1"].ToString().Trim() + dt.Rows[i]["ap_cname2"].ToString().Trim()).Replace("’", "'");
			string CompanyEname = (dt.Rows[i]["ap_ename1"].ToString().Trim() + dt.Rows[i]["ap_ename2"].ToString().Trim()).Replace("’", "'");
			//AA：本國公司機關無統編者
			if (dt.Rows[i]["apclass"].ToString().Trim() == "AA") {
				dt.Rows[i]["apclass_name"] = "法人公司機關學校";
				dt.Rows[i]["c_id"] = "S999999999";
				dt.Rows[i]["Title_cname"] = "中文名稱";
				dt.Rows[i]["Title_ename"] = "英文名稱";
				dt.Rows[i]["Cname_string"] = CompanyCname;
				dt.Rows[i]["Ename_string"] = CompanyEname;
			}
			//外國人/公司增加判斷-若有填寫申請人姓&名,則顯示姓名
			//CA：外國人(尚無智局給的ID)
			//CB：外國人(已有智局給的ID 10碼)
			//CT：外國人(已有國外所給的ID 6碼X99999)
			else if (dt.Rows[i]["apclass"].ToString().Left(1) == "C") {
				if (PersonCname == ",") {
					dt.Rows[i]["apclass_name"] = "法人公司機關學校";
					dt.Rows[i]["Title_cname"] = "中文名稱";
					dt.Rows[i]["Title_ename"] = "英文名稱";
					dt.Rows[i]["Cname_string"] = CompanyCname;
					dt.Rows[i]["Ename_string"] = CompanyEname;
				} else {
					dt.Rows[i]["apclass_name"] = "自然人";
					dt.Rows[i]["Title_cname"] = "中文姓名";
					dt.Rows[i]["Title_ename"] = "英文姓名";
					dt.Rows[i]["Cname_string"] = PersonCname;
					dt.Rows[i]["Ename_string"] = (PersonEname == "," ? "" : PersonEname);
				}
			}
			//AD：行號/工廠
			else if (dt.Rows[i]["apclass"].ToString().Trim() == "AD") {
				dt.Rows[i]["apclass_name"] = "商號行號工廠";
				dt.Rows[i]["c_id"] = dt.Rows[i]["apcust_no"].ToString().Trim().Left(8);
				dt.Rows[i]["Title_cname"] = "中文名稱";
				dt.Rows[i]["Title_ename"] = "英文名稱";
				dt.Rows[i]["Cname_string"] = CompanyCname;
				dt.Rows[i]["Ename_string"] = CompanyEname;
			}
			//B：本國人(身份證10碼)
			else if (dt.Rows[i]["apclass"].ToString().Trim() == "B") {
				dt.Rows[i]["apclass_name"] = "自然人";
				dt.Rows[i]["c_id"] = dt.Rows[i]["apcust_no"].ToString().Trim();
				dt.Rows[i]["Title_cname"] = "中文姓名";
				dt.Rows[i]["Title_ename"] = "英文姓名";
				dt.Rows[i]["Cname_string"] = PersonCname;
				dt.Rows[i]["Ename_string"] = (PersonEname == "," ? "" : PersonEname);
			}else {
				dt.Rows[i]["apclass_name"] = "法人公司機關學校";
				dt.Rows[i]["c_id"] = dt.Rows[i]["apcust_no"].ToString().Trim();
				dt.Rows[i]["Title_cname"] = "中文名稱";
				dt.Rows[i]["Title_ename"] = "英文名稱";
				dt.Rows[i]["Cname_string"] = CompanyCname;
				dt.Rows[i]["Ename_string"] = CompanyEname;
			}

			dt.Rows[i]["Country_name"] = dt.Rows[i]["apcountry"].ToString().Trim();
			//2011/2/8因應申請人序號修改，地址改抓取交辦申請人檔，但若無申請人序號且無中文地址則抓取申請人主檔資料
			dt.Rows[i]["c_zip"] = dt.Rows[i]["ap_zip"].ToString().Trim();
			dt.Rows[i]["c_addr"] = (dt.Rows[i]["ap_addr1"].ToString().Trim() + dt.Rows[i]["ap_addr2"].ToString().Trim()).Replace("’", "'");
			dt.Rows[i]["e_addr"] = dt.Rows[i]["ap_eaddr1"].ToString().Trim() +
									dt.Rows[i]["ap_eaddr2"].ToString().Trim() +
									dt.Rows[i]["ap_eaddr3"].ToString().Trim() +
									dt.Rows[i]["ap_eaddr4"].ToString().Trim();

			if (dt.Rows[i]["ap_sql"].ToString().Trim() == "" && dt.Rows[i]["c_addr"].ToString() == "") {
				dt.Rows[i]["c_zip"] = dt.Rows[i]["ap_ap_zip"].ToString().Trim();
				dt.Rows[i]["c_addr"] = (dt.Rows[i]["ap_ap_addr1"].ToString().Trim() + dt.Rows[i]["ap_ap_addr2"].ToString().Trim()).Replace("’", "'");
				dt.Rows[i]["e_addr"] = dt.Rows[i]["ap_ap_eaddr1"].ToString().Trim() +
										dt.Rows[i]["ap_ap_eaddr2"].ToString().Trim() +
										dt.Rows[i]["ap_ap_eaddr3"].ToString().Trim() +
										dt.Rows[i]["ap_ap_eaddr4"].ToString().Trim();
			}
			//國籍是台灣才要郵遞區號
			if (dt.Rows[i]["ap_country"].ToString().Trim() != "T")
				dt.Rows[i]["c_zip"] = "";
		}
		this.Apcust = dt;
	}
	#endregion

	#region 抓代理人 -void SetAgent()
	/// <summary>
	/// 抓代理人
	/// </summary>
	private void SetAgent() {
		string SQL = "SELECT a.agt_no,b.*,''s_agatt_tel,''s_agatt_fax ";
		SQL += " FROM dmt_temp a";
		SQL += " inner join agt b on a.agt_no=b.agt_no ";
		SQL += " WHERE a.in_no = '" +_in_no + "'";
		SQL += " and a.case_sqlno=" + (_case_sqlno == "" ? "0" : _case_sqlno) + " ";
		SQL += " and a.agt_no not in('YYYY','XXXX') ";
		DataTable dt = new DataTable();
		_conn.DataTable(SQL, dt);

		if (dt.Rows.Count != 0) {
			string s_agatt_tel = "";
			if (dt.Rows[0]["agatt_tel0"].ToString().Trim() != "") s_agatt_tel += dt.Rows[0]["agatt_tel0"].ToString().Trim();
			if (dt.Rows[0]["agatt_tel"].ToString().Trim() != "") s_agatt_tel += "-"+dt.Rows[0]["agatt_tel"].ToString().Trim();
			if (dt.Rows[0]["agatt_tel1"].ToString().Trim() != "") s_agatt_tel += "#" + dt.Rows[0]["agatt_tel1"].ToString().Trim();
			dt.Rows[0]["s_agatt_tel"] = s_agatt_tel;

			string s_agatt_fax = "";
			if (dt.Rows[0]["agatt_tel0"].ToString().Trim() != "") s_agatt_fax += dt.Rows[0]["agatt_tel0"].ToString().Trim();
			if (dt.Rows[0]["agatt_fax"].ToString().Trim() != "") s_agatt_fax += "-" + dt.Rows[0]["agatt_fax"].ToString().Trim();
			dt.Rows[0]["s_agatt_fax"] = s_agatt_fax;

			dt.Rows[0]["agt_name1"] = dt.Rows[0]["agt_name1"].ToString().Trim().Left(1) + "," + dt.Rows[0]["agt_name1"].ToString().Trim().Substring(1);
			dt.Rows[0]["agt_name2"] = dt.Rows[0]["agt_name2"].ToString().Trim().Left(1) + "," + dt.Rows[0]["agt_name2"].ToString().Trim().Substring(1);
		}

		this.Agent = dt;
	}
	#endregion

	#region 抓主張展覽會優先權資料 -void SetShow()
	/// <summary>
	/// 抓主張展覽會優先權資料
	/// </summary>
	private void SetShow() {
		string SQL = "select a.* from casedmt_show a ";
		SQL+=" where a.in_no='" + _in_no + "'";
		SQL += " and a.case_sqlno=" + (_case_sqlno == "" ? "0" : _case_sqlno) + " ";

		DataTable dt = new DataTable();
		_conn.DataTable(SQL, dt);
		this.Show = dt;
	}
	#endregion

	#region 抓商品服務類別資料 -void SetGoods()
	/// <summary>
	/// 抓商品服務類別資料
	/// </summary>
	private void SetGoods() {
		string SQL = "select *,''pclass from casedmt_good ";
		SQL += " where in_no = '" + _in_no + "' and in_scode='"+ _in_scode +"' ";
		SQL += " and case_sqlno=" + (_case_sqlno == "" ? "0" : _case_sqlno) + " ";
		SQL += " order by cast(class as int)";
		DataTable dt = new DataTable();
		_conn.DataTable(SQL, dt);
		for (int i = 0; i < dt.Rows.Count; i++) {
			string pclass = dt.Rows[i]["class"].ToString().Trim();
			if (pclass.Length >= 3) pclass = pclass.Substring(1);
			dt.Rows[i]["pclass"] = pclass;
		}
		this.Goods = dt;
	}
	#endregion

	#region 抓附送書件資料 -void SetAttach()
	/// <summary>
	/// 抓附送書件資料
	/// </summary>
	private void SetAttach() {
		string SQL = "select a.att_sqlno,b.doc_type,c.code_name as doc_typenm,b.attach_desc,b.source_name ";
		SQL += ",case when b.doc_type='99' then 99 else 0 end sort ";
		SQL += " from attcase_dmt a ";
		SQL += " inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' ";//抓取電子送件
		SQL += " inner join cust_code c on c.code_type='tdoc' and c.cust_code=b.doc_type and c.ref_code='Eattach' ";//抓取可顯示於附件書件之文件種類
		SQL += " where a.sign_stat='NN' and a.in_no='" + _in_no + "' ";
		SQL += " order by sort,charindex(','+c.code_name+',',',委任書,基本資料表,') desc,doc_type";

		DataTable dt = new DataTable();
		_conn.DataTable(SQL, dt);
		this.Attach = dt;
	}
	#endregion

	#region 抓異動資料 -void SetTran()
	/// <summary>
	/// 抓異動資料
	/// </summary>
	private void SetTran() {
		string SQL = "select * from dmt_tran " +
		"where in_no = '" + _in_no + "' and in_scode='" + _in_scode + "'";
		DataTable dt = new DataTable();
		_conn.DataTable(SQL, dt);
		this.Tran = dt;

		SQL = "select ncname1,(ncname1+isnull(ncname2,'')) as cname from dmt_tranlist " +
		"where in_no = '" + _in_no + "' and in_scode='" + _in_scode + "' and mod_field='mod_dmt'";
		DataTable dt1 = new DataTable();
		_conn.DataTable(SQL, dt1);
		this.TranList = dt1;

		SQL = "select * from dmt_tranlist " +
		"where in_no = '" + _in_no + "' and in_scode='" + _in_scode + "' and mod_field='mod_class'";
		DataTable dt2 = new DataTable();
		_conn.DataTable(SQL, dt2);
		this.TranListClass = dt2;

		SQL = "select * from dmt_tranlist " +
		"where in_no = '" + _in_no + "' and in_scode='" + _in_scode + "'";
		DataTable dt3 = new DataTable();
		_conn.DataTable(SQL, dt3);
		this.TranListE = dt3.AsEnumerable();

		/*
			//移轉關係人
			SQL = "select old_no,(isnull(ocname1,'')+isnull(ocname2,'')) as ocname " +
			",(isnull(oename1,'')+' '+isnull(oename2,'')) as oename,oapclass " +
			",''Title_cname,''Title_ename " +
			" from dmt_tranlist where in_scode='" + _in_scode + "' and in_no='" + _in_no + "' " +
			" and mod_field='mod_ap'";
			DataTable dt2 = new DataTable();
			_conn.DataTable(SQL, dt2);
			for (int i = 0; i < dt2.Rows.Count; i++) {
				if (dt2.Rows[i].SafeRead("Title_cname", "") == "B") {
					dt2.Rows[i]["Title_cname"] = "中文姓名";
					dt2.Rows[i]["Title_ename"] = "英文姓名";
				} else {
					dt2.Rows[i]["Title_cname"] = "中文名稱";
					dt2.Rows[i]["Title_ename"] = "英文名稱";
				}
			}
			this.TranListAP = dt2;
			 * */
	}
	#endregion

	#region 抓關係人 -void SetModAP()
	/// <summary>
	/// 抓關係人
	/// </summary>
	private void SetModAP() {
		string SQL = "Select a.* ";
		SQL += ",(SELECT c.coun_code+c.coun_cname FROM sysctrl.dbo.ipo_country c WHERE c.ref_coun_code = a.oap_country ) AS oapcountry "; 
		SQL += ",''oapclass_name,''Country_name,''Title_cname,''Cname_string,''Title_ename,''Ename_string ";
		SQL += ",''o_id,''o_zip,''c_addr,''e_addr ";
		SQL += "from dmt_tranlist a ";
		SQL += "where mod_field='mod_ap' ";
		SQL += "and in_no ='" + _in_no + "' and in_scode='" + _in_scode + "' ";
		DataTable dt = new DataTable();
		_conn.DataTable(SQL, dt);

		for (int i = 0; i < dt.Rows.Count; i++) {
			string PersonCname = (dt.Rows[i]["ocname1"].ToString().Trim() + "," + dt.Rows[i]["ocname2"].ToString().Trim()).Replace("’", "'");
			string PersonEname = (dt.Rows[i]["oename1"].ToString().Trim() + "," + dt.Rows[i]["oename2"].ToString().Trim()).Replace("’", "'");
			string CompanyCname = (dt.Rows[i]["ocname1"].ToString().Trim() + dt.Rows[i]["ocname2"].ToString().Trim()).Replace("’", "'");
			string CompanyEname = (dt.Rows[i]["oename1"].ToString().Trim() + dt.Rows[i]["oename2"].ToString().Trim()).Replace("’", "'");
			//AA：本國公司機關無統編者
			if (dt.Rows[i]["oapclass"].ToString().Trim() == "AA") {
				dt.Rows[i]["oapclass_name"] = "法人公司機關學校";
				dt.Rows[i]["o_id"] = "S999999999";
				dt.Rows[i]["Title_cname"] = "中文名稱";
				dt.Rows[i]["Title_ename"] = "英文名稱";
				dt.Rows[i]["Cname_string"] = CompanyCname;
				dt.Rows[i]["Ename_string"] = CompanyEname;
			}
				//外國人/公司增加判斷-若有填寫申請人姓&名,則顯示姓名
				//CA：外國人(尚無智局給的ID)
				//CB：外國人(已有智局給的ID 10碼)
				//CT：外國人(已有國外所給的ID 6碼X99999)
			else if (dt.Rows[i]["oapclass"].ToString().Left(1) == "C") {
				if (PersonCname == ",") {
					dt.Rows[i]["oapclass_name"] = "法人公司機關學校";
					dt.Rows[i]["Title_cname"] = "中文名稱";
					dt.Rows[i]["Title_ename"] = "英文名稱";
					dt.Rows[i]["Cname_string"] = CompanyCname;
					dt.Rows[i]["Ename_string"] = CompanyEname;
				} else {
					dt.Rows[i]["oapclass_name"] = "自然人";
					dt.Rows[i]["Title_cname"] = "中文姓名";
					dt.Rows[i]["Title_ename"] = "英文姓名";
					dt.Rows[i]["Cname_string"] = PersonCname;
					dt.Rows[i]["Ename_string"] = (PersonEname == "," ? "" : PersonEname);
				}
			}
				//AD：行號/工廠
			else if (dt.Rows[i]["oapclass"].ToString().Trim() == "AD") {
				dt.Rows[i]["oapclass_name"] = "商號行號工廠";
				dt.Rows[i]["o_id"] = dt.Rows[i]["old_no"].ToString().Trim().Left(8);
				dt.Rows[i]["Title_cname"] = "中文名稱";
				dt.Rows[i]["Title_ename"] = "英文名稱";
				dt.Rows[i]["Cname_string"] = CompanyCname;
				dt.Rows[i]["Ename_string"] = CompanyEname;
			}
				//B：本國人(身份證10碼)
			else if (dt.Rows[i]["oapclass"].ToString().Trim() == "B") {
				dt.Rows[i]["oapclass_name"] = "自然人";
				dt.Rows[i]["o_id"] = dt.Rows[i]["old_no"].ToString().Trim();
				dt.Rows[i]["Title_cname"] = "中文姓名";
				dt.Rows[i]["Title_ename"] = "英文姓名";
				dt.Rows[i]["Cname_string"] = PersonCname;
				dt.Rows[i]["Ename_string"] = (PersonEname == "," ? "" : PersonEname);
			} else {
				dt.Rows[i]["oapclass_name"] = "法人公司機關學校";
				dt.Rows[i]["o_id"] = dt.Rows[i]["old_no"].ToString().Trim();
				dt.Rows[i]["Title_cname"] = "中文名稱";
				dt.Rows[i]["Title_ename"] = "英文名稱";
				dt.Rows[i]["Cname_string"] = CompanyCname;
				dt.Rows[i]["Ename_string"] = CompanyEname;
			}

			dt.Rows[i]["Country_name"] = dt.Rows[i]["oapcountry"].ToString().Trim();
			dt.Rows[i]["o_zip"] = dt.Rows[i]["ozip"].ToString().Trim();
			dt.Rows[i]["c_addr"] = (dt.Rows[i]["oaddr1"].ToString().Trim() + dt.Rows[i]["oaddr2"].ToString().Trim()).Replace("’", "'");
			dt.Rows[i]["e_addr"] = dt.Rows[i]["oeaddr1"].ToString().Trim() +
									dt.Rows[i]["oeaddr2"].ToString().Trim() +
									dt.Rows[i]["oeaddr3"].ToString().Trim() +
									dt.Rows[i]["oeaddr4"].ToString().Trim();
			//國籍是台灣才要郵遞區號
			if (dt.Rows[i]["oap_country"].ToString().Trim() != "T")
				dt.Rows[i]["o_zip"] = "";
		}
		this.TranListAP = dt;
	}
	#endregion

	#region 產生繳費資訊區塊 +void CreateFees()
	/// <summary>
	/// 產生繳費資訊區塊
	/// </summary>
	public void CreateFees() {
		CopyBlock("b_fees");

		//20191230因申請書列印無相關request參數,直接抓case_dmt的值
		if (this.RectitleFlag == "") {
			this.RectitleTitle = Dmt.Rows[0].SafeRead("receipt_title", "B");//若db無值則為空白
			if (this.RectitleTitle != "B" && this.RectitleTitle != "") {
				this.RectitleFlag = "Y";
			} else {
				this.RectitleFlag = "N";
			}
		}
		//串申請人
		string RectitleNameStr = "";
		string SQL = "Select a.ap_cname from dmt_temp_ap a where a.in_no='" + _in_no + "' and a.case_sqlno=0 order by a.server_flag desc,a.temp_ap_sqlno";
		using (SqlDataReader dr = _conn.ExecuteReader(SQL)) {
			while (dr.Read()) {
				if (RectitleNameStr != "") RectitleNameStr += "、";
				RectitleNameStr += dr.GetString("ap_cname");
			}
		}

		if (this.RectitleTitle == "A") {//專利權人
			this.RectitleName = RectitleNameStr;
		} else if (this.RectitleTitle == "C") {//專利權人(代繳人)
			this.RectitleName = RectitleNameStr + "(代繳人：聖島國際專利商標聯合事務所)";
		} else {//空白
			this.RectitleName = "";
		}
		ReplaceBookmark("fees", Dmt.Rows[0]["fees"].ToString().Trim(), "0");
        ReplaceBookmark("receipt_name", this.RectitleName.ToXmlUnicode(), true);
	}
	#endregion

	#region 產生附送書件區塊 +void CreateAttach(List<string[]> br_value)
	/// <summary>
	/// 產生附送書件區塊
	/// </summary>
    /*
	public void CreateAttach(List<string[]> br_value) {
		CopyBlock("b_attach1");

		using (DataTable dtAttach = new DataTable()) {
			//先產生必備的附送書件tag
			string SQL = "";
			SQL = "select * from( ";
            SQL += "	select '1'src_type,c2.Cust_code,c2.Code_name as doc_typenm,c2.form_name,c.SortFld,c.form_name other_desc,c.mark1 other_source_name ";
			SQL += "	,case when c.Cust_code='99' then 99 else 0 end sort ";
			SQL += "	from Cust_code c ";
			SQL += "	join cust_code c2 on c2.Code_type='Tdoc' and c2.ref_code='Eattach' and c.cust_code=c2.cust_code ";
			SQL += "	where c.Code_type='erpt_" + this.ReportCode + "' and isnull(c.ref_code,'')='*' ";
			SQL += ")z ";
			SQL += "left join ( ";
			SQL += "	select b.source_name,b.attach_desc,b.doc_type ";
			SQL += "	from attcase_dmt a ";
			SQL += "	inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' ";//抓取電子送件
			SQL += "	inner join cust_code c on c.code_type='tdoc' and c.cust_code=b.doc_type and c.ref_code='Eattach' ";//抓取可顯示於附件書件之文件種類
			SQL += "	where a.sign_stat='NN' and a.in_no='" + _in_no + "' ";
			SQL += ")x on z.Cust_code=x.doc_type ";
			SQL += "order by z.SortFld";
			_conn.DataTable(SQL, dtAttach);

			//產生非必備的附送書件tag(對應交辦內容設定,交辦有勾則顯示不論有無上傳)
			if (br_value != null) {
				foreach (var v in br_value) {
					//交辦有勾則顯示不論有無上傳
					SQL = "select * from( ";
                    SQL += "	select '2'src_type,c2.Cust_code,c2.Code_name as doc_typenm,c2.form_name,c.SortFld,c.form_name other_desc,c.mark1 other_source_name ";
					SQL += "	from Cust_code c ";
					SQL += "	join cust_code c2 on c2.Code_type='Tdoc' and c2.ref_code='Eattach' and c.cust_code=c2.cust_code ";
					SQL += "	where c.Code_type='erpt_" + this.ReportCode + "' and isnull(c.ref_code,'')<>'*' ";
					//SQL += "	and charindex('|'+c.ref_code+'|','|'+'Z17|Z9-肖像或著名姓名之商標註冊同意書及申請人身分證影本-Z9|Z16|Z15|Z12|Z141|Z141C|')>0 ";
					SQL += "	and charindex('|'+c.ref_code+'|','|" + v[0] + "|')>0 ";
					if (v[1]!=null && v[1] != "") {
						SQL += "	and c.code_name='" + v[1] + "' ";
					}
					SQL += ")z ";
					SQL += "left join ( ";
					SQL += "	select b.source_name,b.attach_desc,b.doc_type ";
					SQL += "	,case when b.doc_type='99' then 99 else 0 end sort ";
					SQL += "	from attcase_dmt a ";
					SQL += "	inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' ";//抓取電子送件
					SQL += "	inner join cust_code c on c.code_type='tdoc' and c.cust_code=b.doc_type and c.ref_code='Eattach' ";//抓取可顯示於附件書件之文件種類
					SQL += "	where a.sign_stat='NN' and a.in_no='" + _in_no + "' ";
					SQL += ")x on z.Cust_code=x.doc_type ";
					SQL += "order by z.SortFld";
					_conn.DataTable(SQL, dtAttach);

					//交辦沒勾但有上傳
					SQL = "select * from( ";
                    SQL += "	select '3'src_type,c2.Cust_code,c2.Code_name as doc_typenm,c2.form_name,c.SortFld,c.form_name other_desc,c.mark1 other_source_name ";
					SQL += "	from Cust_code c ";
					SQL += "	join cust_code c2 on c2.Code_type='Tdoc' and c2.ref_code='Eattach' and c.cust_code=c2.cust_code ";
					SQL += "	where c.Code_type='erpt_" + this.ReportCode + "' and isnull(c.ref_code,'')<>'*' ";
					SQL += "	and charindex('|'+c.ref_code+'|','|" + v[0] + "|')=0 ";
					if (v[1] != null && v[1] != "") {
                        SQL += "	and c.code_name='" + v[1] + "' ";
					}
					SQL += ")z ";
					SQL += "inner join ( ";
					SQL += "	select b.source_name,b.attach_desc,b.doc_type ";
					SQL += "	,case when b.doc_type='99' then 99 else 0 end sort ";
					SQL += "	from attcase_dmt a ";
					SQL += "	inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' ";//抓取電子送件
					SQL += "	inner join cust_code c on c.code_type='tdoc' and c.cust_code=b.doc_type and c.ref_code='Eattach' ";//抓取可顯示於附件書件之文件種類
					SQL += "	where a.sign_stat='NN' and a.in_no='" + _in_no + "' ";
					SQL += ")x on z.Cust_code=x.doc_type ";
					SQL += "order by z.SortFld";
					_conn.DataTable(SQL, dtAttach);
				}
			}

			//不在cust_code設定的附件tag
			SQL = "select '4'src_type,c.Cust_code,b.doc_type,c.code_name as doc_typenm,b.attach_desc,b.source_name,c.SortFld ";
			SQL += ",case when b.doc_type='99' then 99 else 0 end sort ";
			SQL += "from attcase_dmt a ";
			SQL += "inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' ";//抓取電子送件
			SQL += "inner join cust_code c on c.code_type='tdoc' and c.cust_code=b.doc_type and c.ref_code='Eattach' ";//抓取可顯示於附件書件之文件種類
			SQL += "where a.sign_stat='NN' and a.in_no='" + _in_no + "' ";
			SQL += "and not exists( ";
			SQL += "	select c2.cust_code ";
			SQL += "	from Cust_code c1 ";
			SQL += "	join cust_code c2 on c2.Code_type='Tdoc' and c2.ref_code='Eattach' and c1.cust_code=c2.cust_code ";
			SQL += "	where c1.Code_type='erpt_" + this.ReportCode + "' and b.doc_type=c2.cust_code ";
			SQL += "	and isnull(c1.ref_code,'')" + (br_value != null ? "<>''" : "='*'") + " ";
			SQL += ") ";
			SQL += "order by sort";
			_conn.DataTable(SQL, dtAttach);

			dtAttach.ShowTable();
			if (dtAttach.Rows.Count != 0) {
				for (int i = 0; i < dtAttach.Rows.Count; i++) {
					if (dtAttach.Rows[i]["Cust_code"].ToString() != "99") {
						CopyBlock("b_attach3");
						string filename = dtAttach.Rows[i]["form_name"].ToString();
						if (dtAttach.Rows[i]["source_name"].ToString() != "") {
							filename = dtAttach.Rows[i]["source_name"].ToString();
						}
						string doc_typenm = dtAttach.Rows[i]["doc_typenm"].ToString().Trim();
						ReplaceBookmark("doc_typenm", doc_typenm);
						int padCount = (doc_typenm.Length > 11) ? 0 : 11 - doc_typenm.Length;
						ReplaceBookmark("source_name", new string('　', padCount) + filename);//補齊全型空白
					} else {
						CopyBlock("b_attach4");
                        //描述
						string oth_desc = dtAttach.Rows[i]["other_desc"].ToString();
						if (dtAttach.Rows[i]["attach_desc"].ToString() != "") {
							oth_desc = dtAttach.Rows[i]["attach_desc"].ToString();
						}
                        //檔名
                        string source_name = dtAttach.Rows[i]["other_source_name"].ToString();
                        if (dtAttach.Rows[i]["source_name"].ToString() != "") {
                            source_name = dtAttach.Rows[i]["source_name"].ToString();
                        }
                        ReplaceBookmark("oth_attach_desc", oth_desc);
                        ReplaceBookmark("oth_source_name", source_name);
					}
				}
			}
		}
		AddParagraph();
	}
    */
    #endregion

    #region 產生附送書件區塊 +void CreateAttach(List<AttachMapping> brMap) {
    /// <summary>
    /// 產生附送書件區塊
    /// </summary>
    public void CreateAttach(List<AttachMapping> brMap) {
        CopyBlock("b_attach1");
        using (DataTable dtAttach = new DataTable()) {
            string exclude = "";
            string SQL = "";
            for (int y = 0; y < brMap.Count; y++) {
                //必備的附送書件
                if (brMap[y].mapValue == "*") {
                    exclude += "," + brMap[y].docType;
                    SQL = "select * from( ";
                    SQL += "	select '1'src_type,c2.cust_code,c2.Code_name as doc_typenm,c2.form_name ";
                    SQL += "	from Cust_code c2 ";
                    SQL += "	where c2.Code_type='Tdoc' and c2.ref_code='Eattach' and c2.cust_code='" + brMap[y].docType + "' ";
                    SQL += ")z ";
                    SQL += "left join ( ";
                    SQL += "	select b.source_name,b.attach_desc,b.doc_type ";
                    SQL += "	from attcase_dmt a ";
                    SQL += "	inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' ";//抓取電子送件
                    SQL += "	inner join cust_code c on c.code_type='tdoc' and c.cust_code=b.doc_type and c.ref_code='Eattach' ";//抓取可顯示於附件書件之文件種類
                    SQL += "	where a.sign_stat='NN' and a.in_no='" + _in_no + "' and b.doc_type='" + brMap[y].docType + "' ";
                    SQL += ")x on z.cust_code=x.doc_type ";
                    _conn.DataTable(SQL, dtAttach);
                } else {
                    //有對應交辦欄位,且有勾選,則顯示不論有無上傳
                    string whereSQL = "	and 1=0 ";
                    if (("|" + brMap[y].brColValue + "|").IndexOf("|" + brMap[y].mapValue + "|") > -1) {
                        whereSQL = "	and 1=1 ";
                        exclude += "," + brMap[y].docType;
                    }
                    SQL = "select * from( ";
                    SQL += "	select '2'src_type,c2.cust_code,c2.Code_name as doc_typenm,c2.form_name ";
                    SQL += "	from Cust_code c2 ";
                    SQL += "	where c2.Code_type='Tdoc' and c2.ref_code='Eattach' and c2.cust_code='" + brMap[y].docType + "' " + whereSQL;
                    SQL += ")z ";
                    SQL += "left join ( ";
                    SQL += "	select b.source_name,b.attach_desc,b.doc_type ";
                    SQL += "	from attcase_dmt a ";
                    SQL += "	inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' ";//抓取電子送件
                    SQL += "	inner join cust_code c on c.code_type='tdoc' and c.cust_code=b.doc_type and c.ref_code='Eattach' ";//抓取可顯示於附件書件之文件種類
                    SQL += "	where a.sign_stat='NN' and a.in_no='" + _in_no + "' and b.doc_type='" + brMap[y].docType + "' ";
                    SQL += ")x on z.Cust_code=x.doc_type ";
                    _conn.DataTable(SQL, dtAttach);
                }
            }

            //沒對應到的其他附件
            SQL = "select '4'src_type,c.Cust_code,c.code_name as doc_typenm,c.form_name,b.source_name,b.attach_desc,b.doc_type ";
            SQL += ",case when b.doc_type='99' then 99 else 0 end sort ";
            SQL += "from attcase_dmt a ";
            SQL += "inner join dmt_attach b on a.in_no=b.in_no and a.att_sqlno=b.att_sqlno and b.attach_flag<>'D' and b.doc_flag='E' ";//抓取電子送件
            SQL += "inner join cust_code c on c.code_type='tdoc' and c.cust_code=b.doc_type and c.ref_code='Eattach' ";//抓取可顯示於附件書件之文件種類
            SQL += "where a.sign_stat='NN' and a.in_no='" + _in_no + "' ";
            if (exclude != "") {
                SQL += "and b.doc_type not in('" + exclude.Substring(1).Replace(",","','") + "') ";
            }
            SQL += "order by sort";
            _conn.DataTable(SQL, dtAttach);

            dtAttach.ShowTable();

            if (dtAttach.Rows.Count != 0) {
                for (int i = 0; i < dtAttach.Rows.Count; i++) {
                    if (dtAttach.Rows[i]["Cust_code"].ToString() != "99") {
                        CopyBlock("b_attach3");
                        string filename = dtAttach.Rows[i]["form_name"].ToString();
                        if (dtAttach.Rows[i]["source_name"].ToString() != "") {
                            filename = dtAttach.Rows[i]["source_name"].ToString();
                        }
                        string doc_typenm = dtAttach.Rows[i]["doc_typenm"].ToString().Trim();
                        ReplaceBookmark("doc_typenm", doc_typenm);
                        int padCount = (doc_typenm.Length > 11) ? 0 : 11 - doc_typenm.Length;
                        ReplaceBookmark("source_name", new string('　', padCount) + filename);//補齊全型空白
                    } else {
                        CopyBlock("b_attach4");
                        //描述
                        string oth_desc = dtAttach.Rows[i]["doc_typenm"].ToString();
                        if (dtAttach.Rows[i]["attach_desc"].ToString() != "") {
                            oth_desc = dtAttach.Rows[i]["attach_desc"].ToString();
                        }
                        //檔名
                        string source_name = dtAttach.Rows[i]["form_name"].ToString();
                        if (dtAttach.Rows[i]["source_name"].ToString() != "") {
                            source_name = dtAttach.Rows[i]["source_name"].ToString();
                        }
                        ReplaceBookmark("oth_attach_desc", oth_desc);
                        ReplaceBookmark("oth_source_name", source_name);
                    }
                }
            }
        }
        AddParagraph();
    }
    #endregion

    #region 產生附送書件區塊 +void CreateAttach()
    public void CreateAttach() {
		//附送書件
		CopyBlock("b_attach1");
		using (DataTable dtAttach = Attach) {
			if (dtAttach.Rows.Count == 0) {
				CopyBlock("b_attach2");
				AddParagraph();
			} else {
				bool basic_flag = false;
				//先產生不是【其他】的附件
				for (int i = 0; i < dtAttach.Rows.Count; i++) {
					//有基本資料表
					if (dtAttach.Rows[i]["doc_type"].ToString() == "19") basic_flag = true;
					if (dtAttach.Rows[i]["doc_type"].ToString() != "99") {
						CopyBlock("b_attach3");
						string doc_typenm = dtAttach.Rows[i]["doc_typenm"].ToString().Trim();
						ReplaceBookmark("doc_typenm", doc_typenm);
						int padCount = (doc_typenm.Length > 11) ? 0 : 11 - doc_typenm.Length;
						ReplaceBookmark("source_name", new string('　', padCount) + dtAttach.Rows[i]["source_name"].ToString());
					}
				}
				//如果尚未上傳基本資料表則先產生tag
				if (!basic_flag) {
					CopyBlock("b_attach3");
					ReplaceBookmark("doc_typenm", "基本資料表");
					ReplaceBookmark("source_name", "　　　　　　Contact.pdf");
				}
				//最後產生【其他】的附件
				for (int i = 0; i < dtAttach.Rows.Count; i++) {
					if (dtAttach.Rows[i]["doc_type"].ToString() == "99") {
						CopyBlock("b_attach4");
						ReplaceBookmark("oth_attach_desc", dtAttach.Rows[i]["attach_desc"].ToString());
						ReplaceBookmark("oth_source_name", dtAttach.Rows[i]["source_name"].ToString());
					}
				}
				AddParagraph();
			}
		}
	}
	#endregion

	#region 產生基本資料表 +AppendBaseData(string baseDocName)
	/// <summary>
	/// 產生基本資料表
	/// </summary>
	public void AppendBaseData(string baseDocName) {
		CopyBlock(baseDocName, "base_title");
		//申請人
		for (int i = 0; i < Apcust.Rows.Count; i++) {
			CopyBlock(baseDocName, "base_apcust");
			if (this.BaseRptAPTag == null || this.BaseRptAPTag == "") {
				ReplaceBookmark("base_ap_type", "申請人");
			} else {
				ReplaceBookmark("base_ap_type", this.BaseRptAPTag);
			}
			ReplaceBookmark("base_ap_num", (i + 1).ToString());
			//身份類別
			if (AP_marknm != null) {
				if (AP_marknm.ContainsKey(Dmt.Rows[0]["mark"].ToString().Trim())) {
					ReplaceBookmark("base_ap_mark", AP_marknm[Dmt.Rows[0]["mark"].ToString().Trim()]);
				} else {
					ReplaceBookmark("base_ap_mark", "");
				}
			} else {
				ReplaceBookmark("base_ap_mark", "", true);
			}
			ReplaceBookmark("base_ap_country", Apcust.Rows[i]["Country_name"].ToString());
			ReplaceBookmark("ap_class", Apcust.Rows[i]["apclass_name"].ToString());
			//選定代表人(有一個以上的申請人才要填)
			if (Apcust.Rows[i]["server_flag"].ToString() == "Y" && Apcust.Rows.Count > 1) {
				ReplaceBookmark("server_flag", "是");
			} else {
				ReplaceBookmark("server_flag", "", true);
			}
			ReplaceBookmark("apcust_no", Apcust.Rows[i]["c_id"].ToString(), true);
			ReplaceBookmark("base_ap_cname_title", Apcust.Rows[i]["Title_cname"].ToString());
			ReplaceBookmark("base_ap_ename_title", Apcust.Rows[i]["Title_ename"].ToString());
			ReplaceBookmark("base_ap_cname", Apcust.Rows[i]["Cname_string"].ToString().ToXmlUnicode());
			ReplaceBookmark("base_ap_ename", Apcust.Rows[i]["Ename_string"].ToString().ToXmlUnicode(true), true);
			ReplaceBookmark("ap_live_country", Apcust.Rows[i]["Country_name"].ToString());
			ReplaceBookmark("ap_zip", Apcust.Rows[i]["c_zip"].ToString(), true);
			if (Apcust.Rows[i]["ap_country"].ToString().Trim() == "T" || Apcust.Rows[i]["ap_country"].ToString().Trim() == "CM" || Apcust.Rows[i]["ap_country"].ToString().Trim() == "HO" || Apcust.Rows[i]["ap_country"].ToString().Trim() == "MC") {
				ReplaceBookmark("ap_addr", Apcust.Rows[i]["c_addr"].ToString());
				ReplaceBookmark("ap_eddr", "", true);
			} else {
				ReplaceBookmark("ap_addr", Apcust.Rows[i]["c_addr"].ToString(), true);
				ReplaceBookmark("ap_eddr", Apcust.Rows[i]["e_addr"].ToString().ToXmlUnicode(true));
			}
			ReplaceBookmark("ap_crep", Apcust.Rows[i]["ap_crep"].ToString().ToXmlUnicode(), true);
			ReplaceBookmark("ap_erep", Apcust.Rows[i]["ap_erep"].ToString().ToXmlUnicode(true), true);
		}
		//註冊前變更(FC1)要顯示原申請人
		if (this.ReportCode == "FC1") {
			var mod_ap = Tran.Rows[0].SafeRead("mod_ap", "").ToCharArray();
			if (mod_ap.Length >= 1 && mod_ap[0] == 'Y') {
				for (int i = 0; i < TranListAP.Rows.Count; i++) {
					CopyBlock(baseDocName,"base_mod_ap");
					ReplaceBookmark("mod_ap_type", "原申請人");
					ReplaceBookmark("mod_ap_num", (i + 1).ToString());
					ReplaceBookmark("mod_ap_cname_title", TranListAP.Rows[i]["Title_cname"].ToString());
					ReplaceBookmark("mod_ap_ename_title", TranListAP.Rows[i]["Title_ename"].ToString());
					ReplaceBookmark("mod_ap_cname", TranListAP.Rows[i]["Cname_string"].ToString().ToXmlUnicode());
					ReplaceBookmark("mod_ap_ename", TranListAP.Rows[i]["Ename_string"].ToString().ToXmlUnicode(true),true);
					ReplaceBookmark("mod_ap_addr", "", true);
					ReplaceBookmark("mod_ap_eddr", "", true);
					ReplaceBookmark("mod_ap_crep", "", true);
				}
			}
		}
		//申請異議(DO1)要顯示被異議人、申請評定(DI1)要顯示註冊人、申請廢止(DR1)要顯示註冊人
		if (this.ReportCode == "DO1" || this.ReportCode == "DI1" || this.ReportCode == "DR1") {
			var mod_ap = Tran.Rows[0].SafeRead("mod_ap", "").ToCharArray();
			if (mod_ap.Length >= 1 && mod_ap[0] == 'Y') {
				for (int i = 0; i < TranListAP.Rows.Count; i++) {
					CopyBlock(baseDocName,"base_mod_ap");
					ReplaceBookmark("mod_ap_type", this.BaseRptModTag);
					ReplaceBookmark("mod_ap_num", (i + 1).ToString());
					ReplaceBookmark("mod_ap_cname_title", "中文名稱");
					ReplaceBookmark("mod_ap_ename_title", "",true);
					ReplaceBookmark("mod_ap_cname", TranListAP.Rows[i]["ncname1"].ToString());
					ReplaceBookmark("mod_ap_ename", "",true);
					ReplaceBookmark("mod_ap_addr", TranListAP.Rows[i]["naddr1"].ToString(), true);
					ReplaceBookmark("mod_ap_eddr", "", true);
					ReplaceBookmark("mod_ap_crep", TranListAP.Rows[i]["ncrep"].ToString());
				}
			}
		}
		//代理人
		//申請授權(FL1)、再授權(FL2)、廢止授權(FL3)、廢止再授權(FL4)tag要顯示申請人種類
		string agtType = "";
		if (this.ReportCode == "FL1" || this.ReportCode == "FL2" || this.ReportCode == "FL3" || this.ReportCode == "FL4") {
			agtType = BaseRptAPTag + "之";
		}
		for (int i = 0; i < Agent.Rows.Count; i++) {
			CopyBlock(baseDocName, "base_agent");
			ReplaceBookmark("agt_id1", Agent.Rows[i]["agt_id1"].ToString());
			ReplaceBookmark("base_agt_type1", agtType);
			ReplaceBookmark("base_agt_name1", Agent.Rows[i]["agt_name1"].ToString(), true);
			ReplaceBookmark("agt_zip1", Agent.Rows[i]["agt_zip"].ToString(), true);
			ReplaceBookmark("agt_addr1", Agent.Rows[i]["agt_addr"].ToString(), true);
			ReplaceBookmark("agatt_tel1", Agent.Rows[i]["s_agatt_tel"].ToString(), true);
			ReplaceBookmark("agatt_fax1", Agent.Rows[i]["s_agatt_fax"].ToString(), true);

			ReplaceBookmark("agt_id2", Agent.Rows[i]["agt_id2"].ToString());
			ReplaceBookmark("base_agt_type2", agtType);
			ReplaceBookmark("base_agt_name2", Agent.Rows[i]["agt_name2"].ToString(), true);
			ReplaceBookmark("agt_zip2", Agent.Rows[i]["agt_zip"].ToString(), true);
			ReplaceBookmark("agt_addr2", Agent.Rows[i]["agt_addr"].ToString(), true);
			ReplaceBookmark("agatt_tel2", Agent.Rows[i]["s_agatt_tel"].ToString(), true);
			ReplaceBookmark("agatt_fax2", Agent.Rows[i]["s_agatt_fax"].ToString(), true);
		}

		//申請授權(FL1)、再授權(FL2)、廢止授權(FL3)、廢止再授權(FL4)要顯示關係人基本資料
		if (this.ReportCode == "FL1" || this.ReportCode == "FL2" || this.ReportCode == "FL3" || this.ReportCode == "FL4") {
			for (int i = 0; i < TranListAP.Rows.Count; i++) {
				CopyBlock(baseDocName, "base_apcust");
				ReplaceBookmark("base_ap_type", this.BaseRptModTag);
				ReplaceBookmark("base_ap_num", (i + 1).ToString());
				ReplaceBookmark("base_ap_mark", "", true);
				ReplaceBookmark("base_ap_country", TranListAP.Rows[i]["Country_name"].ToString());
				//身分種類
				ReplaceBookmark("ap_class", TranListAP.Rows[i]["oapclass_name"].ToString());
				//選定代表人(DB沒有這欄)
				ReplaceBookmark("server_flag", "", true);
				ReplaceBookmark("apcust_no", TranListAP.Rows[i]["o_id"].ToString(), true);
				ReplaceBookmark("base_ap_cname_title", TranListAP.Rows[i]["Title_cname"].ToString());
				ReplaceBookmark("base_ap_ename_title", TranListAP.Rows[i]["Title_ename"].ToString());
				ReplaceBookmark("base_ap_cname", TranListAP.Rows[i]["Cname_string"].ToString().ToXmlUnicode());
				ReplaceBookmark("base_ap_ename", TranListAP.Rows[i]["Ename_string"].ToString().ToXmlUnicode(true), true);
				ReplaceBookmark("ap_live_country", TranListAP.Rows[i]["Country_name"].ToString());
				ReplaceBookmark("ap_zip", TranListAP.Rows[i]["o_zip"].ToString(), true);
				if (TranListAP.Rows[i]["oap_country"].ToString().Trim() == "T" || TranListAP.Rows[i]["oap_country"].ToString().Trim() == "CM" || TranListAP.Rows[i]["oap_country"].ToString().Trim() == "HO" || TranListAP.Rows[i]["oap_country"].ToString().Trim() == "MC") {
					ReplaceBookmark("ap_addr", TranListAP.Rows[i]["c_addr"].ToString());
					ReplaceBookmark("ap_eddr", "", true);
				} else {
					ReplaceBookmark("ap_addr", TranListAP.Rows[i]["c_addr"].ToString(), true);
					ReplaceBookmark("ap_eddr", TranListAP.Rows[i]["e_addr"].ToString().ToXmlUnicode(true));
				}
				ReplaceBookmark("ap_crep", TranListAP.Rows[i]["ocrep"].ToString().ToXmlUnicode(), true);
				ReplaceBookmark("ap_erep", TranListAP.Rows[i]["oerep"].ToString().ToXmlUnicode(true), true);
			}
		}
		CopyPageFoot(baseDocName, false);//頁尾
	}
	#endregion

	#region 更新列印狀態 +SetPrint()
	/// <summary>
	/// 更新列印狀態
	/// </summary>
	public void SetPrint() {
		string SQL = "update case_dmt set new='P' " +
					",rectitle_flag='" + this.RectitleFlag + "' " +
					",receipt_title='" + this.RectitleTitle + "' " +
					",rectitle_name='" + this.RectitleName.ToBig5() + "' " +
					"where in_scode='" + _in_scode + "' and in_no='" + _in_no + "'";
		_conn.ExecuteNonQuery(SQL);
	}
	#endregion
}

public class AttachMapping {
    public string brColValue { get; set; }
    public string mapValue { get; set; }
    public string docType { get; set; }
}