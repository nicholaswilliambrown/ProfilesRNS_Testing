using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Xml;

namespace API_test
{
    class SPARQLAPI
    {
        public static int runTests(string url, string databasename)
        {
            string sqlConnectionString = "Data Source=(local);Initial Catalog=" + databasename + ";User ID=App_Profiles10;Password=Password1234";

            try
            {
                if (!searchByLastName(sqlConnectionString, url)) { Log.logLn("ERROR in search by last name test"); return 1; }
                Log.logLn("All SPARQL API tests passed");
            }
            catch (Exception e)
            {
                Log.logLn("****** Exception caught during SPARQL tests ******");
                Log.logLn(e.Message);
                return 1;
            }

            return 0;
        }

        private static bool searchByLastName(string sqlConnectionString, string url)
        {
            SqlConnection dbconnection = new SqlConnection(sqlConnectionString);
            SqlCommand dbcommand = new SqlCommand("SELECT top 1 lastname, COUNT(*) count FROM [Profile.Data].[Person] GROUP BY lastname HAVING COUNT(*) > 0 ORDER BY COUNT(*) DESC");

            SqlDataReader dbreader;
            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;
            dbcommand.CommandTimeout = Config.commandTimeOut;
            dbcommand.Connection = dbconnection;
            dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);

            int count = -1;

            String lastname = null;

            while (dbreader.Read())
            {
                if (dbreader["count"] != null)
                {
                    count = Convert.ToInt32(dbreader["count"].ToString());
                }
                if (dbreader["lastname"] != null)
                {
                    lastname = dbreader["lastname"].ToString();
                }
            }

            string postData = "<query-request><query>" +
                                "PREFIX core: &lt;http://vivoweb.org/ontology/core#&gt; " +
                                "PREFIX foaf: &lt;http://xmlns.com/foaf/0.1/&gt; " +
                                "SELECT DISTINCT ?s " +
                                "WHERE { " +
                                    "?s foaf:lastName \"" + lastname + "\" . " +
                                    "?s ?p ?o " +
                                "}</query></query-request>";
            String result = prnsAPI.PostForm(url, postData);
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(result);

            XmlNodeList uriList = doc.GetElementsByTagName("uri");
            return count == uriList.Count;
        }
    }
}
