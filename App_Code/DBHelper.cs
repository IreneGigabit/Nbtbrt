using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// 資料庫操作類別
/// </summary>
public class DBHelper : IDisposable
{
    private SqlConnection _conn = null;
    private SqlTransaction _tran = null;
    private SqlCommand _cmd = null;
    public string ConnString { get; set; }
    private bool _debug = false;
    private bool _isTran = true;
    public List<string> allSQL = null;
    public List<string> querySQL = null;
    public List<string> exeSQL = null;
    public DBHelper(string connectionString) : this(connectionString, true) { }

    public DBHelper(string connectionString, bool isTransaction) {
        //this._debug = showDebugStr;
        this.ConnString = connectionString;
        this._isTran = isTransaction;
        this.allSQL = new List<string>();
        this.querySQL = new List<string>();
        this.exeSQL = new List<string>();

        this._conn = new SqlConnection(this.ConnString);
        _conn.Open();

        if (this._isTran) {
            this._tran = _conn.BeginTransaction();
            this._cmd = new SqlCommand("", _conn, _tran);
        } else {
            this._cmd = new SqlCommand("", _conn);
        }
    }

    #region +DBHelper Debug(bool showDebugStr)
    public DBHelper Debug(bool showDebugStr) {
        this._debug = showDebugStr;
        return this;
    }
    #endregion

    #region +void Dispose()
    public void Dispose() {
        this._conn.Close(); this._conn.Dispose();
        this._cmd.Dispose();
        if (this._tran != null) this._tran.Dispose();

        GC.SuppressFinalize(this);
    }
    #endregion

    #region +void BeginTran()
    public void BeginTran() {
        if (this._tran.Connection == null) {
            this._tran = _conn.BeginTransaction();
            this._cmd = new SqlCommand("", _conn, _tran);
        }
    }
    #endregion

    #region +void Commit()
    public void Commit() {
        if (this._debug) {
            HttpContext.Current.Response.Write("Rollback...<HR>\n");
            if (this._tran != null) _tran.Rollback();
        } else {
            if (this._tran != null) _tran.Commit();
        }
    }
    #endregion

    #region +void RollBack()
    public void RollBack() {
        if (this._tran != null) _tran.Rollback();
    }
    #endregion

    #region +SqlDataReader ExecuteReader(string commandText) - 執行查詢，取得SqlDataReader
    /// <summary>
    /// 執行查詢，取得SqlDataReader；SqlDataReader使用後須Close，否則會Lock(強烈建議使用using)。
    /// </summary>
    public SqlDataReader ExecuteReader(string commandText) {
        try {
            //if (this._debug) {
            //    HttpContext.Current.Response.Write(commandText + "<HR>\n");
            //}
            this.allSQL.Add(commandText);
            this.querySQL.Add(commandText);
            this._cmd.CommandText = commandText;
            SqlDataReader dr = this._cmd.ExecuteReader();
            return dr;
        }
        catch (Exception ex) {
            throw new Exception(commandText, ex);
        }
    }
    #endregion

    #region +int ExecuteNonQuery(string commandText) - 執行T-SQL，並傳回受影響的資料筆數
    /// <summary>
    /// 執行T-SQL，並傳回受影響的資料筆數。
    /// </summary>
    public int ExecuteNonQuery(string commandText) {
        try {
            if (this._debug) {
                HttpContext.Current.Response.Write(commandText + "<HR>\n");
            }
            this.allSQL.Add(commandText);
            this.exeSQL.Add(commandText);
            this._cmd.CommandText = commandText;
            return this._cmd.ExecuteNonQuery();
        }
        catch (Exception ex) {
            throw new Exception(commandText, ex);
        }
    }
    #endregion

    #region +object ExecuteScalar(string commandText) - 執行查詢，取得第一行第一欄資料，會忽略其他的資料行或資料列
    /// <summary>
    /// 執行查詢，取得第一行第一欄資料，會忽略其他的資料行或資料列。
    /// </summary>
    public object ExecuteScalar(string commandText) {
        try {
            //if (this._debug) {
            //    HttpContext.Current.Response.Write(commandText + "<HR>\n");
            //}
            this.allSQL.Add(commandText);
            this.querySQL.Add(commandText);
            this._cmd.CommandText = commandText;
            return this._cmd.ExecuteScalar();
        }
        catch (Exception ex) {
            throw new Exception(commandText, ex);
        }
    }
    #endregion

