using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Net;
using System.IO;
using System.Xml;

namespace API_test
{
    class prnsAPI
    {
        private enum compareType
        {
            lessThan, lessEqual, equal, greaterEqual, greaterThan 
        }


        public prnsAPI()
        {
            //runTests();
        }
  
        public static int runTests(string url, string databasename )
        {
            //string url = "http://profilestest/ProfilesSearchAPI/ProfilesSearchAPI.svc/Search";
            //string databaseServer = "(local)";
            //string databaseName = "ProfilesRNS_Test3_debug";
            //string databaseUsername = "App_Profiles10";
            //string databasePassword = "Password1234";
            string sqlConnectionString = "Data Source=(local);Initial Catalog=" + databasename + ";User ID=App_Profiles10;Password=Password1234";

            try
            {
                int totalPeople = getTotalPeople(sqlConnectionString);
                if (totalPeople < 0) { Log.logLn("Error getting the number of people from the database"); return 1; }
                if (!allPeople(url, totalPeople)) { Log.logLn("ERROR Wrong number of people returned for all people test"); return 1; }
                if (!keywordAdultPeople(url, totalPeople)) { Log.logLn("ERROR Wrong number of people returned for keywordAdultPeople test"); return 1; }
                Log.logLn("All PRNS API tests passed");
            }
            catch(Exception e)
            {
                Log.logLn(e.Message);
                return 1;
            }

            return 0;
        }

        public static int getTotalPeople(string sqlConnectionString)
        {
            SqlConnection dbconnection = new SqlConnection(sqlConnectionString);
            SqlCommand dbcommand = new SqlCommand("select count (*) as [count] from [Profile.Import].Person");

            SqlDataReader dbreader;
            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;
            dbcommand.CommandTimeout = Config.commandTimeOut;
            //dbcommand.Parameters.Add(new SqlParameter("@userid", sm.Session().UserID));
            dbcommand.Connection = dbconnection;
            dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);

            while (dbreader.Read())
            {
                if (dbreader["count"] != null)
                {
                    return Convert.ToInt32(dbreader["count"].ToString());
                }
            }
            return -1;
        }


        private static bool allPeople(string url, int totalPeople)
        {
            string postData = "<SearchOptions><MatchOptions><ClassURI>http://xmlns.com/foaf/0.1/Person</ClassURI></MatchOptions><OutputOptions><Offset>0</Offset><Limit>15</Limit><SortByList><SortBy IsDesc=\"0\" Property=\"http://xmlns.com/foaf/0.1/lastName\" /><SortBy IsDesc=\"0\" Property=\"http://xmlns.com/foaf/0.1/firstName\" /></SortByList></OutputOptions></SearchOptions>";
            return searchPeople(url, postData, totalPeople, compareType.equal);
        }

        private static bool keywordAdultPeople(string url, int totalPeople)
        {
            string postData = "<SearchOptions><MatchOptions><SearchString>Adult</SearchString></MatchOptions><OutputOptions><Offset>0</Offset><Limit>15</Limit></OutputOptions></SearchOptions>";
            int threshold = totalPeople / 2;
            return searchPeople(url, postData, threshold, compareType.greaterThan);
        }


        private static bool searchPeople(string url, string postData, int personThreshold, compareType type)
        {
            String result = PostForm(url, postData);
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(result);
            XmlNodeList matchesClassGroupsList = doc.GetElementsByTagName("prns:matchesClassGroup");
            for (int i = 0; i < matchesClassGroupsList.Count; i++)
            {
                string label = "";
                string number = "";
                for (int j = 0; j < matchesClassGroupsList[i].ChildNodes.Count; j++)
                {

                    switch (matchesClassGroupsList[i].ChildNodes[j].Name)
                    {
                        case "rdfs:label":
                            label = matchesClassGroupsList[i].ChildNodes[j].InnerText;
                            break;
                        case "prns:numberOfConnections":
                            number = matchesClassGroupsList[i].ChildNodes[j].InnerText;
                            break;
                    }

                    //String label = matchesClassGroupsList[i].ChildNodes[j]
                }
                if (label.Equals("People"))
                {
                    switch (type)
                    {
                        case compareType.lessThan:
                            return Convert.ToInt32(number) < personThreshold;
                        case compareType.lessEqual:
                            return Convert.ToInt32(number) <= personThreshold;
                        case compareType.equal:
                            return Convert.ToInt32(number) == personThreshold;
                        case compareType.greaterEqual:
                            return Convert.ToInt32(number) >= personThreshold;
                        case compareType.greaterThan:
                            return Convert.ToInt32(number) > personThreshold;
                    }
                }
            }
            return false;
        }

        public static string PostForm(String uri, String postData)
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(uri);
            request.Method = "POST";
            request.ContentType = "text/xml";

            byte[] bytes = Encoding.UTF8.GetBytes(postData);
            request.ContentLength = bytes.Length;

            Stream requestStream = request.GetRequestStream();
            requestStream.Write(bytes, 0, bytes.Length);

            WebResponse response = request.GetResponse();
            Stream stream = response.GetResponseStream();
            StreamReader reader = new StreamReader(stream);

            var result = reader.ReadToEnd();
            stream.Dispose();
            reader.Dispose();
            return result.ToString();
        }
    }
}
