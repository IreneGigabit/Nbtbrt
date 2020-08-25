<%@ Page Language="C#" %>

<script runat="server">
	private void Page_Load(System.Object sender, System.EventArgs e) {
		//http://web08/nbtbrt/report/unicodeTester.aspx
		Response.CacheControl = "Private";
		Response.AddHeader("Pragma", "no-cache");
		Response.Expires = -1;
		Response.Clear();
		Response.AddHeader("Content-Disposition", "attachment; filename=\"new.txt\"");
		Response.ContentType = "text/plain";


		string xxx = "1234567890123456789012345678901234567890";
		string aaa = "TD DUERO TONELERÍA DE CALIDAD 及圖";
		string bbb = "TD DUERO TONELER&#205;A DE CALIDAD 及圖";
		string ccc = "TD DUERO TONELER&Iacute;A DE CALIDAD 及圖";

		Response.Write(HttpUtility.HtmlDecode(xxx) + Environment.NewLine);
		Response.Write(HttpUtility.HtmlDecode(aaa) + Environment.NewLine);
		Response.Write(HttpUtility.HtmlDecode(bbb) + Environment.NewLine);
		Response.Write(HttpUtility.HtmlDecode(ccc) + Environment.NewLine);
		Response.Write("==========================" + Environment.NewLine);
		Response.Write(xxx.PadLeftCHT(35, '_') + Environment.NewLine);
		Response.Write(aaa.PadLeftCHT(35, '_') + Environment.NewLine);
		Response.Write(bbb.PadLeftCHT(35, '_') + Environment.NewLine);
		Response.Write(ccc.PadLeftCHT(35, '_') + Environment.NewLine);
		Response.Write("==========================" + Environment.NewLine);
		Response.Write(xxx.PadRightCHT(35, '_') + Environment.NewLine);
		Response.Write(aaa.PadRightCHT(35, '_') + Environment.NewLine);
		Response.Write(bbb.PadRightCHT(35, '_') + Environment.NewLine);
		Response.Write(ccc.PadRightCHT(35, '_') + Environment.NewLine);
	}
</script>