    #region +void DataTable(string commandText, DataTable dt) - 執行查詢，並傳回DataTable 
    /// <summary>
    /// 執行查詢，並傳回DataTable。
    /// </summary>
    public void DataTable(string commandText, DataTable dt) {
        try {
            //if (this._debug) {
            //    HttpContext.Current.Response.Write(commandText + "<HR>\n");
            //}
            this.allSQL.Add(commandText);
            this.querySQL.Add(commandText);
            using (SqlDataAdapter adapter = new SqlDataAdapter(commandText, this._conn)) {
                if (this._isTran) {
                    adapter.SelectCommand.Transaction = this._tran;
                }
                adapter.Fill(dt);
            }
        }
        catch (Exception ex) {
            throw new Exception(commandText, ex);
        }
    }
    #endregion

    #region +void DataSet(string commandText, DataSet ds) - 執行查詢，並傳回DataSet
    /// <summary>
    /// 執行查詢，並傳回DataSet。
    /// </summary>
    public void DataSet(string commandText, DataSet ds) {
        try {
            //if (this._debug) {
            //    HttpContext.Current.Response.Write(commandText + "<HR>\n");
            //}
            this.allSQL.Add(commandText);
            this.querySQL.Add(commandText);
            using (SqlDataAdapter adapter = new SqlDataAdapter(commandText, this._conn)) {
                if (this._isTran) {
                    adapter.SelectCommand.Transaction = this._tran;
                }
                //DataSet ds = new DataSet();
                adapter.Fill(ds);
            }
        }
        catch (Exception ex) {
            throw new Exception(commandText, ex);
        }
    }
    #endregion

    #region +void Procedure(string commandText, Dictionary<string, string> param, DataTable dt) - 執行StoreProcedure，並傳回DataTable
    /// <summary>
    /// 執行StoreProcedure，並傳回DataTable。
    /// </summary>
    public void Procedure(string commandText, Dictionary<string, string> param, DataTable dt) {
        try {
            if (this._debug) {
                HttpContext.Current.Response.Write(commandText + "<HR>\n");
            }
            this.allSQL.Add(commandText);
            this.exeSQL.Add(commandText);

            using (SqlDataAdapter adapter = new SqlDataAdapter(this._cmd)) {
                this._cmd.CommandType = CommandType.StoredProcedure;
                this._cmd.CommandText = commandText;

                if (this._isTran) {
                    adapter.SelectCommand.Transaction = this._tran;
                }

                foreach (KeyValuePair<string, string> pair in param) {
                    this._cmd.Parameters.AddWithValue("@" + pair.Key, pair.Value);
                }
                adapter.Fill(dt);
            }
        }
        catch (Exception ex) {
            throw new Exception(commandText, ex);
        }
    }
    #endregion

    #region +void Procedure(string commandText, Dictionary<string, string> param) - 執行StoreProcedure，並傳回SqlDataReader
    /// <summary>
    /// 執行StoreProcedure，並傳回SqlDataReader。
    /// </summary>
    public SqlDataReader Procedure(string commandText, Dictionary<string, string> param) {
        try {
            if (this._debug) {
                HttpContext.Current.Response.Write(commandText + "<HR>\n");
            }
            this.allSQL.Add(commandText);
            this.exeSQL.Add(commandText);

            this._cmd.CommandType = CommandType.StoredProcedure;
            this._cmd.CommandText = commandText;
            foreach (KeyValuePair<string, string> pair in param) {
                this._cmd.Parameters.AddWithValue("@" + pair.Key, pair.Value);
            }

            SqlDataReader dr = this._cmd.ExecuteReader();
            return dr;
        }
        catch (Exception ex) {
            throw new Exception(commandText, ex);
        }
    }
    #endregion
}
