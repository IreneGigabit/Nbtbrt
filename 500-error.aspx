<%@Page Language="C#" CodePage="65001"%>
<%@Import Namespace = "System.IO"%>
<%@Import Namespace = "System.Diagnostics"%>
<%@Import Namespace = "System.CodeDom.Compiler"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

	private string _expType;
	private Exception _lastError;
	private HttpCompileException _ccExp;
	private CompilerError _ccError;
	private StackFrame _frame;
    private string _fileName;

    private void Page_Load(System.Object sender, System.EventArgs e) {
        // Display Error
        GetError();
        lblType.Text = _expType;
        string ipAddr = Request.ServerVariables["REMOTE_ADDR"].ToString();
        lblMessage.Text = GetErrorMessage();
        lblFile.Text = String.Format("{0} &mdash; {1}", GetFileName(), GetErrorCoordinates());
        ltlSource.Text = GetSourceCode(-4, 3);
        ltlStack.Text = GetStack();
        if (_frame != null) {
            lblExtMsg.Text = (Session["ExtMsg"]??"").ToString();
            Session["ExtMsg"] = "";
        }
        if (_lastError.InnerException != null) {
            lblExtMsg.Text = _lastError.InnerException.Message;
        }

        this.DataBind();
    }

	/// <summary>
	/// Get the Error
	/// </summary>
	private void GetError()
	{
		// Get the last error message
		_lastError = Server.GetLastError();
		string stmp = _lastError.GetType().ToString();
		if (stmp == "System.Web.HttpCompileException") {
			_ccExp = (HttpCompileException) _lastError;
			_expType = "Compilation Error...";
			_ccError = _ccExp.Results.Errors[0];
			_fileName = _ccError.FileName;
			_frame = null;
		} else {
			_ccExp = null;
			_expType = "RunTime Error...";
			_ccError = null;
			// Get the Stack Frame
            StackTrace stack = new StackTrace(_lastError.GetBaseException(), true);
            
            for (int i = 0; i < stack.FrameCount; i++) {
                if (!String.IsNullOrEmpty(stack.GetFrame(i).GetFileName())) {
                    _frame = stack.GetFrame(i);
                    break;
                }
            }
			if (_frame == null) _frame = stack.GetFrame(0);

			// Get file name
			_fileName = _frame.GetFileName();
			if (String.IsNullOrEmpty(_fileName)) _fileName = Request.PhysicalPath;
		}
		Server.ClearError();
		return;
	}

	/// <summary>
	/// Returns the human readable error message
	/// </summary>
	private string GetErrorMessage()
	{
        return Server.HtmlEncode(_lastError.GetBaseException().Message);
	}

	/// <summary>
	/// Gets the file associated with the error
	/// </summary>
	private string GetFileName()
	{
		string appRoot = Request.PhysicalApplicationPath;
		string path = _fileName.Remove(0, appRoot.Length);
		return path.Replace(@"\", @"/");
	}

	/// <summary>
	/// Returns the line and column associated with an error
	/// </summary>
	private string GetErrorCoordinates()
	{
		string sret = "";
		if (_frame != null) sret = String.Format("line {0}, column {1}", _frame.GetFileLineNumber(), _frame.GetFileColumnNumber());
        if (_ccError != null) sret = String.Format("line {0}, column {1}", _ccError.Line, _ccError.Column);
		return sret;
	}

	/// <summary>
	/// Returns the source code associated with an error
	/// starting a specified number of lines before and
	/// after the error line
	/// </summary>
	private string GetSourceCode(int startOffset, int endOffset)
	{
		// Get line number
		int lineNumber = 0;
		int colNumber = 0;

		if (_ccError != null) {
			lineNumber = _ccError.Line;
			colNumber = _ccError.Column;
		}

		if (_frame != null)
		{
			lineNumber = _frame.GetFileLineNumber();
			colNumber = _frame.GetFileColumnNumber();
		}

		// If no line number
		if (lineNumber == 0)
			return "No relevant source code";

		// Load source code file
		string[] sourceLines = File.ReadAllLines(_fileName);

		// Calculate start and end line
		int startLine = lineNumber + startOffset;
		int endLine = lineNumber + endOffset;
		if (startLine < 0) startLine = 0;
		if (endLine > sourceLines.Length) endLine = sourceLines.Length;

		// Format source code
		StringBuilder builder = new StringBuilder();
		for (int k = startLine; k < endLine; k++)
		{
			string sourceLine = HttpContext.Current.Server.HtmlEncode(sourceLines[k]);
			if (k + 1 == lineNumber)
				builder.AppendFormat("<span class='error'>{0}: {1}</span>\n", k + 1, sourceLine);
			else
				builder.AppendFormat("{0}: {1}\n", k + 1, sourceLine);
		}

		return builder.ToString();
	}

	/// <summary>
	/// Returns the error stack
	/// </summary>
    private string GetStack() {
        StringBuilder sb = new StringBuilder();
        
        if (_lastError.InnerException != null) {
            sb.AppendLine(_lastError.InnerException.StackTrace.Replace("\n", "<BR>"));
            sb.AppendLine("<BR><BR>");
        }

        if (_ccError != null) {
            int i = 0;
            //foreach (CompilerError cerr in _ccExp.Results.Errors) {
            //	sb.AppendFormat("{0}: {1}<br />", i + 1, cerr.ToString());
            //	i++;
            //}
            foreach (string cerr in _ccExp.Results.Output) {
                if (i > 2) sb.AppendFormat("{0}<br />", cerr);
                i++;
            }
        }
        if (_frame != null) {
            //StackTrace stack = new StackTrace(_lastError.GetBaseException(), true);
            //for (int i = 0; i < stack.FrameCount; i++) {
            //    sb.AppendFormat("{0}: {1}<br />", i + 1, stack.GetFrame(i).ToString());
            //}

            sb.AppendLine(_lastError.StackTrace.Replace("\n","<BR>"));
        }

        return sb.ToString();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>Compilation Error</title>
<style type="text/css">
html
{
    font-family:Verdana, Arial;
}
legend
{
	color:#800;
    font-family:Verdana, Arial;
    font-size: 10pt;
}
.errType
{
    font-family:Verdana, Arial;
    font-size:20pt;
    font-weight: bold;
}
.errorMessage
{
    font-style:italic;
    font-size:16px;
    font-weight: bold;
}
.source
{
    white-space:pre;
    font:12px Lucida Console;
    line-height:150%;
    background-color:#e9e9e9;
    padding:0px 10px;
}
.error
{
	color:#f00;
    background-color:#bfccbf;
    font: 12px Lucida Console;
    padding:4px 0px;
}
.extmsg
{
    font: 10pt Verdana, Arial;
}
.motivation
{
    padding:5px;
}
.file 
{
	color:blue;
}
</style>
</head>
<body>
<form id="form1" runat="server">
<div>
<asp:Label id="lblType" CssClass="errType" runat="server" />
<hr />
<fieldset><legend>錯誤描述</legend>
<asp:Label id="lblMessage" CssClass="errorMessage" runat="server" />
</fieldset><br />
<fieldset><legend>錯誤位置</legend>
<asp:Label id="lblFile" CssClass="file" runat="server" />
</fieldset><br />
<fieldset><legend>錯誤內容</legend>
<div class="source">
<asp:Literal id="ltlSource" runat="server" />
</div>
</fieldset><br />
<fieldset><legend>自訂訊息</legend>
<asp:Label id="lblExtMsg" CssClass="extmsg" runat="server" />
</fieldset><br />
<fieldset><legend>錯誤堆疊</legend>
<div class="extmsg">
<asp:Literal id="ltlStack" runat="server" />
</div>
</fieldset><br />
</div>
</form>
</body>
</html>
