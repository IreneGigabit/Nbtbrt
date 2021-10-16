<%@ WebHandler Language="C#" Class="UpLoaded" %>

using System;
using System.Web;
using System.Web.SessionState;
using System.IO;
using System.Collections.Generic;
using System.Data.SqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public class UpLoaded : IHttpHandler, IRequiresSessionState
{

    public void ProcessRequest(HttpContext context) {
        string QueryString = context.Request.ServerVariables["QUERY_STRING"];
        //Dictionary<string, string> SrvrVal = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        Dictionary<string, string> ReqVal = Util.GetRequestParam(context, context.Request["chkTest"] == "TEST");

        string msg = "";//回傳訊息
        string attach_flag_value = "A";//回傳畫面的attach_flag值
        string multiUpload = (context.Request["multiupload"] ?? "").ToUpper();//Y=多檔上傳
        string type = (context.Request["type"] ?? "").ToLower();
        string folder_name = context.Request["folder_name"] ?? "";//子目錄
        //string prefix_name = context.Request["prefix_name"] ?? "";//檔案的前置名稱:例如: filename=abc.jpg]=(if prefix="123" ]=(then filename=123_abc.jpg,用於區隔同目錄底下,不同的檔案名稱
        string filename_flag = context.Request["filename_flag"] ?? "";//檔案存檔命名方式
        string draw_file = context.Request["draw_file"] ?? "";//原檔案路徑(畫面上的值)
        string nfilename = context.Request["nfilename"] ?? "";//新檔名格式
        string prgid = context.Request["prgid"] ?? "";//用prgid判斷是出口案/國內案用
        string docbranch = context.Request["branch"] ?? "";//區所別
        //string form_name = context.Request["form_name"] ?? "";//回傳目錄+檔名欄位名,ex:opt_file_5
        //string size_name = context.Request["size_name"] ?? "";//回傳檔案大小欄位名,ex:opt_file_size_5
        //string file_name = context.Request["file_name"] ?? "";//回傳附件名稱欄位名,ex:opt_file_name_5
        //string source_name = context.Request["source_name"] ?? "";//回傳原始檔名欄位名稱,ex:opt_file_source_name_5
        //string btnname = context.Request["btnname"] ?? "";//[上傳]按鈕名,ex:btnopt_file_5
        //string dir_name = context.Request["prgid"] ?? "";//回傳路徑的欄位名/國內案用
        //string doc_in_date = context.Request["in_date"] ?? "";//上傳時間欄位名
        //string doc_in_scode = context.Request["in_scode"] ?? "";//上傳人員欄位名
        //string doc_in_scodenm = context.Request["in_scodenm"] ?? "";//上傳人員欄位名
        //string attach_flag_name = context.Request["attach_flag_name"] ?? "";//回傳attach_flag欄位名
        //string ar_no = context.Request["ar_no"] ?? "";//for 英文invoice
        //string qs_dept = context.Request["qs_dept"] ?? "";//for 英文invoice
        //string draw_name = context.Request["draw_name"] ?? "";//for 英文invoice

        //string aa = "";//最後儲存的檔名(含路徑)
        string ee = "";//最後儲存的檔名
        //string bb = "";//原始儲存的檔名
        //string zz = "";//原始儲存的檔名(不含ext)

        //////////////////////////////////////////////////
        //取得上傳相關設定
        Sys sfile = new Sys();
        if (docbranch != "") {
            sfile.getFileServer(docbranch, prgid);
            folder_name = "temp/" + docbranch + "/" + folder_name;
        } else {
            sfile.getFileServer(Sys.GetSession("SeBranch"), prgid);
        }

        //指定儲存路徑
        string file_path = sfile.gbrWebDir + "/" + folder_name;// +"/";
        switch (type) {
            case "custdb_file"://對催帳客函
            case "db_file"://請款單
            case "custresp_file"://客戶對催回應文件
            case "apcust_file"://契約書、委任書
            case "brdb_file"://英文invoice
                file_path = sfile.gcustDbDir + "/" + folder_name;// + "/";
                break;
        }
        //不存在則新增資料夾
        if (!Directory.Exists(context.Server.MapPath(file_path))) {
            Directory.CreateDirectory(context.Server.MapPath(file_path));
        }

        //原始檔名
        HttpPostedFile uploadedFile = context.Request.Files[0];
        string FName = uploadedFile.FileName;//使用者端目錄(d:\xxxxx)+檔案名稱
        string psource_name = Path.GetFileName(FName);//原始檔名(含Ext)
        string original_name = Path.GetFileNameWithoutExtension(FName);//原始檔名(不含Ext)
        string sExt = Path.GetExtension(FName);//副檔名
        int attach_size = uploadedFile.ContentLength;//檔案大小(bytes)

        string attach_no = "";
        if (multiUpload != "" && nfilename.IndexOf("{{attach_no}}") > -1)//若是多檔上傳且有指定新檔名格式則要取流水號
            attach_no = GetAttachNo(context);

        ee = original_name;//最後儲存的檔名(預設用原始檔名)
        //string ee_new = "";//新檔名
        string old_file1 = "";//舊檔名(畫面上欄位的值)
        if (draw_file != "") {
            old_file1 = Path.GetFileNameWithoutExtension(draw_file);
        }

        //新檔名
        nfilename = nfilename.Replace("{{attach_no}}", attach_no);
        if (filename_flag == "source_name") {
            //ex:原檔名abc.html，nfilename=111，ee=111
            if (nfilename != "")//有指定新檔案名稱
                ee = nfilename;
        } else if (filename_flag == "soure_name2") {
            //若有指定新檔名則用加上新檔名
            //ex:原檔名abc.html，nfilename=111，ee=111-abc.html
            if (nfilename != "")//有指定新檔案名稱
                ee = nfilename + "-" + original_name;

            if (prgid.Left(3) != "brp") {
                if (nfilename != "")//有指定新檔案名稱
                    original_name = nfilename + "-" + original_name;
            }
        } else {
            ee = (nfilename != "" ? nfilename : original_name);
        }

        //判斷能否儲存
        bool saveFlag = true;
        FileInfo fi = new FileInfo(context.Server.MapPath(file_path + "/" + ee + sExt));
        if (original_name == old_file1) {
            if (type == "custdb_file" || type == "db_file" || type == "custresp_file" || type == "apcust_file" || type == "brdb_file") {
                attach_flag_value = "AR";
            }
            if (fi.Exists) {
                string File_name_new = String.Format("{0}_{1}_{2}{3}", ee, DateTime.Now.ToString("yyyyMMddHHmmss"), Sys.GetSession("scode"), sExt);
                fi.MoveTo(context.Server.MapPath(file_path + "/" + File_name_new));
                msg = "此檔案已存在！已覆蓋檔案！";
            }
        } else {
            //2012/5/2增加，因請款單及對催帳客函傳入路徑為需擬路徑/btbrt/custdb_file，所以另外判斷
            if (type == "custdb_file" || type == "db_file" || type == "custresp_file") {
                //如果存在的話原來的要備份起來,備份規則：檔名_年月日時分秒
                if (fi.Exists) {
                    attach_flag_value = "U";
                    saveFlag = false;
                    msg = "該檔案已經存在!!(" + ee + sExt + ")\n\n請將該檔案更名，並重新上傳!!⑴";
                }
            } else if (type == "photo") {//圖檔判斷
                if (fi.Exists) {
                    attach_flag_value = "U";
                    saveFlag = false;
                    msg = "該檔案已經存在!!(" + ee + sExt + ")\n\n請將該檔案更名，並重新上傳!!⑵";
                } else {
                    if (original_name == ee) {//編修時檢查上傳檔名與更名檔名是否相同
                        saveFlag = false;
                        msg = "該檔案" + original_name + "與更名後檔案相同!!\n\n請將該檔案更名，並重新上傳!!";
                    }
                    attach_flag_value = "A";
                }
            } else if (type == "brdb_file") {//英文invoice,檔名命名規則：E+branch+dept+ar_no副檔名為使用者上傳
                if (fi.Exists) {
                    string File_name_new = String.Format("{0}_{1}_{2}{3}", ee, DateTime.Now.ToString("yyyyMMddHHmmss"), Sys.GetSession("scode"), sExt);
                    fi.MoveTo(context.Server.MapPath(file_path + "/" + File_name_new));
                }
            } else if (type == "dmt_photo") {//商標圖檔
                if (fi.Exists) {
                    string File_name_new = String.Format("{0}_{1}_{2}{3}", ee, DateTime.Now.ToString("yyyyMMddHHmmss"),Sys.GetSession("scode"), sExt);
                    fi.MoveTo(context.Server.MapPath(file_path + "/" + File_name_new));
                    msg = "此檔案已存在！已覆蓋檔案！";
                }
            } else {
                //如果存在的話原來的要備份起來,備份規則：檔名_年月日時分秒
                if (fi.Exists) {
                    attach_flag_value = "U";
                    saveFlag = false;
                    msg = "該檔案已經存在!!(" + ee + sExt + ")\n\n請將該檔案更名，並重新上傳!!⑶";
                }
            }
        }

        //aa = (file_path + ee + sExt);//.Replace("\\", "\\\\");//最後儲存的檔名(含路徑)
        //ee = (ee + sExt);//.Replace("\\", "\\\\");//最後儲存的檔名
        //bb = (original_name + sExt);//.Replace("\\", "\\\\");//原始檔名

        if (context.Request["chkTest"] == "TEST") {
            msg += "FName=" + FName + "\n";
            msg += "original_name=" + original_name + "\n";
            msg += "sExt=" + sExt + "\n";
            msg += "attach_size=" + attach_size + "\n";
            msg += "saveAs=" + context.Server.MapPath(file_path + "/" + ee + sExt) + "\n";
            //context.Response.Write(msg);
            //context.Response.End();
        }

        if (saveFlag && context.Request["chkTest"] != "TEST") {
            uploadedFile.SaveAs(context.Server.MapPath(file_path + "/" + ee + sExt));
        }

        context.Response.ContentType = "application/json";
        JObject obj = new JObject(
                 new JProperty("msg", msg),//回傳訊息
                 new JProperty("name", ee + sExt),//實體檔名,KT-2011000060-14m.png
                 new JProperty("full_path", file_path + "/" + ee + sExt),//虛擬完整路徑+實體檔名,/nopt/opt_file/attach/2011/000060/KT-2011000060-14m.png
                 new JProperty("dir", file_path),//虛擬完整路徑(不含檔名)
                 new JProperty("source", psource_name),//原始檔名,[立體商標註冊申請書]-TI-54531-IT_[立體商標註冊申請書]_0000.png
                 new JProperty("desc", original_name),//原始檔名(不含Ext),[立體商標註冊申請書]-TI-54531-IT_[立體商標註冊申請書]_0000
                 new JProperty("size", attach_size),//檔案大小
                 new JProperty("attach_no", attach_no),//attach_no
                 new JProperty("in_scode", context.Session["scode"]),//存檔人
                 new JProperty("in_scodenm", context.Session["sc_name"]),//存檔人
                 new JProperty("attach_flag", attach_flag_value),//回傳畫面的attach_flag值
                 new JProperty("mappath", context.Server.MapPath(file_path + "/" + ee + sExt))//真實路徑
               );
        context.Response.Write(JsonConvert.SerializeObject(obj, Formatting.None));//回傳值
    }

    public bool IsReusable {
        get {
            return false;
        }
    }

    public string GetAttachNo(HttpContext context) {
        //string temptable = context.Request["temptable"] ?? "";//attachtemp
        string attach_tablename = context.Request["attach_tablename"] ?? "";//dmt_attach

        //attachtemp計算attach_no的key值
        string syscode = context.Request["syscode"] ?? Sys.Syscode;
        string branch = context.Request["docbranch"] ?? Sys.GetSession("SeBranch");
        string dept = context.Request["dept"] ?? Sys.GetSession("Dept");
        string seq_area = branch ?? "";//NCSKI
        string seq = context.Request["seq"] ?? "";
        string seq1 = context.Request["seq1"] ?? "";
        string step_grade = context.Request["step_grade"] ?? "";

        //remark用
        string apcode = context.Request["apcode"] ?? "";
        string prgid = context.Request["prgid"] ?? "";
        
        int attach_no = 0;

        string SQL = "";
        using (DBHelper conn = new DBHelper(Conn.btbrt)) {
            //--1.先刪除attachtemp三小時前的資料，再入，以免承辦上傳但未作存檔attach_no虛增
            SQL = "delete from attachtemp ";
            SQL += " where syscode='" + syscode + "' and branch='" + branch + "' and dept='" + dept + "' ";
            SQL += " and seq='" + seq + "' and seq1='" + seq1 + "' and step_grade='" + step_grade + "' ";
            SQL += " and in_date<DATEADD(hour,-3,getdate()) ";
            conn.ExecuteNonQuery(SQL);

            //--2.抓取最大值
            SQL = "select isnull(max(attach_no),1)+1 as maxattach_no ";
            SQL += "from " + attach_tablename;
            SQL += " where seq='" + seq + "' and seq1='" + seq1 + "' and step_grade='" + step_grade + "' ";
            object objResult1 = conn.ExecuteScalar(SQL);
            int maxattach_no1 = (objResult1 == DBNull.Value || objResult1 == null ? 1 : (int)objResult1);

            SQL = "select isnull(max(attach_no),1)+1 as maxattach_no ";
            SQL += "from attachtemp ";
            SQL += " where syscode='" + syscode + "' and branch='" + branch + "' and dept='" + dept + "' ";
            SQL += " and seq='" + seq + "' and seq1='" + seq1 + "' and step_grade='" + step_grade + "' ";
            object objResult2 = conn.ExecuteScalar(SQL);
            int maxattach_no2 = (objResult2 == DBNull.Value || objResult2 == null ? 1 : (int)objResult2);

            attach_no = Math.Max(maxattach_no1, maxattach_no2);

            //--3.回寫db記錄attach_no
            SQL = "select attach_no from attachtemp ";
            SQL += " where syscode='" + syscode + "' and branch='" + branch + "' and dept='" + dept + "' ";
            SQL += " and seq='" + seq + "' and seq1='" + seq1 + "' and step_grade='" + step_grade + "' ";
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    SQL = "update attachtemp ";
                    SQL += " set attach_no='" + attach_no + "'";
                    SQL += ",tran_scode='" + context.Session["scode"] + "'";
                    SQL += ",remark='多檔上傳(" + prgid + ")'";
                    SQL += " where syscode='" + syscode + "' and branch='" + branch + "' and dept='" + dept + "' ";
                    SQL += " and seq='" + seq + "' and seq1='" + seq1 + "' and step_grade='" + step_grade + "' ";
                } else {
                    SQL = "insert into attachtemp ";
                    SQL += "(syscode,apcode,branch,dept,seq,seq1,step_grade,attach_no,in_date,in_scode,tran_date,tran_scode,remark)";
                    SQL += " values('" + syscode + "','" + apcode + "','" + branch + "','" + dept + "','" + seq + "','" + seq1 + "','" + step_grade + "'";
                    SQL += ",'" + attach_no + "',getdate(),'" + context.Session["scode"] + "',getdate(),'" + context.Session["scode"] + "'";
                    SQL += ",'多檔上傳(" + prgid + ")')";
                }
                dr.Close();
                conn.ExecuteNonQuery(SQL);
            }

            conn.Commit();
        }

        return attach_no.ToString();
    }
}
