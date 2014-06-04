using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections.Specialized;
using System.Net;
using System.IO;
using System.Xml.Linq;
using System.Xml;
using System.Data.SqlClient;
using System.Data;

namespace API_test
{
    class Program
    {
        public static string uri = "http://profilestest/ProfilesSearchAPI/ProfilesSearchAPI.svc/Search";

        static int Main(string[] args)
        {
            if(args.Length < 1) { 
                Log.logLn("No Arguments supplied"); return(1); 
                /* // Use for debugging purposes
                string[] args2 = { "TESTSPARQL", "-u", "http://profilestest/ProfilesSPARQLAPI/ProfilesSPARQLAPI.svc/search", "-d", "ProfilesRNS_Test3" };
                Main(args2);
                return 0;
                 */
            }
            int returnVal = 0;
            string url = getArg(args, "-u");
            string database = getArg(args, "-d");
            switch (args[0])
            {
                case "GET":
                    downloadZipFromGitHub(args[1], args[2]);
                    break;
                case "TESTPRNS":
                    returnVal = prnsAPI.runTests(url, database);
                    break;
                case "TESTSPARQL":
                    returnVal = SPARQLAPI.runTests(url, database);
                    break;
                case "LINKS":
                    string baseURI = getArg(args, "-b");
                    makeLinksPage(baseURI, database);
                    break;
                default:
                    Log.logLn("Unknown Argument");
                    break;
            }
            return (returnVal);
        }

        static string getArg(string[] args, string arg)
        {
            for (int i = 1; i < args.Length - 1; i++)
            {
                if (arg.Equals(args[i])) return args[i + 1];
            }
            return null;
        }


        static void downloadZipFromGitHub(string path, string URL)
        {
            WebClient Client = new WebClient();
            Client.DownloadFile(URL, path);
        }

        static void makeLinksPage(string baseURI, string database)
        {
            string sqlConnectionString = "Data Source=(local);Initial Catalog=" + database + ";User ID=App_Profiles10;Password=Password1234";
            int commandTimeOut = 500;
            SqlConnection dbconnection = new SqlConnection(sqlConnectionString);
            SqlCommand dbcommand = new SqlCommand(
                //--People
                "select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person'" +
                //--People with concepts
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/Network/ResearchAreas' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/researchareas/categories' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/researchareas/timeline' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/researchareas/details' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/researchareas/cloud' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/Network/SimilarTo' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/similarto/map' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/similarto/details' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/similarto/list' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid from [Profile.Cache].[Concept.Mesh.Person])" +
                //--People with CoAuthors
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/Network/CoAuthors' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/map' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/radial' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/cluster' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/timeline' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/details' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) + '/network/coauthors/list' as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Person' and internalID in (select personid1 from [Profile.Cache].[SNA.Coauthor])" +
                //--Organizations (these should render, but are not very interesting)
                "union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) as url from [RDF.Stage].[InternalNodeMap] where class = 'http://xmlns.com/foaf/0.1/Organization'" +
                //--Concepts
                //"union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) as url from [RDF.Stage].[InternalNodeMap] where class = 'http://www.w3.org/2004/02/skos/core#Concept'" +
                //--Publications
                //"union select '" + baseURI + "/display/' + convert (nvarchar(50), NodeID) as url from [RDF.Stage].[InternalNodeMap] where class = 'http://vivoweb.org/ontology/core#InformationResource'" +
                //--Search
                "union select '" + baseURI + "/search/default.aspx?searchtype=people&lname=&searchfor=asthma&exactphrase=false&institution=&classuri=http://xmlns.com/foaf/0.1/Person&perpage=15&offset=0'  as url" +
                "union select '" + baseURI + "/search/default.aspx?searchtype=everything&searchfor=asthma&exactphrase=false' as url"
                );

            SqlDataReader dbreader;
            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;
            dbcommand.CommandTimeout = commandTimeOut;
            //dbcommand.Parameters.Add(new SqlParameter("@userid", sm.Session().UserID));
            dbcommand.Connection = dbconnection;
            dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);
            using (System.IO.StreamWriter file = new System.IO.StreamWriter(@"C:\inetpub\wwwroot\index.html"))
            {
                file.WriteLine("<!DOCTYPE html PUBLIC \"-//IETF//DTD HTML 2.0//EN\"><HTML><HEAD><TITLE>List of pages to test</TITLE></HEAD><BODY>");
                while (dbreader.Read())
                {
                    if (dbreader["url"] != null)
                    {
                        file.WriteLine("<a href=\"" + dbreader["url"] + "\">" + dbreader["url"] + "</a>");
                    }
                }
                file.WriteLine("</BODY></HTML>");
            }
        }

    }
}
