<%@ Page Language="C#" CodePage="65001"%>
<%@ Import Namespace = "System.Data.SqlClient"%>

<script runat="server">
    protected string SQL = "";

    protected string p2 = "";
    protected string seq = "";
    protected string seq1 = "";
    protected string fldname = "";
    protected StringBuilder strOut = new StringBuilder();

    protected void Page_Load(object sender, EventArgs e) {
        Response.CacheControl = "no-cache";
        Response.AddHeader("Pragma", "no-cache");
        Response.Expires = -1;

        p2 = (Request["p2"] ?? "").Trim();
        seq = (Request["seq"] ?? "").Trim();
        seq1 = (Request["seq1"] ?? "").Trim();
        fldname = (Request["fldname"] ?? "").Trim();

        
        SQL = "select * ";
        SQL += "from dmt ";
        SQL += "where seq='" + seq + "' ";
        SQL += "and seq1='" + seq1 + "' ";
        SQL += "and end_date is null ";

        string chkseqB = "";
        using (DBHelper conn = new DBHelper(Conn.btbrt, false)) {
            using (SqlDataReader dr = conn.ExecuteReader(SQL)) {
                if (dr.Read()) {
                    chkseqB="";
                } else {
                    chkseqB="OK";//seq+seq1不存在dmt
                }
            }
        }
        
        if (p2 == "A") {
            if (seq != "" && seq1 != "") {
                if (chkseqB != "OK") {
                    strOut.AppendLine("alert('已有 " + seq + "-" + seq1 + " 在案件主檔或該案件已結案，請重新輸入!!!');");
                    if (fldname != "") {
                        strOut.AppendLine("$('#" + fldname + "_New_Ass_seq').val('');");
                        strOut.AppendLine("$('#" + fldname + "_New_Ass_seq1').val('');");
                        strOut.AppendLine("$('#" + fldname + "_New_Ass_seq').focus();");
                    } else {
                        strOut.AppendLine("$('#New_Ass_seq').val('');");
                        strOut.AppendLine("$('#New_Ass_seq1').val('');");
                        strOut.AppendLine("$('#New_Ass_seq').focus();");
                        strOut.AppendLine("$('#dseqa1').val($('#New_Ass_seq').val());");
                        strOut.AppendLine("$('#dseq1a1').val($('#New_Ass_seq1').val());");
                        strOut.AppendLine("$('#dseqb1').val($('#New_Ass_seq').val());");
                        strOut.AppendLine("$('#dseq1b1').val($('#New_Ass_seq1').val());");
                    }
                }
            }
        }
    }
</script>

<%=strOut.ToString()%>
