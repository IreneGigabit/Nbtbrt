﻿<%@ Page Language="C#" %>
<%@ Import Namespace = "System.Collections.Generic"%>
<%@ Import Namespace = "System.IO"%>
<%@ Import Namespace = "DocumentFormat.OpenXml"%>
<%@ Import Namespace = "DocumentFormat.OpenXml.Packaging"%>
<%@ Import Namespace = "DocumentFormat.OpenXml.Wordprocessing"%>

<script runat="server">
    private void Page_Load(System.Object sender, System.EventArgs e) {
        List<Byte[]> srcList = new List<byte[]>();
        //srcList.Add(File.ReadAllBytes(@"\\web02\nt\doc\_\720\72054\NT-72054--0002-1.docx"));
        //srcList.Add(File.ReadAllBytes(@"\\web02\nt\doc\_\720\72050\NT-72050--24223-1.docx"));
        //srcList.Add(File.ReadAllBytes(@"\\web02\nt\doc\_\720\72054\S190003.docx"));
        srcList.Add(File.ReadAllBytes(@"\\web02\nt\doc\_\720\72054\S190004.xml"));
        srcList.Add(File.ReadAllBytes(@"\\web02\nt\doc\_\720\72054\S190005.xml"));

        //2選1
        //MergeFile(source, @"\\web02\nt\doc\merge.docx");//存到server實體目錄
        MergeFile(srcList, @"merge.docx");//直接輸出不存檔
    }

    /// <summary>
    /// 合併檔案後存至指定路徑
    /// </summary>
    /// <param name="sourceFile">要合併的檔案清單(以第一個檔為母檔)</param>
    /// <param name="outputFile">合併後的輸出檔案</param>
    public static void MergeFile(List<Byte[]> sourceFile, string outputFile) {
        byte[] byteArray = sourceFile[0];
        using (MemoryStream stream = new MemoryStream()) {
            stream.Write(byteArray, 0, (int)byteArray.Length);
            using (WordprocessingDocument myDoc = WordprocessingDocument.Open(stream, true)) {
                MainDocumentPart mainPart = myDoc.MainDocumentPart;
                if (sourceFile.Count > 1) {
                    for (var i = 1; i < sourceFile.Count; i++) {
                        mainPart.Document.Body.Append(new Break() { Type = BreakValues.Page });//換頁

                        AlternativeFormatImportPart chunk = mainPart.AddAlternativeFormatImportPart(AlternativeFormatImportPartType.WordprocessingML);
                        string altChunkId = mainPart.GetIdOfPart(chunk);

                        //AlternativeFormatImportPart chunk = mainPart.AddAlternativeFormatImportPart(AlternativeFormatImportPartType.WordprocessingML, altChunkId);

                        chunk.FeedData(new MemoryStream(sourceFile[i]));
                        AltChunk altChunk = new AltChunk();
                        altChunk.Id = altChunkId;

                        mainPart.Document.Body.AppendChild(altChunk);
                    }
                }

                mainPart.Document.Save();
            }

            //有\符號表示為實體路徑
            if (outputFile.IndexOf(@"\") > -1) {
                //存檔
                File.WriteAllBytes(outputFile, stream.ToArray());
            }
            else {
                //直接輸出,不存檔
                HttpContext.Current.Response.Clear();
                HttpContext.Current.Response.HeaderEncoding = System.Text.Encoding.GetEncoding("big5");
                HttpContext.Current.Response.AddHeader("Content-Disposition", "attachment; filename=\"" + outputFile + "\"");
                HttpContext.Current.Response.ContentType = "application/octet-stream";
                HttpContext.Current.Response.AddHeader("Content-Length", stream.Length.ToString());
                HttpContext.Current.Response.BinaryWrite(stream.ToArray());
            }
        }
    }
</script>
