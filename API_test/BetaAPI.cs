using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Xml;

namespace API_test
{
    class BetaAPI
    {
        private enum compareType
        {
            lessThan, lessEqual, equal, greaterEqual, greaterThan
        }

        public static int runTests(string url, string databasename)
        {
            //string url = "http://profilestest/ProfilesSearchAPI/ProfilesSearchAPI.svc/Search";
            //string databaseServer = "(local)";
            //string databaseName = "ProfilesRNS_Test3_debug";
            //string databaseUsername = "App_Profiles10";
            //string databasePassword = "Password1234";
            string sqlConnectionString = "Data Source=(local);Initial Catalog=" + databasename + ";User ID=App_Profiles10;Password=Password1234";

            try
            {
                int totalPeople = prnsAPI.getTotalPeople(sqlConnectionString);
                if (totalPeople < 0) { Log.logLn("Error getting the number of people from the database"); return 1; }
                if (!allPeople(url, totalPeople)) { Log.logLn("ERROR Wrong number of people returned for all people test"); return 1; }
                if (!keywordAdultPeople(url, totalPeople)) { Log.logLn("ERROR Wrong number of people returned for keywordAdultPeople test"); return 1; }
                Log.logLn("All Beta API tests passed");
            }
            catch (Exception e)
            {
                Log.logLn(e.Message);
                return 1;
            }

            return 0;
        }

        private static bool allPeople(string url, int totalPeople)
        {
            string postData = "<?xml version=\"1.0\" encoding=\"utf-8\"?><Profiles xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" Operation=\"GetPersonList\" Version=\"1\" xmlns=\"http://connects.profiles.schema/profiles/query\" xsi:schemaLocation=\"http://connects.profiles.schema/profiles/query ../7-8-2010/Request.xsd\"><QueryDefinition><Name><LastName MatchType=\"left\"/><FirstName/></Name><AffiliationList><Affiliation Primary=\"false\"/></AffiliationList><Keywords><KeywordString MatchType=\"and\"></KeywordString></Keywords></QueryDefinition><OutputOptions SortType=\"QueryRelevance\" StartRecord=\"1\" MaxRecords=\"15\"/></Profiles>";
            return searchPeople(url, postData, totalPeople, compareType.equal);
        }

        private static bool keywordAdultPeople(string url, int totalPeople)
        {
            string postData = "<?xml version=\"1.0\" encoding=\"utf-8\"?><Profiles xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" Operation=\"GetPersonList\" Version=\"1\" xmlns=\"http://connects.profiles.schema/profiles/query\" xsi:schemaLocation=\"http://connects.profiles.schema/profiles/query ../7-8-2010/Request.xsd\"><QueryDefinition><Name><LastName MatchType=\"left\"/><FirstName/></Name><AffiliationList><Affiliation Primary=\"false\"/></AffiliationList><Keywords><KeywordString MatchType=\"and\">\"Adult\"</KeywordString></Keywords></QueryDefinition><OutputOptions SortType=\"QueryRelevance\" StartRecord=\"1\" MaxRecords=\"15\"/></Profiles>";
            int threshold = totalPeople / 2;
            return searchPeople(url, postData, threshold, compareType.greaterThan);
        }


        private static bool searchPeople(string url, string postData, int personThreshold, compareType type)
        {
            String result = prnsAPI.PostForm(url, postData);
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(result);
            XmlNodeList personList = doc.GetElementsByTagName("PersonList");

            int totalCount = Convert.ToInt32(personList[0].Attributes["TotalCount"].Value);

            switch (type)
            {
                case compareType.lessThan:
                    return totalCount < personThreshold;
                case compareType.lessEqual:
                    return totalCount <= personThreshold;
                case compareType.equal:
                    return totalCount == personThreshold;
                case compareType.greaterEqual:
                    return totalCount >= personThreshold;
                case compareType.greaterThan:
                    return totalCount > personThreshold;
            }

            return false;
        }
    }
}
